#!/bin/bash
echo "SECRET_KEY_BASE=$(LC_CTYPE=C < /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-128};echo;)" > .env-prod
