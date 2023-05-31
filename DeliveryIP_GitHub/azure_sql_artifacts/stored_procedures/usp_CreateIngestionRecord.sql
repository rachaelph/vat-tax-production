CREATE OR ALTER PROCEDURE [dbo].[usp_CreateIngestionRecord]
(
     @SourceFolderPath NVARCHAR(255)
    ,@SourceContainerName NVARCHAR(50)
    ,@SinkFolderPath NVARCHAR(255)
    ,@SinkFileSystem NVARCHAR(50)
	,@FileType NVARCHAR(20)
    ,@DataLoadType NVARCHAR(25) = 'FullLoad'
    ,@SourceCompressionType NVARCHAR(50) = NULL
    ,@SinkCompressionType NVARCHAR(50) = NULL
	,@TriggerName NVARCHAR(50) = '' --Empty string incase no trigger required
	,@DataAnalyst NVARCHAR(255)
    ,@DataOwner NVARCHAR(255)
    ,@Filename NVARCHAR(255)
    ,@DataSourceType NVARCHAR(255)

)
AS
BEGIN
DECLARE @query AS NVARCHAR(MAX) = 'DECLARE @MainControlMetadata NVARCHAR(MAX)  = N''[
    {
        "SourceObjectSettings": {
            "fileName": "'+ @FileType +'",
			"folderPath": "' +  @SourceFolderPath +'",
             "container": "' + @SourceContainerName +'"
        },
        "SinkObjectSettings": {
            "fileName": null,
            "folderPath": "' + @SinkFolderPath +'",
            "fileSystem": "' + @SinkFileSystem + '"
        },
        "CopySourceSettings": {
            "recursive": true,
            "wildcardFileName": "*"
        },
        "CopyActivitySettings": {
            "translator": null,
            "enableSkipIncompatibleRow": false,
            "skipErrorFile": {
                "fileMissing": true,
                "dataInconsistency": false
            }
        },
        "TopLevelPipelineName": "PL_2_Process_Landed_Files",
        "TriggerName": "TR_blobCreatedEvent",
        "DataLoadingBehaviorSettings": {
            "dataLoadingBehavior": "FullLoad"
        },
        "TaskId": 0,
        "CopyEnabled": 1,
		"DataContract": {
			"DataAnalyst": "' + @DataAnalyst + '",
			"DataOwner": "' + @DataOwner + '",
			"FileName": "' + @Filename + '",
			"DatasetType": "' + @DataSourceType + '",
		}

    }
]'';
INSERT INTO [dbo].[ControlTable] (
    [SourceObjectSettings],
    [SourceConnectionSettingsName],
    [CopySourceSettings],
    [SinkObjectSettings],
    [SinkConnectionSettingsName],
    [CopySinkSettings],
    [CopyActivitySettings],
    [TopLevelPipelineName],
    [TriggerName],
    [DataLoadingBehaviorSettings],
    [TaskId],
    [CopyEnabled],
	[DataContract])
SELECT * FROM OPENJSON(@MainControlMetadata)
    WITH ([SourceObjectSettings] [nvarchar](max) AS JSON,
    [SourceConnectionSettingsName] [varchar](max),
    [CopySourceSettings] [nvarchar](max) AS JSON,
    [SinkObjectSettings] [nvarchar](max) AS JSON,
    [SinkConnectionSettingsName] [varchar](max),
    [CopySinkSettings] [nvarchar](max) AS JSON,
    [CopyActivitySettings] [nvarchar](max) AS JSON,
    [TopLevelPipelineName] [varchar](max),
    [TriggerName] [nvarchar](max) AS JSON,
    [DataLoadingBehaviorSettings] [nvarchar](max) AS JSON,
    [TaskId] [int],
    [CopyEnabled] [bit],
	[DataContract [nvarchar](max) AS JSON)
	)'


EXEC sp_executesql @query,
    N'  @SourceFolderPath NVARCHAR(255),
		@SourceContainerName NVARCHAR(50),
        @SinkFolderPath NVARCHAR(255),
        @SinkFileSystem NVARCHAR(50),
		@FileType NVARCHAR(100),
		@DataAnalyst NVARCHAR(255),
    	@DataOwner NVARCHAR(255),
    	@Filename NVARCHAR(255),
    	@DataSourceType NVARCHAR(255)',
		@SourceFolderPath,
        @SourceContainerName,
        @SinkFolderPath,
        @SinkFileSystem,
		@FileType,
		@DataAnalyst,
    	@DataOwner,
    	@Filename,
    	@DataSourceType
END
GO