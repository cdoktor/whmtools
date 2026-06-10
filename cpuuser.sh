#!/bin/bash
#
# Script untuk menghitung total penggunaan CPU per user
# Tidak menampilkan user dengan penggunaan CPU 0%
# Menambahkan total CPU keseluruhan

echo "Total CPU Usage per User:"
echo "========================="

ps -eo user,pcpu --no-headers \
  | awk '
  {
    cpu[$1]+=$2
    total+=$2
  }
  END {
    for (u in cpu) {
      if (cpu[u] > 0) {
        printf "%-15s %6.2f%%\n", u, cpu[u]
      }
    }
    print "-------------------------"
    printf "%-15s %6.2f%%\n", "TOTAL", total
  }' | sort -k2 -nr
