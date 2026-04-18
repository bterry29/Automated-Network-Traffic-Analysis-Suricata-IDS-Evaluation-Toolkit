# Automated-Network-Traffic-Analysis-Suricata-IDS-Evaluation-Toolkit


## Project Goal

The goal of this project is to make network traffic detection and analysis faster, more repeatable, and consistent through scripting and automation. We aim to achieve this by developing a small toolkit that will automate traffic capture, label attack windows, run IDS evaluations, and generate a structured summary of it all. By reducing manual work and enforcing consistent procedures, the toolkit will shorten alert triage and help users build intuition for recognizing attack patterns that produce valid evidence to highlight and document. 


## Setup Instructions

### 1) Lab Environment (VM Setup)
- Create a Ubuntu VM (UTM) (Link to installation: https://ubuntu.com/download/desktop)
- Install Suricata on the Ubuntu machine (Command: sudo apt install -y suricata)
- Install packet capture software: Wireshark, tcpdump, dumpcap (Command: sudo apt install -y wireshark tcpdump tshark)   
- Download and install the VirtualBox platform (https://www.virtualbox.org/wiki/Downloads)
- Download Kali Linux VirtualBox pre-built image (https://www.kali.org/get-kali/#kali-platforms)

### 2) Enable SSH Service (Scenario logging)
On Ubuntu Machine: 

      sudo apt install -y openssh-server
      sudo systemctl enable --now ssh
      systemctl is-active ssh
  
*Should see "active"*

### 3) Test User Implementation for Controlled Attack Setup
On Ubuntu Machine:

    sudo adduser testuser1

### 4) Verify Connection (Kali -> Ubuntu)
On Kali: 

    ping -c 4 <UBUNTU_IP>
    ssh testuser1@<UBUNTU_IP>

## Technology Used

**Packet Capture**: Wireshark, TShark

**Intrusion Detection System**: Suricata (offline PCAP evaluation) 

**Attack Simulation**: ssh, sshpass (failed-password simulation) 

**Scripting**: Bash (automation + summaries), Python (parsing) 

## Method To Run

### Where to run actions
- **Ubuntu**: runs packet capture, Suricata offline evaluation, summary generation, and orchestrator scripts
- **Kali**: runs SSH brute-force simulation scripts against Ubuntu

**ALL COMMANDS FOR THE SECTION BELOW ASSUME YOU ARE IN THE PROJECT FOLDER OR ROOT**

### 1) Baseline Run (Ubuntu)
Produces a full run folder: PCAP, Suricata logs, summary, and metadata:

    ./scripts/run_baseline.sh 15

**Outputs** (created under runs/)

      runs/baseline_<timestamp>/pcap/baseline.pcap
      runs/baseline_<timestamp>/suricata/ (eve.json, fast.log, stats.log, suricata.log)
      runs/baseline_<timestamp>/summary.md
      runs/baseline_<timestamp>/metadata.json

### 2) SSH Brute-force Run (Manual Trigger from Kali)
**Step 1**: Run orchestrator script on Ubuntu (example 30 seconds):

    ./scripts/run_ssh_bruteforce_manual.sh <interface> 30
    
The script will begin capturing, then pause to provide instructions. While the capture is running, perform the next step on Kali.

**Step 2**: Run one of two attack scripts on Kali:

**OPTION 1** (Connection-Attempt Simulation)

    ./scripts/ssh_bruteforce_sim.sh <UBUNTU_IP> testuser1 20 0.2

**OPTION 2** (Failed-Password Simulation) 

    ./scripts/ssh_failed_password_sim.sh <UBUNTU_IP> testuser1 20 0.2

After the Kali script finishes, return to Ubuntu and press ENTER when prompted. Ubuntu will then run Suricata offline and automatically generate the summary and metadata.


**Outputs** (created under runs/)

      runs/ssh_bruteforce_<timestamp>/pcap/ssh_bruteforce.pcap
      runs/ssh_bruteforce_<timestamp>/suricata/ (eve.json, fast.log, stats.log, suricata.log)
      runs/ssh_bruteforce_<timestamp>/summary.md
      runs/ssh_bruteforce_<timestamp>/metadata.json


### View Results
After any run, the two most useful files to inspect are:

Summary report:
    
    runs/<run_id>/summary.md

Human-readable alerts:

    runs/<run_id>/suricata/fast.log


