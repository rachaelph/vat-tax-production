@description('Location for all resources.')
param location string = resourceGroup().location

param streamAnalyticsName string

param sku string = 'standard'

param streamingUnits int

param compatibilityLevel string

param landingStorageName string

param DeployEventHubNamespace string
param eventHubNamespaceName string

resource r_StreamAnalytics 'Microsoft.StreamAnalytics/StreamingJobs@2021-10-01-preview' = {
  name: streamAnalyticsName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: sku
    }
    outputErrorPolicy: 'stop'
    eventsOutOfOrderPolicy: 'adjust'
    eventsOutOfOrderMaxDelayInSeconds: 0
    eventsLateArrivalMaxDelayInSeconds: 5
    contentStoragePolicy: 'SystemAccount'
    jobType: 'Cloud'
    dataLocale: 'en-US'
    transformation: {
      properties: {
          streamingUnits: streamingUnits
          query: 'SELECT\r\n    *\r\nINTO\r\n    [YourOutputAlias]\r\nFROM\r\n    [YourInputAlias]'
      }
      name: 'Transformation'
    }
    compatibilityLevel: compatibilityLevel
  }
}

module storageAccount_rbac 'rbac_datalake.bicep' = {
  name: 'storageAccount_rbac'
  params: {
    azureResourceName: streamAnalyticsName
    storageAccountName: landingStorageName
    principalId: r_StreamAnalytics.identity.principalId
  }
}

//Grant Stream Analytics as Azure Event Hubs Data Sender to Event Hub
module r_rbac_event_hub_owner 'rbac_event_hub_owner.bicep' = if (DeployEventHubNamespace == 'True') {
  name: 'rbac_event_hub_owner'
  params: {
    azureResourceName: streamAnalyticsName
    eventHubName: eventHubNamespaceName
    principalId: r_StreamAnalytics.identity.principalId
  }
}

