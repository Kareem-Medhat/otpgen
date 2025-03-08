#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

# Extract parameters using trurl
SECRET=$(trurl --url-file - --get '{query:secret}')
ALGORITHM=$(trurl --url-file - --get '{query:algorithm}')
DIGITS=$(trurl --url-file - --get '{query:digits}')

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
