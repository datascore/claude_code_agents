#!/bin/bash
# Claude Code Agent Loader Bridge
# This script ensures Claude Code can properly load your synced agents

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 Claude Code Agent Bridge Initializing..."

# 1. Define directories
CLAUDE_AGENTS_DIR="$HOME/.config/claude/agents"
REPO_AGENTS_DIR="$(pwd)"

# Ensure directories exist
mkdir -p "$CLAUDE_AGENTS_DIR"

# 2. Function to add YAML frontmatter if missing
add_yaml_frontmatter() {
    local file=$1
    local agent_name=$(basename "$file" .md)
    
    # Check if already has frontmatter
    if head -n 1 "$file" 2>/dev/null | grep -q "^---$"; then
        return 0  # Already has frontmatter
    fi
    
    # Extract description from Role section
    local desc=$(grep -A2 "## Role" "$file" 2>/dev/null | tail -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "Specialist agent")
    [ -z "$desc" ] && desc="Specialist agent for Claude Code"
    desc="${desc:0:100}"  # Truncate to 100 chars
    
    # Create temp file with frontmatter
    local temp_file="${file}.tmp"
    cat > "$temp_file" << EOF
---
name: "$agent_name"
description: "$desc"
version: "1.0"
tools: ["*"]
---

EOF
    cat "$file" >> "$temp_file"
    mv "$temp_file" "$file"
    return 1  # Indicates file was modified
}

# 2. Validate agent format for Claude Code compatibility
validate_agent_format() {
    local agent_file=$1
    local agent_name=$(basename "$agent_file")
    local valid=true
    local modified=false
    
    # Add YAML frontmatter if missing
    if add_yaml_frontmatter "$agent_file"; then
        echo -e "${YELLOW}➕ Added YAML frontmatter to $agent_name${NC}"
        modified=true
    fi
    
    # Check for required sections
    if ! grep -q "## Role" "$agent_file"; then
        echo -e "${YELLOW}⚠ $agent_name missing ## Role section${NC}"
        valid=false
    fi
    
    if ! grep -q "## Core Expertise" "$agent_file"; then
        echo -e "${YELLOW}⚠ $agent_name missing ## Core Expertise section${NC}"
        valid=false
    fi
    
    if $valid; then
        if $modified; then
            echo -e "${GREEN}✓ $agent_name is now Claude Code compatible${NC}"
        else
            echo -e "${GREEN}✓ $agent_name is Claude Code compatible${NC}"
        fi
        return 0
    else
        return 1
    fi
}

# 3. Check all agents in current directory
echo ""
echo "📋 Validating agents in repository..."
invalid_count=0
valid_count=0

for agent in *.md; do
    if [ -f "$agent" ] && [[ ! "$agent" =~ (README|CATALOG|SETUP|REMOTE_SETUP|DISCOVERY_WORKFLOW|claude-code-loader) ]]; then
        if validate_agent_format "$agent"; then
            ((valid_count++))
        else
            ((invalid_count++))
        fi
    fi
done

echo ""
echo "📊 Validation Summary:"
echo "   Valid agents: $valid_count"
echo "   Invalid agents: $invalid_count"

# 4. Sync to Claude config directory
echo ""
echo "🔄 Syncing agents to Claude config..."
cp -f *.md "$CLAUDE_AGENTS_DIR/" 2>/dev/null || true
echo -e "${GREEN}✓ Agents synced to $CLAUDE_AGENTS_DIR${NC}"

# 5. Generate agent catalog
echo ""
echo "📚 Generating agent catalog..."

cat > "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md" << 'EOF'
# Available Claude Code Agents

## Quick Start
1. Start a conversation with Claude Code
2. Claude automatically selects the appropriate agent
3. Or request specific agent: "Use the [agent-name] for this"

## Available Specialists

EOF

for agent in "$CLAUDE_AGENTS_DIR"/*.md; do
    if [ -f "$agent" ] && [[ ! "$agent" =~ (README|CATALOG|SETUP|REMOTE_SETUP|DISCOVERY_WORKFLOW|claude-code-loader|CLAUDE_CODE_CATALOG) ]]; then
        agent_name=$(basename "$agent" .md)
        # Extract role (first non-empty line after ## Role)
        role=$(grep -A2 "## Role" "$agent" | tail -n 1 | grep -v "^##" | grep -v "^$" || echo "")
        
        if [ -n "$role" ]; then
            echo "### 🤖 $agent_name" >> "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md"
            echo "$role" >> "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md"
            echo "" >> "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md"
        fi
    fi
done

echo -e "${GREEN}✓ Catalog generated at $CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md${NC}"

# 6. Create manifest for agent loader
echo ""
echo "📦 Creating agent manifest..."

cat > "$CLAUDE_AGENTS_DIR/manifest.json" << EOF
{
  "version": "1.0",
  "updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "agents": [
EOF

first=true
for agent in "$CLAUDE_AGENTS_DIR"/*.md; do
    if [ -f "$agent" ] && [[ ! "$agent" =~ (README|CATALOG|SETUP|REMOTE_SETUP|DISCOVERY_WORKFLOW|claude-code-loader|CLAUDE_CODE_CATALOG) ]]; then
        name=$(basename "$agent" .md)
        
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$CLAUDE_AGENTS_DIR/manifest.json"
        fi
        
        echo -n "    {\"name\": \"$name\", \"file\": \"$(basename "$agent")\"}" >> "$CLAUDE_AGENTS_DIR/manifest.json"
    fi
done

cat >> "$CLAUDE_AGENTS_DIR/manifest.json" << EOF

  ],
  "default": "project-comprehension-agent"
}
EOF

echo -e "${GREEN}✓ Manifest created${NC}"

# 7. Display available agents
echo ""
echo "🎯 Available Claude Code Agents:"
echo "================================"

for agent in "$CLAUDE_AGENTS_DIR"/*.md; do
    if [ -f "$agent" ] && [[ ! "$agent" =~ (README|CATALOG|SETUP|REMOTE_SETUP|DISCOVERY_WORKFLOW|claude-code-loader|CLAUDE_CODE_CATALOG) ]]; then
        agent_name=$(basename "$agent" .md)
        echo "  • $agent_name"
    fi
done

echo ""
echo "✨ Claude Code Bridge Setup Complete!"
echo ""
echo "📝 Next Steps:"
echo "  1. In Claude Code, try: 'Use the project-comprehension-agent'"
echo "  2. Or let Claude auto-select based on your task"
echo "  3. Switch agents mid-conversation as needed"
echo ""
echo "💡 Tip: View the catalog at: $CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md"
