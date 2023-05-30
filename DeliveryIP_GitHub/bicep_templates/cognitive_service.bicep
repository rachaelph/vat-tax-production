@description('That name is the name of our application.')
param cognitiveServiceName string

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'CognitiveServices'
  'FormRecognizer'
])
param kind string = 'FormRecognizer'

@allowed([
  'S0'
])
param sku string = 'S0'

@description('Disable use of API Keys and only allow AAD Auth')
param disableLocalAuth bool = true

param dataLakeName string

param landingStorageName string

param keyVaultName string

param adminGroupObjectID string 

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
var privateDnsZoneName = 'privatelink.cognitiveservices.azure.com'

//logging
param DeployLogAnalytics string
param logAnalyticsName string

resource r_cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' = {
  name: cognitiveServiceName
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  kind: kind
  properties: {
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    customSubDomainName: cognitiveServiceName
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      defaultAction: defaultAction
      ipRules: (ipRangeFilter==false)?null:[
        {
          value: IpRangeCidr
        }
      ]
    }
  }
}

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource r_keyvaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: r_keyvault
  name: '${cognitiveServiceName}-key1'
  properties: {
    value: r_cognitiveService.listKeys().key1
  }
}

module m_datalake_rbac 'rbac_storage_reader.bicep' = {
  name: 'datalake_rbac'
  params: {
    azureResourceName: cognitiveServiceName
    storageAccountName: dataLakeName
    principalId: r_cognitiveService.identity.principalId
  }
}

module m_landingstorage_rbac 'rbac_storage_reader.bicep' = {
  name: 'landingstorage_rbac'
  params: {
    azureResourceName: cognitiveServiceName
    storageAccountName: landingStorageName
    principalId: r_cognitiveService.identity.principalId
  }
}

var azureRBACCognitiveServicesUserRoleID = 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User

resource r_CognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_cognitiveService.id, 'admin_group')
  scope: r_cognitiveService
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACCognitiveServicesUserRoleID)
    principalId: adminGroupObjectID
    principalType:'Group'
  }
}


module m_cognitiveService_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration) {
  name: 'cognitiveService_private_endpoint'
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
    resourceName: cognitiveServiceName
    resourceID: r_cognitiveService.id
    privateEndpointgroupIds: [
      'account'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  name: logAnalyticsName
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (DeployLogAnalytics == 'True') {
  scope: r_cognitiveService
  name: 'cognitiveService-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        categoryGroup: 'Audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
      }
    ]
  }
}
