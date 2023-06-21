/****** Object:  StoredProcedure [dbo].[schemaDynamic]    Script Date: 5/19/2023 3:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[schemaDynamic]
@fileType NVARCHAR(max), @filePath NVARCHAR (max),@currentPage NVARCHAR(max)
AS
BEGIN
DECLARE @SQLStr nvarchar(max)
DECLARE @storageName nvarchar(max)
IF @currentPage = 'Data Contract New Add'
    SET @storageName = 'INSERTLANDINGSTORAGENAME'
ELSE IF @currentPage = 'Mapping Shared Service Source'
    SET @storageName = 'INSERTADLS2STORAGENAME'
IF @fileType = 'PARQUET'
    BEGIN
SET @SQLStr = 
            N'SELECT TOP 1 *                                                                                   '+
            N'FROM OPENROWSET(BULK ''https://' + @storageName +'.dfs.core.windows.net'+ @filePath +''',          '+
            N'FORMAT = '''+ @fileType +'''                                                                      '+
            N') AS [result]';
    END
ELSE IF @fileType = 'CSV'
    BEGIN
    SET @SQLStr = CAST(
            N'SELECT TOP 1 *                                                                                   '+
            N'FROM OPENROWSET(BULK ''https://' + @storageName +'.dfs.core.windows.net'+ @filePath +''',          '+
            N'FORMAT = '''+ @fileType +''',                                                                     '+
            N'HEADER_ROW = true,                                                                                '+
            N'PARSER_VERSION = ''2.0''                                                                          '+
            N') AS [result]'AS NVARCHAR(MAX));
    END
PRINT @SQLStr
EXEC sp_describe_first_result_set @tsql = @SQLStr
END;
GO

