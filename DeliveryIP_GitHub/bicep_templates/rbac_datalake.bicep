param storageAccountName string

param azureResourceName string 

param principalId string = ''

var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor Role

resource r_datalake 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

//Grant Azure Resource a Role Assignment as Blob Data Contributor Role in the Data Lake Storage Account
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_dataLakeRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azureResourceName, storageAccountName)
  scope: r_datalake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: principalId
    principalType:'ServicePrincipal'
  }
}
