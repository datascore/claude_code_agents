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

## Available Agents (15 unique agents, 16 files after sync)

| Agent File | Claude Code Name | Expertise |
|------------|-----------------|-----------|
| api-design-agent | api-design-architect | REST, GraphQL, API design |
| asterisk-expert-agent | asterisk-specialist | Asterisk telephony, VoIP |
| database-engineer-agent | database-architect | Database design, SQL/NoSQL |
| devops-agent | devops-infrastructure-specialist | CI/CD, Docker, Kubernetes |
| gcp-expert-agent | gcp-cloud-architect | Google Cloud Platform |
| go-agent | go-specialist | Go programming language |
| javascript-expert-agent | javascript-specialist | JavaScript, Node.js |
| php-agent | php-specialist | PHP development |
| pr-manager-agent | pr-lifecycle-manager | Pull requests, code review |
| project-comprehension-agent | project-comprehension-specialist | Codebase analysis |
| qa-test-orchestrator | qa-test-orchestrator | Test automation, QA |
| qa-testing-agent | code-quality-auditor | Code quality, testing |
| qa-testing-agent | code-review-auditor | Code review (alias) |
| react-agent | react-specialist | React, frontend |
| vicidial-expert-agent | vicidial-specialist | ViciDial call center |
| webrtc-expert-system | webrtc-expert-system | WebRTC, real-time comm |

## Using Agents in Claude Code

```python
# In Claude Code, use the Task tool with the agent name:
Task(subagent_type: 'go-specialist', task: 'Review this Go code')
Task(subagent_type: 'database-architect', task: 'Optimize this query')
Task(subagent_type: 'react-specialist', task: 'Create a React component')
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
cp go-agent.md ~/.claude/agents/go-specialist.md
```

Then manually add YAML frontmatter to the top of each file:
```yaml
---
name: "go-specialist"
description: "Go programming specialist"
version: "1.0"
tools: ["*"]
---
```

## Repository

https://github.com/datascore/claude_code_agents

## License

MIT
