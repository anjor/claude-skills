# Contributing to Claude Skills Marketplace

Thank you for your interest in contributing! This guide will help you add new skills or improve existing ones.

## Adding a New Skill

### 1. Create the Skill Directory

```bash
mkdir -p plugins/your-skill-name
```

### 2. Create SKILL.md

Every skill requires a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: your-skill-name
description: A clear description of what this skill does. Include trigger words that help Claude recognize when to use it. Example triggers: "cli-name", "tool-name", relevant domain keywords.
---

# Your Skill Name

Brief overview of the skill.

## Overview

What does this tool/CLI do? What are its main features?

## Critical Concepts

Important things Claude needs to know before using commands.

## Reference Files

| Task Type | Reference File |
|-----------|----------------|
| Task category | `reference/file.md` |

## Workflow Files

| Workflow | File |
|----------|------|
| Workflow name | `workflows/file.md` |

## Common Commands Quick Reference

```bash
# Most frequently used commands
your-cli command1
your-cli command2
```

## Best Practices

1. Important tip 1
2. Important tip 2

## Getting Help

```bash
your-cli --help
```
```

### 3. Add Reference Files (Optional)

Create `reference/` directory for detailed command documentation:

```bash
mkdir plugins/your-skill-name/reference
```

Each reference file should cover a logical grouping of commands (e.g., `admin-commands.md`, `query-commands.md`).

### 4. Add Workflow Files (Optional)

Create `workflows/` directory for multi-step task patterns:

```bash
mkdir plugins/your-skill-name/workflows
```

Workflows describe common end-to-end tasks that involve multiple commands.

## Skill Design Guidelines

### Frontmatter

- **name**: Should match the directory name
- **description**: Include:
  - What the skill helps with
  - Key capabilities
  - Trigger words/phrases that should activate the skill

### Content

1. **Be specific**: Include exact command syntax
2. **Show examples**: Real-world usage examples help Claude understand context
3. **Document prerequisites**: Authentication, setup requirements, etc.
4. **Reference structure**: Use tables to map task types to reference files
5. **Keep it scannable**: Use headers, code blocks, and tables

### Reference Files

- One file per logical command group
- Include all flags and options
- Show example output where helpful

### Workflow Files

- Step-by-step instructions for common tasks
- Include decision points and alternatives
- Show how commands chain together

## Testing Your Skill

1. Install the skill locally:
   ```bash
   ./scripts/install.sh install your-skill-name
   ```

2. Start Claude Code and test with trigger phrases:
   ```
   help me with your-skill-name
   ```

3. Verify Claude loads the appropriate reference/workflow files

## Submitting Changes

1. Fork this repository
2. Create a feature branch: `git checkout -b add-skill-name`
3. Add your skill following the guidelines above
4. Test locally
5. Submit a pull request with:
   - Description of the skill
   - Example usage
   - Any special requirements

## Questions?

Open an issue if you have questions about contributing.
