#!/bin/bash

# Claude Code Project Setup Script
# This script sets up Claude Code configuration for a project

set -e

echo "========================================"
echo "Claude Code Project Setup"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and template directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates/project"

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${YELLOW}Warning: Not in a git repository${NC}"
    read -p "Initialize git? (Y/n): " init_git
    if [ "$init_git" != "n" ] && [ "$init_git" != "N" ]; then
        git init
        echo -e "${GREEN}✓ Git initialized${NC}"
    fi
fi

# Get project name
PROJECT_NAME=$(basename "$(pwd)")
echo ""
echo -e "${BLUE}Project: ${PROJECT_NAME}${NC}"

# Create directories
echo ""
echo "Creating project directories..."
mkdir -p .claude/commands
mkdir -p .claude/agents
mkdir -p .claude/skills
mkdir -p docs

echo -e "${GREEN}✓ Directories created${NC}"

# Detect project type
echo ""
echo "Detecting project type..."

PROJECT_TYPE="generic"
if [ -f "package.json" ]; then
    if grep -q "react" package.json 2>/dev/null; then
        PROJECT_TYPE="react"
    elif grep -q "next" package.json 2>/dev/null; then
        PROJECT_TYPE="nextjs"
    elif grep -q "express" package.json 2>/dev/null; then
        PROJECT_TYPE="express"
    else
        PROJECT_TYPE="nodejs"
    fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    if grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
        PROJECT_TYPE="fastapi"
    elif grep -q "django" requirements.txt 2>/dev/null || grep -q "django" pyproject.toml 2>/dev/null; then
        PROJECT_TYPE="django"
    else
        PROJECT_TYPE="python"
    fi
elif [ -f "go.mod" ]; then
    PROJECT_TYPE="go"
fi

echo -e "${GREEN}✓ Detected: ${PROJECT_TYPE}${NC}"

# Copy and customize CLAUDE.md
echo ""
echo "Creating CLAUDE.md..."
if [ -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}Warning: CLAUDE.md already exists${NC}"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Skipping CLAUDE.md..."
    else
        cp "${TEMPLATE_DIR}/CLAUDE.md" ./CLAUDE.md
        sed -i "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g" ./CLAUDE.md
        echo -e "${GREEN}✓ CLAUDE.md created${NC}"
    fi
else
    cp "${TEMPLATE_DIR}/CLAUDE.md" ./CLAUDE.md
    sed -i "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g" ./CLAUDE.md
    echo -e "${GREEN}✓ CLAUDE.md created${NC}"
fi

# Create .mcp.json based on project type
echo ""
echo "Creating .mcp.json..."
if [ -f ".mcp.json" ]; then
    echo -e "${YELLOW}Warning: .mcp.json already exists${NC}"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Skipping .mcp.json..."
    else
        CREATE_MCP=true
    fi
else
    CREATE_MCP=true
fi

if [ "$CREATE_MCP" = true ]; then
    case $PROJECT_TYPE in
        "react"|"nextjs"|"nodejs")
            cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "description": "Browser automation and screenshots"
    }
  }
}
EOF
            ;;
        "express"|"fastapi"|"django")
            cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "postgresql": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL:-postgresql://localhost:5432/dev}"
      },
      "description": "Database schema and query execution"
    }
  }
}
EOF
            ;;
        *)
            cp "${TEMPLATE_DIR}/.mcp.json" ./.mcp.json
            ;;
    esac
    echo -e "${GREEN}✓ .mcp.json created${NC}"
fi

# Copy other template files
echo ""
echo "Copying configuration files..."

# Tasks.json
if [ ! -f "tasks.json" ]; then
    cp "${TEMPLATE_DIR}/tasks.json" ./tasks.json
    sed -i "s/project-name/${PROJECT_NAME}/g" ./tasks.json
    echo -e "${GREEN}✓ tasks.json created${NC}"
else
    echo -e "${YELLOW}✓ tasks.json already exists (skipped)${NC}"
fi

# Issues.json
if [ ! -f "issues.json" ]; then
    cp "${TEMPLATE_DIR}/issues.json" ./issues.json
    sed -i "s/project-name/${PROJECT_NAME}/g" ./issues.json
    echo -e "${GREEN}✓ issues.json created${NC}"
else
    echo -e "${YELLOW}✓ issues.json already exists (skipped)${NC}"
fi

# Progress.md
if [ ! -f "progress.md" ]; then
    cp "${TEMPLATE_DIR}/progress.md" ./progress.md
    sed -i "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g" ./progress.md
    echo -e "${GREEN}✓ progress.md created${NC}"
else
    echo -e "${YELLOW}✓ progress.md already exists (skipped)${NC}"
fi

# .claude/settings.json
if [ ! -f ".claude/settings.json" ]; then
    cp "${TEMPLATE_DIR}/.claude/settings.json" ./.claude/settings.json
    echo -e "${GREEN}✓ .claude/settings.json created${NC}"
else
    echo -e "${YELLOW}✓ .claude/settings.json already exists (skipped)${NC}"
fi

# Commands
cp "${TEMPLATE_DIR}/.claude/commands/start-task.md" ./.claude/commands/
cp "${TEMPLATE_DIR}/.claude/commands/complete-task.md" ./.claude/commands/
cp "${TEMPLATE_DIR}/.claude/commands/log-issue.md" ./.claude/commands/
cp "${TEMPLATE_DIR}/.claude/commands/retrospective.md" ./.claude/commands/
cp "${TEMPLATE_DIR}/.claude/commands/sync-issues-to-global.md" ./.claude/commands/
echo -e "${GREEN}✓ Commands created${NC}"

# Agents
cp "${TEMPLATE_DIR}/.claude/agents/security-reviewer.md" ./.claude/agents/
echo -e "${GREEN}✓ Agents created${NC}"

# Docs
if [ ! -f "docs/architecture.md" ]; then
    cp "${TEMPLATE_DIR}/docs/architecture.md" ./docs/
fi
if [ ! -f "docs/api-specs.md" ]; then
    cp "${TEMPLATE_DIR}/docs/api-specs.md" ./docs/
fi
echo -e "${GREEN}✓ Documentation templates created${NC}"

# Environment template
cp "${TEMPLATE_DIR}/.env.mcp.example" ./.env.mcp.example
echo -e "${GREEN}✓ .env.mcp.example created${NC}"

# Update .gitignore
echo ""
echo "Updating .gitignore..."
if [ -f ".gitignore" ]; then
    if ! grep -q ".claude/settings.local.json" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        cat "${TEMPLATE_DIR}/.gitignore.claude" >> .gitignore
        echo -e "${GREEN}✓ .gitignore updated${NC}"
    else
        echo -e "${YELLOW}✓ .gitignore already contains Claude entries${NC}"
    fi
else
    cat "${TEMPLATE_DIR}/.gitignore.claude" > .gitignore
    echo -e "${GREEN}✓ .gitignore created${NC}"
fi

echo ""
echo "========================================"
echo -e "${GREEN}Project setup complete!${NC}"
echo "========================================"
echo ""
echo "Files created:"
echo "  ./CLAUDE.md"
echo "  ./.mcp.json"
echo "  ./tasks.json"
echo "  ./issues.json"
echo "  ./progress.md"
echo "  ./.claude/settings.json"
echo "  ./.claude/commands/"
echo "    - start-task.md"
echo "    - complete-task.md"
echo "    - log-issue.md"
echo "    - retrospective.md"
echo "    - sync-issues-to-global.md"
echo "  ./.claude/agents/"
echo "  ./docs/"
echo ""
echo "Next steps:"
echo "  1. Customize CLAUDE.md with project details"
echo "  2. Copy .env.mcp.example to .env.mcp and add credentials"
echo "  3. Update docs/architecture.md"
echo "  4. Run 'claude' and verify with '/context'"
echo ""
echo "Issue Management Commands:"
echo "  /log-issue [desc]       - Log an issue during work"
echo "  /retrospective          - End-of-session review"
echo "  /sync-issues-to-global  - Sync to global tracker"
echo ""
