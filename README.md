# ACTS-Accelerator
This is the repository to develop the ACTS Accelerator including Tax, Procurement and Beneficial Ownership. Leveraging the Data Strategy IP as a base.

# VATTAX - released Jan 13 2023
The first release took the sample data from the Dream Demo and instead of utilizing data flows and dedicated SQL was instead deployed and developed with the Data Strategy IP. This deploys the core IP kit including:
1. Handshake service
1. Ingestion service
1. Control file service
1. Analytics service
1. Catalog / Classification service
1. Visualization service
1. Data Science Shared Data service

The steps required to deploy the Data Strategy IP and the additional Dream Demo artifacts are contained below

### Deploy Data Strategy IP package

The [deployment md document](DeliveryIP_GitHub/) in the DeliveryIP_GitHub folder will give step by step instructions on how to successfully deploy the infrastructure.
All required configuration, along with developer access to the deployed artifacts will be in place after deployment. This allows the Dream Demo data and PBI reports to be deployed quickly, with minimal interaction to have data flowing from ingestion through to the Power BI reports.

### Deploy the additional Synapse compute environment

The deployment of a separate compute environment to create the VATTAX data model and populate it needs to be deployed next. [See Instuctions here](DeliveryIP_GitHub/consumers/acts/) This Synapse will leverage pre-packaged data pipelines and data flows that will move the data from the raw container of the data lake and map it to SPARK External tables, creating a visual data model that analysts and BI teams can utilize for reporting, ML, etc. This deployment also will create a mapping table that will properly create the connection from the data in the raw container of the data lake, and map it (parameterization) to the Synapse Lake Database entities. 

### After the [Infrastructure](DeliveryIP_GitHub/) is deployed

Access the [DreamDemoSampleData](DreamDemoSampleData/) and place the entire zip file into the blob storage location "landing" zone. The ingestion service will start as soon as the zip file is added to the landing zone. The Ingestion service will:
1. Unpack the zip file
1. Match the files to entries in the control table
1. Ingest the sample data files into corresponding folder structure in the raw container of the ADLS2 account
Now the data required to populate the PBI models has been ingested into the data lake.

#### After all pipelines complete in Azure Data Factory, run the following pipelines within the Synapse Compute
1. In consumer Synapse, Run this pipeline, **PL_GetLoggingUpdates** - This pipeline gathers the results of the data ingestion run and populates a contol table that will be used for the next pipeline. When this pipeline completes its run, then run:
1. In consumer Synapse, Run this pipeline, **PL_RunDataflow_Part1** - This pipleine will coordinate the mapping of source location to the lake database entities that are already deployed in the Synapse environment. This Lake Database "TAXModel" is where the data is mapped through and lands in the ADLS2 account in the curated container as a new data product.


### Download the PBI Desktop files to your local drive

[DreamDemoReports](DreamDemoReports/)

The PBI files have parameterized connections to the data source entites in Synapse Lake Database. The user will need to update parameters to point to the newly deployed additional synapse workspace. This can be achieved by modifying the parameter that is in each of the PBI desktop reports. 

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
