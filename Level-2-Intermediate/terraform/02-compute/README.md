# 🟡 Level 2.2: Compute - Virtual Machines

## 🎯 Objectives

By the end of this exercise, you will:
- Create Linux/Windows Virtual Machines
- Configure VM extensions and custom data
- Use data sources to reference existing resources
- Implement count and for_each for multiple VMs

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **azurerm_linux_virtual_machine** | Linux VM resource |
| **data source** | Query existing Azure resources |
| **count** | Create multiple identical resources |
| **custom_data** | Bootstrap script (cloud-init) |
| **depends_on** | Explicit resource dependencies |

## 🤖 Copilot Prompts to Try

### Generate VM Configuration
```
Create a Terraform configuration for an Azure Linux VM with:
- Ubuntu 22.04 LTS
- Standard_B2s size
- SSH key authentication
- Custom data script to install nginx
- Managed disk
- Public IP address
```

### Generate Multiple VMs
```
Create 3 identical web server VMs using count
Each VM should have a unique name suffix (web-1, web-2, web-3)
Use cloud-init to install nginx on boot
```

### Explain Data Sources
```
What are Terraform data sources and how do they differ from resources?
When should I use a data source vs creating a new resource?
```

## 📋 Challenge

Create a web server deployment:

### Requirements

| Resource | Configuration |
|----------|--------------|
| VMs | 2 Linux VMs using count |
| Size | Standard_B2s |
| OS | Ubuntu 22.04 LTS |
| Auth | SSH key (no password) |
| Bootstrap | Install nginx via cloud-init |
| Network | Public IP + NIC per VM |

### Bonus
- Use a data source to reference existing VNet/subnet
- Add a VM extension for monitoring
- Configure availability set

## 💡 Hints

<details>
<summary>Hint 1: Cloud-Init Script</summary>

```hcl
locals {
  cloud_init = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF
}

resource "azurerm_linux_virtual_machine" "vm" {
  # ...
  custom_data = base64encode(local.cloud_init)
}
```
</details>

<details>
<summary>Hint 2: Multiple VMs with Count</summary>

```hcl
resource "azurerm_linux_virtual_machine" "web" {
  count = var.vm_count
  name  = "vm-web-${count.index + 1}"
  # ...
}
```
</details>

## ✅ Validation

```bash
cd challenge
terraform init
terraform validate
terraform plan

# After apply, test nginx
curl http://<public-ip>
```

## 📁 Files

```
02-compute/
├── README.md
├── challenge/
│   ├── main.tf
│   ├── variables.tf
│   └── cloud-init.sh
└── solution/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── cloud-init.sh
```
