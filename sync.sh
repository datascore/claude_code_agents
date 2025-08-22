#!/bin/bash
# Ultra-simple sync script - copy files with YAML headers
# KEEPS ORIGINAL FILENAMES - NO RENAMING

echo "🔄 Syncing agents to ~/.claude/agents/"
echo "======================================"

# Create target directory
mkdir -p ~/.claude/agents

# Clean old files
rm -f ~/.claude/agents/*.md 2>/dev/null

echo "📤 Copying agents with original names..."

# Simple function to add YAML and copy - KEEPS ORIGINAL NAME
sync_agent() {
    local filename="$1"
    local basename="${filename%.md}"
    
    if [ -f "$filename" ]; then
        (
            echo "---"
            echo "name: \"$basename\""
            echo "description: \"Specialized AI assistant\""
            echo "version: \"1.0\""
            echo "tools: [\"*\"]"
            echo "---"
            echo ""
            cat "$filename"
        ) > ~/.claude/agents/$filename
        echo "   ✓ $basename"
    fi
}

# Copy each agent WITH ORIGINAL NAMES
sync_agent api-design-agent.md
sync_agent asterisk-expert-agent.md
sync_agent database-engineer-agent.md
sync_agent devops-agent.md
sync_agent gcp-expert-agent.md
sync_agent go-agent.md
sync_agent javascript-expert-agent.md
sync_agent php-agent.md
sync_agent pr-manager-agent.md
sync_agent project-comprehension-agent.md
sync_agent qa-test-orchestrator.md
sync_agent qa-testing-agent.md
sync_agent react-agent.md
sync_agent vicidial-expert-agent.md
sync_agent webrtc-expert-system.md

echo ""
echo "✅ Done! Agents synced to ~/.claude/agents/"
echo "Total: $(ls -1 ~/.claude/agents/*.md 2>/dev/null | wc -l) agents"
