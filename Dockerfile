FROM mcr.microsoft.com/mssql/server:2019-latest

# Switch to root to configure system files and permissions
USER root

ENV DEBIAN_FRONTEND=noninteractive

# Create application directories
RUN mkdir -p /usr/src/app /var/opt/mssql/backup

# Install the tools required to download the backup and run initialization SQL.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends curl gnupg2 apt-transport-https ca-certificates unixodbc-dev \
	&& curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl -fsSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list -o /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& ACCEPT_EULA=Y apt-get install -y --no-install-recommends mssql-tools18 \
	&& rm -rf /var/lib/apt/lists/*

# Copy initialization scripts into the image layer
COPY import-data.sh /usr/src/app/import-data.sh
COPY restore.sql /usr/src/app/restore.sql
COPY startup.sh /usr/src/app/startup.sh

# Set safe executable permissions for the shell script
RUN chmod +x /usr/src/app/import-data.sh /usr/src/app/startup.sh

# Switch back to the default mssql user for security compliance
USER mssql

# Run the startup wrapper so the restore script actually executes.
ENTRYPOINT [ "/usr/src/app/startup.sh" ]