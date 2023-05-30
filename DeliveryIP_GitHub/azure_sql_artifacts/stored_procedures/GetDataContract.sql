SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[GetDataContract]
(
	@control_table_record_id int
)
AS
BEGIN
SELECT 
JSON_VALUE([DataContract], '$.DataContractID') [DataContractID] 
,JSON_VALUE([DataContract], '$.DatContractName') [DatContractName] 
,JSON_VALUE([DataContract], '$.DataOwnerDisplayName') [DataOwnerDisplayName]
,JSON_VALUE([DataContract], '$.DataOwnerCountry') [DataOwnerCountry]
,JSON_VALUE([DataContract], '$.DataOwnerEmail') [DataOwnerEmail]
,JSON_VALUE([DataContract], '$.DataSensitivity') [DataSensitivity]
,JSON_VALUE([DataContract], '$.FileName') [FileName]
,JSON_VALUE([DataContract], '$.DatasetType') [DatasetType]
FROM [dbo].[ControlTable]
WHERE [Id] = @control_table_record_id
RETURN
END
GO