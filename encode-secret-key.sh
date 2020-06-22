#!/usr/bin/sh

# Usage: ./encode-secret-key.sh <name>
# Encodes the secret key named by <name> as a series of QR code images
# dependencies: gpg, paperkey, qrencode, convert (imagemagick)

set -euo pipefail

if [ $# -eq 0 ]; then
    echo 'Please supply key name as an argument'
    exit 1
fi

PREFIX=secret-key-
OLD_KEY_FILES=$(find . -maxdepth 1 -name ${PREFIX}\*)
OLD_KEY_QR_FILES=$(find . -maxdepth 1 -name ${PREFIX}\*.qr.png)
FINGERPRINT=$(gpg --with-fingerprint \
    --with-colons \
    --list-public-keys "$1" \
    | awk -F: '$1 == "fpr" {print $10;}' \
    | head -n 1)

rm -f $OLD_KEY_FILES
rm -f $OLD_KEY_QR_FILES

gpg --export-secret-keys "$1" \
    | paperkey --output-type raw \
    | base64 \
    | split -l 15 - secret-key-

KEY_FILES=$(find . -maxdepth 1 -name ${PREFIX}\*)
KEY_QR_FILES=$(find . -maxdepth 1 -name ${PREFIX}\*.qr.png)

for key in $KEY_FILES; do
    echo "encoding ${key}.qr.png from ${key}"
    qrencode --8bit --output ${key}.qr.png <${key}
    convert ${key}.qr.png \
        -background White -density 120 -pointsize 12 label:"${key}.qr.png" \
        -gravity Center -append ${key}.qr.png
    convert ${key}.qr.png \
        -background white -density 120 -pointsize 8 label:"${FINGERPRINT}" \
        +swap -gravity Center -append ${key}.qr.png
done

rm ${KEY_FILES}
