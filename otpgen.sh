#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

if [ -n "$1" ]; then
    URI="$1"
else
    URI=$(cat /dev/stdin)
    if [ -z "$URI" ]; then
        echo "Usage: $0 'otpclient://totp/Account?secret=SECRET&algorithm=SHA256&digits=8'"
        exit 1
    fi
fi


# Extract parameters using trurl
SECRET=$(trurl --url "$URI" --get '{query:secret}')
ALGORITHM=$(trurl --url "$URI" --get '{query:algorithm}')
DIGITS=$(trurl --url "$URI" --get '{query:digits}')

# Default values if parameters are missing
ALGORITHM=${ALGORITHM:-SHA1}  # Default: SHA1
DIGITS=${DIGITS:-6}           # Default: 6 digits

# Convert algorithm to oathtool format
case "$ALGORITHM" in
    SHA1)   ALGO_ARG="--totp" ;;
    SHA256) ALGO_ARG="--totp=SHA256" ;;
    SHA512) ALGO_ARG="--totp=SHA512" ;;
    *)      echo "Unsupported algorithm: $ALGORITHM"; exit 1 ;;
esac

# Generate OTP
oathtool $ALGO_ARG -d "$DIGITS" -b "$SECRET"
