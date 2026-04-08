#!/usr/bin/env bash

set -euo pipefail

# Implemented after discovering wait can only wait on processes started
# by the same shell. Helper gives TMP_PCAP path while orchestrator starts tshark.

# Prints TMP_PCAP path for a given final output path.
# Usage: ./scripts/capture/tmp_pcap_helper.sh <final_pcap_path>
# Output: TMP_PCAP=/tmp/<basename>

FINAL_PCAP="${1:-}"
if [[ -z "$FINAL_PCAP" ]]; then
  echo "Usage: $0 <final_pcap_path>"
  exit 1
fi

TMP_PCAP="/tmp/$(basename "$FINAL_PCAP")"
echo "TMP_PCAP=$TMP_PCAP"
