#!/bin/sh
set -e

# --------------------------------------------------
# Configuration
# --------------------------------------------------
USE_SSL="${USE_SSL:-false}"

HOST_TEMPLATE_DIR="/docker/nginx/templates"
NGX_TEMPLATE_DIR="/etc/nginx/templates"
DEST_TEMPLATE="/etc/nginx/conf.d/default.conf"

SSL_TEMPLATE="$HOST_TEMPLATE_DIR/nginx.ssl.conf.template"
NON_SSL_TEMPLATE="$HOST_TEMPLATE_DIR/nginx.conf.template"

echo "[Entrypoint] USE_SSL=$USE_SSL"

# --------------------------------------------------
# Select template
# --------------------------------------------------
if [ "$USE_SSL" = "true" ]; then
  SELECTED="$SSL_TEMPLATE"
  echo "[Entrypoint] → Using SSL template"
else
  SELECTED="$NON_SSL_TEMPLATE"
  echo "[Entrypoint] → Using non-SSL template"
fi

# Sanity check
if [ ! -f "$SELECTED" ]; then
  echo "ERROR: Selected template not found: $SELECTED"
  exit 1
fi

# --------------------------------------------------
# Install ONLY the chosen template for envsubst
# --------------------------------------------------
mkdir -p "$NGX_TEMPLATE_DIR"
cp "$SELECTED" "$DEST_TEMPLATE"

# # Remove any other *.template that might already be there
# find "$NGX_TEMPLATE_DIR" -type f -name '*.template' ! -name 'default.conf.template' -delete

echo "[Entrypoint] Installed template → $DEST_TEMPLATE"
# Let the main entry-point continue (envsubst will process default.conf.template)