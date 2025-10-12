#!/usr/bin/env bash
set -euo pipefail

# Wait for mongod processes to accept connections
function wait_mongo() {
  local host=$1; local port=$2
  echo "Waiting for ${host}:${port} ..."
  until mongosh --quiet --host "${host}" --port "${port}" --eval 'db.runCommand({ ping: 1 })' >/dev/null 2>&1; do
    sleep 2
  done
  echo "${host}:${port} is up"
}

sleep 5

wait_mongo mongo1 27017 || true
wait_mongo mongo2 27018 || true
wait_mongo mongo3 27019 || true

cfg='{ _id: "rs0", members: [
  { _id: 0, host: "mongo1:27017" },
  { _id: 1, host: "mongo2:27018" },
  { _id: 2, host: "mongo3:27019" }
]}'

echo "Initiating replicaset..."

set +e
mongosh --host mongo1 --port 27017 --eval "rs.initiate(${cfg})" || true
set -e

mongosh --host mongo1 --port 27017 --eval 'rs.status()'

# Create app database and a collection
mongosh --host mongo1 --port 27017 <<'EOF'
use resistance
db.createCollection('markers')
EOF

echo "ReplicaSet initialized."
