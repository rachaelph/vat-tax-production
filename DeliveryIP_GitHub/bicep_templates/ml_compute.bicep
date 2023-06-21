param location string = resourceGroup().location

param mlWorkspaceName string

param dataLakeName string

param keyVaultName string

param PrimaryRgName string

//ml cluster
param imageBuildComputeCluster object
param computeClusters array

//for compute in vnet
param DeployWithCustomNetworking string
param DeployMLComputeInVnet string
param VnetForResourcesRgName string
param VnetForResourcesName string
param MLComputeSubnetName string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && DeployMLComputeInVnet == 'True')?true:false

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = if (vnetIntegration) {
  scope: resourceGroup(VnetForResourcesRgName)
  name: VnetForResourcesName
}

resource r_mlworkspace 'Microsoft.MachineLearningServices/workspaces@2022-06-01-preview' existing = {
  name: mlWorkspaceName
}

resource r_mlImageCompute 'Microsoft.MachineLearningServices/workspaces/computes@2022-06-01-preview' = {
  name: imageBuildComputeCluster.ClusterName
  parent: r_mlworkspace
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: imageBuildComputeCluster.disableLocalAuth
    computeType: 'AmlCompute'
    properties: {
      vmSize: imageBuildComputeCluster.VMSize
      vmPriority: imageBuildComputeCluster.mlComputevmPriority
      enableNodePublicIp: imageBuildComputeCluster.enableNodePublicIp
      osType: imageBuildComputeCluster.mlComputevmOSType
      remoteLoginPortPublicAccess: imageBuildComputeCluster.mlComputeremoteLoginPortPublicAccess
      scaleSettings: {
        minNodeCount: imageBuildComputeCluster.minNodeCount
        maxNodeCount: imageBuildComputeCluster.maxNodeCount
        nodeIdleTimeBeforeScaleDown: imageBuildComputeCluster.mlComputerscaleSettingsIdleTimeBeforeScaleDown
      }
      subnet: (vnetIntegration == false)?null:{
        id: '${r_vnet.id}/subnets/${MLComputeSubnetName}'
      }
    }
  }
  dependsOn: [
  ]
}

resource r_mlCompute 'Microsoft.MachineLearningServices/workspaces/computes@2022-06-01-preview' = [for computeCluster in computeClusters: {
  name: computeCluster.ClusterName
  parent: r_mlworkspace
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: computeCluster.disableLocalAuth
    computeType: 'AmlCompute'
    properties: {
      vmSize: computeCluster.VMSize
      vmPriority: computeCluster.mlComputevmPriority
      enableNodePublicIp: computeCluster.enableNodePublicIp
      osType: computeCluster.mlComputevmOSType
      remoteLoginPortPublicAccess: computeCluster.mlComputeremoteLoginPortPublicAccess
      scaleSettings: {
        minNodeCount: computeCluster.minNodeCount
        maxNodeCount: computeCluster.maxNodeCount
        nodeIdleTimeBeforeScaleDown: computeCluster.mlComputerscaleSettingsIdleTimeBeforeScaleDown
      }
      subnet: (vnetIntegration == false)?null:{
        id: '${r_vnet.id}/subnets/${MLComputeSubnetName}'
      }
    }
  }
  dependsOn: [
  ]
}]

//give ml compute cluster rbac contributor rights to data lake
module r_mlCompteClusterDataLake_rbac 'rbac_datalake.bicep' = [for computeCluster in computeClusters: {
  scope: resourceGroup(PrimaryRgName)
  name: '${computeCluster.ClusterName}_datalake_rbac'
  params: {
    azureResourceName: '${mlWorkspaceName}-${computeCluster.ClusterName}'
    storageAccountName: dataLakeName
    principalId: r_mlCompute[computeCluster.id].identity.principalId
  }
}]

//give ml compute cluster rbac secret user on key vault
module keyvault_rbac 'rbac_keyvault.bicep' = [for computeCluster in computeClusters: {
  scope: resourceGroup(PrimaryRgName)
  name: '${computeCluster.ClusterName}_keyvault_rbac'
  params: {
    azureResourceName: '${mlWorkspaceName}-${computeCluster.ClusterName}'
    keyVaultName: keyVaultName
    principalId: r_mlCompute[computeCluster.id].identity.principalId
  }
}]

//give workspace rbac contributor rights to data lake
module r_mlWorkspaceDataLake_rbac 'rbac_datalake.bicep' = {
  scope: resourceGroup(PrimaryRgName)
  name: 'mlWorkspaceDataLake_rbac'
  params: {
    azureResourceName: mlWorkspaceName
    storageAccountName: dataLakeName
    principalId: r_mlworkspace.identity.principalId
  }
}
