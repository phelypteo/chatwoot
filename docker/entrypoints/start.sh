#!/bin/sh

set -x

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

# Let DATABASE_URL env take presedence over individual connection params.
$(docker/entrypoints/helpers/pg_database_url.rb)
PG_READY="pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME"

until $PG_READY
do
  sleep 2;
done

echo "Database ready to accept connections."

bundle check

# CHATWOOT_ROLE=sidekiq  → starts Sidekiq worker
# CHATWOOT_ROLE=app (or unset) → starts Rails server
if [ "$CHATWOOT_ROLE" = "sidekiq" ]; then
  echo "Starting Sidekiq..."
  exec bundle exec sidekiq -C config/sidekiq.yml
else
  echo "Starting Rails server..."
  exec bundle exec rails s -p 3000 -b 0.0.0.0
fi
