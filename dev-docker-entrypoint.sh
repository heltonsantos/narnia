#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bundle check || bundle install

bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:migrate:reset
bundle exec rake db:seed

exec "$@"
