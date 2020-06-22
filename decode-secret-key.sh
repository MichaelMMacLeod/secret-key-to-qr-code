#!/usr/bin/sh

# Usage ./decode-secret-key.sh <pubring>
# Decodes a secret key from a series of QR codes (from a webcam) 
# <pubring> is a path to a public key file.
#  $ gpg --recv-keys <fingerprint> # fingerprint should be on the top of the QR code
#  $ gpg --export <fingerprint> > pubring.asc
# dependencies: zbarcam (zbar), paperkey, gpg

set -euo pipefail

if [ $# -eq 0 ]; then
   echo 'Please supply path to pubring as an argument'
   exit 1
fi

PREFIX=secret-key-
BASE64=secret.key.base64
KEY=secret.key

for q in {a..z}; do
    for r in {a..z}; do
        echo "Now scanning image ${q}${r}"
        zbarcam -1 --raw -Sbinary >> $BASE64
        read -r -p "More images to scan? [Y/n] " response
        case "${response}" in
            [nN][oO]|[nN])
                echo "$BASE64 written, attempting to decode and import key"
                base64 --decode $BASE64 | paperkey --pubring "$1" | gpg --import
                exit 0
                ;;
            *)
                ;;
        esac
    done
done
