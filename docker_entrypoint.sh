#!/bin/bash
set -e

# Start 4 workers in the background
for i in 1 2 3 4; do
  bundle exec rake jobs:work --trace &
done

# Start Puma in the foreground
exec bundle exec puma -C /docker/config/puma.rb