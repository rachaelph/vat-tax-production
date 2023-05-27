# Steps to Deploy the GitHub IP
1. [Create a Service Principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
2. Assign Service Principal with Subscription Rights. There's 2 Options
    - Assign the Service Principal RBAC Owner rights at the Subscription(s)
    - Pre-create all Resource Groups and Assign the Service Principal Owner RBAC Owner rights at each Resource Group

3. [Create an Azure Active Directory (AAD) group](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/concept-learn-about-groups) and add all project team members, or, if only you will be interacting with the deployed resources, yourself

4. [Add the following Repository Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) *with the same name*
    - **TENANT_ID** - [how to find](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant#find-tenant-id-through-the-azure-portal)
    - **SUBSCRIPTION_ID_DEV** - [how to find](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id#find-your-azure-subscription)
    - **SUBSCRIPTION_ID_TEST** (if deploying test environment)
    - **SUBSCRIPTION_ID_PROD** (if deploying prod environment)
    - **SERVICE_PRINCIPAL_CLIENT_ID** (From Step 1) - [how to find](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals#application-object)
    - **SERVICE_PRINCIPAL_SECRET** (From Step 1) - [secret value](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#option-2-create-a-new-application-secret)
    - **AAD_GROUP_ID** (From Step 2) - [AAD Group Object Id](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/how-to-manage-groups#add-members-or-owners-of-a-group)
    - **SYNAPSE_ADMIN_USERNAME**
    - **SYNAPSE_ADMIN_PASSWORD**
5. Create the below secrets *with the same name* if you're creating private endpoints
    - **DNS_ZONE_SUBSCRIPTION_ID_DEV**
    - **DNS_ZONE_SUBSCRIPTION_ID_TEST** (if deploying test environment)
    - **DNS_ZONE_SUBSCRIPTION_ID_PROD** (if deploying prod environment)
6. Create the below secrets *with the same name* if you're deploying VM's with Bastion
    - **VM_USERNAME**
    - **VM_PASSWORD**

7. For each environment you're deploying, update the [feature flag variable file](variables/general_feature_flags/) to indicate which resources you are deploying or behavior of resources

8. For each environment you're deploying, update the [general variable file](variables/general_variables/) with the resource names for the resources you indicated you are deploying based on the feature flag file. Also add required tags, Azure location, and resource group names.
    - Note that most Azure resource names need to be globally unique, but keep the SQL Database name as "MetadataControl"
    - The following variable values can only container letters and numbers and must be between 3 and 24 characters long
        - dataLakeName...
        - landingStorageName...
        - logicAppStorageName...
        - mlStorageName...
    - The following variable values must be between 3 and 24 characters long
        - keyVaultName...
    - The following variable values can only container letters and numbers
        - mlContainerRegistryName...
    - If Key Vault or Container Registry are deleted and need to be redeployed, please change the resource name
        - this is due to soft delete policies

9. Update the [networking setup file](variables/networking_setup/) **if** you inputted *true* for **DeployWithCustomNetworking** in the feature flag variable file

10. Confirm the following resource providers are registered in your Azure Subscription. If not, [register them](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider-1)
    - *Microsoft.EventGrid*
    - If you're deploying Purview: *Microsoft.Purview*, *Microsoft.EventHub*

11. Trigger the **data-strategy-orchestrator** GitHub Action. If you're unfamiliar with triggering a GitHub Action, follow these [instructions](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow).
    - Please do not use the "rerun" job functionality. Always execute the job using method in above instructions

# Post Deployment Tasks - Azure SQL
1. Execute the below stored procedure in the deployed Azure SQL Database(s)
    - Login with AAD. SQL Auth is disabled.
```sql
EXEC [dbo].[AddManagedIdentitiesAsUsers]
```

# Post Deployment Tasks - Synapse
1. Execute the below stored procedure in the Synapse Serverless Database **StoredProcDB** 
    - Login with AAD. SQL Auth is disabled post deployment.
```sql
EXEC [dbo].[AddManagedIdentitiesAsUsers]
```

# Post Deployment Tasks - Purview
1. Add the ADF and Synapse managed identities as [Data Curator's in the Root Collection of Purview](https://learn.microsoft.com/en-us/azure/synapse-analytics/catalog-and-governance/quickstart-connect-azure-purview#set-up-authentication)
    - This is required for lineage
2. When lake DBs are created, you will need to execute the below commands for Purview to scan
```sql
CREATE LOGIN [PurviewAccountName] FROM EXTERNAL PROVIDER;
CREATE USER [PurviewAccountName] FOR LOGIN [PurviewAccountName];
ALTER ROLE db_datareader ADD MEMBER [PurviewAccountName]; 
```
#### If your deploying all resources with no public access behind a virtual network and your service principal didn't have Owner RBAC rights on the **Subscription**

3. Get Owner of Subscription to Provide AAD Group with Contributor Access to Purview Managed Resource Group

##### if you set the feature flag, *DeployPurviewIngestionPrivateEndpoints*, to true

4. Within the Azure Portal, navigate to Purview's managed Storage Account and Event Hub. For each resource, approve the pending Private Endpoint connections created by the GitHub Action.

#### If your deploying all resources with no public access behind a virtual network
5. Set up a [Managed VNET Integration Runtime](https://learn.microsoft.com/en-us/azure/purview/catalog-managed-vnet#deployment-steps) to scan [supported Azure data sources](https://learn.microsoft.com/en-us/azure/purview/catalog-managed-vnet#supported-data-sources)
6. Set up a [Self-Hosted Integration Runtime](https://learn.microsoft.com/en-us/azure/purview/catalog-private-link-end-to-end#deploy-self-hosted-integration-runtime-ir-and-scan-your-data-sources) to scan data sources unsupported by the Managed VNET Integration Runtime
