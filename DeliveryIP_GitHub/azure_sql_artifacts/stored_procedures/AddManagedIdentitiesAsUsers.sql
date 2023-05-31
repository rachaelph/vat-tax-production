SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[AddManagedIdentitiesAsUsers]
AS
BEGIN

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_datafactory_or_synapse_name')
  BEGIN
    CREATE USER [insert_datafactory_or_synapse_name] FROM EXTERNAL PROVIDER;
  END

GRANT SELECT ON OBJECT::[dbo].[ControlTable] 
    TO [insert_datafactory_or_synapse_name]; 

GRANT EXECUTE ON OBJECT::[dbo].[ConfirmLandedDataNotDuplicate] 
    TO [insert_datafactory_or_synapse_name];  

GRANT EXECUTE ON OBJECT::[dbo].[DetermineFileVersionForControlFile]  
    TO [insert_datafactory_or_synapse_name];  

GRANT EXECUTE ON OBJECT::[dbo].[LogDataLandedInLandingZone]  
    TO [insert_datafactory_or_synapse_name];  

GRANT EXECUTE ON OBJECT::[dbo].[GetControlTableRecord]  
    TO [insert_datafactory_or_synapse_name];  

GRANT EXECUTE ON OBJECT::[dbo].[FIFO_Status] 
    TO [insert_datafactory_or_synapse_name];  

GRANT EXECUTE ON OBJECT::[dbo].[DatasetFirstLoadCheck] 
    TO [insert_datafactory_or_synapse_name];  

GRANT EXECUTE ON OBJECT::[dbo].[GetDataContract] 
    TO [insert_datafactory_or_synapse_name];  

--logic app feature flag inputted from feature flags during deployment
--The "DeployLogicApp" text is replaced during deployment from the GitHub Action
declare @logicAppDeployed varchar(255) = 'DeployLogicApp'

IF  @logicAppDeployed = 'True'
BEGIN
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_logicapp_name')
  BEGIN
    CREATE USER [insert_logicapp_name] FROM EXTERNAL PROVIDER;
  END

GRANT EXECUTE ON OBJECT::[dbo].[usp_CreateAuditRequestRecord]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[CreateIngestionRecord_Orchestrator]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_CreateIngestionRecord]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_GetIngestionRecordBySource]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_CreateIngestionRecordNew]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_CreateIngestionRecordDelimited]
TO [insert_logicapp_name];

GRANT SELECT ON OBJECT::[dbo].[ControlTable]
TO [insert_logicapp_name];

GRANT INSERT ON OBJECT::[dbo].[ControlTable]
TO [insert_logicapp_name];

GRANT SELECT ON OBJECT::[dbo].[DataContract]
TO [insert_logicapp_name];

GRANT INSERT ON OBJECT::[dbo].[DataContract]
TO [insert_logicapp_name];

GRANT UPDATE ON OBJECT::[dbo].[DataContract]
TO [insert_logicapp_name];

GRANT SELECT ON OBJECT::[dbo].[Handshake]
TO [insert_logicapp_name];

GRANT INSERT ON OBJECT::[dbo].[Handshake]
TO [insert_logicapp_name];

GRANT UPDATE ON OBJECT::[dbo].[Handshake]
TO [insert_logicapp_name];

GRANT SELECT ON OBJECT::[dbo].[DataMapping]
TO [insert_logicapp_name];

GRANT INSERT ON OBJECT::[dbo].[DataMapping]
TO [insert_logicapp_name];

GRANT UPDATE ON OBJECT::[dbo].[DataMapping]
TO [insert_logicapp_name];

GRANT INSERT ON OBJECT::[dbo].[IngestionServiceAudit]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_InsertDataMapping] 
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_EditDataContract]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_InsertHandshake]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_PackagePayloadConfigurator]
TO [insert_logicapp_name];

GRANT EXECUTE ON OBJECT::[dbo].[usp_InsertDataContract]
TO [insert_logicapp_name];

GRANT SELECT ON OBJECT::[dbo].[IngestedLandingDataAudit]
TO [insert_logicapp_name];

END

END
GO
