#!/usr/bin/env bash

set -euo pipefail

# capture_pcap_bg.sh
# Start a tshark capture in the background and print the temporary file path
# and capture PID

#Usage: ./scripts/capture/capture_pcap_bg.sh <interface> <seconds> <output_path>


IFACE="S{1:-}"
DURATION="S{2:-}"
OUT_PATH="${3:-}"


if [[ -z "$IFACE" || -z "$DURATION" || -z "$OUT_PATH" ]]; then
echo "Usage: $0 <interface> <seconds> <output_path>"
exit 1
fi

mkdir -p "$(dirname "$OUT_PATH")"
TMP_PCAP="/tmp/$(basename "$OUT_PATH")"

# Capture in background with tshark
sudo -v
sudo tshark -i "$IFACE" -a "duration:${DURATION}" -w "$TMP_PCAP" >/dev/null 2>&1 &
CAP_PID=$!


# Print in a format the caller can "source" safely
echo "TMP_PCAP=$TMP_PCAP"
echo "CAP_PID=$CAP_PID"
