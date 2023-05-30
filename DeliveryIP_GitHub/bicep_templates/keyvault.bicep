param location string = resourceGroup().location

param keyVaultName string

param enabledForTemplateDeployment bool

param enabledForDiskEncryption bool

param enabledForDeployment bool

param softDeleteRetentionInDays int

param AAD_Admin_Group_ID string

param enableDiagnostics bool

param DeployLogAnalytics string
param logAnalyticsRG string
param logAnalyticsName string

var azureRBACKeyVaultSecretsOfficerRoleID = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' //Key Vault Secrets Officer

@allowed([
  'premium'
  'standard'
])
param sku string = 'standard'

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

//ip firewall rules
param AllowAccessToIpRange string
param IpRangeCidr string
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

//for private link setup
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
var privateDnsZoneName = 'privatelink.vaultcore.azure.net'

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    createMode: 'default'
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    networkAcls: {
      defaultAction: defaultAction
      ipRules: (ipRangeFilter==false)?null:[
        {
          value: IpRangeCidr
        }
      ]
    }
    publicNetworkAccess: publicNetworkAccess
    sku: {
      family: 'A'
      name: sku
    }
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tenantId: tenant().tenantId
  }
}

//Grant Key Vault Secrets Officer to Admin AAD Group on Key Vault
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_dataLakeRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultName, 'admin_group')
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACKeyVaultSecretsOfficerRoleID)
    principalId: AAD_Admin_Group_ID
    principalType:'Group'
  }
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(logAnalyticsRG)
  name: logAnalyticsName
}


resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && DeployLogAnalytics == 'True') {
  scope: r_keyvault
  name: 'kv-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

module m_keyvault_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration) {
  name: 'keyvault_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:privateDnsZoneName
    privateDnsZoneConfigsName:replace(privateDnsZoneName,'.','-')
    resourceName: keyVaultName
    resourceID: r_keyvault.id
    privateEndpointgroupIds: [
      'vault'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
