#!/bin/bash

set -euo pipefail

/opt/mssql/bin/sqlservr &
sqlserver_pid=$!

trap 'kill "${sqlserver_pid}"' SIGTERM SIGINT

/usr/src/app/import-data.sh

wait "${sqlserver_pid}"