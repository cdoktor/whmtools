#!/bin/bash

echo "SILAKAN PILIH AKSI YANG TERSEDIA"
echo "--------------------------------------------"
echo "1. Aktifkan BOT"
echo "2. Nonaktifkan BOT"
read -p "Pilihan Anda [1-2]: " pil

# Memeriksa apakah input adalah 1 atau 2
if [[ "$pil" != "1" && "$pil" != "2" ]]; then
  echo "Pilihan tidak valid. Silakan pilih antara 1 atau 2."
  exit 1
fi

# Fungsi untuk mengecek apakah username cPanel Valid
check_user() {
  local USERNAME="$1"
  whmapi1 listaccts | grep -w "user: ${USERNAME}" > /dev/null 2>&1
  return $?
}

# Fungsi untuk mengecek apakah domain valid
check_domain() {
  local DOMAIN="$1"
  whmapi1 domainuserdata domain="$DOMAIN" | grep -w "servername: ${DOMAIN}" > /dev/null 2>&1
  return $?
}

# Meminta input username cPanel
read -p "Masukkan username cPanel: " USERNAME_CPANEL

# Cek apakah username cPanel terdaftar
if ! check_user "$USERNAME_CPANEL"; then
  echo "Error: Username cPanel '$USERNAME_CPANEL' tidak ditemukan."
  exit 1
fi

# Meminta input domain setelah username tervalidasi
read -p "Masukkan domain cPanel untuk username '$USERNAME_CPANEL': " DOMAIN_CPANEL
# Cek apakah domain valid menggunakan
if ! check_domain "$DOMAIN_CPANEL"; then
  echo "Error: Domain '$DOMAIN_CPANEL' tidak valid atau tidak ditemukan."
  exit 1
fi

# Menentukan direktori konfigurasi
STD_DIR="/usr/local/apache/conf/userdata/std/2_4/${USERNAME_CPANEL}/${DOMAIN_CPANEL}"
SSL_DIR="/usr/local/apache/conf/userdata/ssl/2_4/${USERNAME_CPANEL}/${DOMAIN_CPANEL}"
CUSTOM_CONF_FILE_STD="${STD_DIR}/custom.conf"
CUSTOM_CONF_FILE_SSL="${SSL_DIR}/custom.conf"

if [ "$pil" -eq 1 ]; then
  # Mengaktifkan BOT
  echo "Mengaktifkan BOT untuk domain '$DOMAIN_CPANEL' pada akun '$USERNAME_CPANEL'."

  # Membuat direktori dan menambahkan konfigurasi SET ON
  mkdir -p "${STD_DIR}" "${SSL_DIR}"
  cat <<EOF > "${CUSTOM_CONF_FILE_STD}"
<IfModule LiteSpeed>
   LsRecaptcha 100
</IfModule>
EOF
  cat <<EOF > "${CUSTOM_CONF_FILE_SSL}"
<IfModule LiteSpeed>
   LsRecaptcha 100
</IfModule>
EOF

elif [ "$pil" -eq 2 ]; then
  # Menonaktifkan BOT
  echo "Menonaktifkan BOT untuk domain '$DOMAIN_CPANEL' pada akun '$USERNAME_CPANEL'."

  # Cek dulu folder ada baru timpa
  if [ -d "$STD_DIR" ] && [ -d "$SSL_DIR" ]; then
    cat <<EOF > "${CUSTOM_CONF_FILE_STD}"
<IfModule LiteSpeed>
   LsRecaptcha 0
</IfModule>
EOF
    cat <<EOF > "${CUSTOM_CONF_FILE_SSL}"
<IfModule LiteSpeed>
   LsRecaptcha 0
</IfModule>
EOF
  else
    echo "Folder konfigurasi belum ada, tidak ada perubahan yang dilakukan."
  fi
fi

# Menjalankan command untuk memastikan konfigurasi virtual host
/scripts/ensure_vhost_includes --all-users

# Tampilkan pesan selesai
echo -e "Selesai memproses BOT untuk domain '\e[31m$DOMAIN_CPANEL\e[0m' pada akun '\e[31m$USERNAME_CPANEL\e[0m'."

