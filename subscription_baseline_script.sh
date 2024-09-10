#!/bin/bash

# Load variables for use
source ./variables.sh

error="Either Subscription is not set, you cancelled, dependent folders / repos are missing or something else went wrong. Exiting"

confirm_number_of_layers (){
   read -p "How many layers do you want (Each layer means a separate state file) [1234] " answer
   re='^[0-9]+$'
   error="Erros: Either you didn't give a value, entered a non-numerical value or you have entered a number of layers larger than 4 which is not suggested."
   if ! [[ $answer =~ $re ]] || [[ $answer -gt 4 ]] ; then
      echo "$error"
      exit
   elif [[ $answer == 4 ]] ; then
      echo "Contunuring with default $answer layers"
   elif [[ $answer == 3 ]] ; then
      # echo "$answer"
      sed '/^SHAREDSERVICES_PREFIX/d' -i variables.sh
      sed '/^SS_KEY_NAME/d' -i variables.sh
      rm -rf ./sharedservices
   elif [[ $answer == 2 ]] ; then
      # echo "$answer"
      sed '/^SHAREDSERVICES_PREFIX/d' -i variables.sh 
      sed '/^SS_KEY_NAME/d' -i variables.sh
      sed '/^INFRA_PREFIX/d' -i variables.sh
      sed '/^INFRA_KEY_NAME/d' -i variables.sh
      rm -rf ./sharedservices
      rm -rf ./infra
   elif [[ $answer == 1 ]] ; then
      # echo "$answer"
      sed '/^SHAREDSERVICES_PREFIX/d' -i variables.sh
      sed '/^SS_KEY_NAME/d' -i variables.sh
      sed '/^INFRA_PREFIX/d' -i variables.sh
      sed '/^INFRA_KEY_NAME/d' -i variables.sh
      sed '/^NETWORK_PREFIX/d' -i variables.sh
      sed '/^NETWORK_KEY_NAME/d' -i variables.sh
      rm -rf ./sharedservices
      rm -rf ./infra
      rm -rf ./network

   else
      # echo "$answer"
      echo $error
      exit 1
   fi
}

confirm (){
   read -p "Ok to continue? [yn] " answer
   if [[ $answer = y ]] ; then
      echo "Running Subscription baseline scripts"
   else
      echo ""
      echo ""
      echo $error
      exit 1
   fi
}

runsubscriptionbaselines (){
   source ./variables.sh

   # Create resource group
   az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

   # Create storage account
   az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
   stoaccountid=$(az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv)

   # Get storage account key
   ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

   # Create blob container
   az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

   # Create keyvault to store secret e.g. storage account key
   az keyvault create --location $LOCATION --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP_NAME --sku Premium
   keyVaultid=$(az keyvault show --name $KEYVAULT_NAME --query id --output tsv)

   #Enable diagnostics settings on the key vault
   az monitor diagnostic-settings create --storage-account $stoaccountid --resource $keyVaultid --name 'Audit Log Settings' --logs '[{"category": "AuditEvent","enabled": true, "retentionPolicy": {"enabled": true,"days": 180}}]' --metrics '[{"category": "AllMetrics","enabled": true, "retentionPolicy": {"enabled": true,"days": 180}}]'

   # Create keyvault to store secret, individual keys for different components and pipeline setup
   declare -a azure_secret=("$SCAFFOLD_KEY_NAME" "$NETWORK_KEY_NAME" "$INFRA_KEY_NAME" "$SS_KEY_NAME")
   for i in "${azure_secret[@]}"
   do
      az keyvault secret set --name $i --vault-name $KEYVAULT_NAME --value $ACCOUNT_KEY
   done

   echo "Setup complete"
   echo "You can fetch the secret by running - az keyvault secret show --name <keyname> --vault-name $KEYVAULT_NAME --query value -o tsv"
}

# This is not used at present, the pipelines use the service connection and not the secrets in the variable group, which this is used to populate

# if [[ ! -n ${ARM_CLIENT_ID} ]] ;
# then
#    echo "You don't have the right environment variables setup. Please see the README file."
#    exit 1
# fi

if [[ -n ${HUB_SUBS} && -d "../$DEVOPS_TFMODULES_REPO/.git" && -d "../$DEVOPS_ARMTEMPLATES_REPO/.git" ]] ; then
   echo "It seems you have the right variables set and dependent repos available."
   confirm_number_of_layers
   name=`az account show --query name`
   id=`az account show --query id`
   echo "NOTE: PLEASE RUN THIS SCRIPT ONLY ONCE AT THE START OF A SUBSCRIPTION."
   echo ""
   echo "You are trying to run baseline script referencing '$DEVOPS_REPO' repo in https://dev.azure.com/$ORGANIZATION/$DEVOPS_PROJECT"
   echo "The script will run against the current subsciption $name($id) on ${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}."
   echo "Please also make sure you have configured the Service Connection at https://dev.azure.com/$ORGANIZATION/$DEVOPS_PROJECT/_settings/adminservices"
   echo "Assuming the above values are correct."
   echo ""
   confirm
   runsubscriptionbaselines
   . ./generate_tfpatial_config.sh
   read -p "Do you want to Setup Azure DevOps now? You can always setup later by running setup_azdevops.sh script. [yn] " answer
   if [[ $answer = y ]] ; then
      echo "Setting up Azure Devops"
      . ./setup_azdevops.sh
   fi
else
   echo "You need dependent repos in the same folder as the current repo. Please make sure they are named correctly in Variable.sh file."
   echo '''
DEVOPS_REPO (this repo)
├───templates
    └───files
├───scaffold
├───infra
├───network
├───Readme.MD
└───scripts.sh
|
DEVOPS_TFMODULES_REPO (for Azure terraform modules)
├───terraform-azurerm-key-vault
├───terraform-azurerm-storage
├───terraform-azurerm-vm
├───terraform-azurerm-vnet
└───terraform-azurerm-nsg
|
DEVOPS_ARMTEMPLATES_REPO (for Azure arm templates)
├───azure-arm-policies
└───azure-arm-templates
   '''
   echo $error
   exit 1
fi
