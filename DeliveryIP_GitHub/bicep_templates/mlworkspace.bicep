param location string = resourceGroup().location

param mlWorkspaceName string

param mlStorageAccountName string

param dataLakeName string

param synapseWorkspaceName string

param appInsightsName string

param containerRegistryName string

param keyVaultName string

param mainResourcesRG string

@description('Public Networking Access')
param RedeploymentAfterNetworkingIsSetUp string
//always enabled initially so ML Artifacts artifacts can be deployed from GitHub Runner. 
//Public network access is then turned off later in current deployment
//unless self hosted agent has access to vnet. something that would occur after initial deployment
var publicNetworkAccess = (RedeploymentAfterNetworkingIsSetUp == 'False')?'Enabled':'Disabled'

param hbiWorkspace bool

param DataLakeContainerNames array

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
var privateDnsZoneName1 = 'privatelink.api.azureml.ms'
var privateDnsZoneName2 = 'privatelink.notebooks.azure.net'

var azureRBACContributorRoleID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource r_mlStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: mlStorageAccountName
}

resource r_Synapse 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  scope: resourceGroup(mainResourcesRG)
  name: synapseWorkspaceName
}

resource r_appinsights 'microsoft.insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource r_containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: containerRegistryName
}

resource r_mlworkspace 'Microsoft.MachineLearningServices/workspaces@2022-06-01-preview' = {
  name: mlWorkspaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: mlWorkspaceName
    storageAccount: r_mlStorageAccount.id
    keyVault: r_keyvault.id
    applicationInsights: r_appinsights.id
    containerRegistry: r_containerRegistry.id
    hbiWorkspace: hbiWorkspace
    v1LegacyMode: false
    publicNetworkAccess: publicNetworkAccess
    discoveryUrl: 'https://eastus.api.azureml.ms/discovery'
  }
}

resource r_dataLake_adls_datastores 'Microsoft.MachineLearningServices/workspaces/datastores@2022-06-01-preview' = [for DataLakeContainerName in DataLakeContainerNames: {
  name: 'ds_adls_${DataLakeContainerName}'
  parent: r_mlworkspace
  properties: {
    credentials: {
      credentialsType: 'None'
    }
    description: 'Datastore for the Azure Data Lake Gen2 Account'
    properties: {}
    tags: {}
    datastoreType: 'AzureDataLakeGen2'
    accountName: dataLakeName
    filesystem: DataLakeContainerName
    serviceDataAccessAuthIdentity: 'WorkspaceSystemAssignedIdentity'
  }
}]

resource r_dataLake_blob_datastores 'Microsoft.MachineLearningServices/workspaces/datastores@2022-06-01-preview' = [for DataLakeContainerName in DataLakeContainerNames: {
  name: 'ds_blob_${DataLakeContainerName}'
  parent: r_mlworkspace
  properties: {
    credentials: {
      credentialsType: 'None'
    }
    description: 'Datastore for the Azure Data Lake Gen2 Account'
    properties: {}
    tags: {}
    datastoreType: 'AzureBlob'
    accountName: dataLakeName
    containerName: DataLakeContainerName
    serviceDataAccessAuthIdentity: 'WorkspaceSystemAssignedIdentity'
  }
}]

module m_aml_private_endpoint 'private_endpoint_ML.bicep' = if (vnetIntegration) {
  name: 'aml_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName1:privateDnsZoneName1
    privateDnsZoneConfigsName1:replace(privateDnsZoneName1,'.','-')
    privateDnsZoneName2:privateDnsZoneName2
    privateDnsZoneConfigsName2:replace(privateDnsZoneName2,'.','-')
    resourceName: mlWorkspaceName
    resourceID: r_mlworkspace.id
    privateEndpointgroupIds: [
      'amlworkspace'
    ]
    mlStorageName: mlStorageAccountName
    mlWorkspacePrincipalId: r_mlworkspace.identity.principalId
    PrivateEndpointId: PrivateEndpointId
  }
}

//Grant Synapse Contributor Rights on Azure Machine Learning
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_synapseContribRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_mlworkspace.name, r_Synapse.name)
  scope: r_mlworkspace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACContributorRoleID)
    principalId: r_Synapse.identity.principalId
    principalType:'ServicePrincipal'
  }
}
