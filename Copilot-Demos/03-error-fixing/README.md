# 🎯 Demo 3: Error Fixing

Use Copilot to diagnose and fix IaC errors.

## Demo Duration: ~10 minutes

---

## Demo Scenario 1: Fix Syntax Errors

### Setup
1. Open `broken-terraform.tf`
2. Notice the red squiggles (errors)
3. Open Copilot Chat

### Prompt
```
/fix
```
Or: "Fix the errors in this file"

### What to Highlight
- Copilot identifies multiple error types
- Provides corrected code
- Explains what was wrong

---

## Demo Scenario 2: Fix Type Mismatches

### The Code Has:
- Wrong variable types
- Missing required attributes
- Invalid resource references

### Prompt
```
This Terraform code has type errors. Find and fix them.
```

### What to Highlight
- Copilot understands Terraform type system
- Fixes complex type mismatches
- Suggests proper variable definitions

---

## Demo Scenario 3: Fix Dependency Issues

### Prompt
```
Fix the dependency cycle in this configuration
```

### What to Highlight
- Copilot understands resource dependencies
- Suggests depends_on when needed
- Recommends restructuring if necessary

---

## Demo Scenario 4: Fix Bicep Errors

### Setup
1. Open `broken-bicep.bicep`
2. Review the errors

### Prompt
```
Fix all errors in this Bicep file
```

### What to Highlight
- Works with Bicep too
- Fixes API version issues
- Corrects property names

---

## Files for This Demo

- `broken-terraform.tf` - Terraform with intentional errors
- `broken-bicep.bicep` - Bicep with intentional errors
