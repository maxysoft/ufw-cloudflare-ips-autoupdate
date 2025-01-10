#!/bin/bash

# Locally stored ips
CF_IPS_FILE="/root/scripts/cloudflare-ips/cloudflare-ips.txt"
TEMP_IPS_FILE="/tmp/cloudflare-ips-temp.txt"

# Fetch current Cloudflare IPs
fetch_cloudflare_ips() {
    curl -s https://www.cloudflare.com/ips-v4 > "$TEMP_IPS_FILE"
    echo "" >> "$TEMP_IPS_FILE"  # Add a newline
    curl -s https://www.cloudflare.com/ips-v6 >> "$TEMP_IPS_FILE"
    # Remove any blank lines and sort
    sed -i '/^[[:space:]]*$/d' "$TEMP_IPS_FILE"
    sort "$TEMP_IPS_FILE" -o "$TEMP_IPS_FILE"
}

# Add UFW rule
add_ufw_rule() {
    local ip=$1
    ufw allow proto tcp from $ip to any port 80,443 comment 'Cloudflare IP'
}

# Remove UFW rule
remove_ufw_rule() {
    local ip=$1
    ufw delete allow proto tcp from $ip to any port 80,443
}

# Call the funcion Fetch current Cloudflare IPs
fetch_cloudflare_ips

# Check if cloudflare-ips.txt exists (for the first time run)
if [ ! -f "$CF_IPS_FILE" ]; then
    # First run - save IPs and add UFW rules
    echo "First run - adding all Cloudflare IPs to UFW rules"
    while IFS= read -r ip; do
        add_ufw_rule "$ip"
    done < "$TEMP_IPS_FILE"

    # Save the current IPs
    cp "$TEMP_IPS_FILE" "$CF_IPS_FILE"
else
    # check for changes
    echo "Checking for changes in Cloudflare IPs"

    # Find new IPs (in temp file)
    while IFS= read -r ip; do
        if ! grep -Fxq "$ip" "$CF_IPS_FILE"; then
            echo "Adding new IP: $ip"
            add_ufw_rule "$ip"
        fi
    done < "$TEMP_IPS_FILE"

    # Find removed IPs (in stored file but not in temp)
    while IFS= read -r ip; do
        if ! grep -Fxq "$ip" "$TEMP_IPS_FILE"; then
            echo "Removing old IP: $ip"
            remove_ufw_rule "$ip"
        fi
    done < "$CF_IPS_FILE"

    # Update the stored IPs
    cp "$TEMP_IPS_FILE" "$CF_IPS_FILE"
fi

# Clean up temp file
rm "$TEMP_IPS_FILE"
