#!/bin/bash
# Convert all agents to Claude Code format with YAML frontmatter
set -e

echo "🔄 Converting agents to Claude Code format with YAML frontmatter..."

AGENTS_DIR="$HOME/.config/claude/agents"
BACKUP_DIR="$HOME/.config/claude/agents_backup_$(date +%Y%m%d_%H%M%S)"

# Create backup
echo "📦 Creating backup at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$AGENTS_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true

# Function to extract description from agent content
extract_description() {
    local file=$1
    # Try to get first line after ## Role, removing leading/trailing whitespace
    local desc=$(grep -A2 "## Role" "$file" 2>/dev/null | tail -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
    
    # If empty, try to get first line after # (main title)
    if [ -z "$desc" ]; then
        desc=$(grep -A1 "^# " "$file" 2>/dev/null | tail -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "Specialist agent")
    fi
    
    # Truncate if too long and ensure it's not empty
    if [ -z "$desc" ]; then
        desc="Specialist agent for Claude Code"
    else
        # Truncate to 100 chars if needed
        desc="${desc:0:100}"
    fi
    
    echo "$desc"
}

# Function to add YAML frontmatter to agent file
add_frontmatter() {
    local file=$1
    local agent_name=$(basename "$file" .md)
    
    # Skip if already has frontmatter
    if head -n 1 "$file" | grep -q "^---$"; then
        echo "⏭️  Skipping $agent_name (already has frontmatter)"
        return
    fi
    
    echo "Converting: $agent_name"
    
    # Extract description from content
    local description=$(extract_description "$file")
    
    # Create temp file with frontmatter
    local temp_file="${file}.tmp"
    
    cat > "$temp_file" << EOF
---
name: "$agent_name"
description: "$description"
version: "1.0"
tools: ["*"]
---

EOF
    
    # Append original content
    cat "$file" >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
    
    echo "✓ Converted $agent_name"
}

# Convert all agent files
converted=0
skipped=0

for agent in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent" ]; then
        # Skip non-agent files
        if [[ $(basename "$agent") =~ (README|CATALOG|SETUP|REMOTE_SETUP|DISCOVERY_WORKFLOW|claude-code-loader|CLAUDE_CODE_CATALOG) ]]; then
            continue
        fi
        
        if add_frontmatter "$agent"; then
            ((converted++))
        else
            ((skipped++))
        fi
    fi
done

echo ""
echo "✅ Conversion Complete!"
echo "   Converted: $converted agents"
echo "   Skipped: $skipped agents (already had frontmatter)"
echo "   Backup: $BACKUP_DIR"
echo ""
echo "🎯 Your agents are now Claude Code compatible!"
echo ""
echo "Try in Claude Code:"
echo "  /agents  - to see all available agents"
echo "  Use the [agent-name] - to activate a specific agent"
