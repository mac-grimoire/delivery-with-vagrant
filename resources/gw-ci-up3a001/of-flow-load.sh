#!/bin/bash
BRIDGE="${1}"
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname ${SCRIPT})
CFG_FILE="${SCRIPTPATH}/../etc/of-flows.txt"
cd ${SCRIPTPATH}/../etc
if [[ ! -d .git ]]; then
  echo "Initializing the Openflow configuration repository"
  [ -f /tmp/openflow.lastcommitted ] && rm /tmp/openflow.lastcommitted
  git init
  git config user.name "System"
  git config user.email "me@foo.org"
  echo "foo.sh" > .gitignore 
  git add .gitignore
fi
git add ${CFG_FILE}
git commit -m "fix"
CURRENT=$(git log -1 --pretty=format:"%h")
if [[ ! -f /tmp/openflow.lastcommitted ]]; then
  echo "Performing a full load ..."
  ovs-ofctl del-flows --protocols=OpenFlow10,OpenFlow13 ${BRIDGE}
  while IFS= read -r line
  do
    [[ "$line" =~ ^#.*$ ]] && continue
    COMMAND=$(echo $line | sed "s/^\"/ovs-ofctl add-flow ${BRIDGE} --protocols=OpenFlow10,OpenFlow13 \"/g")
    [ -n "${COMMAND}" ] && echo "Executing '${COMMAND}'"
    eval ${COMMAND}
  done < ${CFG_FILE}
else
  PREVIOUS=$(cat /tmp/openflow.lastcommitted)
  #echo PREVIOUIS=$PREVIOUS
  #=$(git log -2 --pretty=format:"%h"|tail -n 1)
  if [[ "${CURRENT}" == "$PREVIOUS" ]]; then
     echo "We are alread at $PREVIOUS, so there's nothing to do, ... exiting"
     exit 0
  fi
  ADD=$(git diff $PREVIOUS..$CURRENT |grep -- '+"')
  REMOVE=$(git diff $PREVIOUS..$CURRENT |grep -- '-"')
  #echo CURRENT=$CURRENT
  #echo PREVIOUS=$PREVIOUS
  while IFS= read -r line
  do
      COMMAND=$(echo $line| sed "s+^-\"\(cookie=0x[0-9]*\).*+ovs-ofctl del-flows ${BRIDGE} --protocols=OpenFlow10,OpenFlow13 \"\1/-1\"+")
      [ -n "${COMMAND}" ] && echo "Executing '${COMMAND}'"
      eval ${COMMAND}
  done <<< "$REMOVE"
  
  while IFS= read -r line
  do
    #echo $line
    COMMAND=$(echo $line | sed "s/^+\"/ovs-ofctl add-flow ${BRIDGE} --protocols=OpenFlow10,OpenFlow13 \"/g")
     [ -n "${COMMAND}" ] && echo "Executing '${COMMAND}'"
    eval ${COMMAND}
  done <<< "$ADD"
fi
echo ${CURRENT} > /tmp/openflow.lastcommitted
