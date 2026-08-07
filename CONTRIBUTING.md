# Contributing to Claude Skills Marketplace

Thank you for your interest in contributing! This guide will help you add new plugins or improve existing ones.

## Adding a New Plugin

### 1. Create the Plugin Directory Structure

```bash
mkdir -p plugins/your-plugin-name/.claude-plugin
mkdir -p plugins/your-plugin-name/skills/your-skill-name
```

### 2. Create plugin.json

Every plugin requires a `.claude-plugin/plugin.json` manifest:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json",
  "name": "your-plugin-name",
  "description": "A clear description of what this plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  },
  "repository": "https://github.com/your-username/your-repo",
  "license": "MIT",
  "keywords": ["cli-name", "domain-keyword"]
}
```

`name` is the only required field; the rest improve discovery and validation.

### 3. Create SKILL.md

Create `skills/your-skill-name/SKILL.md` with YAML frontmatter. Skills follow
the [Agent Skills spec](https://agentskills.io/specification), which defines six
fields: `name` and `description` (required), plus `license`, `compatibility`,
`metadata`, and `allowed-tools`.

```yaml
---
name: your-skill-name
description: "Use when working with <tool> - <the tasks it covers>. Also use when the user mentions <trigger words>."
license: MIT
compatibility: "Requires <cli> vX.Y+ and configured credentials"
metadata:
  version: "1.0.0"
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

### 4. Add Reference Files (Optional)

Create `skills/your-skill-name/reference/` directory for detailed command documentation:

```bash
mkdir plugins/your-plugin-name/skills/your-skill-name/reference
```

Each reference file should cover a logical grouping of commands (e.g., `admin-commands.md`, `query-commands.md`).

### 5. Add Workflow Files (Optional)

Create `skills/your-skill-name/workflows/` directory for multi-step task patterns:

```bash
mkdir plugins/your-plugin-name/skills/your-skill-name/workflows
```

Workflows describe common end-to-end tasks that involve multiple commands.

### 6. Register in Marketplace

Add your plugin to the root `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "your-plugin-name",
      "source": "./plugins/your-plugin-name",
      "description": "Your plugin description",
      "version": "1.0.0",
      "category": "development"
    }
  ]
}
```

Categories include: `development`, `productivity`, `utilities`, etc.

## Plugin Design Guidelines

### plugin.json

- **name**: Should match the directory name
- **version**: Follow semantic versioning (e.g., 1.0.0)
- **description**: Clear, concise description of capabilities

### SKILL.md Frontmatter

- **name**: Must match the skill directory name. Lowercase letters, numbers and
  single hyphens only, 1-64 characters, no leading or trailing hyphen.
- **description**: Max 1024 characters. This is the only part of the skill
  Claude sees before deciding to load it, so write it as triggering conditions:
  start with "Use when...", write in the third person, and name the tasks,
  symptoms and keywords that should pull the skill in. Don't summarize the
  skill's internal workflow - Claude will follow the summary instead of reading
  the body.
- **Quote descriptions containing `: `**. A bare colon-space terminates a YAML
  plain scalar, so `description: Does X. Triggers: foo` fails to parse and the
  skill loads with *no* metadata at all - silently invisible to Claude. Wrap the
  value in double quotes.
- **compatibility / license / metadata**: optional spec fields for version and
  dependency requirements. Prefer these over prose in the body.

Fields outside the spec's six (`disable-model-invocation`, `argument-hint`,
`context`, `arguments`, `disallowed-tools`) are Claude Code extensions. They work
in plugin skills but are rejected when the same skill is uploaded to claude.ai or
the Skills API, so avoid them if the skill needs to be portable.

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

## Testing Your Plugin

1. Validate the manifests and frontmatter first - this catches the YAML
   parse errors that otherwise fail silently at runtime:
   ```bash
   claude plugin validate ./plugins/your-plugin-name --strict
   claude plugin validate . --strict   # the marketplace manifest
   ```

2. Add the local marketplace:
   ```bash
   /plugin marketplace add ./
   ```

3. Install your plugin:
   ```bash
   /plugin install your-plugin-name@anjor-claude-skills
   ```

4. Test with trigger phrases:
   ```
   help me with your-skill-name
   ```

5. Verify Claude loads the appropriate reference/workflow files

## Submitting Changes

1. Fork this repository
2. Create a feature branch: `git checkout -b add-plugin-name`
3. Add your plugin following the guidelines above
4. Test locally
5. Submit a pull request with:
   - Description of the plugin
   - Example usage
   - Any special requirements

## Questions?

Open an issue if you have questions about contributing.
