# 🟡 Level 2.1: Networking - Virtual Networks and Subnets

## 🎯 Objectives

By the end of this exercise, you will:
- Create Azure Virtual Networks
- Configure multiple subnets
- Implement Network Security Groups (NSGs)
- Understand resource dependencies

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **Virtual Network** | Isolated network in Azure |
| **Subnet** | Segment within a VNet |
| **NSG** | Network Security Group with rules |
| **for_each** | Create multiple resources from a map |
| **cidrsubnet** | Calculate subnet CIDR ranges |

## 🤖 Copilot Prompts to Try

### Generate VNet Configuration
```
Create a Terraform configuration for an Azure VNet with:
- Address space 10.0.0.0/16
- Three subnets: web (10.0.1.0/24), app (10.0.2.0/24), db (10.0.3.0/24)
- NSG for each subnet with appropriate rules
- Use for_each to create subnets from a map
```

### Generate NSG Rules
```
Create NSG rules for a 3-tier web application:
- Web tier: allow HTTP/HTTPS from internet
- App tier: allow 8080 from web tier only
- DB tier: allow 1433 from app tier only
```

### Explain CIDR
```
Explain CIDR notation and how to calculate subnet ranges in Azure
What does /16 vs /24 mean?
```

## 📋 Challenge

Create a hub-spoke style network topology:

### Requirements

| Resource | Configuration |
|----------|--------------|
| VNet | 10.0.0.0/16 address space |
| Web Subnet | 10.0.1.0/24 |
| App Subnet | 10.0.2.0/24 |
| DB Subnet | 10.0.3.0/24 |
| Web NSG | Allow 80, 443 from Internet |
| App NSG | Allow 8080 from Web subnet |
| DB NSG | Allow 1433 from App subnet |

### Bonus
- Use `for_each` to create subnets from a variable
- Use `cidrsubnet()` function to calculate ranges
- Associate NSGs with subnets

## 💡 Hints

<details>
<summary>Hint 1: Subnet Map Variable</summary>

```hcl
variable "subnets" {
  type = map(object({
    address_prefix = string
    nsg_rules      = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}
```
</details>

<details>
<summary>Hint 2: Creating Subnets with for_each</summary>

```hcl
resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
}
```
</details>

## ✅ Validation

```bash
cd challenge
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
```

## 📁 Files

```
01-networking/
├── README.md
├── challenge/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── solution/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```
