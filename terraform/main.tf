resource "random_string" "group" {
  length  = 16
  special = false
  upper   = false
}

resource "azurerm_resource_group" "function" {
  name     = random_string.group.result
  location = "australia east"
}

resource "random_string" "storage" {
  length  = 16
  special = false
  upper   = false
}

resource "azurerm_storage_account" "function" {
  name                     = random_string.storage.result
  resource_group_name      = azurerm_resource_group.function.name
  location                 = azurerm_resource_group.function.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "function" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.function.location
  resource_group_name = azurerm_resource_group.function.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}


resource "random_string" "appinsights" {
  length  = 16  
  special = false
  upper   = false
}

resource "azurerm_application_insights" "insights" {
  name                = random_string.appinsights.result
  location            = azurerm_resource_group.function.location
  resource_group_name = azurerm_resource_group.function.name
  application_type    = "web"
}

resource "random_string" "function" {
  length  = 16
  special = false
  upper   = false
}

resource "azurerm_function_app" "function" {
  name                       = random_string.function.result
  location                   = azurerm_resource_group.function.location
  resource_group_name        = azurerm_resource_group.function.name
  app_service_plan_id        = azurerm_app_service_plan.function.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key
  os_type                    = "linux"
  version                    = "~4"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.insights.instrumentation_key}"
  }

  site_config {
    linux_fx_version = "python|3.11"
  }
}
