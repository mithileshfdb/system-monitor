#!/bin/bash

# ================= CONFIG =================
LOG_DIR="/var/log/system-monitor"

CPU_THRESHOLD=80   # %
MEM_THRESHOLD=80   # %
TOP_N=5
# =========================================

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
FILE_TS=$(date +"%Y%m%d_%H%M%S")
HOSTNAME=$(hostname)

CSV_LOG="$LOG_DIR/spikes_${HOSTNAME}_${FILE_TS}.csv"
JSON_LOG="$LOG_DIR/spikes_${HOSTNAME}_${FILE_TS}.json"

# ---------- CPU USAGE ----------
CPU_IDLE=$(top -bn1 | awk '/Cpu\(s\)/ {print $8}')
CPU_USED=$(awk "BEGIN {print 100 - $CPU_IDLE}")
CPU_USED_INT=${CPU_USED%.*}

# ---------- MEMORY USAGE ----------
MEM_USED=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

# ---------- Threshold Check ----------
# Exit ONLY if both CPU & MEM are below threshold
if [[ $CPU_USED_INT -lt $CPU_THRESHOLD && $MEM_USED -lt $MEM_THRESHOLD ]]; then
  exit 0
fi

# ---------- CSV Header ----------
echo "timestamp,hostname,cpu_used_percent,mem_used_percent,pid,process,cpu_percent,mem_percent" > "$CSV_LOG"

# ---------- JSON Start ----------
echo "[" > "$JSON_LOG"

# ---------- Top Processes ----------
FIRST=true
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n $((TOP_N+1)) | tail -n $TOP_N | while read -r PID CMD CPU MEM; do

  # CSV
  echo "$TIMESTAMP,$HOSTNAME,$CPU_USED,$MEM_USED,$PID,$CMD,$CPU,$MEM" >> "$CSV_LOG"

  # JSON (avoid trailing comma)
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    echo "," >> "$JSON_LOG"
  fi

  cat <<EOF >> "$JSON_LOG"
  {
    "timestamp": "$TIMESTAMP",
    "hostname": "$HOSTNAME",
    "cpu_used_percent": $CPU_USED,
    "mem_used_percent": $MEM_USED,
    "pid": $PID,
    "process": "$CMD",
    "cpu_percent": $CPU,
    "mem_percent": $MEM
  }
EOF

done

# ---------- JSON End ----------
echo "]" >> "$JSON_LOG"
