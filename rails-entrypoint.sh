#!/bin/bash
set -e

exec bin/delayed_job start -n 3 &
exec rake assets:precompile &
exec rails s -b 0.0.0.0

exec "$@"
