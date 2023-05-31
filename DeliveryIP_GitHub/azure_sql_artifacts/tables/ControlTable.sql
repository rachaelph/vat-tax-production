CREATE TABLE [dbo].[ControlTable] (
    [Id]                           INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectSettings]         NVARCHAR (MAX) NULL,
    [SourceConnectionSettingsName] VARCHAR (MAX)  NULL,
    [CopySourceSettings]           NVARCHAR (MAX) NULL,
    [SinkObjectSettings]           NVARCHAR (MAX) NULL,
    [SinkConnectionSettingsName]   VARCHAR (MAX)  NULL,
    [CopySinkSettings]             NVARCHAR (MAX) NULL,
    [CopyActivitySettings]         NVARCHAR (MAX) NULL,
    [TopLevelPipelineName]         VARCHAR (MAX)  NULL,
    [TriggerName]                  NVARCHAR (MAX) NULL,
    [DataLoadingBehaviorSettings]  NVARCHAR (MAX) NULL,
    [TaskId]                       INT            NULL,
    [CopyEnabled]                  BIT            NULL,
    [DataContract]                 NVARCHAR (MAX) NULL,                 
    PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

DECLARE @controlTableRecords INTEGER 

SET @controlTableRecords = (SELECT COUNT(*) FROM [dbo].[ControlTable])

IF @controlTableRecords = 0
BEGIN
INSERT INTO [dbo].[ControlTable]
VALUES (
'{ "fileName": "%.zip", "folderPath": "%/%", "container": "landing" }'
,''
,''
,'{ "fileName": null, "folderPath": null, "container": "landing" }'
,''
,''
,''
,'PL_2_Process_Landed_Files_Step2'
,'TR_blobCreatedEvent'
,'{ "dataLoadingBehavior": "Unzip_Zip_Folder" }'
,0
,1
,''
)
END
