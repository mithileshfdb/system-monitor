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

## 1️⃣ Define S3 URLs (After Upload) : 📌 Replace your S3 UPLOAD section with this:
```bash
# ---------- S3 UPLOAD ----------
aws s3 cp "$CSV_LOG" "$S3_BUCKET/$HOSTNAME/"
aws s3 cp "$JSON_LOG" "$S3_BUCKET/$HOSTNAME/"

S3_CSV_URL="$S3_BUCKET/$HOSTNAME/$(basename "$CSV_LOG")"
S3_JSON_URL="$S3_BUCKET/$HOSTNAME/$(basename "$JSON_LOG")"

These are S3 object paths (work even for private buckets via AWS console or presigned URLs).
```

## 2️⃣ Add S3 URLs to Email Body : 📌 Update your EMAIL ALERT section like this:
```bash
# ---------- EMAIL ALERT WITH ATTACHMENTS + S3 LINKS ----------
MAIL_SUBJECT="🚨 System Alert: High CPU/Memory on $HOSTNAME"
MAIL_BODY="
🚨 System Alert Triggered

Host      : $HOSTNAME
Time      : $TIMESTAMP
CPU Usage : $CPU_USED %
Memory    : $MEM_USED %

Local Attachments:
- CSV log
- JSON log

S3 Locations:
- CSV  : $S3_CSV_URL
- JSON : $S3_JSON_URL
"

echo "$MAIL_BODY" | mail \
  -s "$MAIL_SUBJECT" \
  -a "$CSV_LOG" \
  -a "$JSON_LOG" \
  "$EMAIL_TO"

```
## 📧 Example Email Content
```bash
🚨 System Alert Triggered

Host      : prod-app-01
Time      : 2026-01-14 13:42:10
CPU Usage : 91 %
Memory    : 86 %

Local Attachments:
- CSV log
- JSON log

S3 Locations:
- CSV  : s3://system-monitor-logs/prod-app-01/spikes_prod-app-01_20260114_134210.csv
- JSON : s3://system-monitor-logs/prod-app-01/spikes_prod-app-01_20260114_134210.json

```

## 🔐 Optional (Very Useful): Presigned URLs (Clickable) : If you want clickable HTTPS links (valid for 24 hours):
```bash
S3_CSV_URL=$(aws s3 presign "$S3_BUCKET/$HOSTNAME/$(basename "$CSV_LOG")" --expires-in 86400)
S3_JSON_URL=$(aws s3 presign "$S3_BUCKET/$HOSTNAME/$(basename "$JSON_LOG")" --expires-in 86400)

Now email recipients can download directly without AWS access.
```

## ✅ Option 1 (Recommended): --acl public-read during upload (This makes only the uploaded objects public, not the whole bucket.)

```bash
PREFIX="spikes"
S3_BUCKET="s3://your-bucket-name/system-monitor/$(hostname)/"

# Upload spike files with public read access
aws s3 cp . "$S3_BUCKET" \
  --recursive \
  --exclude "*" \
  --include "${PREFIX}*" \
  --acl public-read

# Verify upload before cleanup
if aws s3 ls "$S3_BUCKET" | grep -q "${PREFIX}"; then
  echo "Files verified in S3. Cleaning up local files..."
  rm -f ${PREFIX}*.csv ${PREFIX}*.json
else
  echo "Verification failed. Cleanup skipped."
fi

```

## Without Kubernetes: Server log in the best UI

```bash
Please follow the below link or pdf documents
https://chatgpt.com/share/69688dd8-e774-8000-ab0e-6c534790d75a
```
