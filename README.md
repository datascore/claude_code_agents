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

That's it! The agents are now available in `~/.claude/agents/`

## Available Agents (15 agents)

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
| vicidial-expert-agent.md | ViciDial call center |
| webrtc-expert-system.md | WebRTC, real-time comm |

## Using Agents in Claude Code

```python
# In Claude Code, use the Task tool with the agent name:
Task(subagent_type: 'go-agent', task: 'Review this Go code')
Task(subagent_type: 'database-engineer-agent', task: 'Optimize this query')
Task(subagent_type: 'react-agent', task: 'Create a React component')
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
mkdir -p ~/.claude/agents
cp go-agent.md ~/.claude/agents/go-agent.md
```

Then manually add YAML frontmatter to the top of each file:
```yaml
---
name: "go-agent"
description: "Go programming specialist"
version: "1.0"
tools: ["*"]
---
```

## Repository

https://github.com/datascore/claude_code_agents

## License

MIT
