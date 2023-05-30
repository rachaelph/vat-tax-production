SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[FIFO_Status]
(
	@control_table_record_id int,
	@logging_table_record_id int
)
AS
BEGIN

DECLARE @continue_processing nvarchar(255) = 'No'

DECLARE @first_record datetime2
DECLARE @current_record datetime2

set @first_record = (
	SELECT		min(event_start_datetime_utc) [first]
	FROM 		[dbo].[IngestedLandingDataAudit]
	WHERE		ingestion_status = 'Started'
	AND			DATEDIFF(hour, event_start_datetime_utc, GETUTCDATE()) <= 2
	AND 		control_table_record_id = @control_table_record_id
	GROUP BY	control_table_record_id
)

set @current_record = (
	SELECT		event_start_datetime_utc [current]
	FROM 		[dbo].[IngestedLandingDataAudit]
	WHERE		id = @logging_table_record_id
)

IF 	@first_record = @current_record
BEGIN
SET @continue_processing = 'Yes'
END

SELECT	@continue_processing [continue_processing]
RETURN

END
GO