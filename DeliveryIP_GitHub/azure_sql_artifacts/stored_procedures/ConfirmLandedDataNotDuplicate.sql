SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[ConfirmLandedDataNotDuplicate]
(
	@filename NVARCHAR(255),
	@md5hash NVARCHAR(1000),
	@destination_path_prefix NVARCHAR(1000)
)
AS
BEGIN

DECLARE @matched_rows int
DECLARE @file_status varchar(1000) = 'Not Duplicate'

--Does landed file's MD5 hash match an already ingested file's MD5 hsah?
--lookup is based on the logging table
--do not match on empty string for MD5 hash
SET @matched_rows = (SELECT COUNT(*)
FROM dbo.IngestedLandingDataAudit
WHERE ([source_file_md5_hash] = @md5hash
AND '' != @md5hash)
AND [destination_folderpath] LIKE @destination_path_prefix
)

IF (cast(@matched_rows as int) > 0)
BEGIN;
	SET @file_status = 'Duplicate';
END;

-- return value for ADF pipeline to use in downstream logic
Select @file_status AS 'file_status'

END
GO
