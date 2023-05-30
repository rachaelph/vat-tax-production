CREATE OR ALTER PROCEDURE [dbo].[DatasetFirstLoadCheck]
(
	@control_table_record_id int
)
AS
BEGIN
DECLARE @firstLoad nvarchar(255) = 'Yes'
DECLARE @control_table_record_id_query int
set @control_table_record_id_query = (
	SELECT		min(control_table_record_id) [control_table_record_id]
	FROM 		[dbo].[IngestedLandingDataAudit]
	WHERE		ingestion_status = 'Processed'
	AND 		control_table_record_id = @control_table_record_id
)
IF 	@control_table_record_id = @control_table_record_id_query
BEGIN
SET @firstLoad = 'No'
END
SELECT	@firstLoad [firstLoad]
RETURN
END
GO