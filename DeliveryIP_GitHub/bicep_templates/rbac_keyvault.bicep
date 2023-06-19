param keyVaultName string

param azureResourceName string 

param principalId string = ''

var azureRBACStorageKeyVaultSecretsUserRoleID = '4633458b-17de-408a-b874-0445c86b69e6' //Key Vault Secrets User

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

//Grant Azure Resource a Role Assignment as Secret Reader Role in the Key Vault
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_dataLakeRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azureResourceName, keyVaultName)
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageKeyVaultSecretsUserRoleID)
    principalId: principalId
    principalType:'ServicePrincipal'
  }
}
