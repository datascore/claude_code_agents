#!/bin/bash
# Ultra-simple sync script - copy files with YAML headers
# KEEPS ORIGINAL FILENAMES - NO RENAMING
# SYNCS TO USER-LEVEL ONLY (~/.claude/agents/) - NOT PROJECT-LEVEL

echo "🔄 Syncing agents to USER-LEVEL directory"
echo "   Location: ~/.claude/agents/"
echo "   Scope: Available across ALL projects"
echo "======================================"

# Check if Claude Code agents directory exists
if [ ! -d ~/.claude/agents ]; then
    echo "❌ Error: ~/.claude/agents directory does not exist!"
    echo "   Please ensure Claude Code is properly installed first."
    exit 1
fi

# Clean old files
rm -f ~/.claude/agents/*.md 2>/dev/null

echo "📤 Copying agents with original names..."

# Simple function to add YAML and copy - KEEPS ORIGINAL NAME
sync_agent() {
    local filename="$1"
    local description="$2"
    local basename="${filename%.md}"
    
    if [ -f "$filename" ]; then
        # Extract the "You are" line from the ## Role section
        role_line=$(grep -A 1 "^## Role" "$filename" | tail -1)
        
        # Create the properly formatted agent file
        (
            echo "---"
            echo "name: $basename"
            echo "description: $description"
            echo "tools: Read, Write, Edit, Bash, Grep, Find, SearchCodebase, CreateFile, RunCommand, Task"
            echo "---"
            # Output the role line directly after frontmatter
            echo "$role_line"
            echo ""
            # Skip the first few lines (title and role section) and output the rest
            awk '/^## Core Expertise/,EOF' "$filename"
        ) > ~/.claude/agents/$filename
        echo "   ✓ $basename - $description"
    fi
}

# Copy each agent WITH ORIGINAL NAMES and proactive descriptions
sync_agent api-design-agent.md "MUST BE USED for REST, GraphQL, and API design. Proactively reviews API patterns, endpoints, and OpenAPI specs"
sync_agent asterisk-expert-agent.md "MUST BE USED for Asterisk PBX and VoIP telephony. Proactively handles SIP, dialplans, and telephony configurations"
sync_agent database-engineer-agent.md "MUST BE USED for database design, SQL/NoSQL optimization. Proactively reviews queries, schemas, and migrations"
sync_agent devops-agent.md "MUST BE USED for CI/CD, Docker, Kubernetes. Proactively handles deployments, pipelines, and infrastructure"
sync_agent gcp-expert-agent.md "MUST BE USED for Google Cloud Platform. Proactively manages GCP services, BigQuery, and cloud architecture"
sync_agent go-agent.md "MUST BE USED for Go programming. Proactively reviews Go code, concurrency patterns, and module management"
sync_agent javascript-expert-agent.md "MUST BE USED for JavaScript, Node.js, and modern JS. Proactively handles ES6+, async patterns, and frameworks"
sync_agent php-agent.md "MUST BE USED for PHP development and Laravel. Proactively reviews PHP code, composer packages, and frameworks"
sync_agent pr-manager-agent.md "MUST BE USED for pull requests and code reviews. Proactively manages PR workflows and review processes"
sync_agent project-comprehension-agent.md "MUST BE USED for understanding new codebases. Proactively analyzes project structure and dependencies"
sync_agent qa-test-orchestrator.md "MUST BE USED for test automation and QA strategies. Proactively designs test suites and frameworks"
sync_agent qa-testing-agent.md "MUST BE USED for code quality and testing. Proactively writes tests and ensures coverage"
sync_agent react-agent.md "MUST BE USED for React and frontend development. Proactively handles components, hooks, and state management"
sync_agent typescript-specialist.md "MUST BE USED for TypeScript and type systems. Proactively adds types, migrations, and advanced patterns"
sync_agent vicidial-expert-agent.md "MUST BE USED for ViciDial call center platform. Proactively handles campaign setup and agent management"
sync_agent webrtc-expert-system.md "MUST BE USED for WebRTC and real-time communication. Proactively handles media streams and peer connections"

echo ""
echo "✅ Done! Agents synced to ~/.claude/agents/"
echo "Total: $(ls -1 ~/.claude/agents/*.md 2>/dev/null | wc -l) agents"
