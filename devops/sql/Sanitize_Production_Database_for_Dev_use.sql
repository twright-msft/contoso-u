USE ContosoUniversity_DevBig;

-- Sanitize production data for development use.
-- Use Norwegian encryption.
UPDATE dbo.Person SET
	FirstName = REVERSE(FirstName)
	,LastName = REVERSE(LastName);

