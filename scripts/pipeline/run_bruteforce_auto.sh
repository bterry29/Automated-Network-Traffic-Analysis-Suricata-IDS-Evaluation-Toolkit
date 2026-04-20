#!/usr/bin/env bash
set -euo pipefail

# Run the SSH bruteforce attack pipeline end-to-end with full automation
# 1. Capture PCAP in background with tshark
# 2. Ubuntu triggers Kali attack script remotely over private network
# 3. Moves PCAP into run folder after capture finishes
# 4. Run Suricata offline on the PCAP
# 5. Generate summary report from eve.json
# 6. Save run metadata

# Usage: ./scripts/pipeline/run_bruteforce_auto.sh <interface> <duration_seconds> [attempts] [delay]

# Example: ./scripts/pipeline/run_bruteforce_auto.sh enp0s2 30 40 0.2
IFACE="${1:-}"
DURATION="${2:-}"
ATTEMPTS="${3-25}"
DELAY="${4-0.4}"
TARGET_USER="testuser1"
SCENARIO="ssh_bruteforce"

# Create a unique run id
RUN_ID="${SCENARIO}_$(date +%Y%m%d_%H%M%S)"
RUN_DIR="runs/$RUN_ID"

PCAP_PATH="$RUN_DIR/pcap/${SCENARIO}.pcap"
SURICATA_DIR="$RUN_DIR/suricata"
SUMMARY_PATH="$RUN_DIR/summary.md"
META_PATH="$RUN_DIR/metadata.json"


# If one  parameter is missing, display proper usage
if [[ -z "$IFACE"  || -z "$DURATION" ]]; then
echo "Usage: $0 <interface> <duration_seconds> [attempts] [delay]"
exit 1
fi

# Lab-specific settings for private subnet
UBUNTU_TARGET_IP="192.168.56.3"
KALI_HOST="brandon@192.168.56.2"
KALI_KEY="$HOME/.ssh/kali_lab_key"
KALI_ATTACK_SCRIPT="scripts/ssh_failed_password_sim.sh"

# Make sure user has elevated privileges
echo "[*] Sudo is required for execution" 
sudo -v


#Ensure the directory exists
mkdir -p "$RUN_DIR/pcap" "$RUN_DIR/suricata"

echo
echo "[*] Run ID: $RUN_ID"
echo "[*] Interface: $IFACE"
echo "[*] Duration: $DURATION seconds"
echo "[*] Ubuntu target IP: $UBUNTU_TARGET_IP"
echo "[*] Kali host: $KALI_HOST" 
echo

# Capture PCAP using tmp_pcap_helper.sh (helper so tshark can run in same shell)
echo "[1] Starting background capture..."
eval "$(scripts/capture/tmp_pcap_helper.sh "$PCAP_PATH")"
echo "[*] Temp PCAP: $TMP_PCAP"


sudo tshark -i "$IFACE" -a "duration:${DURATION}" -w "$TMP_PCAP" >/dev/null 2>&1 &
CAP_PID=$!

echo "[*] Capture PID: $CAP_PID"
echo

ATTACK_START="$(date -Iseconds)"
echo "[2] Triggering Kali attack remote..."
ssh -i "$KALI_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
"$KALI_HOST" "bash -lc 'cd Network_IDS_Project && ./$KALI_ATTACK_SCRIPT $UBUNTU_TARGET_IP $TARGET_USER $ATTEMPTS $DELAY'"
ATTACK_END="$(date -Iseconds)"
echo

# Finish capture and move PCAP into run folder
echo "[*] Waiting for capture to complete..."
wait "$CAP_PID"
echo "[+] Capture complete."

echo "[*] Moving PCAP into run folder: $PCAP_PATH"
sudo mv "$TMP_PCAP" "$PCAP_PATH"
sudo chown "$USER":"$USER" "$PCAP_PATH"
ls -lh "$PCAP_PATH"
echo
 

# Run Suricata offline on PCAP using run_suricata_offline.sh
echo "[3] Running Suricata offline..."
bash scripts/suricata/run_suricata_offline.sh "$PCAP_PATH" "$SURICATA_DIR"
echo

# Generate log summary from eve.json using eve_quick_stats.sh
echo "[4] Generating EVE summary..."
bash scripts/analysis/eve_quick_stats.sh "$SURICATA_DIR/eve.json" "$SUMMARY_PATH"
echo

# Write run metadata
echo "[5] Writing metadata..."
START_TIME="$(date -Iseconds)"
END_TIME="$(date -Iseconds)"
{
echo "=== $RUN_ID Metadata ==="
echo
echo "run_id: $RUN_ID"
echo "scenario: $SCENARIO"
echo "interface: $IFACE"

echo "target_user: $TARGET_USER"
echo "duration_seconds: $DURATION"
echo "pcap_path: $PCAP_PATH"
echo "suricata_directory: $SURICATA_DIR"
echo "summary_path: $SUMMARY_PATH"
echo "start_time: $START_TIME"
echo "end_time: $END_TIME"
echo "attack_window : {start: $ATTACK_START, end: $ATTACK_END}"
echo
} > "$META_PATH"

echo "[+] SSH bruteforce run complete" 
