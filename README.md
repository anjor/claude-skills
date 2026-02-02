# Claude Skills Marketplace

A personal collection of Claude Code skills that can be installed and used with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Available Skills

| Skill | Description |
|-------|-------------|
| [pltr-cli](plugins/pltr-cli/) | Work with Palantir Foundry using the pltr CLI - query datasets, manage orchestration builds, work with ontologies, run SQL queries, and more |
| [freeagent-cli](plugins/freeagent-cli/) | Interact with FreeAgent accounting software (placeholder - coming soon) |

## Installation

### Quick Install (Recommended)

Use the install script to symlink skills to your Claude Code configuration:

```bash
# Clone this repository
git clone https://github.com/anjor/claude-skills.git
cd claude-skills

# Install a specific skill
./scripts/install.sh install pltr-cli

# List available skills
./scripts/install.sh list

# Uninstall a skill
./scripts/install.sh uninstall pltr-cli
```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/anjor/claude-skills.git
   ```

2. Symlink the desired skill to `~/.claude/skills/`:
   ```bash
   mkdir -p ~/.claude/skills
   ln -s /path/to/claude-skills/plugins/pltr-cli ~/.claude/skills/pltr-cli
   ```

3. Restart Claude Code to pick up the new skill.

## Skill Structure

Each skill follows a standard structure:

```
plugins/<name>/
├── SKILL.md          # Required: frontmatter + skill definition
├── reference/        # Optional: detailed command/API references
└── workflows/        # Optional: multi-step task patterns
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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new skills.

## License

MIT
