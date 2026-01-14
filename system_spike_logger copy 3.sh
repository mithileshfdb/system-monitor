#!/bin/bash

# ================= CONFIG =================
LOG_DIR="/var/log/system-monitor"
CSV_LOG="$LOG_DIR/system_state.csv"
JSON_LOG="$LOG_DIR/system_state.json"
TOP_N=5
# ==========================================

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

# CPU & Memory summary
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | xargs)
MEM_USED=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')

# Header for CSV (once)
if [ ! -f "$CSV_LOG" ]; then
  echo "timestamp,hostname,pid,process,cpu_percent,mem_percent,load_avg,mem_used_percent" >> "$CSV_LOG"
fi

# Top processes by CPU
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n $((TOP_N+1)) | tail -n $TOP_N | \
while read -r PID CMD CPU MEM; do

  # ---------- CSV ----------
  echo "$TIMESTAMP,$HOSTNAME,$PID,$CMD,$CPU,$MEM,\"$CPU_LOAD\",$MEM_USED" >> "$CSV_LOG"

  # ---------- JSON ----------
  echo "{
    \"timestamp\": \"$TIMESTAMP\",
    \"hostname\": \"$HOSTNAME\",
    \"pid\": $PID,
    \"process\": \"$CMD\",
    \"cpu_percent\": $CPU,
    \"mem_percent\": $MEM,
    \"load_average\": \"$CPU_LOAD\",
    \"mem_used_percent\": $MEM_USED
  }," >> "$JSON_LOG"

done
