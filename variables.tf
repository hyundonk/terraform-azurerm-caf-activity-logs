variable "resource_group_name" {
  description = "(Required) Name of the resource group to deploy the activity logs."
}

variable "location" {
  description = "(Required) Define the region where the resources will be created."
}

variable "log_analytics_workspace_id" {
  description = "(Required) Id of the Log Analytics workspace"
}

variable "tags" {
  description = "(Required) Tags for the logs repositories to be created "
  
}
variable "prefix" {
  description = "(Optional) You can use a prefix to add to the list of resource groups you want to create"
}

variable "logs_rentention" {
  description = "(Required) Number of days to keep the logs for long term retention"
}

variable "enable_event_hub" {
  description = "(Optional) Determine to deploy Event Hub for the configuration"
  default = true
}

variable "convention" {
  description = "(Required) Naming convention method to use"  
}

variable "name" {
  description = "(Required) Name for the objects created (before naming convention applied.)"    
}

variable "audit_settings_object" {
  description = "(Required) Contains the settings for Azure Audit activity log retention"
}
