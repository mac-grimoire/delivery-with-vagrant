LINES=$(nmcli conn show | tail -n +2  | awk '{ print "sudo nmcli connection modify "$(NF-2)" connection.id \"System "$(NF)"\";" }')
eval ${LINES}
PRIVATE_DEV=$(lshw -C network | grep -A 6 -- "-virtio" | grep "logical name:" | cut -d: -f 2 | awk '{print $1}')
CONN_NAME=$(nmcli conn show | grep " ${PRIVATE_DEV}" | awk '{ print $(NF-2) }')
sudo nmcli conn delete ${CONN_NAME}
sleep 2
CONN_NAME=$(nmcli conn show | grep " ${PRIVATE_DEV}" | awk '{ print $(NF-2) }')
sudo nmcli conn delete ${CONN_NAME}
sleep 2
NET_DEV=$(nmcli device | grep disconnected | awk '{ print $1}')
sudo nmcli con add type vlan con-name vlan-${NET_DEV}.${VLAN} ifname ${NET_DEV}.${VLAN} dev ${NET_DEV} id ${VLAN} ip4 ${IP}/${MASK}
CONN_NAME=$(nmcli conn show | grep "vlan-${NET_DEV}\.${VLAN}" | awk '{ print $(NF-2) }')
sudo nmcli con mod "${CONN_NAME}" +ipv4.routes "${ROUTES}"
sudo nmcli con mod "${CONN_NAME}" ipv4.ignore-auto-dns true
sudo nmcli con up "${CONN_NAME}"
sudo dnf install -y lvm2 vim-enhanced
sudo parted -a optimal /dev/sdb mklabel gpt
SDB_DISK_SIZE=$(sudo parted /dev/sdb unit s print free |grep -v "^$" |tail -n 1|awk '{ print $2 }')
sudo parted -a optimal /dev/sdb mkpart primary 2048s ${SDB_DISK_SIZE=}
sudo parted /dev/sdb  set 1 lvm on
sudo pvcreate /dev/sdb1
sudo vgcreate data /dev/sdb1
sudo lvcreate -L 2GiB -n pgsql_data data
sudo mkfs.xfs -L pgsql_data /dev/mapper/data-pgsql_data
sudo mkdir -m 755 -p xfs /var/lib/pgsql
echo "LABEL=pgsql_data   /var/lib/pgsql  xfs     defaults        0 0" | sudo tee -a /etc/fstab
sudo mount /var/lib/pgsql
sudo dnf update -y
sudo shutdown -r now
