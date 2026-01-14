# System Monitor – CPU & Memory Spike Logger

## Files
- system_spike_logger.sh
- system-monitor.logrotate

## Install
```bash
sudo cp system_spike_logger.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/system_spike_logger.sh
```

## Test Mode
```bash
sudo /usr/local/bin/system_spike_logger.sh test
```

## Cron (every minute)
```bash
* * * * * /usr/local/bin/system_spike_logger.sh
```

## Logrotate
```bash
sudo cp system-monitor.logrotate /etc/logrotate.d/system-monitor
```

## Expected result ---> Files created:
```bash
/var/log/system-monitor/spikes.csv
/var/log/system-monitor/spikes.json
```

## CSV example:
```csv
timestamp,hostname,pid,process,cpu_percent,mem_percent
2026-01-14 10:25:01,ubuntu,9999,test-process,99.9,88.8
```

## Optional cleanup (keep 7 days only)
```bash
find /var/log/system-monitor -type f -mtime +7 -delete
```
## ✉️ Email With CSV + JSON Attachments (Ubuntu mailutils supports attachments via -a.)
```bash
# ---------- EMAIL ALERT WITH ATTACHMENTS ----------
MAIL_SUBJECT="🚨 System Alert: High CPU/Memory on $HOSTNAME"
MAIL_BODY="
System threshold crossed!

Host      : $HOSTNAME
Time      : $TIMESTAMP
CPU Usage : $CPU_USED %
Memory    : $MEM_USED %

Attached:
- CSV log
- JSON log
"

echo "$MAIL_BODY" | mail \
  -s "$MAIL_SUBJECT" \
  -a "$CSV_LOG" \
  -a "$JSON_LOG" \
  "$EMAIL_TO"
```

## 🧹 Auto-Cleanup Old Local Logs (📌 Add this at the very end of the script:)
```bash
# ---------- AUTO CLEANUP OLD LOGS ----------
find "$LOG_DIR" -type f -mtime +$LOG_RETENTION_DAYS -name "spikes_*" -delete
```

## Example
```bash
If today is Jan 14 and LOG_RETENTION_DAYS=7, anything before Jan 7 is removed automatically.
```