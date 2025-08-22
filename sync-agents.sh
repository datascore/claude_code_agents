#!/bin/bash
# Sync agents to Claude Code with proper name mapping
# Claude Code expects specific names like go-specialist, not go-agent

set -e

echo "🔄 Syncing agents to Claude Code..."

# Define directories
SOURCE_DIR="$(pwd)"  # Current agents directory
CLAUDE_CODE_DIR="$HOME/.config/claude/agents"  # Claude Code location

# Create Claude Code agents directory if it doesn't exist
echo "📁 Creating Claude Code agents directory..."
mkdir -p "$CLAUDE_CODE_DIR"

# Clean out old files first
echo "🧹 Cleaning old agent files..."
rm -f "$CLAUDE_CODE_DIR"/*.md 2>/dev/null || true

# Function to sync agent with proper name mapping for Claude Code
sync_agent_to_claude_code() {
    local source_file=$1
    local agent_name=$(basename "$source_file" .md)
    local target_name=""
    
    # Map our agent names to Claude Code expected names
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
        "javascript-expert-agent")
            # Keep original name for this one
            target_name="javascript-expert-agent"
            ;;
        "qa-test-orchestrator")
            # This one stays the same
            target_name="qa-test-orchestrator"
            ;;
        *)
            # Default: use original name
            target_name="$agent_name"
            ;;
    esac
    
    local target_file="$CLAUDE_CODE_DIR/${target_name}.md"
    
    # For Claude Code, we DON'T need YAML frontmatter
    # Just copy the original content
    cp "$source_file" "$target_file"
    
    echo "✓ Synced $agent_name → $target_name"
}

# List of agent files to sync
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

echo ""
echo "📋 Syncing agents to Claude Code..."
synced=0

for agent in "${AGENT_FILES[@]}"; do
    if [ -f "$agent" ]; then
        sync_agent_to_claude_code "$agent"
        ((synced++))
    else
        echo "⚠️  Missing: $agent"
    fi
done

# Also add a code-review-auditor (which Claude Code expects)
if [ -f "qa-testing-agent.md" ]; then
    cp "qa-testing-agent.md" "$CLAUDE_CODE_DIR/code-review-auditor.md"
    echo "✓ Created code-review-auditor (from qa-testing-agent)"
    ((synced++))
fi

echo ""
echo "✅ Claude Code Sync Complete!"
echo "   Synced: $synced agents"
echo "   Location: $CLAUDE_CODE_DIR"
echo ""
echo "📝 Available in Claude Code Task tool:"
echo "   • database-architect"
echo "   • devops-infrastructure-specialist"
echo "   • qa-test-orchestrator"
echo "   • gcp-cloud-architect"
echo "   • react-specialist"
echo "   • go-specialist"
echo "   • code-review-auditor"
echo "   • api-design-architect"
echo "   • code-quality-auditor"
echo "   • pr-lifecycle-manager"
echo ""
echo "💡 Usage example:"
echo "   Task(subagent_type: 'go-specialist', task: 'Review this Go code')"
