#!/bin/bash

source ./variables.sh

if [[ -n ${AZURE_DEVOPS_EXT_PAT} ]] ; then

    echo "Setting up https://dev.azure.com/$ORGANIZATION/$DEVOPS_PROJECT."

    az devops configure --defaults organization=https://dev.azure.com/$ORGANIZATION project=$DEVOPS_PROJECT

    commonvgname=${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}_common_vg
    az pipelines variable-group create --project ${DEVOPS_PROJECT} --organization https://dev.azure.com/${ORGANIZATION} --name $commonvgname \
    --variables hub_subscription=$HUB_SUBS \
    RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME \
    STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME \
    CONTAINER_NAME=$CONTAINER_NAME

else
    source ./variables.sh
    echo "Could not find a PAT token or an export variable AZURE_DEVOPS_EXT_PAT"
    echo "You can generate one at https://dev.azure.com/$ORGANISATION/_usersSettings/tokens"
    cat << END_TEMPLATE
----
  export AZURE_DEVOPS_EXT_PAT=<pat-token>
  az devops configure --defaults organization=https://dev.azure.com/${ORGANIZATION} project=${DEVOPS_PROJECT}
  az pipelines variable-group list
----
END_TEMPLATE
    echo "$template"
    exit 1
fi

