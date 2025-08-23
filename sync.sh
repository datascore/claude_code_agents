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
    local description="$2"
    local basename="${filename%.md}"
    
    if [ -f "$filename" ]; then
        (
            echo "---"
            echo "name: $basename"
            echo "description: $description"
            echo "tools: Read, Write, Edit, Bash, Grep, Find, SearchCodebase, CreateFile, RunCommand, Task"
            echo "---"
            echo ""
            cat "$filename"
        ) > ~/.claude/agents/$filename
        echo "   ✓ $basename - $description"
    fi
}

# Copy each agent WITH ORIGINAL NAMES and meaningful descriptions
sync_agent api-design-agent.md "Expert in REST, GraphQL, and API design patterns"
sync_agent asterisk-expert-agent.md "Asterisk PBX and VoIP telephony specialist"
sync_agent database-engineer-agent.md "Database design, optimization, and SQL/NoSQL expert"
sync_agent devops-agent.md "CI/CD, Docker, Kubernetes, and infrastructure automation"
sync_agent gcp-expert-agent.md "Google Cloud Platform architecture and services expert"
sync_agent go-agent.md "Go programming language specialist and best practices"
sync_agent javascript-expert-agent.md "JavaScript, Node.js, and modern JS frameworks expert"
sync_agent php-agent.md "PHP development, Laravel, and web application expert"
sync_agent pr-manager-agent.md "Pull request management and code review specialist"
sync_agent project-comprehension-agent.md "Codebase analysis and project understanding expert"
sync_agent qa-test-orchestrator.md "Test automation, QA strategies, and testing frameworks"
sync_agent qa-testing-agent.md "Code quality assurance and testing best practices"
sync_agent react-agent.md "React, frontend development, and component architecture"
sync_agent typescript-specialist.md "TypeScript expert for type systems, advanced patterns, and migrations"
sync_agent vicidial-expert-agent.md "ViciDial call center platform specialist"
sync_agent webrtc-expert-system.md "WebRTC, real-time communication, and media streaming"

echo ""
echo "✅ Done! Agents synced to ~/.claude/agents/"
echo "Total: $(ls -1 ~/.claude/agents/*.md 2>/dev/null | wc -l) agents"
