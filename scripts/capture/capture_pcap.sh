#!/usr/bin/env bash
set -euo pipefail

# Captures network traffic packets from given interface for a fixed duration.
# Writes to /tmp, then moves it into a specific output path. 

# Usage: ./scripts/capture/capture_pcap.sh <interface> <second> <output_path>


IFACE="${1:-}"
DURATION="${2:-}"
OUT_PATH="${3:-}"


# If one parameter is missing, display proper usage
if [[ -z "$IFACE" || -z "$DURATION" || -z "$OUT_PATH" ]]; then
echo "Usage: $0 <interface> <seconds> <output_path> "
exit 1
fi

# Make sure output path exists
mkdir -p "$(dirname "$OUT_PATH")"

TMP_PATH="/tmp/$(basename "$OUT_PATH")"

# Capture and move t o tmp path
echo "[*] Capturing ${DURATION}s on interface ${IFACE} to ${TMP_PATH}"
sudo tshark -i "$IFACE" -a "duration:${DURATION}" -w "$TMP_PATH"

# Move pcap into desired folder
echo "[*] Moving PCAP into project folder: ${OUT_PATH}"
sudo mv "$TMP_PATH" "$OUT_PATH"
sudo chown "$USER":"$USER" "$OUT_PATH"

# Display final file to show success 
echo "[+] PCAP saved: $OUT_PATH"
ls -lh "$OUT_PATH" 
