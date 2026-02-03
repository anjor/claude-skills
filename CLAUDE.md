# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Skills Marketplace - a collection of Claude Code skills that extend Claude's capabilities with domain-specific CLI tools. Skills are installed via symlinks to `~/.claude/skills/` for Claude Code discovery.

## Commands

```bash
# Skill management
./scripts/install.sh list              # List available skills
./scripts/install.sh install pltr-cli  # Install a specific skill
./scripts/install.sh install-all       # Install all skills
./scripts/install.sh uninstall pltr-cli
./scripts/install.sh status            # Show installation status

# First-time setup
chmod +x ./scripts/install.sh
```

## Architecture

### Directory Structure

- `plugins/` - Skill plugins, each in its own directory
- `scripts/install.sh` - Installation/management script

### Skill Format

Each skill follows this structure:
```
plugins/<skill-name>/
├── SKILL.md           # Required - YAML frontmatter with name/description
├── reference/         # Optional - detailed command documentation
└── workflows/         # Optional - multi-step task patterns
```

**SKILL.md frontmatter** must include:
- `name`: Skill identifier
- `description`: Trigger words and capability summary (Claude uses this to decide when to load the skill)

### Current Skills

- **pltr-cli**: Comprehensive Palantir Foundry CLI documentation (production-ready)
- **freeagent-cli**: FreeAgent accounting CLI (template/WIP)
- **technical-hiring**: Reserved directory (empty)

## Contributing New Skills

1. Create `plugins/<skill-name>/SKILL.md` with required frontmatter
2. Add `reference/` files for detailed command documentation
3. Add `workflows/` files for multi-step task patterns
4. Test locally with `./scripts/install.sh install <skill-name>`
5. See CONTRIBUTING.md for detailed guidelines
