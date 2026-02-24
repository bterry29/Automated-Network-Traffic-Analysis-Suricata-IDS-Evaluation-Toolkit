# Virtual Lab Connectivity Verification

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

      ip -br a (same as Ubuntu)

Output: 

        lo  UNKNOWN  127.0.0.1/8 ::1/128
        eth0  UP  10.0.2.15/24  fd17:625c:...


