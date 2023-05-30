/****** Object:  StoredProcedure [dbo].[usp_InsertDataContract]    Script Date: 5/19/2023 10:42:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_InsertDataContract]
    @jsonData nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @createdOnDate datetime2 = GETUTCDATE();
    DECLARE @active bit = 1;
    DECLARE @activeDate datetime2 = GETUTCDATE();
 /*  -- Check if there is an active contract for the given ContractID
    IF EXISTS (
        SELECT 1
        FROM DataContract
        WHERE ContractID = (SELECT ContractID FROM OPENJSON(@jsonData) WITH (ContractID nvarchar(255) '$.ContractID'))
            AND Active = 1
    )
    BEGIN
        RAISERROR('There is already an active contract for the given ContractID.', 16, 1)
        RETURN;
    END */



    
    INSERT INTO DataContract (
        ContractID,
        SubjectArea,
        SourceSystem,
        PublisherName,
        DataNameSystem,
        DataNameFriendly,
        [Description],
        BusinessContact,
        BusinessContactEmail,
        BusinessContactUPN,
        BusinessContactObjID,
        EngineeringContact,
        EngineeringContactEmail,
        EngineeringContactUPN,
        EngineeringContactObjID,
        DataOwner,
        DataOwnerEmail,
        DataOwnerUPN,
        DataOwnerObjID,
        SME,
		Pattern,
        [Format],
        Restrictions,
        Metadata,
        DataClassificationLevel,
        CreatedBy,
        CreatedByEmail,
        CreatedByUPN,
        [CreatedById],
        DataSchema,
        CreatedOnDate,
        Active,
        ActiveDate,
        InactiveDate
    )
    SELECT 
        ContractID,
        SubjectArea,
        SourceSystem,
        PublisherName,
        DataNameSystem,
        DataNameFriendly,
        [Description],
        BusinessContact,
        BusinessContactEmail,
        BusinessContactUPN,
        BusinessContactObjID,
        EngineeringContact,
        EngineeringContactEmail,
        EngineeringContactUPN,
        EngineeringContactObjID,
        DataOwner,
        DataOwnerEmail,
        DataOwnerUPN,
        DataOwnerObjID,
        SME,
		Pattern,
        [Format],
        Restrictions,
        Metadata,
        DataClassificationLevel,
        CreatedBy,
        CreatedByEmail,
        CreatedByUPN,
        [CreatedById],
        DataSchema,
        @createdOnDate,
        @active,
        @activeDate,
        '9999-12-31'
        
    FROM OPENJSON(@jsonData)
    WITH (
        ContractID nvarchar(255) '$.ContractID',
        SubjectArea nvarchar(255) '$.SubjectArea',
        SourceSystem nvarchar(255) '$.SourceSystem',
        PublisherName nvarchar(255) '$.PublisherName',
        DataNameSystem nvarchar(255) '$.DataNameSystem',
        DataNameFriendly nvarchar(255) '$.DataNameFriendly',
        [Description] nvarchar(255) '$.Description',
        BusinessContact nvarchar(255)  '$.BusinessContact',
        BusinessContactEmail nvarchar(500) '$.BusinessContactEmail',
        BusinessContactUPN nvarchar(255) '$.BusinessContactUPN',
        BusinessContactObjID nvarchar(255) '$.BusinessContactObjID',
        EngineeringContact nvarchar(255) '$.EngineeringContact',
        EngineeringContactEmail nvarchar(500) '$.EngineeringContactEmail',
        EngineeringContactUPN nvarchar(255) '$.EngineeringContactUPN',
        EngineeringContactObjID nvarchar(255) '$.EngineeringContactObjID',
        DataOwner nvarchar(255) '$.DataOwner',
        DataOwnerEmail nvarchar(500) '$.DataOwnerEmail',
        DataOwnerUPN nvarchar(255) '$.DataOwnerUPN',
        DataOwnerObjID nvarchar(255) '$.DataOwnerObjID',
        SME nvarchar(max) as JSON,
		Pattern nvarchar(255) '$.Pattern',
        [Format] nvarchar(255) '$.Format',
        Restrictions nvarchar(255) '$.Restrictions',
        Metadata nvarchar(255) '$.Metadata',
        DataClassificationLevel nvarchar(255) '$.DataClassificationLevel',
        DataSchema nvarchar(MAX) AS JSON,
		CreatedBy nvarchar(255) '$.CreatedBy',
		CreatedByEmail nvarchar(500) '$.CreatedByEmail',
		CreatedByUPN nvarchar(255) '$.CreatedByUPN',
		[CreatedById] nvarchar(255) '$.CreatedById'
    );
    
END
GO

