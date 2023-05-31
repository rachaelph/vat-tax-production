param location string = resourceGroup().location

param storageAccountName string

param DataLakeContainerNames array = [
  'raw'
  'structured'
  'curated'
]

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string

@allowed([
  'Hot'
  'Cool'
])
param accessTier string

param isHnsEnabled bool

param requireInfrastructureEncryption bool

param AAD_Admin_Group_ID string

param softDeleteEnabled bool

param autoDeletePolicy bool = false

param allowBlobPublicAccess bool = false

//purview set up
param purviewResourceGroup string
param addPurviewAsBlobReader bool
param purviewName string
param DeployPurview string

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

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

//ip firewall rules
param AllowAccessToIpRange string
param IpRangeCidr string
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
var blobprivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var dfsprivateDnsZoneName = 'privatelink.dfs.${environment().suffixes.storage}'
var fileprivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var queueprivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var tableprivateDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'

param deployblobPE bool
param deploydfsPE bool
param deployfilePE bool
param deployqueuePE bool
param deploytablePE bool

resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    defaultToOAuthAuthentication: true
    allowBlobPublicAccess: allowBlobPublicAccess
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
    isHnsEnabled: isHnsEnabled
    encryption: {
      requireInfrastructureEncryption: requireInfrastructureEncryption
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {
      defaultAction: defaultAction
      ipRules: (ipRangeFilter==false)?null:[
        {
          action: 'Allow'
          value: IpRangeCidr
        }
      ]
    }
  }
}

//define retention policy
resource r_storageAccountRetentionPolicy 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = if (softDeleteEnabled) {
  name: 'default'
  parent: r_storageAccount
  properties: {
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 7
      enabled: true
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 7
      enabled: true
    }
  }
}

resource r_autoDeletePolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2022-05-01' = if (autoDeletePolicy) {
  name: 'default'
  parent: r_storageAccount
  properties: {
    policy: {
      rules: [
        {
          definition: {
            actions: {
              baseBlob: {
                delete: {
                  daysAfterCreationGreaterThan: 30
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
                'appendBlob'
              ]
            }
          }
          enabled: true
          name: 'DeleteAfter30Days'
          type: 'Lifecycle'
        }
      ]
    }
  }
}

resource r_storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for containerName in DataLakeContainerNames: {
  name: '${r_storageAccount.name}/default/${containerName}'
}]

var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor Role

//Grant Blob Storage Contributor to Admin AAD Group on Storage Account
resource r_dataLakeRoleAssignmentAADGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_storageAccount.id, 'admin_group')
  scope: r_storageAccount
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: AAD_Admin_Group_ID
    principalType:'Group'
  }
}

//Grant Blob Storage Read to Purview
resource r_purview 'Microsoft.Purview/accounts@2021-07-01' existing = if (addPurviewAsBlobReader && DeployPurview == 'True') {
  scope: resourceGroup(purviewResourceGroup)
  name: purviewName
}

var azureRBACStorageBlobDataReaderRoleID = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

resource r_dataLakeRoleAssignmentPurview 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addPurviewAsBlobReader && DeployPurview == 'True') {
  name: guid(r_storageAccount.id, r_purview.id)
  scope: r_storageAccount
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: (DeployPurview != 'True')?'':r_purview.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

module m_blob_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration && deployblobPE) {
  name: 'blob_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:blobprivateDnsZoneName
    privateDnsZoneConfigsName:replace(blobprivateDnsZoneName,'.','-')
    resourceName: storageAccountName
    resourceID: r_storageAccount.id
    privateEndpointgroupIds: [
      'blob'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}


module m_dfs_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration && deploydfsPE) {
  name: 'dfs_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:dfsprivateDnsZoneName
    privateDnsZoneConfigsName:replace(dfsprivateDnsZoneName,'.','-')
    resourceName: storageAccountName
    resourceID: r_storageAccount.id
    privateEndpointgroupIds: [
      'dfs'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_file_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration && deployfilePE) {
  name: 'file_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:fileprivateDnsZoneName
    privateDnsZoneConfigsName:replace(fileprivateDnsZoneName,'.','-')
    resourceName: storageAccountName
    resourceID: r_storageAccount.id
    privateEndpointgroupIds: [
      'file'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_queue_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration && deployqueuePE) {
  name: 'queue_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:queueprivateDnsZoneName
    privateDnsZoneConfigsName:replace(queueprivateDnsZoneName,'.','-')
    resourceName: storageAccountName
    resourceID: r_storageAccount.id
    privateEndpointgroupIds: [
      'queue'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_table_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration && deploytablePE) {
  name: 'table_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:tableprivateDnsZoneName
    privateDnsZoneConfigsName:replace(tableprivateDnsZoneName,'.','-')
    resourceName: storageAccountName
    resourceID: r_storageAccount.id
    privateEndpointgroupIds: [
      'table'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
