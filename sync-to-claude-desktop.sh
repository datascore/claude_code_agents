#!/bin/bash
# Sync agents to Claude Desktop's correct location (~/.claude/agents/)
set -e

echo "🔄 Syncing agents to Claude Desktop..."

# Define directories
SOURCE_DIR="$(pwd)"  # Current agents directory
CLAUDE_DESKTOP_DIR="$HOME/.claude/agents"  # Claude Desktop expects agents here
OLD_CONFIG_DIR="$HOME/.config/claude/agents"  # Our old location

# Create Claude Desktop agents directory if it doesn't exist
echo "📁 Creating Claude Desktop agents directory..."
mkdir -p "$CLAUDE_DESKTOP_DIR"

# Function to sync an agent with proper naming
sync_agent() {
    local source_file=$1
    local agent_name=$(basename "$source_file" .md)
    
    # Map our agent names to Claude Desktop names if needed
    case "$agent_name" in
        "devops-agent")
            target_name="devops-infrastructure-specialist"
            ;;
        "database-engineer-agent")
            target_name="database-architect"
            ;;
        "gcp-expert-agent")
            target_name="gcp-cloud-architect"
            ;;
        "react-agent")
            target_name="react-specialist"
            ;;
        "go-agent")
            target_name="go-specialist"
            ;;
        "api-design-agent")
            target_name="api-design-architect"
            ;;
        "qa-testing-agent")
            target_name="code-quality-auditor"
            ;;
        "pr-manager-agent")
            target_name="pr-lifecycle-manager"
            ;;
        *)
            target_name="$agent_name"
            ;;
    esac
    
    local target_file="$CLAUDE_DESKTOP_DIR/${target_name}.md"
    
    # Copy with YAML frontmatter if needed
    if head -n 1 "$source_file" 2>/dev/null | grep -q "^---$"; then
        # Already has frontmatter, just copy
        cp "$source_file" "$target_file"
        echo "✓ Synced $agent_name → $target_name"
    else
        # Add frontmatter during copy
        cat > "$target_file" << EOF
---
name: "$target_name"
description: "Specialist agent for Claude Desktop"
version: "1.0"
tools: ["*"]
---

EOF
        cat "$source_file" >> "$target_file"
        echo "✓ Synced $agent_name → $target_name (added frontmatter)"
    fi
}

# Sync all agent files
echo ""
echo "📋 Syncing agents..."
synced=0

# List of actual agent files only
AGENT_FILES=(
    "api-design-agent.md"
    "asterisk-expert-agent.md"
    "database-engineer-agent.md"
    "devops-agent.md"
    "gcp-expert-agent.md"
    "go-agent.md"
    "javascript-expert-agent.md"
    "php-agent.md"
    "pr-manager-agent.md"
    "project-comprehension-agent.md"
    "qa-test-orchestrator.md"
    "qa-testing-agent.md"
    "react-agent.md"
    "vicidial-expert-agent.md"
    "webrtc-expert-system.md"
)

for agent in "${AGENT_FILES[@]}"; do
    if [ -f "$agent" ]; then
        sync_agent "$agent"
        ((synced++))
    fi
done

# Create a symlink from old location to new if needed
if [ -d "$OLD_CONFIG_DIR" ] && [ ! -L "$OLD_CONFIG_DIR" ]; then
    echo ""
    echo "🔗 Creating compatibility symlink..."
    mv "$OLD_CONFIG_DIR" "${OLD_CONFIG_DIR}.backup.$(date +%Y%m%d)"
    ln -s "$CLAUDE_DESKTOP_DIR" "$OLD_CONFIG_DIR"
    echo "✓ Old location now points to Claude Desktop location"
fi

echo ""
echo "✅ Sync Complete!"
echo "   Synced: $synced agents"
echo "   Location: $CLAUDE_DESKTOP_DIR"
echo ""
echo "📝 Available in Claude Desktop:"
echo "   User agents: ~/.claude/agents/"
echo "   Use /agents command to see all available agents"
echo ""
echo "💡 To use an agent:"
echo "   1. Type /agents to see the list"
echo "   2. Click on an agent to activate it"
echo "   3. Or type: Use the [agent-name] agent"
