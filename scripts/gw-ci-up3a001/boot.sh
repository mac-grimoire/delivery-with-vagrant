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
nmcli c add type ovs-bridge conn.interface br-prod con-name br-prod
nmcli c add type ovs-port conn.interface br-prod master br-prod con-name br-prod-system
nmcli c add type ovs-interface slave-type ovs-port conn.interface br-prod master br-prod-system con-name br-prod-system-if0
nmcli c add type ovs-port conn.interface ${NET_DEV} master br-prod con-name br-prod-trunk
nmcli c add type ethernet conn.interface ${NET_DEV} master br-prod-trunk con-name br-prod-trunk-if0
nmcli c add type ovs-port conn.interface netinfra-tier3 master br-prod ovs-port.tag 1 con-name br-prod-vlan1
nmcli c add type ovs-port conn.interface core-tier2 master br-prod ovs-port.tag 109 con-name br-prod-vlan109
nmcli c add type ovs-port conn.interface core-tier3 master br-prod ovs-port.tag 110 con-name br-prod-vlan110
nmcli c add type ovs-port conn.interface tools-tier3 master br-prod ovs-port.tag 111 con-name br-prod-vlan111
nmcli c add type ovs-port conn.interface prod-fss-tier3 master br-prod ovs-port.tag 112 con-name br-prod-vlan112
nmcli c add type ovs-port conn.interface prod-sql-tier3 master br-prod ovs-port.tag 113 con-name br-prod-vlan113
nmcli c add type ovs-port conn.interface prod-lb-tier3 master br-prod ovs-port.tag 114 con-name br-prod-vlan114
nmcli c add type ovs-port conn.interface prod-www-tier3 master br-prod ovs-port.tag 115 con-name br-prod-vlan115
nmcli c add type ovs-port conn.interface prod-apps-tier3 master br-prod ovs-port.tag 116 con-name br-prod-vlan116
nmcli c add type ovs-port conn.interface prod-sql-tier2 master br-prod ovs-port.tag 117 con-name br-prod-vlan117
nmcli c add type ovs-port conn.interface prod-lb-tier2 master br-prod ovs-port.tag 118 con-name br-prod-vlan118
nmcli c add type ovs-port conn.interface prod-www-tier2 master br-prod ovs-port.tag 119 con-name br-prod-vlan119
nmcli c add type ovs-port conn.interface prod-apps-tier2 master br-prod ovs-port.tag 120 con-name br-prod-vlan120
nmcli c add type ovs-port conn.interface mgmt-tier3 master br-prod ovs-port.tag 4093 con-name br-prod-vlan4093
nmcli c add type ovs-port conn.interface mgmt-tier2 master br-prod ovs-port.tag 4094 con-name br-prod-vlan4094
nmcli c add type ovs-interface slave-type ovs-port conn.interface netinfra-tier3 master br-prod-vlan1 con-name br-prod-vlan1-if0 ipv4.method static ipv4.address 172.16.0.253/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface core-tier2 master br-prod-vlan109 con-name br-prod-vlan109-if0 ipv4.method static ipv4.address 192.168.149.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface core-tier3 master br-prod-vlan110 con-name br-prod-vlan110-if0 ipv4.method static ipv4.address 192.168.150.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface tools-tier3 master br-prod-vlan111 con-name br-prod-vlan111-if0 ipv4.method static ipv4.address 192.168.151.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-fss-tier3 master br-prod-vlan112 con-name br-prod-vlan112-if0 ipv4.method static ipv4.address 192.168.152.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-sql-tier3 master br-prod-vlan113 con-name br-prod-vlan113-if0 ipv4.method static ipv4.address 192.168.153.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-lb-tier3 master br-prod-vlan114 con-name br-prod-vlan114-if0 ipv4.method static ipv4.address 192.168.154.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-www-tier3 master br-prod-vlan115 con-name br-prod-vlan115-if0 ipv4.method static ipv4.address 192.168.155.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-apps-tier3 master br-prod-vlan116 con-name br-prod-vlan116-if0 ipv4.method static ipv4.address 192.168.156.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-sql-tier2 master br-prod-vlan117 con-name br-prod-vlan117-if0 ipv4.method static ipv4.address 192.168.157.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-lb-tier2 master br-prod-vlan118 con-name br-prod-vlan118-if0 ipv4.method static ipv4.address 192.168.158.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-www-tier2 master br-prod-vlan119 con-name br-prod-vlan119-if0 ipv4.method static ipv4.address 192.168.159.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface prod-apps-tier2 master br-prod-vlan120 con-name br-prod-vlan120-if0 ipv4.method static ipv4.address 192.168.160.254/24
nmcli c add type ovs-interface slave-type ovs-port conn.interface mgmt-tier3 master br-prod-vlan4093 con-name br-prod-vlan4093-if0 ipv4.method static ipv4.address 192.168.254.250/30
nmcli c add type ovs-interface slave-type ovs-port conn.interface mgmt-tier2 master br-prod-vlan4094 con-name br-prod-vlan4094-if0 ipv4.method static ipv4.address 192.168.254.254/30
sudo ovs-vsctl set bridge br-prod other-config:hwaddr=00:00:00:00:00:03
sudo ovs-vsctl set bridge br-prod protocols=OpenFlow13
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
sudo systemctl enable --now openflow.service 
sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 /g' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo dnf install -y lvm2
sudo dnf update -y
