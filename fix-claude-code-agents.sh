#!/bin/bash
# Fix Claude Code agent format with proper YAML frontmatter
# Based on Claude's diagnostic findings

set -e

CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
BACKUP_DIR="$HOME/.claude/agents_backup_$(date +%Y%m%d_%H%M%S)"

echo "🔧 Fixing Claude Code Agent Format"
echo "=================================="

# Create backup
echo "📦 Creating backup at $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
cp -r "$CLAUDE_AGENTS_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true

# Claude Code available tools (comma-separated format)
TOOLS="Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS, WebFetch, WebSearch, NotebookEdit, Task"

# Function to convert agent name to lowercase-with-hyphens
convert_name() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g'
}

# Function to extract description from Role section
extract_description() {
    local file=$1
    # Get the first meaningful line after ## Role
    local desc=$(awk '/^## Role/{getline; getline; print; exit}' "$file" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # If empty, try to get from first paragraph
    if [ -z "$desc" ]; then
        desc=$(awk '/^## Role/{p=1; next} p && /^[A-Za-z]/{print; exit}' "$file" 2>/dev/null)
    fi
    
    # Default if still empty
    [ -z "$desc" ] && desc="Specialized agent for Claude Code"
    
    # Clean up and truncate
    desc=$(echo "$desc" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    echo "${desc:0:200}"  # Limit to 200 chars
}

# Process each agent file
echo ""
echo "📝 Converting agents to Claude Code format..."

for agent_file in "$CLAUDE_AGENTS_DIR"/*.md; do
    [ -f "$agent_file" ] || continue
    
    agent_basename=$(basename "$agent_file" .md)
    
    # Skip non-agent files
    if [[ "$agent_basename" =~ (README|CATALOG|SETUP|REMOTE|DISCOVERY|claude-code|manifest) ]]; then
        continue
    fi
    
    echo "Processing: $agent_basename"
    
    # Convert name to lowercase-with-hyphens
    agent_name=$(convert_name "$agent_basename")
    
    # Extract description
    description=$(extract_description "$agent_file")
    
    # Remove existing frontmatter if present
    temp_content=$(mktemp)
    if head -n 1 "$agent_file" | grep -q "^---$"; then
        # Remove old frontmatter
        awk '/^---$/{c++; next} c==2{print}' "$agent_file" > "$temp_content"
    else
        # Keep all content
        cat "$agent_file" > "$temp_content"
    fi
    
    # Create new file with proper frontmatter
    cat > "$agent_file" << EOF
---
name: $agent_name
description: $description
tools: $TOOLS
---

EOF
    
    # Append original content
    cat "$temp_content" >> "$agent_file"
    rm "$temp_content"
    
    echo "  ✓ Fixed: $agent_basename → $agent_name"
done

# Count fixed agents
AGENT_COUNT=$(find "$CLAUDE_AGENTS_DIR" -name "*.md" -type f | grep -v -E "(README|CATALOG|SETUP|REMOTE|DISCOVERY|claude-code|manifest)" | wc -l | tr -d ' ')

echo ""
echo "✅ Conversion Complete!"
echo "   • Fixed agents: $AGENT_COUNT"
echo "   • Backup saved: $BACKUP_DIR"
echo ""
echo "🎯 Testing Instructions:"
echo "   1. Open Claude Code"
echo "   2. Type: /agents"
echo "   3. Your agents should now appear!"
echo ""
echo "   To use with Task tool:"
echo "   Task(subagent_type: \"$agent_name\", ...)"
