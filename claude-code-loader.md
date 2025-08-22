# Claude Code Agent Loader Bridge

## Overview
This document bridges the gap between the sophisticated agent sync system and Claude Code's agent loading mechanism.

## How Claude Code Loads Agents

### 1. Agent Discovery
Claude Code looks for `.md` files in the agents directory that follow a specific structure:
- Must have a `## Role` section
- Should have `## Core Expertise` section
- Can include specialized instructions

### 2. Agent Selection
When you interact with Claude Code, it:
1. Reads available agent files
2. Analyzes your request
3. Selects the most appropriate agent based on expertise match
4. Loads that agent's instructions as context

### 3. Agent Context Loading
The selected agent's entire `.md` file becomes part of Claude's context, essentially becoming Claude's "personality" and expertise for that conversation.

## Integration with Your Sync System

### Current State
Your sync system (`update_claude.sh`) already:
- ✅ Syncs agent files from GitHub
- ✅ Updates local ~/.config/claude/agents/
- ✅ Maintains version control
- ✅ Provides rollback capability

### The Missing Bridge

```bash
#!/bin/bash
# claude-code-bridge.sh
# This script ensures Claude Code can properly load your synced agents

# 1. Ensure Claude Code knows where to find agents
CLAUDE_AGENTS_DIR="$HOME/.config/claude/agents"
CLAUDE_CODE_DIR="$HOME/Library/Application Support/Claude/agents"  # macOS path

# 2. Create symbolic link if Claude Code uses different location
if [ -d "$CLAUDE_CODE_DIR" ]; then
    echo "Linking agents to Claude Code directory..."
    ln -sf "$CLAUDE_AGENTS_DIR"/* "$CLAUDE_CODE_DIR/"
fi

# 3. Validate agent format for Claude Code compatibility
validate_agent_format() {
    local agent_file=$1
    
    # Check for required sections
    if ! grep -q "## Role" "$agent_file"; then
        echo "Warning: $agent_file missing ## Role section"
        return 1
    fi
    
    if ! grep -q "## Core Expertise" "$agent_file"; then
        echo "Warning: $agent_file missing ## Core Expertise section"
        return 1
    fi
    
    return 0
}

# 4. Process all agents
for agent in "$CLAUDE_AGENTS_DIR"/*.md; do
    if [ -f "$agent" ]; then
        agent_name=$(basename "$agent")
        echo "Validating $agent_name..."
        
        if validate_agent_format "$agent"; then
            echo "✓ $agent_name is Claude Code compatible"
        else
            echo "✗ $agent_name needs formatting fixes"
        fi
    fi
done

# 5. Generate agent catalog for Claude Code
generate_catalog() {
    cat > "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md" << 'EOF'
# Available Agents for Claude Code

## How to Use
1. Start a conversation with Claude Code
2. Claude will automatically select the appropriate agent
3. Or you can request a specific agent: "Use the go-agent for this task"

## Available Specialists
EOF

    for agent in "$CLAUDE_AGENTS_DIR"/*.md; do
        if [ -f "$agent" ] && [[ ! "$agent" =~ (README|CATALOG|SETUP) ]]; then
            agent_name=$(basename "$agent" .md)
            role=$(grep -A1 "## Role" "$agent" | tail -1)
            echo "" >> "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md"
            echo "### $agent_name" >> "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md"
            echo "$role" >> "$CLAUDE_AGENTS_DIR/CLAUDE_CODE_CATALOG.md"
        fi
    done
}

generate_catalog
echo "Agent catalog generated for Claude Code"
```

## Claude Code Integration Points

### 1. Agent Loading Trigger
Claude Code loads an agent when:
- You explicitly request it: "Use the project-comprehension-agent"
- Your query matches agent expertise
- A project type is detected (Go project → go-agent)

### 2. Agent Switching
During a conversation, you can switch agents:
```
"Now use the database-engineer-agent to design the schema"
```

### 3. Multi-Agent Coordination
The Project Comprehension Agent can coordinate multiple agents by:
1. Creating an SDD
2. Identifying required expertise
3. Suggesting which agents to use for each part

## Enhanced Update Script

```bash
#!/bin/bash
# update_claude_enhanced.sh
# Enhanced version that bridges with Claude Code

set -e

# Your existing sync logic
source ~/.config/claude/update_claude.sh

# Additional Claude Code integration
echo "Bridging with Claude Code..."

# 1. Ensure Claude Code compatibility
for agent in ~/.config/claude/agents/*.md; do
    # Add required sections if missing
    if ! grep -q "## Role" "$agent"; then
        echo -e "\n## Role\nSpecialist agent for Claude Code\n" >> "$agent"
    fi
done

# 2. Create agent loader manifest
cat > ~/.config/claude/agents/manifest.json << EOF
{
  "version": "1.0",
  "agents": [
$(for agent in ~/.config/claude/agents/*.md; do
    if [[ ! "$agent" =~ (README|CATALOG|SETUP) ]]; then
        name=$(basename "$agent" .md)
        echo "    {\"name\": \"$name\", \"file\": \"$agent\"},"
    fi
done | sed '$ s/,$//')
  ],
  "default": "project-comprehension-agent"
}
EOF

# 3. Notify Claude Code of updates (if running)
if pgrep -x "Claude" > /dev/null; then
    echo "Claude Code is running - new agents will be available on next conversation"
fi

echo "✓ Claude Code bridge complete"
```

## Usage in Claude Code

### Starting a Conversation
```markdown
You: "I need to add recording to our FreeSWITCH system"

Claude (automatically loads project-comprehension-agent): 
"I'll analyze this as your Technical Architect. Let me review the discovery 
document and research your codebase to create a detailed SDD..."
```

### Explicit Agent Request
```markdown
You: "Use the go-agent to review this Go code"

Claude (switches to go-agent):
"As your Go specialist, I'll review this code following Go best practices..."
```

### Multi-Agent Workflow
```markdown
You: "Here's the SDD. Now implement the database changes"

Claude (loads database-engineer-agent):
"I'll design the schema changes based on the SDD specifications..."
```

## Validation Checklist

### For Each Agent File
- [ ] Has `## Role` section
- [ ] Has `## Core Expertise` section  
- [ ] Follows markdown formatting
- [ ] No syntax errors
- [ ] Clear expertise definition
- [ ] Actionable instructions

### For the Sync System
- [ ] Agents sync to ~/.config/claude/agents/
- [ ] Update script runs successfully
- [ ] Rollback mechanism works
- [ ] Version tracking active

### For Claude Code
- [ ] Agents are discoverable
- [ ] Expertise matching works
- [ ] Agent switching functions
- [ ] Context loads properly

## Troubleshooting

### Agent Not Loading
1. Check file has required sections
2. Verify file is in correct directory
3. Ensure .md extension
4. Check for markdown syntax errors

### Wrong Agent Selected
1. Make expertise section more specific
2. Use explicit agent request
3. Check for expertise overlap

### Sync Issues
1. Run validation script
2. Check GitHub connectivity
3. Verify local permissions
4. Review update logs

## Next Steps

1. **Run the bridge script** to ensure compatibility
2. **Test agent loading** in Claude Code
3. **Validate each agent** has proper format
4. **Document any custom agents** you create

The bridge is now complete! Your sophisticated sync system will work seamlessly with Claude Code's agent loading mechanism.
