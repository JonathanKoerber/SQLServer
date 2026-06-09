# SQLServer
Run sql server 2019 

## What was wrong

The container image only started the SQL Server engine. The data-load script was copied into the image, but nothing ever executed it, so the AdventureWorks backup was never downloaded and the restore never ran.

The helper script also depended on tools that were not installed in the image:

- `curl` for downloading the backup
- `sqlcmd` for running `restore.sql`

## How to build and run

Build the image:

```bash
docker compose build
```

Start the stack:

```bash
docker compose up
```

SQL Server listens on port `1433`, so local tools should connect to `localhost,1433`.

## Troubleshooting

If the database does not appear, check the container logs first:

```bash
docker compose logs -f sqlserver
```

Look for these failures:

- SQL Server not ready yet when the restore script runs
- Missing `AdventureWorks2017.bak`
- Incorrect SA password in `docker-compose.yml`
- `sqlcmd` connection or certificate errors
- The backup file was being written to a non-writable path; it now lands in `/var/opt/mssql/data`

The restore script now waits for SQL Server readiness and uses the `MSSQL_SA_PASSWORD` value from the environment, so those failures should be much easier to diagnose.
