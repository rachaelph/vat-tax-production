param location string = resourceGroup().location

param cognitiveSearchName string

@allowed([
  'basic'
  'free'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param sku_name string

param disableLocalAuth bool

param partitionCount int 

param replicaCount int 

param hostingMode string

//for private link setup
param DeployWithCustomNetworking string

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

//ip firewall rules
param AllowAccessToIpRange string
param IpRangeCidr string
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

var networkRuleSet = {
  defaultAction: defaultAction
  ipRules: (ipRangeFilter==false)?null:[
    {
      action: 'Allow'
      value: IpRangeCidr
    }
  ]
}

resource r_CognitiveSearch 'Microsoft.Search/searchServices@2021-04-01-preview' = {
  name: cognitiveSearchName
  location: location
  sku: {
    name: sku_name
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostingMode: hostingMode
    networkRuleSet: (sku_name=='basic')?null:networkRuleSet
    partitionCount: partitionCount
    replicaCount: replicaCount
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}
