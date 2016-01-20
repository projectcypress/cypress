#!/bin/bash
set -e

exec rake jobs:work &
exec rake assets:precompile &
exec rails s -b 0.0.0.0

exec "$@"
