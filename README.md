# Azure ML VNET

Implementation of [AML network isolation][1] with a customer-managed VNET.

<img src=".assets/aml.png" />

## Setup

Create the variables file:

```sh
cp config/template.tfvars .auto.tfvars
```

Configuration:

1. Set your IP address in the `allowed_ip_address` variable.
2. Set your the Entra ID tenant in the  `entraid_tenant_domain` variable.

Generate a key pair to manage instances with SSH:

```sh
ssh-keygen -f keys/ssh_key
```

Create the resources:

```sh
terraform init
terraform apply -auto-approve
```

Confirm and approve any private endpoints, both in the subscription, and within the managed AML workspace.

Manually create the datastores in AML and run the test notebooks.

## Compute

Create the AML compute and other resources by changing the appropriate flags:

> 💡 Follow the [documentation][2] steps to enable AKS VNET integration, if not yet done so.

```terraform
mlw_instance_create_flag = true
mlw_aks_create_flag      = true
mlw_mssql_create_flag    = true
vm_proxy_create_flag     = true
```

## Forward Proxy

### Squid

Connect to the proxy VM server:

```sh
ssh -i keys/ssh_key azureuser@<public-ip>
```

Squid will already be installed via `cloud-init`. If you need to make changes, check the [official docs][5].

Testing with default configuration:

```sh
curl -x "http://127.0.0.1:3128" "https://github.com/"
```

### NGINX

> ⚠️ From this [thread][4], running NGINX full proxy with HTTPS will required additional configuration steps.

Connect to the proxy server:

```sh
ssh -i keys/ssh_key azureuser@<public-ip>
```

I've used [this article][3] as reference to setup the forward proxy server on NGINX.

1. Comment the default server config within `/etc/nginx/sites-enabled/default`.
2. Create the [nginx/forward][nginx/forward] config file.
3. Restart NGINX (`systemctl restart nginx.service`).

The forward proxy service should be available at port `8888`.

```sh
curl -x "http://127.0.0.1:8888" "https://github.com/"
```

---

### Clean-up

Delete the resources and avoid unplanned costs:

```sh
terraform destroy -auto-approve
```

[1]: https://learn.microsoft.com/en-us/azure/machine-learning/how-to-network-isolation-planning?view=azureml-api-2#recommended-architecture-use-your-azure-vnet
[2]: https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration
[3]: https://www.baeldung.com/nginx-forward-proxy
[4]: https://serverfault.com/a/1090581/560797
[5]: https://ubuntu.com/server/docs/how-to-install-a-squid-server
