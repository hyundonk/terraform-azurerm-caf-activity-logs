# Defines the subscription-wide logging and eventing settings
# Creating the containers on Storage Account and Event Hub (optional)

module "caf_name_st" {
  source  = "aztfmod/caf-naming/azurerm"
  version = "~> 0.1.0"
  
  name    = var.name
  type    = "st"
  convention  = var.convention
}

module "caf_name_evh" {
  source  = "aztfmod/caf-naming/azurerm"
  version = "~> 0.1.0"

  name    = var.name
  type    = "evh"
  convention  = var.convention
}

resource "azurerm_storage_account" "log" {
  name                      = module.caf_name_st.st
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  access_tier               = "Hot"
  enable_https_traffic_only = true
  tags                      = local.tags

  blob_properties {
    logging {
      delete  = enabled
      read    = enabled
      write   = enabled
      version = "2"
      retention_policy_days = "30"
    }
  }
}

resource "azurerm_eventhub_namespace" "log" {
  count = var.enable_event_hub ? 1 : 0 
  
  name                    = module.caf_name_evh.evh
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku                     = "Standard"
  capacity                = 2
  tags                    = local.tags
  auto_inflate_enabled    = false
  # kafka_enabled         = true

}

resource "azurerm_monitor_diagnostic_setting" "audit" {
  name                           = var.name
  target_resource_id             = data.azurerm_subscription.current.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  eventhub_authorization_rule_id = var.enable_event_hub ? "${azurerm_eventhub_namespace.log[0].id}/authorizationrules/RootManageSharedAccessKey" : null
  eventhub_name                  = var.enable_event_hub ? azurerm_eventhub_namespace.log[0].name : null
  storage_account_id             = azurerm_storage_account.log.id

  dynamic "log" {
    for_each = var.audit_settings_object.log
    content {
      category    = log.value[0]
      enabled     = log.value[1]
      retention_policy {
        enabled   = log.value[2]
        days      = log.value[3]
      }
    }
  } 
}

/*
resource "azurerm_monitor_log_profile" "subscription" {
  name = "default"

  categories = [
    "Action",
    "Delete",
    "Write"
  ]

# Add all regions - > put in variable
# az account list-locations --query '[].name' 
# updated Dec 15 2019 
  locations = [
  "global",
  "eastasia",
  "southeastasia",
  "centralus",
  "eastus",
  "eastus2",
  "westus",
  "northcentralus",
  "southcentralus",
  "northeurope",
  "westeurope",
  "japanwest",
  "japaneast",
  "brazilsouth",
  "australiaeast",
  "australiasoutheast",
  "southindia",
  "centralindia",
  "westindia",
  "canadacentral",
  "canadaeast",
  "uksouth",
  "ukwest",
  "westcentralus",
  "westus2",
  "koreacentral",
  "koreasouth",
  "francecentral",
  "francesouth",
  "australiacentral",
  "australiacentral2",
  "uaecentral",
  "uaenorth",
  "southafricanorth",
  "southafricawest",
  "switzerlandnorth",
  "switzerlandwest",
  "germanynorth",
  "germanywestcentral",
  "norwaywest",
  "norwayeast"
  ]

# RootManageSharedAccessKey is created by default with listen, send, manage permissions
servicebus_rule_id = var.enable_event_hub == true ? "${azurerm_eventhub_namespace.log[0].id}/authorizationrules/RootManageSharedAccessKey" : null
storage_account_id = azurerm_storage_account.log.id

  retention_policy {
    enabled = true
    days    = var.logs_rentention
  }
}
*/
