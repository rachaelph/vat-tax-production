# Feature Flag Definitions

| Id | Feature Flag | Description    |     
| :---  | :---         | :---           |
| 1 | DeployDevEnvironment   | Whether a dev environment is deployed    |
| 2 | DeployTestEnvironment    | Whether a test/qa/pre-prod environment is deployed       |
| 3 | DeployProdEnvironment   | Whether a prod environment is deployed       |
| 4 | DeployResourcesWithPublicAccess     | Whether resources are deployed with public network access. i.e. 0.0.0.0/0 networking access. Credentials will still be needed to access resources     | 
| 5 | DeployWithCustomNetworking | Whether some or all resources will be integrated with a new or existing virtual network and/or have IP rule filters applied at applicable resources. If true, all additional networking setup will need to take place under the "networking_setup" folder |
| 6 | ServicePrincipalHasOwnerRBACAtSubscription   | Flag only needed for Purview deployment currently. If the service principal does NOT have owner rights at the subscription, ingestion private endpoints cannot be created for Purview.     |
| 7 | DeployDataLake    | Whether the Data Lake is redeployed. It should always be deployed initially       |
| 8 | DeployLandingStorage    | Whether Landing Storage is redeployed. It should always be deployed initially       |
| 9 | DeployKeyVault    | Whether Key Vault is redeployed. It should always be deployed initially       |
| 10 | DeployAzureSQL    | Whether Azure SQL is redeployed. It should always be deployed initially       |
| 11 | DeployAzureSQLArtifacts    | Whether Azure SQL tables and stored procedures are redeployed. They should always be deployed initially       |
| 12 | DeployMetadataDrivenPipelinesToSynapse    | If False, pipelines will be deployed to ADF. It is recommended to set this feature flag to false      | 
| 13 | DeployADF    | Whether ADF is redeployed. It should always be deployed initially unless EnvironmentWillNotIncludeADF is true      |
| 14 | DeployADFArtifacts    | Whether ADF artifacts like pipelines and linked services are redeployed. They should always be deployed initially unless EnvironmentWillNotIncludeADF is true      | 
| 15 | DeploySynapse    | Whether Synapse is redeployed. It should always be deployed initially |
| 16 | DeploySynapsePools    | Whether Synapse SQL/Spark Pools are redeployed. Only Spark Pools are deployed currently. It should always be deployed initially |
| 17 | DeploySynapseArtifacts    | Whether Synapse artifacts like pipelines and linked services are redeployed. They should always be deployed initially | 
| 18 | DeploySynapseWithDataExfiltrationProtection    | Whether to enable exfiltration protection in Synapse. You *cannot* orchestrate Azure Machine Learning Workspace activities using Synapse if enabled | 
| 19 | DeployPurview    | Whether Purview is deployed/redeployed      |
| 20 | DeployLogicApp   | Whether the Logic App and its associated resources like application insights are redeployed. It should always be deployed initially     |
| 21 | DeployLogicAppArtifacts   | Whether the Logic App workflows are redeployed. They should always be deployed initially      |
| 22 | DeployLogAnalytics   | Whether Log Analytics is deployed/redeployed      |
| 23 | DeployMLWorkspace  | Whether an Azure ML Workspace and its associated artifacts like container registry are deployed or redeployed |
| 24 | DeployMLCompute  | Whether compute clusters for an Azure ML workspace are deployed or redeployed |
| 25 | DeployCognitiveService  | Whether Cognitive Service is deployed/redeployed       | 
| 26 | DeployEventHubNamespace  | Whether an Event Hub Namespace is deployed/redeployed       | 
| 27 | DeployStreamAnalytics  | Whether Stream Analytics is deployed/redeployed       |
| 28 | DeployDataScienceToolkit  | Whether DeployDataScienceToolkit application is deployed/redeployed       |