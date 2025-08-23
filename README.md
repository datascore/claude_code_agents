# Claude Code Agents

Specialized AI agents for Claude Code that provide expert assistance across various technical domains.

⚠️ **IMPORTANT**: See `AGENTS_MANIFEST.md` for the definitive list of which files are agents vs documentation.

## Quick Setup

```bash
# Clone the repository
git clone https://github.com/datascore/claude_code_agents.git ~/agents
cd ~/agents

# Sync agents to Claude Code
./sync.sh
```

That's it! The agents are now available globally in `~/.claude/agents/` (user-level)

## Available Agents (16 agents)

| Agent File | Expertise |
|------------|------------|
| api-design-agent.md | REST, GraphQL, API design |
| asterisk-expert-agent.md | Asterisk telephony, VoIP |
| database-engineer-agent.md | Database design, SQL/NoSQL |
| devops-agent.md | CI/CD, Docker, Kubernetes |
| gcp-expert-agent.md | Google Cloud Platform |
| go-agent.md | Go programming language |
| javascript-expert-agent.md | JavaScript, Node.js |
| php-agent.md | PHP development |
| pr-manager-agent.md | Pull requests, code review |
| project-comprehension-agent.md | Codebase analysis |
| qa-test-orchestrator.md | Test automation, QA |
| qa-testing-agent.md | Code quality, testing |
| react-agent.md | React, frontend |
| typescript-specialist.md | TypeScript, type systems |
| vicidial-expert-agent.md | ViciDial call center |
| webrtc-expert-system.md | WebRTC, real-time comm |

## Agent Installation

Agents are installed to the **user-level directory only**:
- Location: `~/.claude/agents/`
- Scope: Available across ALL your projects
- Not installed to project-level `.claude/agents/` directories

## Agent Format

All agents follow the Claude Code subagent format:
- YAML frontmatter with `name`, `description`, and `tools`
- Immediately followed by "You are..." role description
- Detailed expertise and patterns in the body

## Using Agents in Claude Code

```python
# In Claude Code, use the Task tool with the agent name:
Task(subagent_type: 'go-agent', task: 'Review this Go code')
Task(subagent_type: 'database-engineer-agent', task: 'Optimize this query')
Task(subagent_type: 'react-agent', task: 'Create a React component')
Task(subagent_type: 'typescript-specialist', task: 'Add TypeScript to my project')
```

## Updating Agents

```bash
cd ~/agents
git pull
./sync.sh
```

## Troubleshooting

If the sync script hangs, you can manually copy agents:

```bash
# Manual copy example (for one agent)
# Note: ~/.claude/agents/ should already exist from Claude Code installation
cp go-agent.md ~/.claude/agents/go-agent.md
```

Then manually add YAML frontmatter to the top of each file:
```yaml
---
name: go-agent
description: Go programming specialist
tools: Read, Write, Edit, Bash, Grep, Find, SearchCodebase, CreateFile, RunCommand, Task
---
You are [agent role description here]...
```

## Repository

https://github.com/datascore/claude_code_agents

## License

MIT
