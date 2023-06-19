SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[DetermineFileVersionForControlFile]
(
	@prior_control_file_output NVARCHAR(max),
	@current_file_structure NVARCHAR(max)
)
AS
BEGIN

DECLARE @file_version int

DECLARE @new_existing_structure varchar(255) = 'existing'

--determine control file version of landed data
--using structure field

--only do comparison if previous control files exist
IF @prior_control_file_output != '[]'
BEGIN
SET @file_version = (
SELECT VersionNumber
FROM OPENJSON(@prior_control_file_output)
	WITH (
		VersionNumber INT,
		Structure NVARCHAR(max)
	)
WHERE Structure = @current_file_structure
)
END
--if no previous control files exist, this must be version 1
-- as it is the first file landed for specific dataset
ELSE
BEGIN
SET @file_version = 1
SET @new_existing_structure = 'new'
END

-- if file schema/structure doesn't match on any existing control file
-- and prior landed data exists
-- data has a new schema and needs a new version
-- make the control file version 1 greater than the latest version
IF @file_version IS NULL
BEGIN
SET @file_version = (
SELECT MAX(VersionNumber) + 1
FROM OPENJSON(@prior_control_file_output)
	WITH (
		VersionNumber INT,
		Structure NVARCHAR(max)
	)
)
SET @new_existing_structure = 'new'
END

SELECT @file_version [VersionNumber], @new_existing_structure [Flag_New_Existing]
RETURN

END
GO
