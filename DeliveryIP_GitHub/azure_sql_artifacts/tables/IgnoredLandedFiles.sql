SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IgnoredLandedFiles](
	[filename] [nvarchar](255) NULL,
	[condition] [nvarchar](255) NULL,
	[reason] [nvarchar](1000) NULL
) ON [PRIMARY]
GO

DECLARE @TableRecords INTEGER 

SET @TableRecords = (SELECT COUNT(*) FROM [dbo].[IgnoredLandedFiles])

IF @TableRecords = 0
BEGIN
INSERT INTO [dbo].[IgnoredLandedFiles]
VALUES (
'%.%'
,'NOT LIKE'
,'All processed files should have file extension in filename'
)
INSERT INTO [dbo].[IgnoredLandedFiles]
VALUES (
'%IGNORE%'
,'LIKE'
,'filename contains word "ignore"'
)
END