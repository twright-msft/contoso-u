-- Create small dev database.
USE master;

ALTER DATABASE ContosoUniversity_DevBig SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

EXEC sp_detach_db 'ContosoUniversity_DevBig';
GO


