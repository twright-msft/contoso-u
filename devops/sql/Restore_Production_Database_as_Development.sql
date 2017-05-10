RESTORE DATABASE ContosoUniversity_DevBig FROM DISK = '/azurebackups/ContosoUniversity_Production.bak' WITH STATS = 1, MOVE 'ContosoUniversity' TO '/var/opt/mssql/data/ContosoUniversityBig.mdf', MOVE 'ContosoUniversity_log' TO '/var/opt/mssql/data/ContosoUniversityBig.ldf';

