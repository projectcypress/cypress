#!/bin/bash
set -e

cd /home/app/cypress
exec /sbin/setuser app bundle exec unicorn -c config/unicorn.rb -p 3000 >>log/unicorn.log 2>&1
