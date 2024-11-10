terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.5.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "19b8eeb9-3837-4246-bf64-0c2ba1cc117c"
}