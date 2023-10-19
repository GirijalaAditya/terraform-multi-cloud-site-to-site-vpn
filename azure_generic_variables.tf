variable "azure_rg_name" {
  type        = string
  description = "Azure Resource Group Name"
}

variable "client_id" {
  type        = string
  description = "Client ID"
}

variable "client_secret" {
  type        = string
  description = "Client Secret"
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
}

variable "azure_vm_password" {
  type        = string
  description = "Azure VM Password"
  sensitive = true
}