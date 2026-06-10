#!/bin/bash

# ==== Config ====
LIST_FILE="/opt/list-ip-blok-443.txt"

# Ambil IP public server(exclude biar gak ke block)
SERVER_IP=$(curl -s ifconfig.me)

echo " Mulai scan koneksi port 443 - $(date)"

netstat -anp 2>/dev/null | grep ':443' | awk '{print $5}' | cut -d: -f1 | \
    sort | uniq -c | sort -nr | head -20 | while read count ip; do

    if [[ $count -gt 30 && $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ && "$ip" != "$SERVER_IP" ]]; then
        echo "🔍 Cek IP: $ip ($count koneksi)"

        if imunify360-agent ip-list local list | grep -q "$ip"; then
            echo " IP $ip sudah diblacklist, skip"
        else
            imunify360-agent ip-list local add "$ip" --purpose drop --comment "Hit 443 +100 koneksi"
            echo " IP $ip berhasil diblacklist"

            # Tambahkan ke file list pake timestamp
            echo "$(date '+%F %T') - $ip" >> "$LIST_FILE"
        fi
    fi
done

echo " Scan selesai - $(date)"
