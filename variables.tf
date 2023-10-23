variable "subscription_id" {
  default = "846b8f05-3084-4014-a069-be8b249676c4"
  type = string
  description = "Azure Subscription Id"
}

# Variables
variable "project_name" {
  default = "project-name"
  type = string
  description = "Project Name and Code"
}

variable "vm_size" {
  default = "Standard_B2s"
  type = string
  description = "Size of VM"
}

variable "region" {
  default = "East Us 2"
  type = string
  description = "Location/Region of VM & RG"
}

variable "vm_name" {
  default = "project-name-stg"
  type = string
  description = "VM name"
}

variable "vm_postfix" {
  default = "ubuntu-eu2-MAS"
  type = string
  description = "VM Name Postfix"
}

variable "enverionment" {
  default = "env-name"
  type = string
  description = "enverionment name"
}

variable "admin_username" {
  default = "vm-root-username"
  type = string
  description = "Admin Username"
}

variable "db_username" {
  default = "db-username"
  type = string
  description = "Admin Username"
}
variable "db_password" {
  default = "db-password"
  type = string
  description = "DB Password"
}

variable "db_sku_name" {
  default = "B_Standard_B1ms"
  type = string
  description = "VM Size"
}