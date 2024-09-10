#!/bin/bash

programme=$0

function usage {
    echo '
NAME
     $azure_seed_pipeline -- Push azure pipeline based on yml configuration present in the terraform folder. 

SYNOPSIS
     azure_seed_pipeline flags [ -p or --pipeline ] [ -sk or --secret-key ]
     See EXAMPLES section on usage
     
DESCRIPTION
     For each operand that names a file of a type other than directory, ls displays its name as well as any requested, associated information.  For each operand that names a file of type directory, ls displays the names of files con-
     tained within that directory, as well as any requested, associated information.

EXAMPLES
     Following lines provide some examples on how to use this utility.

    ./$azure_seed_pipeline.sh -p=scaffold -sk=secretkeytf

    ./$azure_seed_pipeline.sh --pipeline=network --secret-key=secretkeytf
'''
    exit 1
}

function validatereposexist () {
    source ./variables.sh
    echo "Validating few things."
    if [[ $(az repos list --organization https://dev.azure.com/${ORGANIZATION} --project ${DEVOPS_PROJECT} --query [].webUrl | grep ${DEVOPS_REPO}) == "" ]] || \
       [[ $(az repos list --organization https://dev.azure.com/${ORGANIZATION} --project ${DEVOPS_PROJECT} --query [].webUrl | grep ${DEVOPS_TFMODULES_REPO}) == "" ]] || \
       [[ $(az repos list --organization https://dev.azure.com/${ORGANIZATION} --project ${DEVOPS_PROJECT} --query [].webUrl | grep ${DEVOPS_ARMTEMPLATES_REPO}) == "" ]] ;
    then
        echo "Doesn't look like the current ${DEVOPS_REPO} or ${DEVOPS_TFMODULES_REPO} or ${DEVOPS_ARMTEMPLATES_REPO} repos exists in Azure Devops."
        echo "Please import or copy the above repos into Azure Devops before running this."
        exit 1
    else
        echo ""
        echo "I found the repos I can work with at https://dev.azure.com/${ORGANIZATION}/${DEVOPS_PROJECT}/_settings/repositories"
    fi
}

function updatetemplates () {
    # Load variables for use
    source ./variables.sh
    if [[ $(git ls-files --deleted --modified --others --exclude-standard) == "" ]];
    then
        echo "Preparing ${PIPELINE} for seeding."
        currentbranch=$(git symbolic-ref --short -q HEAD)
        cp ./templates/azure-pipelines-templates/azure-deploy.yml "${PIPELINE}/deploy.yml"
        cp ./templates/azure-pipelines-templates/azure-destroy.yml "${PIPELINE}/destroy.yml"
        sed -e "s/changemevg/${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}/g" -i "${PIPELINE}/deploy.yml"
        sed -e "s/changemelayer/${PIPELINE}/g" -i "${PIPELINE}/deploy.yml"
        sed -e "s/changemeproject/${DEVOPS_PROJECT}/g" -i "${PIPELINE}/deploy.yml"
        sed -e "s/changememodules/${DEVOPS_TFMODULES_REPO}/g" -i "${PIPELINE}/deploy.yml"
        sed -e "s/changemetemplates/${DEVOPS_ARMTEMPLATES_REPO}/g" -i "${PIPELINE}/deploy.yml"
        sed -e "s/changemebranch/${currentbranch}/g" -i "${PIPELINE}/deploy.yml"
        sed -e "s/changemeenv/${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}/g" -i "${PIPELINE}/deploy.yml"


        sed -e "s/changemevg/${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}/g" -i "${PIPELINE}/destroy.yml"
        sed -e "s/changemelayer/${PIPELINE}/g" -i "${PIPELINE}/destroy.yml"
        sed -e "s/changemeproject/${DEVOPS_PROJECT}/g" -i "${PIPELINE}/destroy.yml"
        sed -e "s/changememodules/${DEVOPS_TFMODULES_REPO}/g" -i "${PIPELINE}/destroy.yml"
        sed -e "s/changemetemplates/${DEVOPS_ARMTEMPLATES_REPO}/g" -i "${PIPELINE}/destroy.yml"

        echo "Some changes were made to files and those file need to be pushed to the remote."
        echo "I found some changes in current branch $(git rev-parse --abbrev-ref HEAD)"
        echo "Changes:"
        git status -s
        read -p "Is it ok to push those changes to $(git rev-parse --abbrev-ref HEAD) branch? [yn] " answer
        if [[ $answer = y ]] ; then
            echo "Committing and pushing changes"
            git add .
            git commit -am "${PIPELINE} deploy / destroy yml pipelines"
            git push
        else
            echo ""
            echo "Undoing changes. Cannot continue without pushing those changes."
            git stash -u
            echo $error
            exit 1
        fi
    else
        echo ""
        git status -s
        echo "Your working tree is dirty, unstaged or not pushed. This step requires that no other changes are to be staged / pushed."
        echo "Either stash your changes or clean your working tree and try again."
        exit 1
    fi
}

function pipeline () {

     # Load variables for use
     source ./variables.sh

     az pipelines variable-group create --organization https://dev.azure.com/${ORGANIZATION} --project ${DEVOPS_PROJECT} --name "${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}-${PIPELINE}_vg" --variables workingpath="${PIPELINE}" KEY=${KEY_NAME}
     az pipelines create --name "${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}-${PIPELINE}-deploy" --organization https://dev.azure.com/${ORGANIZATION} --project ${DEVOPS_PROJECT} --repository ${DEVOPS_REPO} --branch ${currentbranch} --yml-path "${PIPELINE}/deploy.yml" --repository-type tfsgit --skip-first-run true
# JKM 2022-06-15 destroy pipelines no longer created as standard
# Uncomment if required to build a destroy pipeline
#     az pipelines create --name "${DEPLOYMENT_ENVIRONMENT}${ENVIRONMENT}-${PIPELINE}-destroy" --organization https://dev.azure.com/${ORGANIZATION} --project ${DEVOPS_PROJECT} --repository ${DEVOPS_REPO} --branch ${currentbranch} --yml-path "${PIPELINE}/destroy.yml" --repository-type tfsgit --skip-first-run true

}

for i in "$@"
do
    case $i in
        -p=*|--pipeline=*)
        PIPELINE="${i#*=}"
        shift # past argument=value
        ;;
        -sk=*|--secret-key=*)
        KEY_NAME="${i#*=}"
        shift # past argument=value
        ;;
        --default)
        DEFAULT=YES
        shift # past argument with no value
        ;;
        *)
            # unknown option
        ;;
    esac
done

# echo $PIPELINE

if [[ ! -n ${AZURE_DEVOPS_EXT_PAT} ]] ; then
    echo "Looks like you are trying to run this without a valid Azure DevOps PAT. Can't continue :("
    exit 1
fi

if [[ "${PIPELINE}" == "scaffold" || "${PIPELINE}" == "network" || "${PIPELINE}" == "infra" || "${PIPELINE}" == "sharedservices" ]]; then
    validatereposexist
    updatetemplates
     echo "Pushing ${PIPELINE} pipeles to Azure DevOps."
     pipeline
else
    echo "Maybe you need to read the docs"
    usage
fi
