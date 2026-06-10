#!/bin/bash
#
# nf_conntrack auto reset jika usage mendekati penuh

# === Konfigurasi ===
THRESHOLD=80   # persen, misalnya reset jika >90%
NF_CONNTRACK_COUNT_FILE="/proc/sys/net/netfilter/nf_conntrack_count"
NF_CONNTRACK_MAX_FILE="/proc/sys/net/netfilter/nf_conntrack_max"
NF_CONNTRACK_TOOL="/usr/sbin/conntrack"

# === Cek requirement ===
if [[ ! -f "$NF_CONNTRACK_COUNT_FILE" || ! -f "$NF_CONNTRACK_MAX_FILE" ]]; then
    echo "[ERROR] nf_conntrack tidak ditemukan di sistem ini."
    exit 1
fi

if [[ ! -x "$NF_CONNTRACK_TOOL" ]]; then
    echo "[ERROR] tool 'conntrack' tidak ditemukan. Install dengan: apt install conntrack -y  atau  yum install conntrack-tools -y"
    exit 1
fi

# === Hitung usage ===
COUNT=$(cat $NF_CONNTRACK_COUNT_FILE)
MAX=$(cat $NF_CONNTRACK_MAX_FILE)
USAGE=$(( COUNT * 100 / MAX ))

echo "$(date '+%F %T') [INFO] Usage: $USAGE% ($COUNT/$MAX)"

# === Reset jika melewati ambang ===
if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "[WARNING] nf_conntrack usage $USAGE% ($COUNT/$MAX), reset dilakukan..."

    # Flush semua entry
    $NF_CONNTRACK_TOOL -F

    # Catat ke syslog
    logger -t nf_conntrack_autoreset "Usage $USAGE% ($COUNT/$MAX), conntrack table direset."

    echo "[ACTION] conntrack table sudah direset."
fi

