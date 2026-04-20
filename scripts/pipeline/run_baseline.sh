#!/usr/bin/env bash
set -euo pipefail

# Run the baseline pipeline end-to-end
# 1. Capture PCAP
# 2. Run Suricata offline on the PCAP
# 3. Generate summary report from eve.json
# 4. Save run metadata

# Usage: ./scripts/pipeline/run_baseline.sh <interface> <duration_seconds>

IFACE="${1:-}"
DURATION="${2:-}"
SCENARIO="baseline"

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

# Capture PCAP using capture_pcap.sh
echo "[1] Capturing baseline PCAP..."
bash scripts/capture/capture_pcap.sh "$IFACE" "$DURATION" "$PCAP_PATH"
echo

# Run Suricata offline on PCAP using run_suricata_offline.sh
echo "[2] Running Suricata offline..."
bash scripts/suricata/run_suricata_offline.sh "$PCAP_PATH" "$SURICATA_DIR"
echo

# Generate log summary from eve.json using eve_quick_stats.sh
echo "[3] Generating EVE summary..."
bash scripts/analysis/eve_quick_stats.sh "$SURICATA_DIR/eve.json" "$SUMMARY_PATH"
echo

# Write run metadata
echo "[4] Writing metadata..."
START_TIME="$(date -Iseconds)"
END_TIME="$(date -Iseconds)"
{
echo "=== $RUN_ID Metadata ==="
echo
echo "run_id: $RUN_ID"
echo "scenario: $SCENARIO" 
echo "interface: $IFACE"
echo "duration_seconds: $DURATION"
echo "pcap_path: $PCAP_PATH"
echo "suricata_directory: $SURICATA_DIR"
echo "summary_path: $SUMMARY_PATH"
echo "start_time: $START_TIME"
echo "end_time: $END_TIME"
echo
} > "$META_PATH" 

echo "[+] Baseline run complete" 
