#!/bin/bash
# Clean up Claude Desktop agents directory
# Remove non-agent files that are causing parse errors

set -e

CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
BACKUP_DIR="$HOME/.claude/agents_backup_full_$(date +%Y%m%d_%H%M%S)"

echo "🧹 Cleaning Claude Desktop Agents Directory"
echo "==========================================="

# Create full backup first
echo "📦 Creating full backup at $BACKUP_DIR..."
cp -r "$CLAUDE_AGENTS_DIR" "$BACKUP_DIR"

# List of files to remove (non-agent files)
NON_AGENT_FILES=(
    "AGENT_CATALOG.md"
    "README.md"
    "DISCOVERY_WORKFLOW.md"
    "REMOTE_SETUP.md"
    "claude-code-loader.md"
    "CLAUDE_CODE_CATALOG.md"
    "manifest.json"
    "engageiq-comprehensive-qa-report.md"
    "engageiq-qa-report-detailed.md"
    "engageiq-final-qa-report.md"
)

# Remove .github directory if it exists
if [ -d "$CLAUDE_AGENTS_DIR/.github" ]; then
    echo "🗑️  Removing .github directory..."
    rm -rf "$CLAUDE_AGENTS_DIR/.github"
fi

# Remove non-agent files
echo "🗑️  Removing non-agent files..."
for file in "${NON_AGENT_FILES[@]}"; do
    if [ -f "$CLAUDE_AGENTS_DIR/$file" ]; then
        rm -f "$CLAUDE_AGENTS_DIR/$file"
        echo "   ✓ Removed $file"
    fi
done

# List of valid agent files that should remain
VALID_AGENTS=(
    "api-design-architect"
    "asterisk-expert-agent"
    "database-architect"
    "devops-infrastructure-specialist"
    "gcp-cloud-architect"
    "go-specialist"
    "javascript-expert-agent"
    "php-agent"
    "pr-lifecycle-manager"
    "project-comprehension-agent"
    "qa-test-orchestrator"
    "code-quality-auditor"
    "react-specialist"
    "vicidial-expert-agent"
    "webrtc-expert-system"
    "code-review-auditor"
)

# Verify all valid agents have proper frontmatter
echo ""
echo "✅ Verifying agent files have proper frontmatter..."
for agent in "${VALID_AGENTS[@]}"; do
    agent_file="$CLAUDE_AGENTS_DIR/${agent}.md"
    
    if [ -f "$agent_file" ]; then
        # Check if file has frontmatter
        if ! head -n 1 "$agent_file" | grep -q "^---$"; then
            echo "   ⚠️  Adding frontmatter to $agent"
            
            # Extract description from Role section if possible
            desc=$(grep -A2 "## Role" "$agent_file" 2>/dev/null | tail -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "Specialist agent")
            [ -z "$desc" ] && desc="Specialist agent for Claude Desktop"
            desc="${desc:0:100}"  # Truncate to 100 chars
            
            # Create temp file with frontmatter
            temp_file="${agent_file}.tmp"
            cat > "$temp_file" << EOF
---
name: "$agent"
description: "$desc"
version: "1.0"
tools: ["*"]
---

EOF
            cat "$agent_file" >> "$temp_file"
            mv "$temp_file" "$agent_file"
        else
            echo "   ✓ $agent has frontmatter"
        fi
    else
        echo "   ⚠️  Missing: $agent"
    fi
done

# Count remaining files
AGENT_COUNT=$(ls -1 "$CLAUDE_AGENTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "📊 Summary:"
echo "   • Backup created at: $BACKUP_DIR"
echo "   • Valid agents remaining: $AGENT_COUNT"
echo "   • Non-agent files removed"
echo ""
echo "✨ Claude Desktop agents directory cleaned!"
echo ""
echo "Try the /agents command in Claude Desktop now."
