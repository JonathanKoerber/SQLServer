USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AdventureWorks2017')
BEGIN
    PRINT 'AdventureWorks2017 not found. Proceeding with database restore...';
    RESTORE DATABASE AdventureWorks2017
    FROM DISK = '/var/opt/mssql/data/AdventureWorks2017.bak'
    WITH 
        MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2017.mdf',
        MOVE 'AdventureWorks2017_log' TO '/var/opt/mssql/data/AdventureWorks2017_log.ldf',
        REPLACE,
        STATS = 10;
END
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Student')
BEGIN
    CREATE LOGIN Student WITH PASSWORD = 'SecurePassword123!';
    ALTER SERVER ROLE sysadmin ADD MEMBER Student;
END
GO