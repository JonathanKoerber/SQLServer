#!/bin/bash

set -euo pipefail

sqlcmd_bin="/opt/mssql-tools18/bin/sqlcmd"
sa_password="${MSSQL_SA_PASSWORD:-${SA_PASSWORD:-}}"
backup_path="/var/opt/mssql/data/AdventureWorks2017.bak"

if [[ -z "${sa_password}" ]]; then
    echo "MSSQL_SA_PASSWORD or SA_PASSWORD must be set."
    exit 1
fi

echo "⏱️ Waiting for SQL Server engine to accept connections..."
for attempt in $(seq 1 60); do
    if "${sqlcmd_bin}" -C -S localhost -U sa -P "${sa_password}" -Q "SELECT 1" >/dev/null 2>&1; then
        break
    fi

    if [[ "${attempt}" -eq 60 ]]; then
        echo "SQL Server did not become ready in time."
        exit 1
    fi

    sleep 5
done

if [ -f "${backup_path}" ]; then
    echo "💾 AdventureWorksDW2017.bak already exists. Skipping download."
else
    echo "🌐 Downloading AdventureWorks2017.bak..."
    curl -L -o "${backup_path}" "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2017.bak"
fi

echo "⚙️ Running database restoration script..."
"${sqlcmd_bin}" -C -S localhost -U sa -P "${sa_password}" -i /usr/src/app/restore.sql