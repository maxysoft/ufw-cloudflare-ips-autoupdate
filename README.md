### Mini-script to automatically update ufw firewall and allow incoming connections to ports 80 and 443 only from cloudflare ips.

#### Quick setup
```bash
mkdir -p /root/scripts/cloudflare-ips/logs && \
wget -O /root/scripts/cloudflare-ips/cloudflare-update.sh https://github.com/maxysoft/ufw-cloudflare-ips-autoupdate/raw/refs/heads/master/cloudflare-update.sh && \
chmod +x /root/scripts/cloudflare-ips/cloudflare-update.sh
```

#### Run with crontab every day at 1am
```bash
0 1 * * * /root/scripts/cloudflare-ips/cloudflare-update.sh >> /root/scripts/cloudflare-ips/logs/cloudflare-updates.log 2>&1
```
