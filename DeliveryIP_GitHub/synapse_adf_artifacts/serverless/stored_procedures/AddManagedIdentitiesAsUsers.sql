SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[AddManagedIdentitiesAsUsers]
AS
BEGIN

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_logicapp_name')
  BEGIN
    CREATE LOGIN [insert_logicapp_name] FROM EXTERNAL PROVIDER;

    CREATE USER [insert_logicapp_name] FROM EXTERNAL PROVIDER;
  END

GRANT EXECUTE ON OBJECT::[dbo].[schemaDynamic]  
    TO [insert_logicapp_name]; 

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_synapse_name')
  BEGIN
    CREATE USER [insert_synapse_name] FOR LOGIN [insert_synapse_name];
  END

ALTER ROLE db_owner ADD MEMBER [insert_synapse_name]; 
ALTER ROLE db_owner ADD MEMBER [insert_logicapp_name];


END
GO
