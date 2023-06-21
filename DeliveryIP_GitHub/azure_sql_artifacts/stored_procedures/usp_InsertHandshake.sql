/****** Object:  StoredProcedure [dbo].[InsertHandshake]    Script Date: 5/15/2023 4:39:01 PM ******/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertHandshake]
    @jsondata NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO [dbo].[Handshake] (
        [DataSourceName],
        [Publisher],
        [CreatedBy],
        [CreatedByDate],
        [EditedBy],
        [EditedByDate],
        [Active],
        [ActiveDate],
        [InactiveDate],
        [DataAssetTechnicalInformation],
        [SourceTechnicalInformation],
        [ConnectionType],
        [IngestionSchedule],
        [DataContractID]
    )
    SELECT
        [DataSourceName],
        [PublisherName] AS [Publisher],
        [CreatedBy],
        GETDATE() AS [CreatedByDate],
        NULL AS [EditedBy],
        NULL AS [EditedByDate],
        1 AS [Active],
        GETDATE() AS [ActiveDate],
        NULL AS [InactiveDate],
        [DataAssetTechnicalInformation] AS [DataAssetTechnicalInformation],
        [SourceTechnicalInformation] AS [SourceTechnicalInformation],
        [ConnectionType],
        [IngestionSchedule] AS [IngestionSchedule],
        [DataContractID]
    FROM OPENJSON(@jsonData)
    WITH (
        [DataSourceName] VARCHAR(100),
        [PublisherName] VARCHAR(100),
        [CreatedBy] VARCHAR(100),
        [DataAssetTechnicalInformation] NVARCHAR(MAX) AS JSON,
		[SourceTechnicalInformation] NVARCHAR(MAX) AS JSON,
        [ConnectionType] VARCHAR(100),
        [IngestionSchedule] NVARCHAR(MAX) AS JSON,
        [DataContractID] VARCHAR(36)
    )
END