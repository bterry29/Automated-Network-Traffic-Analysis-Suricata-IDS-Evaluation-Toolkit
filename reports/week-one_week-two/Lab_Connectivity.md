# Virtual Lab Connectivity Verification

The first step of this project is to ensure both virtual machines (Ubuntu and Kali Linux) have access to the network. This is because, in order for the two to communicate, there has to be a known network and IP address. After confirming this, the two machines need to be able to connect using these addresses and through a Secure Shell (SSH) server. Once the basic setup of the lab is complete, the simulations between the two can be made. The following are the commands and tests done to ensure this connection exists for the lab environment. 

## Ubuntu (UTM) IP Info

Terminal Command: 

     ip -br a
(Shows the machine IP information in brief) 

Output: 

        lo  UNKNOWN   127.0.0.1/8 ::1/128

        enp0s1  UP  192.168.64.3/24
*The enp0s1 is the network and IP that will be used for the lab*


## SSH Service Check

Terminal Command: 

       sudo systemctl status ssh

Output(first 3 lines):

         ssh.service - OpenBSD Secure Shell Server 
             Loaded: loaded (/usr/lib/systemd/system/ssh.service; enabled; preset; enabled)
             Active: active (running) since Tue 2026-02-24 13:42:02 EST; 11 min ago


## Kali (VirtualBox) IP Info

Terminal Command: 

      ip -br a 

Output: 

        lo  UNKNOWN  127.0.0.1/8 ::1/128
        eth0  UP  10.0.2.15/24  fd17:625c:...


## Connectivity Test (Kali --> Ubuntu)

Terminal Command:

          ping -c 4 192.168.64.3

*Stops after 4 connection attempts*

Output:

          --- 192.168.64.3 ping statistics ---
          4 packets transmitted, 4 received, 0% packet loss, time 3034ms

Since the output shows that all 4 packets were received from the ping, it is conclusive that Kali can connect and interact with the Ubuntu machine.


## SSH Connection Test (Kali --> Ubuntu)

Terminal Command:

          ssh brandon@192.168.64.3

*For the Ubuntu machine, the username is "brandon." Once the connection is made possible, input the password for the Ubuntu machine to gain access on Kali machine*

Output (first line):

          Welcome to Ubuntu 25.04 (GNU/Linux 6.14.0-37-generic aarch64)
          .
          .
          .
          Last Login: ... 

Verify the connection by running:

          whoami

*The username should be the same as the Ubuntu username. For this project, both machines have the same username*

and then exited the connection with: 

          exit

          

