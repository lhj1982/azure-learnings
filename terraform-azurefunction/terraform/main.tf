
# Create a random pet to generate a unique resource group name
resource "random_pet" "rg_name" {
  prefix = var.resourceGroupNamePrefix
}

# Random String for unique naming of resources
resource "random_string" "name" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = random_pet.rg_name.id
  tags = {
    environment = "dev"
    source = "terraform"
    owner = "james"
  }
}

resource "azapi_resource" "serverFarm" {
  type = "Microsoft.Web/serverfarms@2024-04-01"
  schema_validation_enabled = false
  location = var.location
  name = coalesce(var.functionPlanName, random_string.name.result)
  parent_id = azurerm_resource_group.rg.id
  body = {
      kind = "functionapp",
      sku = {
        tier = "FlexConsumption",
        name = "FC1"
      },
      properties = {
        reserved = true,
        zoneRedundant = var.zoneRedundant
      }
  }
}

resource "azurerm_storage_account" "storageAccount" {
  name                     = coalesce(var.storageAccountName, random_string.name.result)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled = false
}

resource "azurerm_storage_container" "storageContainer" {
  name                  = "deploymentpackage"
  storage_account_id  = azurerm_storage_account.storageAccount.id
  container_access_type = "private"
}

resource "azurerm_log_analytics_workspace" "logAnalyticsWorkspace" {
  name                = coalesce(var.logAnalyticsName, random_string.name.result)
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "appInsights" {
  name                = coalesce(var.applicationInsightsName, random_string.name.result)
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "Node.JS"
  workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
}

locals {
  blobStorageAndContainer = "${azurerm_storage_account.storageAccount.primary_blob_endpoint}deploymentpackage"
}

resource "azapi_resource" "functionApps" {
  type = "Microsoft.Web/sites@2024-04-01"
  schema_validation_enabled = false
  location = var.location
  name = coalesce(var.functionAppName, random_string.name.result)
  parent_id = azurerm_resource_group.rg.id
  body = {
    kind = "functionapp,linux",
    identity = {
      type: "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.serverFarm.id,
        functionAppConfig = {
          deployment = {
            storage = {
              type = "blobContainer",
              value = local.blobStorageAndContainer,
              authentication = {
                type = "SystemAssignedIdentity"
              }
            }
          },
          scaleAndConcurrency = {
            maximumInstanceCount = var.maximumInstanceCount,
            instanceMemoryMB = var.instanceMemoryMB
          },
          runtime = { 
            name = var.functionAppRuntime, 
            version = var.functionAppRuntimeVersion
          }
        },
        siteConfig = {
          appSettings = [
            {
              name = "AzureWebJobsStorage__accountName",
              value = azurerm_storage_account.storageAccount.name
            },
            {
              name = "APPLICATIONINSIGHTS_CONNECTION_STRING",
              value = azurerm_application_insights.appInsights.connection_string
            }
          ]
        }
      }
  }
  depends_on = [ azapi_resource.serverFarm, azurerm_application_insights.appInsights, azurerm_storage_account.storageAccount ]
}

data "azurerm_linux_function_app" "fn_wrapper" {
    name = azapi_resource.functionApps.name
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "storage_roleassignment" {
  scope = azurerm_storage_account.storageAccount.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id = data.azurerm_linux_function_app.fn_wrapper.identity.0.principal_id
  principal_type = "ServicePrincipal"
}