
variable "subscriptionId" {
  default     = "f40a4e41-5aa3-413d-a998-890774d0a55b"
  description = "The Azure Subscription ID in which all resources in this example should be created."
}

variable "resourceGroupNamePrefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resourceGroupName" {
  default     = ""
  description = "The Azure Resource Group name in which all resources in this example should be created."
}

variable "location" {
  default     = "North Europe"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "applicationInsightsName" {
  description = "Your Application Insights name."
}

variable "logAnalyticsName" {
  description = "Your Log Analytics name."
}

variable "functionAppName" {
  description = "Your Flex Consumption app name."
}

variable "functionPlanName" {
  description = "Your Flex Consumption plan name."
}

variable "storageAccountName" {
  description = "Your storage account name."
}

variable "maximumInstanceCount" {
  default = 100
  description = "The maximum instance count for the app"
}

variable "instanceMemoryMB" {
  default = 512
  description = "The instance memory for the instances of the app: 512, 2048, or 4096"
}

variable "functionAppRuntime" {
  default = "node"
  description = "The runtime for your app. One of the following: 'dotnet-isolated', 'python', 'java', 'node', 'powershell'"
}

variable "functionAppRuntimeVersion" {
  default = "20"
  description = "The runtime and version for your app. One of the following: '3.10', '3.11', '7.4', '8.0', '10', '11', '17', '20', '21', '22'"
}
variable "zoneRedundant" {
  default = false
  description = "Whether the app is zone redundant or not"
}
