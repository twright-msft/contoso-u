USE ContosoUniversity_DevSmall;

DELETE dbo.Person WHERE ID > 20;

-- Compact and shrink.
DBCC SHRINKFILE('ContosoUniversity', 1);
DBCC SHRINKFILE('ContosoUniversity_Log', 1);
