#!/bin/bash

# Claude Skills Installer
# Manages symlinks from this repo to ~/.claude/skills/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PLUGINS_DIR="$REPO_DIR/plugins"
SKILLS_DIR="$HOME/.claude/skills"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Claude Skills Installer"
    echo ""
    echo "Usage: $0 <command> [skill-name]"
    echo ""
    echo "Commands:"
    echo "  list                List available skills"
    echo "  install <name>      Install a skill (creates symlink)"
    echo "  install-all         Install all available skills"
    echo "  uninstall <name>    Uninstall a skill (removes symlink)"
    echo "  status              Show installation status of all skills"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 install pltr-cli"
    echo "  $0 uninstall pltr-cli"
    echo "  $0 status"
}

list_skills() {
    echo "Available skills:"
    echo ""
    for skill_dir in "$PLUGINS_DIR"/*/; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            # Extract description from frontmatter
            description=$(sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" | grep "^description:" | sed 's/^description: //')
            # Truncate description if too long
            if [ ${#description} -gt 80 ]; then
                description="${description:0:77}..."
            fi
            echo "  $skill_name"
            echo "    $description"
            echo ""
        fi
    done
}

install_skill() {
    local skill_name="$1"
    local skill_path="$PLUGINS_DIR/$skill_name"

    if [ ! -d "$skill_path" ]; then
        echo -e "${RED}Error: Skill '$skill_name' not found in plugins/${NC}"
        exit 1
    fi

    if [ ! -f "$skill_path/SKILL.md" ]; then
        echo -e "${RED}Error: Skill '$skill_name' is missing SKILL.md${NC}"
        exit 1
    fi

    # Create skills directory if it doesn't exist
    mkdir -p "$SKILLS_DIR"

    local target="$SKILLS_DIR/$skill_name"

    if [ -L "$target" ]; then
        echo -e "${YELLOW}Skill '$skill_name' is already installed (symlink exists)${NC}"
        return 0
    fi

    if [ -e "$target" ]; then
        echo -e "${RED}Error: $target exists but is not a symlink. Please remove it manually.${NC}"
        exit 1
    fi

    ln -s "$skill_path" "$target"
    echo -e "${GREEN}Installed '$skill_name' -> $target${NC}"
}

install_all() {
    echo "Installing all skills..."
    echo ""
    for skill_dir in "$PLUGINS_DIR"/*/; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            install_skill "$skill_name"
        fi
    done
}

uninstall_skill() {
    local skill_name="$1"
    local target="$SKILLS_DIR/$skill_name"

    if [ ! -L "$target" ]; then
        echo -e "${YELLOW}Skill '$skill_name' is not installed (no symlink found)${NC}"
        return 0
    fi

    rm "$target"
    echo -e "${GREEN}Uninstalled '$skill_name'${NC}"
}

show_status() {
    echo "Skill installation status:"
    echo ""
    printf "%-20s %-12s %s\n" "SKILL" "STATUS" "PATH"
    printf "%-20s %-12s %s\n" "-----" "------" "----"

    for skill_dir in "$PLUGINS_DIR"/*/; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            target="$SKILLS_DIR/$skill_name"

            if [ -L "$target" ]; then
                status="${GREEN}installed${NC}"
                path="$target -> $(readlink "$target")"
            else
                status="${YELLOW}not installed${NC}"
                path="-"
            fi

            printf "%-20s " "$skill_name"
            printf "%-12b " "$status"
            printf "%s\n" "$path"
        fi
    done
}

# Main command handling
case "${1:-}" in
    list)
        list_skills
        ;;
    install)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}Error: Please specify a skill name${NC}"
            echo ""
            usage
            exit 1
        fi
        install_skill "$2"
        ;;
    install-all)
        install_all
        ;;
    uninstall)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}Error: Please specify a skill name${NC}"
            echo ""
            usage
            exit 1
        fi
        uninstall_skill "$2"
        ;;
    status)
        show_status
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
