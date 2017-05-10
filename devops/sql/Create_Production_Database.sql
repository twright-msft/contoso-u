USE master;
GO

IF(OBJECT_ID('numbers') IS NULL)
	SELECT TOP(1000000)
		ROW_NUMBER() OVER (ORDER BY (SELECT NUll)) AS number 
	INTO numbers
	FROM sys.messages AS m1
	CROSS JOIN sys.messages AS m2;
GO

ALTER DATABASE ContosoUniversity MODIFY FILE (NAME = 'ContosoUniversity', FILEGROWTH = 20MB);
ALTER DATABASE ContosoUniversity MODIFY FILE (NAME = 'ContosoUniversity_log', FILEGROWTH = 20MB);
ALTER DATABASE ContosoUniversity SET RECOVERY SIMPLE;
GO

USE ContosoUniversity;
GO

select top 20 * from dbo.Person order by ID asc


WITH names AS (
	SELECT FirstName AS name FROM dbo.Person
	UNION
	SELECT LastName FROM dbo.Person
), types AS (
	SELECT type FROM (VALUES('Student'),('Student'),('Student'),('Student'),('Student'),('Student'),('Instructor')) AS a(type)
), people AS (
	SELECT
		(SELECT TOP(1) na.name FROM names AS na WHERE n.number > LEN(na.name) - 10000 ORDER BY NEWID()) AS FirstName
		,(SELECT TOP(1) na.name FROM names AS na WHERE n.number > LEN(na.name) - 10000 ORDER BY NEWID()) AS LastName
		,(SELECT TOP(1) t.type FROM types AS t WHERE n.number > LEN(t.type) - 10000 ORDER BY NEWID()) AS Discriminator
	FROM master.dbo.numbers AS n
	WHERE number <= 1000000
)
INSERT dbo.Person (FirstName, LastName, Discriminator, HireDate, EnrollmentDate)
	SELECT
		FirstName
		,LastName
		,Discriminator
		,CASE Discriminator 
			WHEN 'Instructor' THEN DATEADD(dd, -ABS(CAST(CAST(NEWID() AS BINARY(2)) AS SMALLINT)), GETDATE()) 
			ELSE NULL
		END AS HireDate
		,CASE Discriminator 
			WHEN 'Student' THEN DATEADD(dd, -CAST(CAST(NEWID() AS BINARY(1)) AS TINYINT), GETDATE()) 
			ELSE NULL
		END AS EnrollmentDate
	FROM people;
GO

-- Compact and shrink.
DBCC SHRINKFILE('ContosoUniversity', 1);
DBCC SHRINKFILE('ContosoUniversity_log', 1);
GO

--sp_helpdb 'ContosoUniversity'

