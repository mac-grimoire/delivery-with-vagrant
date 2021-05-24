LINES=$(nmcli conn show | tail -n +2  | awk '{ print "sudo nmcli connection modify "$(NF-2)" connection.id \"System "$(NF)"\";" }')
eval ${LINES}
INTERNAL_DEV=$(lshw -C network | grep -A 6 "physical id: 3" | grep "logical name:" | cut -d: -f 2 | awk '{print $1}')
CONN_NAME=$(nmcli conn show | grep -v " ${INTERNAL_DEV}" | tail -n +2  | awk '{ print $(NF-2) }')
sudo nmcli conn delete ${CONN_NAME}
sleep 2
CONN_NAME=$(nmcli conn show | grep -v " ${INTERNAL_DEV}" | tail -n +2  | awk '{ print $(NF-2) }')
sudo nmcli conn delete ${CONN_NAME} 
sleep 2
NET_DEV=$(nmcli device | grep disconnected | awk '{ print $1}')
sudo nmcli con add type vlan con-name vlan-${NET_DEV}.${VLAN} ifname ${NET_DEV}.${VLAN} dev ${NET_DEV} id ${VLAN} ip4 ${IP}/${MASK}
CONN_NAME=$(nmcli conn show | grep "vlan-${NET_DEV}\.${VLAN}" | awk '{ print $(NF-2) }')
sudo nmcli con mod "${CONN_NAME}" +ipv4.routes "${ROUTES}"
sudo nmcli con mod "${CONN_NAME}" ipv4.ignore-auto-dns true
sudo nmcli con up "${CONN_NAME}"
sudo dnf install -y lvm2 vim-enhanced xorg-x11-xauth.x86_64 libglvnd-glx mesa-dri-drivers firefox
sudo dnf update -y
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" | sudo tee /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" | sudo tee -a /etc/hosts
echo "${IP}  jump-ci-up3a001.mgmt.carcano.local jump-ci-up3a001" | sudo tee -a /etc/hosts
echo "192.168.254.253  jump-ci-up2a001.mgmt.carcano.local jump-ci-up2a001" | sudo tee -a /etc/hosts

