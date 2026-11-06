#!/bin/bash
set -e

# Fix writable directories needed at runtime
mkdir -p /app/public/data/upload
mkdir -p /app/public/uploads

chown -R app:app /app/public/data
chown -R app:app /app/public/uploads
chown app:app /app/public

chmod 755 /app/public
chmod 755 /app/public/data
chmod 755 /app/public/data/upload
chmod 755 /app/public/uploads

# Start 4 workers in the background as app
for i in 1 2 3 4; do
  su -s /bin/bash app -c "bundle exec rake jobs:work --trace" &
done

# Start Puma in the foreground as app
exec su -s /bin/bash app -c "bundle exec puma -C /docker/config/puma.rb"
