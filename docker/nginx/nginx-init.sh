#!/bin/bash
set -e

USE_SSL=${USE_SSL:-false}
SSL_CERT_PATH=/docker/nginx/ssl-certs/cert.txt
SSL_KEY_PATH=/docker/nginx/ssl-certs/key.txt

# Optional: print variables for debugging
echo "[Entrypoint] USE_SSL=${USE_SSL}"

# 1. Check if SSL is enabled
if [ "$USE_SSL" != "true" ]; then
  echo "[Entrypoint] USE_SSL is not set to 'true'. Skipping SSL config."
  # copy the non-ssl config template to default nginx configuration
  cp /docker/nginx/templates/nginx.conf.template /etc/nginx/sites-enabled/default
  exit 0
fi

echo "[Entrypoint] SSL is enabled. Validating certificate paths..."

# 2. Check if SSL_CERT_PATH and SSL_KEY_PATH are set
if [ -z "$SSL_CERT_PATH" ]; then
  echo "ERROR: SSL_CERT_PATH is not set"
  exit 1
fi

if [ -z "$SSL_KEY_PATH" ]; then
  echo "ERROR: SSL_KEY_PATH is not set"
  exit 1
fi

# 3. Check if the files actually exist
if [ ! -f "$SSL_CERT_PATH" ]; then
  echo "ERROR: SSL certificate file not found at $SSL_CERT_PATH"
  exit 1
fi

if [ ! -f "$SSL_KEY_PATH" ]; then
  echo "ERROR: SSL key file not found at $SSL_KEY_PATH"
  exit 1
fi

echo "[Entrypoint] SSL cert and key found."

# copy the ssl config template to default nginx configuration
cp /docker/nginx/templates/nginx.ssl.conf.template /etc/nginx/sites-enabled/default
