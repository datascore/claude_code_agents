# Claude Code Agent Mapping Strategy

## The Problem
Claude Code's Task tool only recognizes a whitelist of agents, not custom ones from `~/.config/claude/agents/`.

### Working Agents (Whitelisted):
- `general-purpose`
- `database-architect` 
- `devops-infrastructure-specialist`
- `qa-test-orchestrator`
- `gcp-cloud-architect`
- `react-specialist`
- `go-specialist`
- `code-review-auditor`
- `api-design-architect`
- `pr-lifecycle-manager`
- `code-quality-auditor`

### Not Working (Custom):
- `project-comprehension-agent` ❌
- `asterisk-expert-agent` ❌
- `vicidial-expert-agent` ❌
- `webrtc-expert-system` ❌
- `javascript-expert-agent` ❌
- `php-agent` ❌

## The Solution: Agent Mapping

Since we can't use custom agents directly with the Task tool, we have two approaches:

### Approach 1: Rename Custom Agents to Overwrite Built-ins

Map our custom agents to replace less-used built-in agents:

```bash
# Backup original
cp ~/.config/claude/agents/code-quality-auditor.md ~/.config/claude/agents/code-quality-auditor.md.backup

# Replace with our custom agent
cp ~/.config/claude/agents/project-comprehension-agent.md ~/.config/claude/agents/code-quality-auditor.md

# Now use: Task(subagent_type: 'code-quality-auditor', ...) 
# But it will actually use project-comprehension-agent
```

### Approach 2: Use General-Purpose with Agent Instructions

Embed the agent's expertise in the task description:

```python
# Instead of:
Task(subagent_type: 'project-comprehension-agent', task: 'Analyze this codebase')

# Use:
Task(subagent_type: 'general-purpose', task: '''
Acting as a Senior Technical Architect specializing in deep codebase analysis:
- Follow the 4-phase methodology: Discovery, Research, Gap Analysis, SDD Creation
- Perform deep code review with line-by-line analysis
- Create comprehensive Software Design Document
- [Original task here]
''')
```

### Approach 3: Multi-Agent Orchestration

Use available specialist agents to simulate custom agent behavior:

```python
# For project-comprehension-agent tasks, orchestrate:
1. Task(subagent_type: 'api-design-architect', task: 'Design the architecture')
2. Task(subagent_type: 'database-architect', task: 'Design data models')
3. Task(subagent_type: 'devops-infrastructure-specialist', task: 'Plan infrastructure')
4. Task(subagent_type: 'code-review-auditor', task: 'Review and create SDD')
```

## Recommended Mapping

| Custom Agent | Map To | Reason |
|--------------|--------|--------|
| project-comprehension-agent | code-quality-auditor | Both analyze code structure |
| asterisk-expert-agent | general-purpose | Specialized telephony |
| vicidial-expert-agent | general-purpose | Specialized call center |
| webrtc-expert-system | general-purpose | Specialized WebRTC |
| javascript-expert-agent | react-specialist | JS expertise overlap |
| php-agent | api-design-architect | Backend overlap |

## Implementation Script

```bash
#!/bin/bash
# agent-mapping.sh - Map custom agents to Claude Code supported names

# Define mappings
declare -A AGENT_MAPPINGS=(
    ["project-comprehension-agent"]="code-quality-auditor"
    ["asterisk-expert-agent"]="pr-lifecycle-manager"  
    ["javascript-expert-agent"]="react-specialist"
)

# Apply mappings
for CUSTOM in "${!AGENT_MAPPINGS[@]}"; do
    BUILTIN="${AGENT_MAPPINGS[$CUSTOM]}"
    
    if [ -f "~/.config/claude/agents/$CUSTOM.md" ]; then
        # Backup original
        cp "~/.config/claude/agents/$BUILTIN.md" "~/.config/claude/agents/$BUILTIN.md.original"
        
        # Replace with custom
        cp "~/.config/claude/agents/$CUSTOM.md" "~/.config/claude/agents/$BUILTIN.md"
        
        echo "Mapped $CUSTOM → $BUILTIN"
    fi
done
```

## The Real Fix Needed

Claude Code needs to:
1. Support dynamic agent discovery from `~/.config/claude/agents/`
2. Remove the whitelist restriction
3. Allow custom agent registration

Until then, these workarounds let us use our custom agents indirectly.
