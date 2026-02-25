# Baseline Packet Capture (Smoke Test) 

The baseline packet capture step is useful to ensure that the capture workflow works correctly and generates a small data artifact that can be used as a foundation to understand how future capture will look. It is also important to practice with commands that properly filter the events to gather the proper information needed, which will be needed when scripting for automation. 

## Run TShark on Ubuntu

Terminal Command: 

    sudo tshark -i enp0s1 -a duration:30 -w /tmp/baseline_test.pcap

**It is important to know that running as root can be dangerous if unauthorized; in this lab environment, it is perfectly safe, as the state of the machine can be reset if anything breaks**

The command runs the network traffic monitoring software tshark, and it captures any packet data on the interface enp0s1 for 30 seconds. The packet capture data is then written to the file baseline_test.pcap in the tmp directory. The tmp directory is used since it does not require specific permissions to write to it, as writing in non-tmp directories can cause the following error:

    tshark: The file to which the capture would be saved <file-path> could not be opened: Permission denied.

If the command is run without issues, the output should be the following instead: 

        Capturing on 'enp0s1'


Tshark will actively capture on the network interface, and after 30 seconds, it will return the number of packets captured in that period. 



## SSH Connection (Kali --> UbuntU)

    ssh brandon@192.168.64.3

To ensure that something is actually captured, use the Kali machine to connect to the SSH server on the Ubuntu machine. While connected, run some random commands like

    whoami
    uname -m
        
This will help generate network traffic that can be analyzed

## Move TMP File to Accessible Directory

Terminal Command:

    sudo mv /tmp/baseline_test.pcap ~/Network_IDS_Project/data/suricata_logs

To make sure the PCAP will be accessible later, it is moved to an accessible directory where all other PCAPs will be stored

## Read PCAP Offline using Suricata

Terminal Command: 

    sudo suricata -r baseline_test.pcap -l ~/Network_IDS_Project/data/suricata_logs

I changed to the .../suricata_logs directory to make the command faster, since the PCAP is in the same directory. Using the full path for the -r option would have worked all the same. Once the file has been read, 4 outputs are then generated:


-'eve.json' (the event log useful for automation/parsing later)


-'fast.log' (human-readable alert log; likely will be empty until Suricata rules are configured)


-'stats.log' (performance stats)


-'suricata.log' (the runtime and configuration log for the software) 


## Quick Metric Filters

Terminal Command: 

    grep -c '"event_type":"alert"' eve.json

Filters the eve.json file and returns the number of alert lines; the resulting output was 0


Terminal Command:

    grep '"dest_port":22' eve.json | head

Prints the first 10 events that contain the destination port 22; for SSH-related events

Terminal Command:

    wc -l eve.json

Prints the total number of events in the file

    
