variable "workload" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet" {
  type = string
}

variable "size" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}
