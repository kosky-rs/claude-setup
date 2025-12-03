#!/bin/bash

# Claude Code Global Setup Script
# This script sets up the global Claude Code configuration

set -e

echo "========================================"
echo "Claude Code Global Setup"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code is not installed${NC}"
    echo "Please install Claude Code first: npm install -g @anthropic/claude-code"
    exit 1
fi

echo -e "${GREEN}✓ Claude Code is installed${NC}"

# Create global directories
echo ""
echo "Creating global directories..."
mkdir -p ~/.claude/docs
mkdir -p ~/.claude/commands

echo -e "${GREEN}✓ Directories created${NC}"

# Check if files already exist
if [ -f ~/.claude/CLAUDE.md ]; then
    echo -e "${YELLOW}Warning: ~/.claude/CLAUDE.md already exists${NC}"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Skipping CLAUDE.md..."
    else
        OVERWRITE_CLAUDE=true
    fi
else
    OVERWRITE_CLAUDE=true
fi

# Copy template files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates/global"

if [ "$OVERWRITE_CLAUDE" = true ]; then
    echo ""
    echo "Copying global CLAUDE.md..."
    cp "${TEMPLATE_DIR}/CLAUDE.md" ~/.claude/CLAUDE.md
    echo -e "${GREEN}✓ CLAUDE.md created${NC}"
fi

echo ""
echo "Copying documentation files..."
cp "${TEMPLATE_DIR}/docs/behavior-principles.md" ~/.claude/docs/
cp "${TEMPLATE_DIR}/docs/task-workflow.md" ~/.claude/docs/
cp "${TEMPLATE_DIR}/docs/quality-gates.md" ~/.claude/docs/
cp "${TEMPLATE_DIR}/docs/code-standards.md" ~/.claude/docs/
echo -e "${GREEN}✓ Documentation files created${NC}"

echo ""
echo "Copying command files..."
cp "${TEMPLATE_DIR}/commands/checkpoint.md" ~/.claude/commands/
cp "${TEMPLATE_DIR}/commands/review.md" ~/.claude/commands/
cp "${TEMPLATE_DIR}/commands/upgrade-global.md" ~/.claude/commands/
cp "${TEMPLATE_DIR}/commands/verify-upgrade.md" ~/.claude/commands/
cp "${TEMPLATE_DIR}/commands/security-review.md" ~/.claude/commands/
echo -e "${GREEN}✓ Command files created${NC}"

# Issues tracking
if [ ! -f ~/.claude/issues.json ]; then
    cp "${TEMPLATE_DIR}/issues.json" ~/.claude/issues.json
    echo -e "${GREEN}✓ issues.json created${NC}"
else
    echo -e "${YELLOW}✓ issues.json already exists (skipped)${NC}"
fi

# Upgrade log
if [ ! -f ~/.claude/upgrade-log.md ]; then
    cp "${TEMPLATE_DIR}/upgrade-log.md" ~/.claude/upgrade-log.md
    echo -e "${GREEN}✓ upgrade-log.md created${NC}"
else
    echo -e "${YELLOW}✓ upgrade-log.md already exists (skipped)${NC}"
fi

# Settings.json
if [ -f ~/.claude/settings.json ]; then
    echo -e "${YELLOW}Warning: ~/.claude/settings.json already exists${NC}"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        cp "${TEMPLATE_DIR}/settings.json" ~/.claude/settings.json
        echo -e "${GREEN}✓ settings.json updated${NC}"
    fi
else
    cp "${TEMPLATE_DIR}/settings.json" ~/.claude/settings.json
    echo -e "${GREEN}✓ settings.json created${NC}"
fi

# User scope MCP (.claude.json)
if [ -f ~/.claude.json ]; then
    echo -e "${YELLOW}Warning: ~/.claude.json already exists${NC}"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        cp "${TEMPLATE_DIR}/claude.json" ~/.claude.json
        echo -e "${GREEN}✓ .claude.json updated${NC}"
    fi
else
    cp "${TEMPLATE_DIR}/claude.json" ~/.claude.json
    echo -e "${GREEN}✓ .claude.json created${NC}"
fi

echo ""
echo "========================================"
echo -e "${GREEN}Global setup complete!${NC}"
echo "========================================"
echo ""
echo "Files created:"
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.claude/settings.json"
echo "  ~/.claude.json"
echo "  ~/.claude/issues.json"
echo "  ~/.claude/upgrade-log.md"
echo "  ~/.claude/security-audit.log (created on first use)"
echo "  ~/.claude/docs/"
echo "  ~/.claude/commands/"
echo "    - checkpoint.md"
echo "    - review.md"
echo "    - security-review.md"
echo "    - upgrade-global.md"
echo "    - verify-upgrade.md"
echo ""
echo "Next steps:"
echo "  1. Review and customize ~/.claude/CLAUDE.md"
echo "  2. Add your API keys to environment variables"
echo "  3. Run 'claude' to verify setup"
echo "  4. Run '/context' to check configuration"
echo ""
echo "Available Commands:"
echo "  /checkpoint       - Save state for session handoff"
echo "  /review           - Code review before commit"
echo "  /security-review  - Security-focused code review"
echo "  /upgrade-global   - Analyze issues and upgrade configuration"
echo "  /verify-upgrade   - Verify effectiveness of recent upgrades"
echo ""
echo "Security Features:"
echo "  - Enhanced permission rules (secrets, keys, dangerous commands)"
echo "  - Audit logging for sensitive operations (~/.claude/security-audit.log)"
echo ""
