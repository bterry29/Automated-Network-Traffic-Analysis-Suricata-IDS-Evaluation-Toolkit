#!/usr/bin/env bash

set -euo pipefail

## ssh_failed_password_sim.sh
## Generate repreated FAILED SSH password attempts in a controlled lab
## * For stromger evidence *
## Usage: ./scripts/ssh_failed_password_sim.sh <target_ip> <target_user> [attempts] [delay]

TARGET_IP="${1:-}"
TARGET_USER="${2:-}"
ATTEMPTS="${3-30}"
DELAY="${4-0.5}"
WRONG_PASSWORD="WromgPassword123"


if [[ -z "$TARGET_IP" || -z "$TARGET_USER" ]]; then
echo "Usage: $0 <target_ip> <target_user> [attempts] [delay]" 
exit 1
fi

if [[ "$ATTEMPTS" -gt  200 ]]; then
echo "! Too many attempts, unsafe for lab" 
exit 1
fi


echo "[*] Simulating SSH brute-force with failed password attemtps" 
echo "[*] Target: ${TARGET_USER}@${TARGET_IP}"
echo "[*] Attempts: ${ATTEMPTS} DELAY: ${DELAY}s"
echo

for i in $(seq 1 "$ATTEMPTS"); do
## 
## ConnectTimeout=3: fails quick with no target connection
## StrictHostKeyChecking=no: avoids prompt for automation purposes (lab-only)
sshpass -p "$WRONG_PASSWORD" ssh -o UserKnownHostsFile=/dev/null -o ConnectTimeout=3 -o StrictHostKeyChecking=no "${TARGET_USER}@${TARGET_IP}" "exit" >/dev/null 2>&1 || true 
sleep "$DELAY" 
done 

echo "[+] Done generating FAILED password attempts!"
