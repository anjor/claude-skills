# Claude Skills Marketplace

A personal collection of Claude Code plugins that can be installed and used with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [pltr-cli](plugins/pltr-cli/) | Work with Palantir Foundry using the pltr CLI - query datasets, manage orchestration builds, work with ontologies, run SQL queries, and more |
| [freeagent-cli](plugins/freeagent-cli/) | Interact with FreeAgent accounting software (placeholder - coming soon) |

## Installation

### Add the Marketplace

```bash
# Add this marketplace to Claude Code
/plugin marketplace add anjor/claude-skills
```

### Install Plugins

```bash
# Install specific plugins
/plugin install pltr-cli@anjor-claude-skills
/plugin install freeagent-cli@anjor-claude-skills
```

### Local Development

For local testing during development:

```bash
# Add local marketplace
/plugin marketplace add ./

# Install plugin from local marketplace
/plugin install pltr-cli@anjor-claude-skills
```

## Plugin Structure

Each plugin follows this structure:

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json    # Plugin manifest with metadata
└── skills/
    └── <skill-name>/
        ├── SKILL.md       # Required: frontmatter + skill definition
        ├── reference/     # Optional: detailed command/API references
        └── workflows/     # Optional: multi-step task patterns
```

### SKILL.md Format

The `SKILL.md` file must include YAML frontmatter:

```yaml
---
name: skill-name
description: A description that helps Claude understand when to use this skill. Include trigger words.
---

# Skill content follows...
```

### plugin.json Format

Each plugin requires a `.claude-plugin/plugin.json` manifest:

```json
{
  "name": "plugin-name",
  "description": "Plugin description",
  "version": "1.0.0",
  "author": {
    "name": "Author Name"
  },
  "repository": "https://github.com/user/repo"
}
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new plugins.

## License

MIT
