# Terraform Settings Block
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.19"
    }
  }
}

# Azure Provider 
provider "azurerm" {
  features {}
  client_id                  = var.client_id
  client_secret              = var.client_secret
  tenant_id                  = var.tenant_id
  subscription_id            = var.subscription_id
  skip_provider_registration = true
}

# AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}