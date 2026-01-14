#!/bin/bash

# ================= CONFIG =================
LOG_DIR="/var/log/system-monitor"
CSV_LOG="$LOG_DIR/spikes.csv"
JSON_LOG="$LOG_DIR/spikes.json"

CPU_THRESHOLD=80   # %
MEM_THRESHOLD=80   # %
TOP_N=5
# =========================================

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

# ---------- CPU USAGE ----------
CPU_IDLE=$(top -bn1 | awk '/Cpu\(s\)/ {print $8}')
CPU_USED=$(awk "BEGIN {print 100 - $CPU_IDLE}")
CPU_USED_INT=${CPU_USED%.*}

# ---------- MEMORY USAGE ----------
MEM_USED=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

# ---------- Check Threshold ----------
if [[ $CPU_USED_INT -lt $CPU_THRESHOLD && $MEM_USED -lt $MEM_THRESHOLD ]]; then
  exit 0
fi

# ---------- CSV Header ----------
if [ ! -f "$CSV_LOG" ]; then
  echo "timestamp,hostname,cpu_used_percent,mem_used_percent,pid,process,cpu_percent,mem_percent" >> "$CSV_LOG"
fi

# ---------- Top Processes ----------
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n $((TOP_N+1)) | tail -n $TOP_N | while read -r PID CMD CPU MEM; do

  # CSV
  echo "$TIMESTAMP,$HOSTNAME,$CPU_USED,$MEM_USED,$PID,$CMD,$CPU,$MEM" >> "$CSV_LOG"

  # JSON
  echo "{
    \"timestamp\": \"$TIMESTAMP\",
    \"hostname\": \"$HOSTNAME\",
    \"cpu_used_percent\": $CPU_USED,
    \"mem_used_percent\": $MEM_USED,
    \"pid\": $PID,
    \"process\": \"$CMD\",
    \"cpu_percent\": $CPU,
    \"mem_percent\": $MEM
  }," >> "$JSON_LOG"

done
