---
name: freeagent-cli
description: Helps you work with FreeAgent accounting software using the freeagent CLI. Use this when you need to manage invoices, expenses, contacts, projects, timeslips, bank transactions, or generate financial reports. Triggers: FreeAgent, invoice, expense, accounting, timeslip, bank transaction.
---

# freeagent-cli: FreeAgent Accounting CLI

This skill helps you use the freeagent-cli to interact with FreeAgent accounting software.

## Compatibility

- **Skill version**: 0.1.0
- **freeagent-cli version**: TODO
- **Dependencies**: TODO

## Overview

<!-- TODO: Add overview of freeagent-cli capabilities -->

freeagent-cli provides commands for:
- **Invoices**: Create, list, send, and manage invoices
- **Expenses**: Track and categorize business expenses
- **Contacts**: Manage clients and suppliers
- **Projects**: Project tracking and billing
- **Timeslips**: Time tracking for billable work
- **Bank Transactions**: Import and reconcile transactions
- **Reports**: Generate financial reports

## Critical Concepts

### Authentication

<!-- TODO: Document authentication setup -->

```bash
# Configure authentication
freeagent configure

# Verify connection
freeagent verify
```

### Output Formats

<!-- TODO: Confirm supported output formats -->

```bash
freeagent <command> --format table    # Default
freeagent <command> --format json     # JSON output
```

## Reference Files

<!-- TODO: Create reference files as CLI is documented -->

| Task Type | Reference File |
|-----------|----------------|
| Invoice management | `reference/invoice-commands.md` |
| Expense tracking | `reference/expense-commands.md` |
| Contact management | `reference/contact-commands.md` |
| Project and timeslip tracking | `reference/project-commands.md` |
| Bank reconciliation | `reference/bank-commands.md` |
| Financial reports | `reference/report-commands.md` |

## Workflow Files

<!-- TODO: Create workflow files for common accounting tasks -->

| Workflow | File |
|----------|------|
| Monthly invoicing | `workflows/monthly-invoicing.md` |
| Expense reporting | `workflows/expense-reporting.md` |
| Bank reconciliation | `workflows/bank-reconciliation.md` |

## Common Commands Quick Reference

<!-- TODO: Add actual commands once CLI is developed -->

```bash
# Verify setup
freeagent verify

# List recent invoices
freeagent invoices list --limit 10

# Create a new invoice
freeagent invoices create --contact "Client Name" --items items.json

# List expenses
freeagent expenses list --from 2024-01-01 --to 2024-01-31

# Add an expense
freeagent expenses create --category "Travel" --amount 50.00 --description "Train fare"

# List contacts
freeagent contacts list

# Get bank transactions
freeagent bank transactions list --account "Main Account"

# Generate profit/loss report
freeagent reports profit-loss --year 2024
```

## Best Practices

1. **Verify authentication**: Run `freeagent verify` before starting work
2. **Use filters**: Narrow down results with date ranges and status filters
3. **Export for analysis**: Use `--format json` for programmatic processing

## Getting Help

```bash
freeagent --help                    # All commands
freeagent <command> --help          # Command help
```
