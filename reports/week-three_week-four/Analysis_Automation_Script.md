# Analysis Automation Script

The following script automates the process of quickly extracting information from an eve.json file after a Suricata PCAP analysis. 

## Bash Script Setup

    #!/usr/bin/env bash

    set -euo pipefail

Ensures the file is run using bash. The -e option exits the script if there is an error to prevent further complications.

The -u option treats unset variables as an error, which prevents set typos.

The -o pipeline option ensures that if one command in the whole script fails, the whole pipeline fails

These will be used in every script to ensure consistency and prevent unknown failures.


## Set The Read Arguments

    EVE_PATH = "${1:-}"
    OUT_PATH = "${2:-}"

The first argument is the path to the eve.json file after the pcap analysis.

The second argument (optional input) is the path to save the analysis summary.

The ":-" portions allow the use of an empty string without the whole thing crashing.


## Check For Valid Input 

    if [[ -z "$EVE_PATH" ]]; then
      echo "Usage: $0 <path_to_eve.json> [output_summary_path]"
      exit 1
    fi 


    if [[ ! -f "$EVE_PATH ]]; then
      echo "Error: eve.json not found at: $EVE_PATH"
      exit 1
    fi

The first if-then statement checks to see if the string is empty, and if so, that means the script will fail and exit. 

The second if-then statement checks to see if the file exists and if the file is regular; if it is not, then the script will fail and exit. 


## Output Path Logic

    if [[ -z "$OUT_PATH" ]]; then
      mkdir -p data/summaries
      TIME = "$(date +%Y%m%d_%H%M%S)"
      OUT_PATH = "data/summaries/eve_summary_${TIME}.md"
    else
      mkdir -p "$(dirname "$OUT_PATH")"
    fi

If a specific output file or path is not implemented, it will create a data/summaries directory. It will then create a timestamp for when the command is run and create a file in the data/summaries directory with this timestamp in the new output file name. 

Otherwise, if an output file is implemented, then it will output to the existing directory.

## Generate Quick Summary File 

    {
    echo "=== Suricata EVE Quick Summary ==="
    echo "Source: $EVE_PATH"
    echo "Generated: $(date): 
    echo

    echo "[1] Total events:" 
    wc -l < "$EVE_PATH"
    echo 

    echo "[2] Event types breakdown (top 10): "
    grep -o '"event_type":"[^"]*"' "$EVE_PATH" | sort | uniq -c | sort -nr | head -n 10 || true
    echo
    
    echo "[3] Alert count:"
    grep -c '"event_type":"alert"' "$EVE_PATH" || true
    echo
    
    echo "[4] Top alert signatures (top 10):"
    grep '"event_type":"alert"' "$EVE_PATH" | grep -o '"signature":"[^"]*"' | sort | uniq -c | sort -nr | head -n 10 || true
    echo

    echo "[5] Top src_ip in alerts (top 10):"
    grep '"event_type":"alert"' "$EVE_PATH" | grep -o '"src_ip":"[^"]*"' | sort | uniq -c | sort -nr | head -n 10 || true
    echo

    echo "[6] Top dest_ip in alerts (top 10):"
    grep '"event_type":"alert"' "$EVE_PATH" | grep -o '"dest_ip":"[^"]*"' | sort | uniq -c | sort -nr | head -n 10 || true
    echo
    } > "$OUT_PATH"

    echo "[+] Wrote summary to: $OUT_PATH"


Produces a summary with six different metrics, analyzing the event log quickly and displaying important information into the output file.
