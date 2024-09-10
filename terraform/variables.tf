variable "tenant_id" {
  description = "tenant id"
  default     = "Enter your tenant"
}

variable "buildby" {
  description = "Name of the build engineer"
  default     = "Vugar Khidirbayli"
}

variable "environment" {
  description = "View environment_map listeing below for valid values"
  default     = "Dev"
}

variable "location" {
  description = "Region to build into"
  default     = "East US"
}


variable "vm_count" {
  description = "VM count"
  default     = "1"
}

variable "vm_count_start" {
  description = "VM start count"
  default     = "0"
}

variable "keyvault_name" {
  description = "Name of Key Vault"
  default     = "devkeyvault"
}

variable "sa_key_name" {
  description = "Name of SA key for Encryption"
  default     = "devsakey"
}

variable "disk_key_name" {
  description = "Name of disk key for Encryption"
  default     = "devdiskkey"
}

variable "blob_storage_account_name" {
  description = "Name of blob Storage Account"
  default     = "devblobstorage"
}

variable "file_storage_account_name" {
  description = "Name of Fileshare Storage Account"
  default     = "devilestorage"
}

variable "bu_vnet_name" {
  description = "Name of the build engineer"
  default     = "dev-vnet"
}

variable "dev_subnet_list" {
  default = [
    {
      name               = "sn_dev_app"
      address_prefixes   = ["10.70.170.128/25"]
      service_endpoints  = ["Microsoft.Storage"]
      service_delegation = ""
    },
    {
      name               = "sn_dev_db"
      address_prefixes   = ["10.70.171.0/27"]
      service_endpoints  = ["Microsoft.Storage"]
      service_delegation = "Microsoft.Sql/managedInstances"
    },
    {
      name               = "sn_dev_gwint"
      address_prefixes   = ["10.70.171.32/27"]
      service_endpoints  = ["Microsoft.Storage"]
      service_delegation = ""
    },
    {
      name               = "AzureBastionSubnet"
      address_prefixes   = ["10.70.171.64/26"]
      service_endpoints  = ["Microsoft.Storage"]
      service_delegation = ""
    },
    {
      name               = "DevOpsBastionSubnet"
      address_prefixes   = ["10.70.171.128/26"]
      service_endpoints  = ["Microsoft.Storage"]
      service_delegation = ""
    }    
  ]
}

