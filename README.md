# Automated-Network-Traffic-Analysis-Suricata-IDS-Evaluation-Toolkit


## Project Goal

The goal of this project is to make network traffic detection and analysis faster, more repeatable, and consistent through scripting and automation. We aim to achieve this by developing a small toolkit that will automate traffic capture, label attack windows, run IDS evaluations, and generate a structured summary of it all. By reducing manual work and enforcing consistent procedures, the toolkit will shorten alert triage and help users build intuition for recognizing attack patterns that produce valid evidence to highlight and document. 


## Setup Instructions

### 1) Lab Environment (VM Setup)
- Install Ubuntu Linux onto Local Machine (Link to installation: https://ubuntu.com/download/desktop)
- Install Suricata on the Ubuntu machine (Command: sudo apt install -y suricata)
- Install packet capture software: Wireshark, tcpdump, dumpcap (Command: sudo apt install -y wireshark, tcpdump, tshark)   
- Download and install the VirtualBox platform (https://www.virtualbox.org/wiki/Downloads)
- Download Kali Linux VirtualBox pre-built image (https://www.kali.org/get-kali/#kali-platforms)

### 2) Enable SSH Service (Scenario logging)
On Ubuntu Machine: 
- sudo apt install -y openssh-server
- sudo systemctl enable --now ssh
- systemctl is-active ssh
  
*Should see "active"*

### 3) Test User Implementation for Controlled Attack Setup
On Ubuntu Machine:
- sudo adduser testuser1

### 4) Verify Connection (Kali -> Ubuntu)
On Kali: 
- ping -c 4 <UBUNUT_IP>
- ssh testuser1@<UBUNTU_IP>

### 5) Repo Setup
On Ubuntu:
- git clone https://github.com/bterry29/Automated-Network-Traffic-Analysis-Suricata-IDS-Evaluation-Toolkit.git
- cd Automated-Network-Traffic-Analysis-Suricata-IDS-Evaluation-Toolkit

## Technology Used

**Packet Capture**: Wireshark, TShark

**Intrusion Detection System**: Suricata (offline PCAP evaluation) 

**Attack Simulation**: Hydra (SSH brute force) 

**Scripting**: Bash (automation + summaries), Python (parsing) 

## Method To Run
