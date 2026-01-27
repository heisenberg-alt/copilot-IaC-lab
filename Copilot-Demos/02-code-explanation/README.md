# 🎯 Demo 2: Code Explanation

Use Copilot to understand complex IaC configurations.

## Demo Duration: ~5 minutes

---

## Demo Scenario 1: Explain Complex Expression

### Setup
1. Open `complex-code.tf`
2. Select the `dynamic` block
3. Open Copilot Chat

### Prompt
```
/explain
```
Or right-click → "Copilot" → "Explain This"

### What to Highlight
- Copilot breaks down complex expressions
- Explains what each part does
- Provides context for the pattern

---

## Demo Scenario 2: Explain Unfamiliar Resource

### Select the AKS resource and ask:

```
Explain what this AKS configuration does and what each property controls
```

### What to Highlight
- Learn about resources you haven't used before
- Understand default values and implications
- Discover related resources needed

---

## Demo Scenario 3: Explain Bicep Decorators

### Prompt
```
Explain all the Bicep decorators: @description, @allowed, @secure, @minLength, @maxLength, @minValue, @maxValue
When should I use each one?
```

### What to Highlight
- Copilot knows language-specific features
- Provides practical usage guidance
- Helps write better code

---

## Demo Scenario 4: Compare Approaches

### Prompt
```
What's the difference between count and for_each in Terraform?
When should I use each approach?
Show examples for creating multiple storage accounts.
```

### What to Highlight
- Copilot explains concepts, not just code
- Provides comparative analysis
- Shows practical examples

---

## Files for This Demo

- `complex-code.tf` - Complex Terraform with dynamic blocks
- `complex-code.bicep` - Complex Bicep with loops
