/****** Object:  StoredProcedure [dbo].[usp_PackagePayloadConfigurator]    Script Date: 5/19/2023 10:44:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[usp_PackagePayloadConfigurator]

@ContractID VARCHAR(36)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cols AS NVARCHAR(MAX);
    DECLARE @cols2 AS NVARCHAR(MAX);
    DECLARE @query AS NVARCHAR(MAX);

    -- Get the list of keys from the JSON object
    WITH cte1 AS (
        SELECT hs.DataContractID,
               hs.ID,
               hs.DataSourceName,
               hs.ConnectionType,
               j.[key],
               MAX(j.[value]) AS [value]
        FROM dbo.handshake AS hs
        CROSS APPLY OPENJSON(hs.DataAssetTechnicalInformation, '$[0]') AS j
        WHERE hs.DataContractID = @ContractID
        GROUP BY hs.DataContractID, hs.ID, hs.DataSourceName, hs.ConnectionType, j.[key]
    ),
    cte2 AS (
        SELECT hs.DataContractID,
               hs.ID,
               hs.DataSourceName,
               hs.ConnectionType,
               j.[key],
               MAX(j.[value]) AS [value]
        FROM dbo.handshake AS hs
        CROSS APPLY OPENJSON(hs.IngestionSchedule, '$[0]') AS j
        WHERE hs.DataContractID = @ContractID
        GROUP BY hs.DataContractID, hs.ID, hs.DataSourceName, hs.ConnectionType, j.[key]
    ),
    cte3 AS (
        SELECT *
        FROM cte1
        UNION ALL
        SELECT *
        FROM cte2
    )
    SELECT @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME([key]) + ' AS ' + QUOTENAME([key])
                          FROM cte3
                          FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''),
           @cols2 = STUFF((SELECT DISTINCT ',' + QUOTENAME([key])
                           FROM cte3
                           FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

    -- Construct a dynamic SQL query to pivot the data and join with other tables
    SET @query = N'WITH cte1 AS (
                      SELECT hs.DataContractID,
                             hs.ID,
                             hs.DataSourceName,
                             hs.ConnectionType,
                             j.[key],
                             MAX(j.[value]) AS [value]
                      FROM dbo.handshake AS hs
                      CROSS APPLY OPENJSON(hs.DataAssetTechnicalInformation, ''$[0]'') AS j
                      WHERE hs.DataContractID = @ContractID
                      GROUP BY hs.DataContractID, hs.ID, hs.DataSourceName, hs.ConnectionType, j.[key]
                  ),
                  cte2 AS (
                      SELECT hs.DataContractID,
                             hs.ID,
                             hs.DataSourceName,
                             hs.ConnectionType,
                             j.[key],
                             MAX(j.[value]) AS [value]
                      FROM dbo.handshake AS hs
                      CROSS APPLY OPENJSON(hs.IngestionSchedule, ''$[0]'') AS j
                      WHERE hs.DataContractID = @ContractID
                      GROUP BY hs.DataContractID, hs.ID, hs.DataSourceName, hs.ConnectionType, j.[key]
                  ),
                  cte3 AS (
                      SELECT *
                      FROM cte1
                      UNION ALL
                      SELECT *
                      FROM cte2
                  )
                  SELECT dc.ContractID,
                         dc.SourceSystem,
                         dc.PublisherName,
                         dc.Format,
                         dc.DataClassificationLevel,
                         dc.Pattern,' + @cols + N'
                  FROM dbo.DataContract AS dc
                  JOIN (
                      SELECT DataContractID,' + @cols2 + N'
                      FROM cte3
                      PIVOT
                      (
                          MAX([value])
                          FOR [key] IN (' + @cols2 + N')
                      ) AS pvt
                  ) AS jd
                  ON dc.ContractID = jd.DataContractID
                  FOR JSON PATH';

    -- Execute the dynamic SQL query with the ContractID parameter value and return the results as a flat JSON object
    EXEC sp_executesql @query, N'@ContractID VARCHAR(36)', @ContractID;
END;
GO

