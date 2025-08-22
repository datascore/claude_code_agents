#!/bin/bash
# Manual sync script - processes each agent explicitly
# No loops that can hang

echo "🔄 Manual Agent Sync"
echo "===================="

TARGET="$HOME/.claude/agents"
mkdir -p "$TARGET"

echo "🧹 Cleaning target directory..."
rm -f "$TARGET"/*.md

echo "📤 Syncing agents one by one..."

# Function to copy with YAML
copy_agent() {
    local source=$1
    local target_name=$2
    local target_file="$TARGET/${target_name}.md"
    
    if [ -f "$source" ]; then
        # Get description
        desc=$(grep -m1 "^You are" "$source" 2>/dev/null | head -c 100 || echo "Specialized AI assistant")
        desc=${desc//\"/}
        
        # Write file
        echo "---" > "$target_file"
        echo "name: \"$target_name\"" >> "$target_file"
        echo "description: \"$desc\"" >> "$target_file"
        echo "version: \"1.0\"" >> "$target_file"
        echo "tools: [\"*\"]" >> "$target_file"
        echo "---" >> "$target_file"
        echo "" >> "$target_file"
        cat "$source" >> "$target_file"
        
        echo "   ✅ $(basename "$source" .md) → $target_name"
    fi
}

# Sync each agent explicitly
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

# Special alias for qa-testing-agent
copy_agent "qa-testing-agent.md" "code-review-auditor"

echo ""
echo "✅ Manual sync complete!"
echo "========================"
echo "📁 Location: $TARGET"
echo "📊 Total agents:"
ls -1 "$TARGET"/*.md 2>/dev/null | wc -l
