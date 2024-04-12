# Project
location = "brazilsouth"
workload = "litware"

# The IPv4 from where you'll access the resources
allowed_ip_address = ""

# VNET
vnet_training_nsg_destination_address_prefix = "Internet" # Internet, VirtualNetwork

# Machine Learning - Training
mlw_instance_create_flag             = false
mlw_instance_vm_size                 = "STANDARD_D2AS_V4"
mlw_instance_ssh_public_key_rel_path = "keys/ssh_key.pub"

# Machine Learning - AKS
mlw_aks_create_flag = false
mlw_aks_node_count  = 1
mlw_aks_vm_size     = "Standard_D2as_V4"

# Proxy
vm_proxy_create_flag = false
vm_proxy_vm_size     = "Standard_B2pts_v2"

# MSSQL
mlw_mssql_create_flag      = false
mssql_sku                  = "Basic"
mssql_max_size_gb          = 2
mssql_admin_login          = "sqladmin"
mssql_admin_login_password = "P4ssw0rd!2023"

# Virtual Machine
vm_size      = "Standard_B4as_v2"
vm_image_sku = "win11-23h2-ent"
vm_password  = "P@ssw0rd.123"

# Data Scientist user
entraid_tenant_domain           = ""
entraid_data_scientist_username = "datascientist"
entraid_data_scientist_password = "P4ssw0rd!2023"
