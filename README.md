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
