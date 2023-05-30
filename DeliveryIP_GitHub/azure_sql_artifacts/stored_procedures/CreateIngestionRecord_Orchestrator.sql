/****** Object:  StoredProcedure [dbo].[CreateIngestionRecord_Orchestrator]    Script Date: 5/19/2023 10:47:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[CreateIngestionRecord_Orchestrator]
(
	@body nvarchar(max)
)
AS
BEGIN
DECLARE @sourceType NVARCHAR(255) = JSON_VALUE(@body, '$.SourceType')
IF @sourceType = 'Excel'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordExcel] @body = @body
END

IF @sourceType = 'Delimited Text'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordDelimited] @body = @body
END

IF @sourceType = 'Open Contracting'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordOpenData] @body = @body
END

IF @sourceType = 'Open Ownership'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordOpenData] @body = @body
END

IF @sourceType = 'Open Sanctions'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordOpenData] @body = @body
END

IF @sourceType = 'JSON'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordJSON] @body = @body
END

IF @sourceType = 'Delta'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordDelta] @body = @body
END

IF @sourceType = 'Parquet'
BEGIN
EXEC [dbo].[usp_CreateIngestionRecordParquet] @body = @body
END

END
GO

