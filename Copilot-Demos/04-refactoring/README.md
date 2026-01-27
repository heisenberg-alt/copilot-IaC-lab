# 🎯 Demo 4: Refactoring

Transform and optimize IaC with Copilot.

## Demo Duration: ~10 minutes

---

## Demo Scenario 1: Replace Hardcoded Values with Variables

### Setup
1. Open `hardcoded.tf`
2. Select the code

### Prompt
```
Refactor this code to use variables instead of hardcoded values.
Add descriptions and validation to all variables.
```

### What to Highlight
- Copilot identifies all hardcoded values
- Creates appropriate variables
- Adds validation where sensible

---

## Demo Scenario 2: Convert count to for_each

### Prompt
```
Refactor this code from using count to for_each for better resource management.
```

### What to Highlight
- Copilot understands the difference
- Converts indexing to keys
- Updates all references

---

## Demo Scenario 3: Extract to Module

### Prompt
```
Extract this storage account configuration into a reusable Terraform module.
Create the module structure with variables.tf, outputs.tf, and README.md.
```

### What to Highlight
- Copilot understands module patterns
- Creates proper file structure
- Adds appropriate outputs

---

## Demo Scenario 4: Add Best Practices

### Prompt
```
Review this code and add Azure security best practices:
- Enable HTTPS only
- Set minimum TLS version
- Add diagnostic settings
- Implement managed identity
```

### What to Highlight
- Copilot knows best practices
- Adds security configurations
- Improves code quality

---

## Demo Scenario 5: Convert Between Languages

### Prompt
```
Convert this Terraform configuration to Bicep
```

### What to Highlight
- Copilot can translate between IaC languages
- Maintains functionality
- Uses idiomatic patterns for target language

---

## Files for This Demo

- `hardcoded.tf` - Code with hardcoded values
- `count-example.tf` - Code using count pattern
