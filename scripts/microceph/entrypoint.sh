#!/bin/bash
set -e

# Start snapd
/usr/lib/snapd/snapd &

# Wait for snapd to be ready
until snap list > /dev/null 2>&1; do
  echo "Waiting for snapd to be ready..."
  sleep 1
done

# Execute the command
exec "$@"
