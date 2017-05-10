-- Create small dev database.
USE master;

EXEC sp_attach_db 'ContosoUniversity_DevBig', '/var/opt/mssql/data/ContosoUniversityBig.mdf', '/var/opt/mssql/data/ContosoUniversityBig.ldf';
EXEC sp_attach_db 'ContosoUniversity_DevSmall', '/var/opt/mssql/data/ContosoUniversitySmall.mdf', '/var/opt/mssql/data/ContosoUniversitySmall.ldf';
GO


