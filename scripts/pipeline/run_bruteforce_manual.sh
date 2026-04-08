#!/usr/bin/env bash
set -euo pipefail

# Run the SSH bruteforce attack pipeline end-to-end
# 1. Capture PCAP in background with tshark
# 2. User runs brute-force script on Kali during capture window
# 3. Moves PCAP into run folder after capture finishes
# 4. Run Suricata offline on the PCAP
# 5. Generate summary report from eve.json
# 6. Save run metadata

# Usage: ./scripts/run_bruteforce_manual.sh <interface> <duration_seconds>

IFACE="${1:-}"
DURATION="${2:-}"
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
echo "Usage: $0 <interface> <duration_seconds> "
exit 1
fi

#Ensure the directory exists
mkdir -p "$RUN_DIR/pcap" "$RUN_DIR/suricata"

echo
echo "[*] Run ID: $RUN_ID"
echo "[*] Interface: $IFACE"
echo "[*] Duration: $DURATION seconds" 
echo

# Make the user type password for sudo privileges
echo "[*] Sudo is required for capture and Suricata."
sudo -v

# Capture PCAP using tmp_pcap_helper.sh (helper so tshark can run in same shell)
echo "[1] Starting background capture..."
eval "$(scripts/capture/tmp_pcap_helper.sh "$PCAP_PATH")"
echo "[*] Temp PCAP: $TMP_PCAP"


sudo tshark -i "$IFACE" -a "duration:${DURATION}" -w "$TMP_PCAP" >/dev/null 2>&1 &
CAP_PID=$!

echo "[*] Capture PID: $CAP_PID"
echo

# Instruct user to run SSH brute-force on attack machine (Kali)
echo "[2] ACTION REQUIRED: Run a brute_force script on Kali NOW."
echo "Example: ./scripts/ssh_bruteforce_sim.sh <UBUNTU_IP> ${TARGET_USER} [ATTEMPTS] [DELAY]"
echo
read -p "Press ENTER after the Kali brute-force script has finished..."_
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
echo
} > "$META_PATH" 

echo "[+] SSH bruteforce run complete" 
