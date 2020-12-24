#!/bin/bash
#######################
# Example Usage ./setup-cron.sh home.example.com
#######################
ledomain=$1

unifiedCron=$(echo "0 0 * * 0 /root/get-certs.sh $ledomain" ; crontab -l)
echo "$unifiedCron" | crontab -
