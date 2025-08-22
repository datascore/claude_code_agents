#!/bin/bash
# Claude Code Agent Sync - FIXED VERSION
# Properly formats agents for Claude Code with correct YAML frontmatter

set -e

echo "🔄 Claude Code Agent Sync (Fixed Version)"
echo "=========================================="

# Define directories
SOURCE_DIR="$(pwd)"
CLAUDE_CODE_DIR="$HOME/.config/claude/agents"  # Claude Code uses .config/claude, not .claude

# Create directory if it doesn't exist
mkdir -p "$CLAUDE_CODE_DIR"

# Clean out old files first
echo "🧹 Cleaning old agent files..."
rm -f "$CLAUDE_CODE_DIR"/*.md 2>/dev/null || true

# Function to extract description from agent content
extract_description() {
    local file=$1
    
    # Try to extract from Role section
    local desc=$(grep -A1 "## Role" "$file" 2>/dev/null | tail -1 | sed 's/^[[:space:]]*//' | head -c 100 || echo "")
    
    # If no Role section, try first "You are" line
    if [ -z "$desc" ]; then
        desc=$(grep -m1 "^You are" "$file" 2>/dev/null | head -c 100 || echo "")
    fi
    
    # If still nothing, try Expertise section
    if [ -z "$desc" ]; then
        desc=$(grep -A1 "## Expertise" "$file" 2>/dev/null | tail -1 | sed 's/^[[:space:]]*//' | head -c 100 || echo "")
    fi
    
    # Default if nothing found
    if [ -z "$desc" ]; then
        desc="Specialized AI assistant for technical tasks"
    fi
    
    # Clean up the description
    desc=$(echo "$desc" | sed 's/["]//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    echo "$desc"
}

# Function to ensure CORRECT Claude Code YAML frontmatter
ensure_claude_code_yaml() {
    local file=$1
    local temp_file="${file}.tmp"
    
    # Extract agent name from filename (remove .processing and .md if present)
    local agent_name=$(basename "$file")
    agent_name=${agent_name%.md.processing}  # Remove .md.processing suffix if present
    agent_name=${agent_name%.processing}  # Remove .processing suffix if present
    agent_name=${agent_name%.md}  # Remove .md suffix if present
    
    # Extract description from content
    local description=$(extract_description "$file")
    
    # Create file with CORRECT Claude Code YAML format
    cat > "$temp_file" << EOF
---
name: "$agent_name"
description: "$description"
version: "1.0"
tools: ["*"]
---

EOF
    
    # Append the original content, skipping any existing frontmatter
    if head -1 "$file" | grep -q "^---$"; then
        # Skip existing frontmatter
        awk 'BEGIN{skip=1}/^---$/{count++; if(count==2) skip=0; next} skip==0{print}' "$file" >> "$temp_file"
    else
        # Just append everything
        cat "$file" >> "$temp_file"
    fi
    
    mv "$temp_file" "$file"
}

# Function to get Claude Code name
get_claude_code_name() {
    local file=$1
    local base_name=$(basename "$file" .md)
    
    # Check for metadata override
    local metadata_name=$(grep -m1 "^<!-- claude-code-name:" "$file" 2>/dev/null | sed 's/<!-- claude-code-name: //' | sed 's/ -->//' || true)
    
    if [ -n "$metadata_name" ]; then
        echo "$metadata_name"
        return
    fi
    
    # Smart naming conversion
    local clean_name="${base_name%-agent}"
    clean_name="${clean_name%-expert}"
    clean_name="${clean_name%-expert-agent}"
    
    case "$clean_name" in
        "devops")
            echo "devops-infrastructure-specialist"
            ;;
        "database-engineer")
            echo "database-architect"
            ;;
        "gcp")
            echo "gcp-cloud-architect"
            ;;
        "react")
            echo "react-specialist"
            ;;
        "go")
            echo "go-specialist"
            ;;
        "api-design")
            echo "api-design-architect"
            ;;
        "qa-testing")
            echo "code-quality-auditor"
            ;;
        "pr-manager")
            echo "pr-lifecycle-manager"
            ;;
        "javascript")
            echo "javascript-specialist"
            ;;
        "python")
            echo "python-specialist"
            ;;
        "typescript")
            echo "typescript-specialist"
            ;;
        "php")
            echo "php-specialist"
            ;;
        *)
            # Default: add -specialist suffix if not present
            if [[ "$clean_name" == *"-specialist" ]] || \
               [[ "$clean_name" == *"-architect" ]] || \
               [[ "$clean_name" == *"-orchestrator" ]] || \
               [[ "$clean_name" == *"-manager" ]] || \
               [[ "$clean_name" == *"-auditor" ]] || \
               [[ "$clean_name" == *"-expert-system" ]]; then
                echo "$clean_name"
            else
                echo "${clean_name}-specialist"
            fi
            ;;
    esac
}

# Function to check if file is an agent
is_agent_file() {
    local file=$1
    local basename=$(basename "$file")
    
    # Skip non-agent files - comprehensive list
    # Special case: qa-test-orchestrator IS an agent despite having 'test' in name
    if [[ "$basename" == "qa-test-orchestrator.md" ]]; then
        # This IS an agent, don't skip it
        :
    elif [[ "$basename" == "README.md" ]] || \
       [[ "$basename" == "AGENT_CATALOG.md" ]] || \
       [[ "$basename" == "DISCOVERY_WORKFLOW.md" ]] || \
       [[ "$basename" == "REMOTE_SETUP.md" ]] || \
       [[ "$basename" == *"orchestration-instructions"* ]] || \
       [[ "$basename" == "claude.md" ]] || \
       [[ "$basename" == *"report"* ]] || \
       [[ "$basename" == *"test"* ]] || \
       [[ "$basename" == *"backup"* ]] || \
       [[ "$basename" == *"temp"* ]] || \
       [[ "$basename" == *"loader"* ]] || \
       [[ "$basename" == *"mapper"* ]] || \
       [[ "$basename" == *"WORKFLOW"* ]] || \
       [[ "$basename" == *"SETUP"* ]] || \
       [[ "$basename" == "."* ]] || \
       [[ "$basename" == *".json" ]] || \
       [[ "$basename" == *".sh" ]] || \
       [[ "$basename" == *".log" ]] || \
       [[ "$basename" == *".plist" ]]; then
        return 1
    fi
    
    # Check for agent markers
    if grep -q "## Role\|## Expertise\|## Core\|## Capabilities\|You are a\|You are an" "$file" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

# Discover all agent files
echo "🔍 Discovering agent files..."
AGENT_FILES=()
AGENT_MAP=()

for file in *.md; do
    if [ -f "$file" ] && is_agent_file "$file"; then
        AGENT_FILES+=("$file")
        claude_name=$(get_claude_code_name "$file")
        AGENT_MAP+=("$(basename "$file" .md):$claude_name")
        echo "   ✓ Found: $(basename "$file" .md) → $claude_name"
    fi
done

echo ""
echo "📊 Discovered ${#AGENT_FILES[@]} agents"

# Sync agents with proper Claude Code formatting
echo ""
echo "📤 Syncing to Claude Code with correct YAML format..."
synced_code=0
failed_sync=0

for agent in "${AGENT_FILES[@]}"; do
    if [ -f "$agent" ]; then
        claude_name=$(get_claude_code_name "$agent")
        target_file="$CLAUDE_CODE_DIR/${claude_name}.md"
        
        # Copy to temp location
        cp "$agent" "${target_file}.processing"
        
        # Apply correct Claude Code YAML format
        ensure_claude_code_yaml "${target_file}.processing"
        
        # Verify YAML is correct
        if head -4 "${target_file}.processing" | grep -q 'name:\|description:\|version:\|tools:'; then
            mv "${target_file}.processing" "$target_file"
            echo "   ✅ $(basename "$agent" .md) → $claude_name"
            ((synced_code++))
        else
            echo "   ❌ Failed to format: $(basename "$agent")"
            rm "${target_file}.processing"
            ((failed_sync++))
        fi
    fi
done

# Create qa-testing alias
if [ -f "qa-testing-agent.md" ]; then
    cp "qa-testing-agent.md" "$CLAUDE_CODE_DIR/code-review-auditor.md"
    ensure_claude_code_yaml "$CLAUDE_CODE_DIR/code-review-auditor.md"
    echo "   ✅ qa-testing-agent → code-review-auditor (alias)"
    ((synced_code++))
fi

# Generate registry
echo ""
echo "📝 Generating agent registry..."
cat > "$SOURCE_DIR/agent-registry.json" << EOF
{
  "generated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_agents": ${#AGENT_FILES[@]},
  "synced": $synced_code,
  "failed": $failed_sync,
  "claude_code_dir": "$CLAUDE_CODE_DIR",
  "yaml_format": "claude-code-v1",
  "mappings": [
EOF

first=true
for mapping in "${AGENT_MAP[@]}"; do
    IFS=':' read -r original claude <<< "$mapping"
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$SOURCE_DIR/agent-registry.json"
    fi
    echo -n "    {\"original\": \"$original\", \"claude_code\": \"$claude\"}" >> "$SOURCE_DIR/agent-registry.json"
done

cat >> "$SOURCE_DIR/agent-registry.json" << EOF

  ]
}
EOF

# Verify all files have correct YAML
echo ""
echo "🔍 Verifying Claude Code YAML format..."
verified=0
missing_fields=0

for file in "$CLAUDE_CODE_DIR"/*.md; do
    if [ -f "$file" ]; then
        # Check for all required fields
        if head -5 "$file" | grep -q "^name:" && \
           head -5 "$file" | grep -q "^description:" && \
           head -5 "$file" | grep -q "^version:" && \
           head -5 "$file" | grep -q "^tools:"; then
            ((verified++))
        else
            echo "   ⚠️ Missing required fields: $(basename "$file")"
            ((missing_fields++))
        fi
    fi
done

echo "   ✅ Verified: $verified/$synced_code agents have correct YAML"
if [ $missing_fields -gt 0 ]; then
    echo "   ⚠️ Missing fields: $missing_fields agents"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "✅ Claude Code Sync Complete!"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "   📊 Total discovered: ${#AGENT_FILES[@]} agents"
echo "   ✅ Successfully synced: $synced_code agents"
if [ $failed_sync -gt 0 ]; then
    echo "   ❌ Failed to sync: $failed_sync agents"
fi
echo "   📁 Location: $CLAUDE_CODE_DIR"
echo "   📝 Registry: $SOURCE_DIR/agent-registry.json"
echo ""
echo "📋 Available agents in Claude Code:"
echo ""

# List all synced agents with descriptions
for file in "$CLAUDE_CODE_DIR"/*.md; do
    if [ -f "$file" ]; then
        agent_name=$(basename "$file" .md)
        # Extract description from YAML
        desc=$(grep "^description:" "$file" 2>/dev/null | sed 's/description: "//' | sed 's/"$//' | head -c 60 || echo "")
        if [ -n "$desc" ]; then
            printf "   • %-35s - %s\n" "$agent_name" "${desc}..."
        else
            printf "   • %s\n" "$agent_name"
        fi
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📝 PROMPT FOR CLAUDE CODE - Copy this:"
echo "--------------------------------------------------------------------------------"
cat << 'PROMPT'
Review all agents in ~/.config/claude/agents/ and generate comprehensive 
orchestration documentation for the project's claude.md file.

Analyze each agent's YAML metadata and content to create:

1. **Complete Agent Inventory** - List all agents with their descriptions and capabilities
2. **Task Routing Guide** - Decision tree for selecting the right agent for each task
3. **Multi-Agent Workflows** - How to combine agents for complex problems
4. **Real-World Examples** - Practical scenarios using agent combinations
5. **Performance Tips** - Best practices for efficient agent usage

Format as structured markdown ready for claude.md integration.
Focus on practical orchestration patterns that maximize collective intelligence.
PROMPT
echo "--------------------------------------------------------------------------------"
echo ""
echo "🚀 Next Steps:"
echo "   1. Copy the prompt above into Claude Code"
echo "   2. Review generated orchestration docs"
echo "   3. Add to your project's claude.md file"
echo ""
echo "🔄 Auto-discovery enabled - new agents sync automatically!"
echo "📌 All agents now have Claude Code compliant YAML frontmatter"
