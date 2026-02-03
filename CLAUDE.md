# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Skills Marketplace - a collection of Claude Code plugins that extend Claude's capabilities with domain-specific CLI tools. This is an official plugin marketplace that users can install via:

```bash
/plugin marketplace add anjor/claude-skills
/plugin install pltr-cli@anjor-claude-skills
```

## Architecture

### Directory Structure

```
claude-skills/
├── .claude-plugin/
│   └── marketplace.json    # Root marketplace manifest
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/
│       │   └── plugin.json # Plugin manifest
│       └── skills/
│           └── <skill-name>/
│               ├── SKILL.md      # Skill definition
│               ├── reference/    # Command documentation
│               └── workflows/    # Multi-step task patterns
```

### Key Files

- `.claude-plugin/marketplace.json` - Lists all available plugins in this marketplace
- `plugins/<name>/.claude-plugin/plugin.json` - Individual plugin metadata
- `plugins/<name>/skills/<skill>/SKILL.md` - Skill definition with YAML frontmatter

### Current Plugins

- **pltr-cli**: Comprehensive Palantir Foundry CLI documentation (production-ready)
- **freeagent-cli**: FreeAgent accounting CLI (template/WIP)

## Contributing New Plugins

1. Create plugin directory: `plugins/<plugin-name>/`
2. Create `.claude-plugin/plugin.json` with plugin metadata
3. Create `skills/<skill-name>/SKILL.md` with required frontmatter
4. Add `reference/` files for detailed command documentation
5. Add `workflows/` files for multi-step task patterns
6. Add plugin entry to root `.claude-plugin/marketplace.json`
7. Test locally with `/plugin marketplace add ./`
8. See CONTRIBUTING.md for detailed guidelines
