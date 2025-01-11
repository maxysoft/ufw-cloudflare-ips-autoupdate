#!/bin/bash

# Locally stored IPs
CF_IPS_FILE="/root/scripts/cloudflare-ips/cloudflare-ips.txt"

# Check if cloudflare-ips.txt exists
if [ ! -f "$CF_IPS_FILE" ]; then
    echo "Error: Cloudflare IPs file not found at $CF_IPS_FILE"
    exit 1
fi

echo "Removing Cloudflare ufw rules..."

# Counter for removed rules
removed_count=0

# Remove UFW rules for each IP
while IFS= read -r ip; do
    echo "Removing UFW rule for IP: $ip"

    # Try to delete the rule and check if successful
    if ufw delete allow proto tcp from $ip to any port 80,443; then
        ((removed_count++))
    else
        echo "Warning: Failed to remove rule for IP: $ip"
    fi
done < "$CF_IPS_FILE"

# Cleanup
if [ $removed_count -gt 0 ]; then
    echo "Removing cloudflare-ips.txt file..."
    rm -f "$CF_IPS_FILE"
    echo "Successfully removed $removed_count Cloudflare UFW rules"
    echo "cloudflare-ips.txt file has been deleted"
else
    echo "No rules were removed"
fi
