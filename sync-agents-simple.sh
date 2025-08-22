#!/bin/bash
# Claude Code Agent Sync - Simple and Reliable
# This is the ONE sync script that works consistently

set -e

echo "🔄 Claude Code Agent Sync"
echo "========================="

TARGET="$HOME/.claude/agents"
mkdir -p "$TARGET"

# Clean old files
echo "🧹 Cleaning old agent files..."
rm -f "$TARGET"/*.md 2>/dev/null || true

echo "📤 Syncing agents to Claude Code..."
echo ""

# Function to copy agent with YAML frontmatter
copy_agent() {
    local source=$1
    local target_name=$2
    local target_file="$TARGET/${target_name}.md"
    
    if [ -f "$source" ]; then
        # Extract description from agent file
        local desc=$(grep -m1 "^You are" "$source" 2>/dev/null | head -c 100 || echo "Specialized AI assistant")
        desc=${desc//\"/}  # Remove quotes
        
        # Write YAML frontmatter and content
        {
            echo "---"
            echo "name: \"$target_name\""
            echo "description: \"$desc\""
            echo "version: \"1.0\""
            echo "tools: [\"*\"]"
            echo "---"
            echo ""
            cat "$source"
        } > "$target_file"
        
        echo "   ✅ $(basename "$source" .md) → $target_name"
        return 0
    else
        return 1
    fi
}

# Sync each agent with proper name mapping
copy_agent "api-design-agent.md" "api-design-architect"
copy_agent "asterisk-expert-agent.md" "asterisk-specialist"
copy_agent "database-engineer-agent.md" "database-architect"
copy_agent "devops-agent.md" "devops-infrastructure-specialist"
copy_agent "gcp-expert-agent.md" "gcp-cloud-architect"
copy_agent "go-agent.md" "go-specialist"
copy_agent "javascript-expert-agent.md" "javascript-specialist"
copy_agent "php-agent.md" "php-specialist"
copy_agent "pr-manager-agent.md" "pr-lifecycle-manager"
copy_agent "project-comprehension-agent.md" "project-comprehension-specialist"
copy_agent "qa-test-orchestrator.md" "qa-test-orchestrator"
copy_agent "qa-testing-agent.md" "code-quality-auditor"
copy_agent "react-agent.md" "react-specialist"
copy_agent "vicidial-expert-agent.md" "vicidial-specialist"
copy_agent "webrtc-expert-system.md" "webrtc-expert-system"

# Special alias: qa-testing-agent also becomes code-review-auditor
copy_agent "qa-testing-agent.md" "code-review-auditor"

echo ""
echo "✅ Sync Complete!"
echo "================="
echo "   📁 Location: $TARGET"
echo "   📊 Total agents synced:"
ls -1 "$TARGET"/*.md 2>/dev/null | wc -l
echo ""
echo "💡 Usage in Claude Code:"
echo "   Task(subagent_type: 'go-specialist', task: 'Review this Go code')"
echo ""
echo "🔍 To verify agents:"
echo "   ls ~/.claude/agents/"
