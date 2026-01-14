#!/bin/bash
# ==========================================
# System Spike Logger (Production + Test Mode)
# ==========================================

LOG_DIR="/var/log/system-monitor"
CSV_LOG="$LOG_DIR/spikes.csv"
JSON_LOG="$LOG_DIR/spikes.json"

CPU_THRESHOLD=50
MEM_THRESHOLD=30
TOP_N=5

TEST_MODE=${1:-false}

mkdir -p "$LOG_DIR"

TIMESTAMP=$(TZ="Asia/Kolkata" date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

if [ "$TEST_MODE" = "test" ]; then
  CPU=99.9
  MEM=88.8
  PID=9999
  CMD="test-process"
else
  ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n $((TOP_N+1)) | tail -n $TOP_N | while read PID CMD CPU MEM; do
    CPU_INT=${CPU%.*}
    MEM_INT=${MEM%.*}
  done
fi

if [ "${CPU_INT:-80}" -ge $CPU_THRESHOLD ] || [ "${MEM_INT:-80}" -ge $MEM_THRESHOLD ]; then
  if [ ! -f "$CSV_LOG" ]; then
    echo "timestamp,hostname,pid,process,cpu_percent,mem_percent" >> "$CSV_LOG"
  fi

  echo "$TIMESTAMP,$HOSTNAME,$PID,$CMD,$CPU,$MEM" >> "$CSV_LOG"

  echo "{
  \"timestamp\": \"$TIMESTAMP\",
  \"hostname\": \"$HOSTNAME\",
  \"pid\": $PID,
  \"process\": \"$CMD\",
  \"cpu_percent\": $CPU,
  \"mem_percent\": $MEM
}," >> "$JSON_LOG"
fi
