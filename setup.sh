sudo ip tuntap del tun0 mode tun
sudo ip tuntap add name tun0 mode tun user $USER
sudo ip link set tun0 up
sudo ip addr add 192.0.2.1 peer 192.0.2.2 dev tun0

sudo ip tuntap del tun1 mode tun
sudo ip tuntap add name tun1 mode tun user $USER
sudo ip link set tun1 up
sudo ip addr add 192.0.3.1 peer 192.0.3.2 dev tun1

sudo iptables -t nat -A POSTROUTING -s 192.0.2.2 -j MASQUERADE
sudo iptables -A FORWARD -i tun0 -s 192.0.2.2 -j ACCEPT
sudo iptables -A FORWARD -o tun0 -d 192.0.2.2 -j ACCEPT

sudo iptables -t nat -A POSTROUTING -s 192.0.3.2 -j MASQUERADE
sudo iptables -A FORWARD -i tun1 -s 192.0.3.2 -j ACCEPT
sudo iptables -A FORWARD -o tun1 -d 192.0.3.2 -j ACCEPT

sudo iptables -A FORWARD -i tun0 -o tun1 -j ACCEPT
sudo iptables -A FORWARD -i tun0 -o tun1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -i tun1 -j ACCEPT



# sudo route add default gw 192.0.2.2 tun1





##
sudo sysctl -w net.ipv4.ip_forward=1

## CREATE TUN 0
sudo ip tuntap del tun0 mode tun
sudo ip tuntap add name tun0 mode tun user $USER
sudo ip link set tun0 up
sudo ip addr add 192.0.2.1 peer 192.0.2.2 dev tun0

## CREATE TUN 1
sudo ip tuntap del tun1 mode tun
sudo ip tuntap add name tun1 mode tun user $USER
sudo ip link set tun1 up
sudo ip addr add 192.0.3.1 peer 192.0.3.2 dev tun1

## Allow forwarding from tun0 to tun1 & Allow forwarding from tun1 to tun0
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
sudo iptables -A FORWARD -i tun0 -o tun1 -j ACCEPT
sudo iptables -A FORWARD -i tun1 -o tun0 -j ACCEPT
## Allow incoming packets on tun1 that are related or established
sudo iptables -A INPUT -i tun1 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo ip route add 192.0.3.1 dev tun1 table 7433
sudo ip route add 192.0.2.1 dev tun0 table 7433

sudo ip rule add from 192.0.2.1 table 7433
sudo ip rule add to 192.0.3.1 table 7433

sudo ip route show table 7433

# ip route add default via 192.0.3.2 dev tun1 table vpn
# ip rule add from all lookup vpn priority 10000


sudo ip route flush cache
##















## CREATE TUN 0
sudo ip tuntap del tun0 mode tun
sudo ip tuntap add name tun0 mode tun user $USER
sudo ip link set tun0 up
sudo ip addr add 192.0.2.1 peer 192.0.2.2 dev tun0

## CREATE TUN 1
sudo ip tuntap del tun1 mode tun
sudo ip tuntap add name tun1 mode tun user $USER
sudo ip link set tun1 up
sudo ip addr add 192.0.3.1 peer 192.0.3.2 dev tun1

sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl net.ipv4.conf.tun0.accept_local=1
sudo sysctl net.ipv4.conf.tun1.accept_local=1
sudo sysctl -p
# sudo iptables -t nat -A POSTROUTING -o tun1 -j MASQUERADE

sudo iptables -A FORWARD -i tun0 -o tun1 -s 192.0.2.0/28 -j ACCEPT
sudo iptables -A FORWARD -i tun1 -o tun0 -j ACCEPT

sudo iptables -A INPUT -i tun1 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo ip route add 192.0.3.0/28 dev tun1 table vpn
sudo ip route add 192.0.2.0/28 dev tun0 table vpn

sudo ip rule add from 192.0.2.0/28 table vpn

sudo ip route show table vpn

sudo ip route flush cache

# echo 1 > /proc/sys/net/ipv4/conf/tun0/accept_local





## final

## CREATE TUN 0
sudo ip tuntap del tun0 mode tun
sudo ip tuntap add name tun0 mode tun user $USER
sudo ip link set tun0 up
sudo ip addr add 192.0.2.1/24 dev tun0

## CREATE TUN 1
sudo ip tuntap del tun1 mode tun
sudo ip tuntap add name tun1 mode tun user $USER
sudo ip link set tun1 up
sudo ip addr add 192.0.3.1/24 dev tun1

sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl net.ipv4.conf.tun0.accept_local=1
sudo sysctl net.ipv4.conf.tun1.accept_local=1
sudo sysctl -p

sudo iptables -A FORWARD -i tun0 -o tun1 -j ACCEPT
sudo iptables -A FORWARD -i tun1 -o tun0 -j ACCEPT
sudo iptables -A INPUT -i tun1 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo ip route flush cache

sudo tcpdump -n -vvvv  -e -i tun1



