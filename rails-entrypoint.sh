#!/bin/bash
set -e

exec bin/delayed_job start -n 3 &
exec rake assets:precompile &
exec unicorn -c config/unicorn.rb -p 3000

exec "$@"
