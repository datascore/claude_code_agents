#!/bin/bash
# Simplified agent sync script that won't hang
# Direct and straightforward approach

set -e

echo "🔄 Simple Agent Sync to Claude Code"
echo "===================================="

# Directories
SOURCE_DIR="$(pwd)"
TARGET_DIR="$HOME/.claude/agents"

# Create target directory
mkdir -p "$TARGET_DIR"

# Clean old files
echo "🧹 Cleaning old agent files..."
rm -f "$TARGET_DIR"/*.md 2>/dev/null || true

# Function to map agent names
get_target_name() {
    local base_name=$1
    case "$base_name" in
        "api-design-agent") echo "api-design-architect" ;;
        "asterisk-expert-agent") echo "asterisk-specialist" ;;
        "database-engineer-agent") echo "database-architect" ;;
        "devops-agent") echo "devops-infrastructure-specialist" ;;
        "gcp-expert-agent") echo "gcp-cloud-architect" ;;
        "go-agent") echo "go-specialist" ;;
        "javascript-expert-agent") echo "javascript-specialist" ;;
        "php-agent") echo "php-specialist" ;;
        "pr-manager-agent") echo "pr-lifecycle-manager" ;;
        "project-comprehension-agent") echo "project-comprehension-specialist" ;;
        "qa-test-orchestrator") echo "qa-test-orchestrator" ;;
        "qa-testing-agent") echo "code-quality-auditor" ;;
        "react-agent") echo "react-specialist" ;;
        "vicidial-expert-agent") echo "vicidial-specialist" ;;
        "webrtc-expert-system") echo "webrtc-expert-system" ;;
        *) echo "$base_name" ;;
    esac
}

# Function to add YAML frontmatter
add_yaml_frontmatter() {
    local input_file=$1
    local output_file=$2
    local agent_name=$3
    
    # Extract first line that starts with "You are" for description
    local description=$(grep -m1 "^You are" "$input_file" 2>/dev/null | head -c 100 || echo "Specialized AI assistant")
    description=${description//\"/}  # Remove quotes
    
    # Write YAML frontmatter
    {
        echo "---"
        echo "name: \"$agent_name\""
        echo "description: \"$description\""
        echo "version: \"1.0\""
        echo "tools: [\"*\"]"
        echo "---"
        echo ""
        cat "$input_file"
    } > "$output_file"
}

echo "📤 Syncing agents..."
echo ""

# Process each agent file
synced=0
for file in *.md; do
    # Skip non-agent files
    if [[ "$file" == "README.md" ]] || \
       [[ "$file" == "AGENT_CATALOG.md" ]] || \
       [[ "$file" == "DISCOVERY_WORKFLOW.md" ]] || \
       [[ "$file" == "REMOTE_SETUP.md" ]] || \
       [[ "$file" == *"claude.md" ]] || \
       [[ "$file" == *"orchestration"* ]] || \
       [[ "$file" == *"report"* ]] || \
       [[ "$file" == *"loader"* ]] || \
       [[ "$file" == *"mapper"* ]]; then
        continue
    fi
    
    # Check if it's an agent file
    if ! grep -q "## Role\|## Expertise\|## Core\|You are" "$file" 2>/dev/null; then
        continue
    fi
    
    # Get the base name
    base_name=${file%.md}
    
    # Get target name from mapping
    target_name=$(get_target_name "$base_name")
    
    # Add YAML and copy to target
    target_file="$TARGET_DIR/${target_name}.md"
    add_yaml_frontmatter "$file" "$target_file" "$target_name"
    
    echo "   ✅ $base_name → $target_name"
    ((synced++))
done

# Special case: qa-testing-agent also becomes code-review-auditor
if [ -f "qa-testing-agent.md" ]; then
    add_yaml_frontmatter "qa-testing-agent.md" "$TARGET_DIR/code-review-auditor.md" "code-review-auditor"
    echo "   ✅ qa-testing-agent → code-review-auditor (alias)"
    ((synced++))
fi

echo ""
echo "✅ Sync Complete!"
echo "================="
echo "   📊 Synced: $synced agents"
echo "   📁 Location: $TARGET_DIR"
echo ""
echo "🔍 Verification:"
ls -1 "$TARGET_DIR"/*.md 2>/dev/null | wc -l | xargs echo "   Total files in target:"
echo ""
echo "📝 To use in Claude Code:"
echo "   Task(subagent_type: 'go-specialist', task: 'Review this code')"
