
**Install these Softwares**

 - Bash
 - Terraform v1.0.2 or above
 - Azure cli v2.21.0
 - jq 1.5
 

# 1. Azure Cloud Authentication ##

## User Identity ###
If using a managed Identity please get the `SUBSCRIPTION ID` from Azure portal and use below:

    export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
    az login
    az account set --subscription $ARM_SUBSCRIPTION_ID
    az account show

## Service Principal ###
You can create a new Service Principal if you have enough permissions using the command:

```
az ad sp create-for-rbac -n "SP_<NAME>_TF_Builder" --role Contributor
--scopes /subscriptions/subscriptionid1 /subscriptions/subscriptionid2
```

```
az ad sp create-for-rbac -n "SP_<NAME>_TF_Builder" --role "Resource Policy Contributor" \ --scopes subscriptions/subscriptionid1 /subscriptions/subscriptionid2
```

If using a managed Identity please get the `SUBSCRIPTION ID`, `TENANT ID`, Service Principal `CLIEND ID` and `SECRET` generated during the creation of service principal from Azure portal and use as below:

    export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
    export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
    export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
    export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
    export AZURE_DEVOPS_EXT_PAT="urdcs4pfizzatimwva7mfb276i53b56cpdjdmzwakandafoeva"
    az login --service-principal --username $ARM_CLIENT_ID --password=$ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
    az account set --subscription $ARM_SUBSCRIPTION_ID
    az account show

# 2. Azure DevOps Setup ##

## Azure Repos ###

To use Azure Devops in a meaningful way. You have to either import your repos into your Azure DevOps or create a link to your github so that repos can be access from Azure DevOps.

**Note**: Please make sure you import the repos under the same name as cloned locally.

## Azure Devops Personal Access Token ###

You will need PAT to authenticate against Azure DevOps. To get PAT to be used with Azure DevOps, please see docs at https://docs.microsoft.com/en-gb/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page#create-a-pat. 

- To generate a PAT token https://dev.azure.com/$ORGANISATION/_usersSettings/tokens

## Service Connection ###
If you are using Service Principal to be able to create variables / variable groups and Azure Devops, a Service Connection has to be created within your Azure DevOps project at https://dev.azure.com/$ORG/$DEVOPS_PROJECT/_settings/adminservices as shown below in an example:

![image info](./Service_Connection.PNG)

For more detail on service connections and how to setup one for use with Azure Devops, please see the docs below:
https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml

# 2. Run subscription baseline script

 - Login into Azure using Azure CLI as described before.

 - Set variables `ORG` and `LOCATION` and any others variables within `variables.sh` file

 - Run `subscription_baseline_script.sh` and follow instructions.

 - Observe as the script generates objects in Azure DevOps Library as well as partial `azure_key.conf` files for later use.
 
**Note:** Appropriate global variables are exported as part of this script which are made available in Azure pipeline library.

# 3a. Development workflow - Local workstation

## Usage with terraform

Once you have run the baseline script `subscription_baseline_script.sh`, you can use terraform to start developing IaC.

`terraform init --backend-config=<path/to/azure_key.conf>`

`terraform validate`

`terraform plan`

`terraform apply`

`terraform destroy`


# 3b. Development workflow - Azure DevOps 

To be able to use Azure devops to deploy your workloads Azure piplines are used. The pipeline is defined using azure devops `yml` format in each layer which themselves use tempalte available at `/tempaltes/azure-pipelines-templates/`. This repo provides scripts which setup pipelines as well as variable groups for each layer in Azure devops ready to be used.

## Seed Azure pipelines ##

- To seed an azure pipeline (`.yml` file), please run `azure_seed_pipeline.sh --pipeline=<layer> --secret-key=<secretkey>` script.
  - To seed scaffold pipeline, use `azure_seed_pipeline.sh -p=terraform -sk=terraformsecretkey`
  
**Note:** Appropriate variables are exported as part of this pipeline and seeding scripts are available to push pipeline code into Azure pipelines ready to be run.

## Run pipeline ##

Head over to Azure devops console at https://dev.azure.com/${ORG}/Azure/_build and observe that the pipelines are ready to be run. Click on the appropriate pipeline to start building.

**Note:** During the first run, you will be prompted to allow the pipeline to access variable groups and any other repos taht make up the pipeline.

