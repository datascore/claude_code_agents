#!/bin/bash
# Ultra-simple sync script - just copy files with YAML headers
# No complex processing that can hang

echo "🔄 Syncing agents to ~/.claude/agents/"
echo "======================================"

# Create target directory
mkdir -p ~/.claude/agents

# Clean old files
rm -f ~/.claude/agents/*.md 2>/dev/null

echo "📤 Copying agents..."

# Simple function to add YAML and copy
sync_agent() {
    if [ -f "$1" ]; then
        (
            echo "---"
            echo "name: \"$2\""
            echo "description: \"Specialized AI assistant\""
            echo "version: \"1.0\""
            echo "tools: [\"*\"]"
            echo "---"
            echo ""
            cat "$1"
        ) > ~/.claude/agents/$2.md
        echo "   ✓ $2"
    fi
}

# Copy each agent
sync_agent api-design-agent.md api-design-architect
sync_agent asterisk-expert-agent.md asterisk-specialist
sync_agent database-engineer-agent.md database-architect
sync_agent devops-agent.md devops-infrastructure-specialist
sync_agent gcp-expert-agent.md gcp-cloud-architect
sync_agent go-agent.md go-specialist
sync_agent javascript-expert-agent.md javascript-specialist
sync_agent php-agent.md php-specialist
sync_agent pr-manager-agent.md pr-lifecycle-manager
sync_agent project-comprehension-agent.md project-comprehension-specialist
sync_agent qa-test-orchestrator.md qa-test-orchestrator
sync_agent qa-testing-agent.md code-quality-auditor
sync_agent qa-testing-agent.md code-review-auditor
sync_agent react-agent.md react-specialist
sync_agent vicidial-expert-agent.md vicidial-specialist
sync_agent webrtc-expert-system.md webrtc-expert-system

echo ""
echo "✅ Done! Agents synced to ~/.claude/agents/"
echo "Total: $(ls -1 ~/.claude/agents/*.md 2>/dev/null | wc -l) agents"
