#!/bin/bash

read -p "Masukkan username cPanel: " USERNAME
if [ -z "$USERNAME" ]; then
  echo "Username tidak boleh kosong!"
  exit 1
fi

USER_DIR="/home/$USERNAME"
if [ ! -d "$USER_DIR" ]; then
  echo "Direktori $USER_DIR tidak ditemukan!"
  exit 1
fi

KEYWORDS="casino|gacor|maxwin|togel|jackpot|pragmatic|bonanza"
SKIP_DIRS="--exclude-dir=tmp --exclude-dir=mail"

echo "Mulai scan di: $USER_DIR (skip tmp dan mail)"
echo "========================================="

highlight() {
  echo "$1" | sed -E "s/($KEYWORDS)/\x1b[1;31m\1\x1b[0m/Ig"
}

scan_content() {
  grep -rniI --binary-files=without-match -E "$KEYWORDS" "$1" $2 2>/dev/null | cut -d: -f1,2,3- | \
  while IFS=":" read -r FILE LINE CONTENT; do
    if [[ -z "${SEEN[$FILE]}" ]]; then
      SEEN["$FILE"]=1
      MATCH=$(echo "$CONTENT" | grep -oEi ".{0,10}($KEYWORDS).{0,10}" | head -n 1)
      HIGHLIGHTED=$(highlight "$MATCH")
      echo "Konten mencurigakan:"
      echo "  File  : $FILE"
      echo "  Baris : $LINE"
      echo "  Match : $HIGHLIGHTED"
      echo "-----------------------------------------"
    fi
  done
}

scan_names() {
  find "$1" $2 -type f -iname "*.*" 2>/dev/null | grep -iE "$KEYWORDS" | while read -r FILE; do
    echo "Nama file mencurigakan:"
    echo "  $FILE"
    echo "-----------------------------------------"
  done

  find "$1" $2 -type d 2>/dev/null | grep -iE "$KEYWORDS" | while read -r DIR; do
    echo "Nama folder mencurigakan:"
    echo "  $DIR"
    echo "-----------------------------------------"
  done
}

declare -A SEEN
scan_content "$USER_DIR" "$SKIP_DIRS"
scan_names "$USER_DIR" "$SKIP_DIRS"

read -p "Lanjut scan folder tmp dan mail? (y/n): " LANJUT
if [[ "$LANJUT" =~ ^[Yy]$ ]]; then
  for FOLDER in tmp mail; do
    if [ -d "$USER_DIR/$FOLDER" ]; then
      echo "Scan folder: $FOLDER"
      echo "========================================="
      unset SEEN
      declare -A SEEN
      scan_content "$USER_DIR/$FOLDER" ""
      scan_names "$USER_DIR/$FOLDER" ""
    fi
  done
fi


