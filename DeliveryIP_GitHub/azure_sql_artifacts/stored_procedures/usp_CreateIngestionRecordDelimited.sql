CREATE OR ALTER PROCEDURE [dbo].[usp_CreateIngestionRecordDelimited]
(
    @body nvarchar(max)
)
AS 
BEGIN
DECLARE @currentdate DATETIME
SET @currentdate = GETDATE()

DECLARE @createddate DATETIME
SET @createddate = GETDATE()

DECLARE @FolderPath NVARCHAR(255) 
SET @FolderPath = JSON_VALUE(@body, '$.SourceFolderPath')
/*
DECLARE @TriggerName NVARCHAR(255) 
SET @TriggerName = 'TR_' + JSON_VALUE(@body, '$.DomainInput') + '_' + JSON_VALUE(@body, '$.DataSourceInput') + '_' + JSON_VALUE(@body, '$.DataSetInput')

DECLARE @dataContract NVARCHAR(MAX)
SET @dataContract = CONCAT('{', '"ItemID": "', JSON_VALUE(@body, '$.ItemID'), '"',
				    ',"DataContractID": "', JSON_VALUE(@body, '$.DataContractID'), '"',
                    ',"DataContractName": "' , JSON_VALUE(@body, '$.DataContractName') , '"',
                    ',"DataOwnerDisplayName": "' , JSON_VALUE(@body, '$.DataOwnerDisplayName') , '"',
                    ',"DataOwnerEmail": "' , JSON_VALUE(@body, '$.DataOwnerEmail') , '"',
                    ',"DataSensitivity": "' , JSON_VALUE(@body, '$.DataSensitivity') , '"',
					',"DataSourceType": "' , JSON_VALUE(@body, '$.SourceType'), '"',
                    ',"AADObjectID": "', JSON_VALUE(@body, '$.AADObjectID'), '"',
                    ',"FileName": "', JSON_VALUE(@body, '$.FileName'), '"',
                    ',"DelimiterType": "', JSON_VALUE(@body, '$.DelimiterType'), '"',
                    ',"IngestionFileType": "' , JSON_VALUE(@body, '$.IngestionFileType'), '"',
					',"BusinessProblem": "' , JSON_VALUE(@body, '$.BusinessProblem'), '"',
					',"IPDescription": "' , JSON_VALUE(@body, '$.IPDescription'), '"',
					',"BusinessValue": "' , JSON_VALUE(@body, '$.BusinessValue'), '"',
					',"ArchitectureResponse": "' , JSON_VALUE(@body, '$.ArchitectureResponse'), '"',
					',"TimeStamp": "' , JSON_VALUE(@body, '$.TimeStamp'), '"'
                    )
*/
INSERT INTO [dbo].[ControlTable] (
	 SourceObjectSettings
	,SourceConnectionSettingsName
	,CopySourceSettings
	,SinkObjectSettings
	,SinkConnectionSettingsName
	,CopySinkSettings
	,CopyActivitySettings
	,TopLevelPipelineName
	,TriggerName
	,DataLoadingBehaviorSettings
	,TaskId
	,CopyEnabled
	,DataContract 
)
VALUES (
--SourceObjectSettings
'{ "fileName": "' + JSON_VALUE(@body, '$.fileName') + '", 
   "folderPath": "' + JSON_VALUE(@body, '$.SourceFolderPath') + '", 
   "container": "landing"
}'
--SourceConnectionSettingsName
,''
--CopySourceSettings
,'{ "fileType": "' + JSON_VALUE(@body, '$.fileType') + '",
    "delimiter": "' + JSON_VALUE(@body, '$.columnDelimiter') + '",
    "compression": "None"
}'
--SinkObjectSettings
,'{"fileName": "' + JSON_VALUE(@body, '$.fileName') + '",
	"folderPath": "' + JSON_VALUE(@body, '$.dynamicSinkPath') + '", 
   "container": "raw"
   }'
--SinkConnectionSettingsName
,''
--CopySinkSettings
,''
--CopyActivitySettings
,''
--TopLevelPipelineName
,'PL_2_Process_Landed_Files_Step2'
--TriggerName
,'[TR_blobCreatedEvent]'
--DataLoadingBehaviorSettings
,'{ "dataLoadingBehavior": "Copy_to_Raw", 
    "loadType": "full" }'
--TaskId
,0
--CopyEnabled
,1
--DataContract
,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'"}'
)
END
GO