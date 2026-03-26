#!/usr/bin/env bash
set -euo pipefail

# Runs Suricata in offline mode on PCAP and then writes logs to a specific output folder

# Usage: .scripts/suricata/run_suricata_offline.sh <pcap_path> <output_path>

PCAP="${1:-}"
OUT_PATH="${2:-}"

# If one parameter is missing, display proper usage
if [[ -z "$PCAP" || -z "$OUT_PATH" ]]; then
echo "Usage: $0 <pcap_path <output_folder>"
exit 1
fi

# Error if pcap filename does not exist
if [[ ! -f "$PCAP" ]]; then
echo "Error: PCAP not found at: $PCAP"
exit 1
fi

# Make sure output folder exists
mkdir -p "$OUT_PATH"

echo "[*] Running Suricata offline on: $PCAP"
echo 
echo "[*] Writing logs to: $OUT_PATH"

# Read packet capture and output to specified folder
sudo suricata -r "$PCAP" -l "$OUT_PATH"

echo "[+] Suricata complete. Output files:"
ls -lh "$OUT_PATH"

