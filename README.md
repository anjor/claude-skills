# Claude Skills Marketplace

A personal collection of Claude Code plugins that can be installed and used with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [pltr-cli](plugins/pltr-cli/) | Work with Palantir Foundry using the pltr CLI - query datasets, manage orchestration builds, work with ontologies, run SQL queries, and more |
| [overleaf](plugins/overleaf/) | Work on Overleaf LaTeX projects over the Git bridge - edit paper prose, compile and fix build errors locally, manage `.bib` files and citations |
| [anjor](plugins/anjor/) | `anjor-mode`: Anjor's working conventions for agents. Opt in per session with `/anjor:anjor-mode` |
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
/plugin install overleaf@anjor-claude-skills
/plugin install anjor@anjor-claude-skills
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

Skills follow the [Agent Skills spec](https://agentskills.io/specification).
`SKILL.md` must start with YAML frontmatter:

```yaml
---
name: skill-name
description: "Use when <triggering conditions> - <tasks covered>. Also use when the user mentions <keywords>."
license: MIT
compatibility: "Requires <cli> vX.Y+"
metadata:
  version: "1.0.0"
---

# Skill content follows...
```

Quote any description containing `: ` — an unquoted colon-space breaks YAML
parsing and the skill loads with no metadata at all. Keep `SKILL.md` under 500
lines and push detail into `reference/` and `workflows/`, which load only when
needed.

### plugin.json Format

Each plugin has a `.claude-plugin/plugin.json` manifest (`name` is the only
required field):

```json
{
  "$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json",
  "name": "plugin-name",
  "description": "Plugin description",
  "version": "1.0.0",
  "author": {
    "name": "Author Name"
  },
  "repository": "https://github.com/user/repo",
  "license": "MIT",
  "keywords": ["keyword"]
}
```

### Validating

```bash
claude plugin validate ./plugins/<name> --strict   # manifest + skill frontmatter
claude plugin validate . --strict                  # marketplace manifest
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new plugins.

## License

MIT
