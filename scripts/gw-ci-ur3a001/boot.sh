sudo dnf install -y centos-release-openstack-train
sudo dnf install -y openvswitch NetworkManager-ovs frr vim-enhanced wget net-tools jq git
sudo systemctl enable --now openvswitch
sudo service NetworkManager restart
CONN_RENAME=$(nmcli conn show | tail -n +2  | awk '{ print "sudo nmcli connection modify "$(NF-2)" connection.id \"System "$(NF)"\";" }')
eval ${CONN_RENAME}
INTERNAL_DEV=$(sudo lshw -C network | grep -A 6 "physical id: 3" | grep "logical name:" | cut -d: -f 2 | awk '{print $1}')
CONN_REMOVE=$(nmcli conn show | grep -v " ${INTERNAL_DEV}" | tail -n +2  | awk '{ print "sudo nmcli conn delete "$(NF-2)";" }')
eval $CONN_REMOVE
CONN_REMOVE=$(nmcli conn show | grep -v " ${INTERNAL_DEV}" | tail -n +2  | awk '{ print "sudo nmcli conn delete "$(NF-2)";" }')
eval $CONN_REMOVE
NET_DEV=$(nmcli device | grep disconnected | awk '{ print $1}')
nmcli c add type ovs-bridge conn.interface br-prep con-name br-prep
nmcli c add type ovs-port conn.interface br-prep master br-prep con-name br-prep-system
nmcli c add type ovs-interface slave-type ovs-port conn.interface br-prep master br-prep-system con-name br-prep-system-if0
nmcli c add type ovs-port conn.interface ${NET_DEV} master br-prep con-name br-prep-trunk
nmcli c add type ethernet conn.interface ${NET_DEV} master br-prep-trunk con-name br-prep-trunk-if0
nmcli c add type ovs-port conn.interface netinfra-tier3 master br-prep ovs-port.tag 1 con-name br-prep-vlan1
nmcli c add type ovs-port conn.interface core-tier3 master br-prep ovs-port.tag 110 con-name br-prep-vlan10
nmcli c add type ovs-port conn.interface tools-tier3 master br-prep ovs-port.tag 111 con-name br-prep-vlan11
nmcli c add type ovs-port conn.interface prep-fss-tier3 master br-prep ovs-port.tag 112 con-name br-prep-vlan12
nmcli c add type ovs-port conn.interface prep-sql-tier3 master br-prep ovs-port.tag 113 con-name br-prep-vlan13
nmcli c add type ovs-port conn.interface prep-lb-tier3 master br-prep ovs-port.tag 114 con-name br-prep-vlan14
nmcli c add type ovs-port conn.interface prep-www-tier3 master br-prep ovs-port.tag 115 con-name br-prep-vlan15
nmcli c add type ovs-port conn.interface prep-apps-tier3 master br-prep ovs-port.tag 116 con-name br-prep-vlan16
nmcli c add type ovs-port conn.interface prep-sql-tier2 master br-prep ovs-port.tag 117 con-name br-prep-vlan17
nmcli c add type ovs-port conn.interface prep-lb-tier2 master br-prep ovs-port.tag 118 con-name br-prep-vlan18
nmcli c add type ovs-port conn.interface prep-www-tier2 master br-prep ovs-port.tag 119 con-name br-prep-vlan19
nmcli c add type ovs-port conn.interface prep-apps-tier2 master br-prep ovs-port.tag 120 con-name br-prep-vlan20
nmcli c add type ovs-interface slave-type ovs-port conn.interface netinfra-tier3 master br-prep-vlan1 con-name br-prep-vlan1-if0 ipv4.method static ipv4.address 172.16.0.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface core-tier3 master br-prep-vlan10 con-name br-prep-vlan10-if0 ipv4.method static ipv4.address 192.168.50.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface tools-tier3 master br-prep-vlan11 con-name br-prep-vlan11-if0 ipv4.method static ipv4.address 192.168.51.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-fss-tier3 master br-prep-vlan12 con-name br-prep-vlan12-if0 ipv4.method static ipv4.address 192.168.52.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-sql-tier3 master br-prep-vlan13 con-name br-prep-vlan13-if0 ipv4.method static ipv4.address 192.168.53.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-lb-tier3 master br-prep-vlan14 con-name br-prep-vlan14-if0 ipv4.method static ipv4.address 192.168.54.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-www-tier3 master br-prep-vlan15 con-name br-prep-vlan15-if0 ipv4.method static ipv4.address 192.168.55.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-apps-tier3 master br-prep-vlan16 con-name br-prep-vlan16-if0 ipv4.method static ipv4.address 192.168.56.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-sql-tier2 master br-prep-vlan17 con-name br-prep-vlan17-if0 ipv4.method static ipv4.address 192.168.57.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-lb-tier2 master br-prep-vlan18 con-name br-prep-vlan18-if0 ipv4.method static ipv4.address 192.168.58.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-www-tier2 master br-prep-vlan19 con-name br-prep-vlan19-if0 ipv4.method static ipv4.address 192.168.59.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prep-apps-tier2 master br-prep-vlan20 con-name br-prep-vlan20-if0 ipv4.method static ipv4.address 192.168.60.254/24
sudo ovs-vsctl set bridge br-prep other-config:hwaddr=00:00:00:00:00:02
sudo ovs-vsctl set bridge br-prep protocols=OpenFlow13
sudo sed -i 's/^[ ]*ospfd[ ]*=.*/ospfd=yes/' /etc/frr/daemons
sudo sed -i 's/^[ ]*zebra[ ]*=.*/zebra=yes/' /etc/frr/daemons
sudo sed -i 's/^[ ]*zebra_options[ ]*=.*/zebra_options=("-A 127.0.0.1 -M fpm")/' /etc/frr/daemons
sudo mv /vagrant/zebra.conf /etc/frr/zebra.conf
HOSTNAME=$(hostname)
sudo sed -i "s/hostname .*/hostname $HOSTNAME/" /etc/frr/zebra.conf 
sudo mv /vagrant/ospfd.conf /etc/frr/ospfd.conf
sudo sed -i "s/hostname .*/hostname $HOSTNAME/" /etc/frr/ospfd.conf
sudo sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/frr.conf 
sudo systemctl enable --now frr
##sudo systemctl enable network
sudo mkdir -p /opt/grymoire/bin /opt/grymoire/etc
sudo mv /vagrant/of-flows.txt /opt/grymoire/etc
sudo mv /vagrant/of-flow-load.sh /opt/grymoire/bin
sudo chmod 755 /opt/grymoire/bin/of-flow-load.sh
sudo mv /vagrant/openflow.service /etc/systemd/system/openflow.service
sudo chown root: /etc/systemd/system/openflow.service
sudo chmod 644 /etc/systemd/system/openflow.service
sudo chown -R root: /opt/grymoire
sudo restorecon -R /opt/grymoire
sudo systemctl daemon-reload
systemctl enable --now openflow.service 
sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 /g' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo dnf install -y lvm2
sudo dnf update -y
