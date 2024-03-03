# SENEC Log Downloader

Bash script to download log files from your SENEC device

## Using the script

First, download the script and make it executable:

```bash
curl -sSO https://raw.githubusercontent.com/solectrus/senec-log-downloader/main/download.sh
chmod +x download.sh
```

For configuration, you can use your `.env` file from SOLECTRUS **or** create and edit a new one using the following commands:

```
curl -sSO https://raw.githubusercontent.com/solectrus/senec-log-downloader/main/.env
nano .env
```

Now you can run the script with `./download.sh`. After the script has finished, you will find the results in the `logs/` directory.

## Searching the logs

After downloading the logs, you can search them for specific entries by using `grep`. Here are some examples:

### MCU Firmware updates

```bash
grep -rh "\[I|Settings\] MCU firmware" logs | sort | uniq --skip-fields=2
```

### Reboots

```bash
grep -rhi "Reboot" logs | sort
```

### OpMode changes

```bash
grep -rh "Changed operating mode" logs | sort
```

### NPU Switched off

```bash
grep -rh "Switched off" logs | sort
```
