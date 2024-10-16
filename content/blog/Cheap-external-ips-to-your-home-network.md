---
title: "Cheap External Ips to Your Home Network"
date: 2024-10-16T14:33:57+02:00
draft: true
---

Intro
-----

For my homelab Kubernetes cluster i had an interesting problem: i already have 443/tcp bound to my main ipv4 address from my provider. I use it already in my homelab as a reverse proxy to some other services already
running on some other virtual machines. But i also run a Kubernetes cluster in my homelab that i mainly use for hosting experimental things. Also a lot of ingress stuff. So i wanted the host my own ingress on a external ip address. After some trial and error i found the perfect cheap solution: A Hetzner virtual machine with a floating ip and routing that IP through GRE to my OPNSense router. 

## Some preperations

First, i needed to set some things up. I created a virtual machine at Hetzner Cloud. Just a low spec virtual machine. After that machine was up and running i added a "Floating IP". That is basically a ip address that you can assign to one or more virtual machines. 

After the machine was created i logged in and turned on the `arp_proxy` and `forwarding` in `/etc/sysctl.conf`:

```bash
$ sudo cat /etc/sysctl.conf 

net.ipv4.ip_forward=1
net.ipv4.conf.all.proxy_arp=1
```

After that, i run the following command for it to persist:

```bash
$ sudo sysctl -p
```
After that, Proxy ARP and IP Forwarding was activated and i could continue with the next step: setting up GRE. 


## Setting up GRE - Hetzner side

For GRE to work you can add a new tunnel interface file to `/etc/network/interfaces.d`  directory. I created the file called `gre-tunnel.cfg`


```bash
$ sudo cat /etc/network/interfaces.d/gre-tunnel.cfg
auto tun0
iface tun0 inet static
  address 10.99.239.17
  netmask 255.255.255.252
  pre-up ip tunnel add tun0 mode gre remote 2.2.2.2 local 1.1.1.1 dev eth0
  up ip route add 123.123.123.123/32 dev tun0
  pre-down ip route del 123.123.123.123
  pre-down ip tunnel del tun0
```
Lets break this down bit by bit:

### the `address` part

The address is part of your GRE point to point network. I use a CIDR block `10.99.239.16/30` here. This basically gives you 2 usable ip address. perfect for a point-to-point network. Thet netmask is calculated from `/30`  and will be `255.255.255.252`

```bash
$ ipcalc 10.99.239.16/30
Address:   10.99.239.16         00001010.01100011.11101111.000100 00
Netmask:   255.255.255.252 = 30 11111111.11111111.11111111.111111 00
Wildcard:  0.0.0.3              00000000.00000000.00000000.000000 11
=>
Network:   10.99.239.16/30      00001010.01100011.11101111.000100 00
HostMin:   10.99.239.17         00001010.01100011.11101111.000100 01
HostMax:   10.99.239.18         00001010.01100011.11101111.000100 10
Broadcast: 10.99.239.19         00001010.01100011.11101111.000100 11
Hosts/Net: 2                     Class A, Private Internet
```

So i use the first ip address in that range as my point-to-point on the Hetzner side.

### the `pre-up` part

In the `pre-up`  part i specify that i want the tunnel to be created before the interface is being configured with this command:
```
ip tunnel add tun0 mode gre remote 2.2.2.2 local 1.1.1.1 dev eth0
```

the `remote 2.2.2.2` part is the other side you want to connect, in this example this would be my home address. the `local 1.1.1.1` part would be my local IP address from my Hetzner VM. This is the host IP itself, not the Floating IP Address.

### the `up` part

In the `up` part i add a static route to my tunnel address. 
```
up ip route add 123.123.123.123/32 dev tun0
```

The IP `123.123.123.123/32`  is the floating IP address that i assigned to my virtual machine in the hetzner console. I basically add a static route so the ip address will be routed to that interface

### the `pre-down` part
In the `pre-down`  part i specify that i want to delete the route and remove the tunnel before the interface itself is taken down

## Setting up GRE - OPNSense at home side

The OPNSense part was more tricky to fix. I had to fiddle out some specific settings. I will describe them the best i can.

### GRE - Interface set-up - OPNSense

