#!/usr/bin/env bash

set -euo pipefail

## ssh_bruteforce_sim.sh
## Generate repreated FAILED SSH login attempts in a controlled lab
## Usage: ./scripts/ssh_bruteforce_sim.sh <target_ip> <target_user> [attempts] [delay]

TARGET_IP="${1:-}"
TARGET_USER="${2:-}"
ATTEMPTS="${3-30}"
DELAY="${4-0.5}"


if [[ -z "$TARGET_IP" || -z "$TARGET_USER" ]]; then
echo "Usage: $0 <target_ip> <target_user> [attempts] [delay]" 
exit 1
fi

if [[ "$ATTEMPTS" -gt  200 ]]; then
echo "! Too many attempts, unsafe for lab" 
exit 1
fi


echo "[*] Simulating SSH brute-force with failed login attemtps" 
echo "[*] Target: ${TARGET_USER}@${TARGET_IP}"
echo "[*] Attempts: ${ATTEMPTS} DELAY: ${DELAY}s"
echo

for i in $(seq 1 "$ATTEMPTS"); do
## Batchmode=yes: no prompt for password
## ConnectTimeout=3: fails quick with no target connection
## StrictHostKeyChecking=no: avoids prompt for automation purposes (lab-only)
ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no "${TARGET_USER}@${TARGET_IP}" "exit" >/dev/null 2>&1 || true 
sleep "$DELAY" 
done 

echo "[+] SSH brute-force attempts completed!"
