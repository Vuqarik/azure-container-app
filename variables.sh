#!/bin/bash


ORG=dev # Globally Unique across Azure. A Global prefix (No special characters, see Azure naming conventions)

### Following Variables are strictly related to Azure Devops
ORGANIZATION=mydevopsorganization # Azure DevOps Organisation
DEVOPS_PROJECT=Azure # Name of the project on Azure DevOps
DEVOPS_REPO=$(basename `git rev-parse --show-toplevel`) # Current repo name for DevOps Project
DEVOPS_TFMODULES_REPO=terraform-modules # Repo name where terraform modules are stored
DEVOPS_ARMTEMPLATES_REPO=arm-templates # Repo name where arm templates are stored
# Generates a variable to be used with Azuredevops with format subscription-name(subscription_id) e.g. abc-landingzone(xxxxxxxxxxxxxxxxxxxxxxxxxxxx)
HUB_SUBS="$(az account show | jq -r .name)($(az account show | jq -r .id))"

### Following variables are related to Azure Cloud and Resources created for it.
DEPLOYMENT_ENVIRONMENT=northamerica # No special characters allowed.
ENVIRONMENT=dev  # Environment e.g. Dev / Prod or Leave Empty for Shared Services. No special characters allowed.
LOCATION=eastus # Must use valid Azure location
TERRAFORM_PREFIX=terraform # Name of the layer, default layer named terraform is used for infra resources, VPN Gateways, Firewalls etc.
POSTFIX=tf # Postfix to identify resources generated using this script are terraform specific.

RESOURCE_GROUP_NAME=${ORG}rg${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}${POSTFIX}
STORAGE_ACCOUNT_NAME=${ORG}sa${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}${POSTFIX}
CONTAINER_NAME=${ORG}cn${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}${POSTFIX}
KEYVAULT_NAME=${ORG}kv${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}${POSTFIX}

TERRAFORM_KEY_NAME=${ORG}key${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}${TERRAFORM_PREFIX}${POSTFIX}

