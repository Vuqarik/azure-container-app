#!/bin/bash

# Load variables for use
source ./variables.sh

layers=$(cat variables.sh | grep "_KEY_NAME=" | wc -l)

if [ $layers == 1 ] ; then
    declare -a azure_partial_conf=("$TERRAFORM_KEY_NAME")
else
    exit 1
fi

   for i in "${azure_partial_conf[@]}"
   do
      source ./variables.sh
      RG=$RESOURCE_GROUP_NAME
      SA=$STORAGE_ACCOUNT_NAME
      CN=$CONTAINER_NAME
      cat << EOF > azure_$i.conf
   resource_group_name  = "$RG"
   storage_account_name = "$SA"
   container_name       = "$CN"
   key                  = "$i"
EOF

   done
 
