#!/bin/bash
set -e

echo "Custom startup script: dumping filesystem usage..."
df -h /var/lib/mysql || true

# Start a background process to print df again in 20 seconds
(
  sleep 20
  echo "20 seconds filesystem usage snapshot:"
  df -h /var/lib/mysql || true
) &

#echo "Dumping effective mysqld config:"
#mysqld --verbose --help | tee /tmp/mysqld-config.txt || true

# Now run the original entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"
