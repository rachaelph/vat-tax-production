# Feature Flag Definitions

| Id | Feature Flag | Description    |     
| :---  | :---         | :---           |
| 1 | AllowAccessToIpRange     | IP Range to allow access to for resources that allow network restrictions by IP like Storage accounts or event hub |
| 2 | DeployNewVnet     | Whether a Virtual Network is deployed and deployed resources are connected to it through private endpoints or injected into a subnet |
| 3 | DeployLogicAppInVnet     | Whether the Logic App Should be Deployed in a Virtual Network |
| 4 | DeployMLComputeInVnet     | Whether Azure Machine Learning Compute Clusters Should Be Deployed in a Virtual Network.     |
| 5 | CreatePrivateEndpoints     | Whether private endpoints are created to PAAS resorces that support private endpoints    |
| 6 | CreatePrivateEndpointsInSameRgAsResource     | Whether private endpoints are created in same Resource group as resources or in the Resource Group that contains the Virtual Network     |
| 7 | UseManualPrivateLinkServiceConnections     | Used when the network admin does not have access to approve connections to the remote resource.    |
| 8 | DeployADFPortalPrivateEndpoint     | Set to False if Client Does not have DNS Zones for ADF Portal    |
| 9 | DeploySynapseWebPrivateEndpoint     | Set to False if Client has already deployed this Private Endpoint for another Synapse or they do not have DNS Zones for Synapse Web. Most of the time this value will be False   |
| 10 | DeployPurviewPrivateEndpoints     | Set to False if Client Does not have DNS Zones for Purview Account or Portal     |
| 11 | DeployPurviewIngestionPrivateEndpoints     | Set to False if you are not deploying ingestion private endpoints for Purview  |
| 12 | RedeploymentAfterNetworkingIsSetUp     | Whether your self hosted runner has access to the vnet in the subscription and all deployed resources are connected to the vnet. Input false is that is correct. true if it's not true. Will always be true on initial deployment. |
| 13 | DeployVMswithBastion     | Whether VM's are created with Azure Bastion so you can access your private resources after deployment |