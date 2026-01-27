# 🟡 Level 2.1: Networking - Virtual Networks and Subnets (Bicep)

## 🎯 Objectives

By the end of this exercise, you will:
- Create Azure Virtual Networks using Bicep
- Configure multiple subnets using loops
- Implement Network Security Groups (NSGs)
- Use conditions and loops in Bicep

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **for loop** | Create multiple resources from arrays |
| **conditions** | Conditional resource creation |
| **union()** | Merge objects/arrays |
| **NSG rules** | Security rules with dynamic blocks |

## 🤖 Copilot Prompts to Try

### Generate VNet Configuration
```
Create a Bicep template for Azure VNet with:
- Address space 10.0.0.0/16
- Three subnets using a loop: web, app, db
- NSG for each subnet with appropriate rules
- Use parameter array for subnet definitions
```

### Explain Loops
```
Explain how for loops work in Bicep for creating multiple resources
Show examples of indexed loops vs item loops
```

## 📋 Challenge

Create a network infrastructure:

### Requirements

| Resource | Configuration |
|----------|--------------|
| VNet | 10.0.0.0/16 address space |
| Subnets | web, app, db (use loop) |
| NSGs | One per subnet with rules |

## 📁 Files

```
01-networking/
├── README.md
├── challenge/
│   ├── main.bicep
│   └── main.bicepparam
└── solution/
    ├── main.bicep
    └── main.bicepparam
```
