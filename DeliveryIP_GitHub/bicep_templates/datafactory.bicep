param location string = resourceGroup().location

param dataFactoryName string 

@description('Public Networking Access')
param RedeploymentAfterNetworkingIsSetUp string
//always enabled initially so ADF artifacts can be deployed from GitHub Runner then turned off later in current deployment
//unless self hosted agent has access to vnet. something that would occur after initial deployment
var publicNetworkAccess = (RedeploymentAfterNetworkingIsSetUp == 'True')?'Enabled':'Disabled'

param dataLakeName string

param landingStorageName string

param DeployPurview string

param purviewName string

param keyVaultName string

param synapseWorkspaceName string

param azureSQLServerName string

param azureSQLServerDBName string

param DeployLogicApp string

param logicAppRG string

param logicAppName string

param cognitiveServiceName string

param configureGit bool

param gitAccountName string = ''

param gitRepositoryName string = ''

param enableDiagnostics bool

param DeployLogAnalytics string

param logAnalyticsName string

param DeployCognitiveService string

var azureRBACDataFactoryContributorRoleID = '673868aa-7521-48a0-acc6-0f60742d39f5' //Data Factory Contributor

var LS_Rest_Example_properties_typeProperties_url = 'https://ghoapi.azureedge.net/api/Indicator'

//for private link setup
param DeployADFPortalPrivateEndpoint string
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
var adfPrivateDnsZoneName = 'privatelink.datafactory.azure.net'
var adfPortalPrivateDnsZoneName = 'privatelink.adf.azure.com'


resource r_datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    globalParameters: {
      blobStorageAccountName: {
        type: 'string'
        value: landingStorageName
      }
    }
    publicNetworkAccess: publicNetworkAccess
    purviewConfiguration: (DeployPurview != 'True')?null:{
      purviewResourceId: r_purview.id
    }
    repoConfiguration: (configureGit == false)?null:{
      accountName: gitAccountName
      collaborationBranch: 'main'
      repositoryName: gitRepositoryName
      rootFolder: '${dataFactoryName}/'
      type: 'FactoryGitHubConfiguration'
    }
  }
}

resource r_datafactory_vnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: 'default'
  parent: r_datafactory
  properties: {}
}

resource r_integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: 'ManagedVnetIntegrationRuntime'
  parent: r_datafactory
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 8
          timeToLive: 10
          cleanup: false
        }
      }
    }
  }
  dependsOn: [
    r_datafactory_vnet
  ]
}

resource r_datalake 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: dataLakeName
}

resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: landingStorageName
}

resource r_purview 'Microsoft.Purview/accounts@2021-07-01' existing = if (DeployPurview == 'True') {
  name: purviewName
}

resource r_azureSQLServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: azureSQLServerName
}

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource r_cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' existing = if (DeployCognitiveService == 'True') {
  name: cognitiveServiceName
}

resource r_logicapp 'Microsoft.Web/sites@2022-03-01' existing = if (DeployLogicApp == 'True') {
  scope: resourceGroup(logicAppRG)
  name: logicAppName
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  name: logAnalyticsName
}

resource r_synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkspaceName
}

resource r_MPE_DataLake_Blob 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: 'MPE_DataLake_Blob'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    fqdns: [
      r_datalake.properties.primaryEndpoints.blob
    ]
    groupId: 'blob'
    privateLinkResourceId: r_datalake.id
  }
}


resource r_MPE_DataLake_DFS 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: 'MPE_DataLake_DFS'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    fqdns: [
      r_datalake.properties.primaryEndpoints.dfs
    ]
    groupId: 'dfs'
    privateLinkResourceId: r_datalake.id
  }
}

resource r_MPE_LandingStorage_Blob 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: 'MPE_LandingStorage_Blob'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    fqdns: [
      r_storageAccount.properties.primaryEndpoints.blob
    ]
    groupId: 'blob'
    privateLinkResourceId: r_storageAccount.id
  }
}

resource r_MPE_LandingStorage_DFS 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: 'MPE_LandingStorage_DFS'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    fqdns: [
      r_storageAccount.properties.primaryEndpoints.dfs
    ]
    groupId: 'dfs'
    privateLinkResourceId: r_storageAccount.id
  }
}


resource r_MPE_KeyVault 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: 'MPE_KeyVault'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    groupId: 'vault'
    privateLinkResourceId: r_keyvault.id
  }
}

resource r_MPE_AzureSQL 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: 'MPE_AzureSQL'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    groupId: 'sqlServer'
    privateLinkResourceId: r_azureSQLServer.id
  }
}

resource r_MPE_Purview 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = if (DeployPurview == 'True') {
  name: 'MPE_Purview'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    groupId: 'account'
    privateLinkResourceId: r_purview.id
  }
}

var purviewStorageName = (DeployPurview != 'True')?'NA':split(r_purview.properties.managedResources.storageAccount,'/')[length(split(r_purview.properties.managedResources.storageAccount,'/'))-1]

resource r_MPE_PurviewStorage_Blob 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = if (DeployPurview == 'True') {
  name: 'MPE_PurviewStorage_Blob'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    fqdns: [
      'https://${purviewStorageName}.blob.${environment().suffixes.storage}'
    ]
    groupId: 'blob'
    privateLinkResourceId: (DeployPurview != 'True')?'NA':r_purview.properties.managedResources.storageAccount
  }
}

resource r_MPE_PurviewStorage_Queue 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = if (DeployPurview == 'True') {
  name: 'MPE_PurviewStorage_Queue'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    groupId: 'queue'
    privateLinkResourceId: (DeployPurview != 'True')?'NA':r_purview.properties.managedResources.storageAccount
  }
}

resource r_MPE_CognitiveService 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = if (DeployCognitiveService == 'True') {
  name: 'MPE_CognitiveService'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    groupId: 'account'
    privateLinkResourceId: r_cognitiveService.id
  }
}

resource r_MPE_Synapse 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: 'MPE_Synapse'
  parent: r_datafactory_vnet
  properties: {
    connectionState: {}
    groupId: 'Dev'
    privateLinkResourceId: r_synapseWorkspace.id
  }
}

resource factoryName_LS_Rest_Example 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: 'LS_Rest_Example'
  parent: r_datafactory
  properties: {
    annotations: []
    type: 'RestService'
    typeProperties: {
      url: LS_Rest_Example_properties_typeProperties_url
      enableServerCertificateValidation: true
      authenticationType: 'Anonymous'
    }
  }
  dependsOn: []
}

resource r_LS_DataLake 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_DataLake'
  parent: r_datafactory
  properties: {
    annotations: []
    type: 'AzureBlobFS'
    typeProperties: {
        url: replace(r_datalake.properties.primaryEndpoints.dfs, '.net/', '.net')
    }
    connectVia: {
      referenceName: 'ManagedVnetIntegrationRuntime'
      type: 'IntegrationRuntimeReference'
    }
  }
  dependsOn: [
    r_integrationRuntime
  ]
}

resource r_LS_LandingStorage 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_LandingStorage'
  parent: r_datafactory
  properties: {
    annotations: []
    type: 'AzureBlobFS'
    typeProperties: {
      url: replace(r_storageAccount.properties.primaryEndpoints.dfs, '.net/', '.net')
    }
    connectVia: {
      referenceName: 'ManagedVnetIntegrationRuntime'
      type: 'IntegrationRuntimeReference'
    }
  }
  dependsOn: [
    r_integrationRuntime
  ]
}

resource r_LS_KeyVault 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_KeyVault'
  parent: r_datafactory
  properties: {
    annotations: []
    type: 'AzureKeyVault'
    typeProperties: {
        baseUrl: r_keyvault.properties.vaultUri
    }
  }
  dependsOn: [
    r_integrationRuntime
  ]
}

resource r_LS_SQL_MetadataControl 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_SQL_MetadataControl'
  parent: r_datafactory
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
        connectionString: 'Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${azureSQLServerName}.database.windows.net;Initial Catalog=${azureSQLServerDBName}'
    }
    connectVia: {
      referenceName: 'ManagedVnetIntegrationRuntime'
      type: 'IntegrationRuntimeReference'
    }
  }
  dependsOn: [
    r_integrationRuntime
  ]
}

resource r_LS_Synapse 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_Synapse'
  parent: r_datafactory
  properties: {
    annotations: []
    type: 'AzureSynapseArtifacts'
    typeProperties: {
      endpoint: 'https://${synapseWorkspaceName}.dev.azuresynapse.net'
      authentication: 'MSI'
      workspaceResourceId: r_synapseWorkspace.id
    }
    connectVia: {
      referenceName: 'ManagedVnetIntegrationRuntime'
      type: 'IntegrationRuntimeReference'
    }
  }
  dependsOn: [
    r_integrationRuntime
  ]
}

module datalake_rbac 'rbac_datalake.bicep' = {
  name: 'datalake_rbac'
  params: {
    azureResourceName: r_datafactory.name
    storageAccountName: dataLakeName
    principalId: r_datafactory.identity.principalId
  }
}

module storageAccount_rbac 'rbac_datalake.bicep' = {
  name: 'storageAccount_rbac'
  params: {
    azureResourceName: r_datafactory.name
    storageAccountName: landingStorageName
    principalId: r_datafactory.identity.principalId
  }
}

module keyvault_rbac 'rbac_keyvault.bicep' = {
  name: 'keyvault_rbac'
  params: {
    azureResourceName: r_datafactory.name
    keyVaultName: keyVaultName
    principalId: r_datafactory.identity.principalId
  }
}

module r_cognitiveService_rbac 'rbac_cognitive_service_user.bicep' = if (DeployCognitiveService == 'True') {
  name: 'rbac_cognitive_service_user'
  params: {
    azureResourceName: r_datafactory.name
    cognitiveServiceName: cognitiveServiceName
    principalId: r_datafactory.identity.principalId
  }
}

//Grant Logic App a Role Assignment as Data Factory Contributor in Data Factory
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_dataLakeRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployLogicApp == 'True') {
  name: guid(r_logicapp.name, r_datafactory.name)
  scope: r_datafactory
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACDataFactoryContributorRoleID)
    principalId: (DeployLogicApp != 'True')?'':r_logicapp.identity.principalId
    principalType:'ServicePrincipal'
  }
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && DeployLogAnalytics == 'True') {
  scope: r_datafactory
  name: 'adf-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        category: 'ActivityRuns'
        enabled: true
      }
      {
        category: 'PipelineRuns'
        enabled: true
      }
      {
        category: 'TriggerRuns'
        enabled: true
      }
      {
        category: 'SSISPackageEventMessages'
        enabled: true
      }
      {
        category: 'SSISPackageExecutableStatistics'
        enabled: true
      }
      {
        category: 'SSISPackageEventMessageContext'
        enabled: true
      }
      {
        category: 'SSISPackageExecutionComponentPhases'
        enabled: true
      }
      {
        category: 'SSISPackageExecutionDataStatistics'
        enabled: true
      }
      {
        category: 'SSISIntegrationRuntimeLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

//deploy Azure Private Links
module m_adf_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration) {
  name: 'adf_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:adfPrivateDnsZoneName
    privateDnsZoneConfigsName:replace(adfPrivateDnsZoneName,'.','-')
    resourceName: dataFactoryName
    resourceID: r_datafactory.id
    privateEndpointgroupIds: [
      'dataFactory'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_adfportal_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration && DeployADFPortalPrivateEndpoint == 'True') {
  name: 'adfportal_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:adfPortalPrivateDnsZoneName
    privateDnsZoneConfigsName:replace(adfPortalPrivateDnsZoneName,'.','-')
    resourceName: dataFactoryName
    resourceID: r_datafactory.id
    privateEndpointgroupIds: [
      'portal'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
