# Claude Code AI Agents Collection

## Overview
A comprehensive collection of specialized AI agents for Claude Code's Task tool subagent system. These agents provide expert assistance across various domains including development, infrastructure, databases, and specialized technologies.

**Repository**: https://github.com/datascore/claude_code_agents

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/datascore/claude_code_agents.git
cd claude_code_agents

# Sync agents to Claude Code
./sync-agents.sh
```

## 📋 Available Agents

After syncing, these specialized agents are available in Claude Code:

### Core Development
- **`go-specialist`** - Go language expertise, microservices, backend systems
- **`react-specialist`** - React, TypeScript, frontend development
- **`javascript-expert-agent`** - JavaScript/Node.js expert
- **`php-agent`** - PHP development specialist

### Infrastructure & DevOps
- **`devops-infrastructure-specialist`** - CI/CD, Docker, Kubernetes, automation
- **`database-architect`** - Database design, optimization, migrations
- **`gcp-cloud-architect`** - Google Cloud Platform services and architecture

### API & Architecture
- **`api-design-architect`** - REST, GraphQL, API design patterns
- **`project-comprehension-agent`** - Technical architecture and SDD creation

### Quality & Testing
- **`qa-test-orchestrator`** - Test planning, automation, quality assurance
- **`code-quality-auditor`** - Code quality, testing, maintainability
- **`code-review-auditor`** - Code review, best practices, security audit

### Workflow Management
- **`pr-lifecycle-manager`** - Pull request and Git workflow management

### Specialized Technologies
- **`asterisk-expert-agent`** - Asterisk PBX and telephony systems
- **`vicidial-expert-agent`** - ViciDial call center platform
- **`webrtc-expert-system`** - WebRTC real-time communications

## 💻 Usage in Claude Code

### Using with Task Tool
```python
# Use specialized agents as subagents
Task(subagent_type: 'go-specialist', task: 'Review this Go code and suggest improvements')
Task(subagent_type: 'database-architect', task: 'Design a scalable database schema for user management')
Task(subagent_type: 'devops-infrastructure-specialist', task: 'Create a CI/CD pipeline with GitHub Actions')
```

### Examples by Domain

#### Backend Development
```python
Task(subagent_type: 'go-specialist', task: 'Implement a REST API with proper error handling')
Task(subagent_type: 'api-design-architect', task: 'Design RESTful endpoints for a blog platform')
```

#### Frontend Development
```python
Task(subagent_type: 'react-specialist', task: 'Create a responsive dashboard component')
Task(subagent_type: 'javascript-expert-agent', task: 'Optimize this JavaScript code for performance')
```

#### Infrastructure
```python
Task(subagent_type: 'devops-infrastructure-specialist', task: 'Set up Docker containers for microservices')
Task(subagent_type: 'gcp-cloud-architect', task: 'Design a scalable GCP architecture')
```

#### Database
```python
Task(subagent_type: 'database-architect', task: 'Optimize this PostgreSQL query')
Task(subagent_type: 'database-architect', task: 'Design a migration strategy from MySQL to PostgreSQL')
```

#### Quality Assurance
```python
Task(subagent_type: 'qa-test-orchestrator', task: 'Create an E2E testing strategy')
Task(subagent_type: 'code-review-auditor', task: 'Review this code for security vulnerabilities')
```

## 🔄 Keeping Agents Updated

### Manual Update
```bash
cd claude_code_agents
git pull origin main
./sync-agents.sh
```

### Automatic Updates (Optional)
```bash
# Install background sync service (macOS)
./agent-service-control.sh install

# Check service status
./agent-service-control.sh status

# View sync logs
./agent-service-control.sh logs
```

## 📁 Agent Location

Agents are synced to: `~/.config/claude/agents/`

The sync script automatically:
- Maps agent names to Claude Code expected format
- Copies agents to the correct location
- Ensures compatibility with Task tool

## 🛠️ Troubleshooting

### Agents Not Available in Task Tool
1. Run `./sync-agents.sh` to ensure agents are synced
2. Verify agents exist in `~/.config/claude/agents/`
3. Check that agent names match Claude Code format (e.g., `go-specialist`, not `go-agent`)

### Sync Issues
```bash
# Check current status
ls ~/.config/claude/agents/

# Force resync
rm -rf ~/.config/claude/agents/*
./sync-agents.sh
```

## 🤝 Contributing

This is a public repository with restricted write access:
- View and fork: Anyone
- Direct push: Only @datascore
- Contributions: Submit pull requests for review

## 📄 License

MIT License - See LICENSE file for details

## 🔗 Links

- **Repository**: https://github.com/datascore/claude_code_agents
- **Issues**: https://github.com/datascore/claude_code_agents/issues
- **Pull Requests**: https://github.com/datascore/claude_code_agents/pulls
