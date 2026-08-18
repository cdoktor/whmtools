#!/bin/bash

read -p "Masukkan username: " user

if [ -z "$user" ]; then
    echo "Username tidak boleh kosong."
    exit 1
fi

echo "Disable CageFS untuk user: $user"
cagefsctl --disable "$user"

echo "Enable CageFS untuk user: $user"
cagefsctl --enable "$user"

echo "Selesai."
