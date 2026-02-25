# Baseline Packet Capture (Smoke Test) 

## Run TShark on Ubuntu

Terminal Command: 

    sudo tshark -i enp0s1 -a duration:30 -w /tmp/baseline_test.pcap

Output: 


## SSH Connection (Kali --> UbuntU)

    ssh brandom@192.168.64.3


## Move TMP File to Accessible Directory

Terminal Command:

    sudo mv /tmp/baseline_test.pcap ~/Network_IDS_Project/data/suricata_logs


## Read PCAP Offline using Suricata

Terminal Command: 

    sudo suricata -r baseline_test.pcap -l ~/Network_IDS_Project/data/suricata_logs

I changed to the .../suricata_logs directory to make the command quicker to do, since the PCAP is in the same directory. Using the full path for the -r option would have worked all the same. 


## Quick Metrics Filter

    
