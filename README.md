# Claude Code AI Agents Collection

## Overview
A comprehensive collection of specialized AI agents for Claude Code's Task tool subagent system. These agents provide expert assistance across various domains including development, infrastructure, databases, and specialized technologies.

**Repository**: https://github.com/datascore/claude_code_agents

## 🚀 Quick Start for Claude Code Servers

### Complete Setup (Copy & Run)
```bash
# 1. Clone the repository
git clone https://github.com/datascore/claude_code_agents.git ~/agents
cd ~/agents

# 2. Run the enhanced sync script (with proper YAML formatting)
./claude-code-sync-fixed.sh

# 3. Install git hooks for automatic syncing
./setup-git-hooks.sh

# 4. (Optional) Install background sync service for auto-updates
./agent-service-control.sh install
```

**That's it!** Agents are now available in `~/.claude/agents/` with proper YAML frontmatter.

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

### Three Ways to Stay Synchronized

#### 1. Automatic via Git Hooks (Recommended)
Once installed, agents auto-sync when you:
- Run `git pull` (post-merge hook)
- Commit agent changes (post-commit hook)

#### 2. Background Service (Set and Forget)
```bash
# Install background sync service
./agent-service-control.sh install

# Service automatically:
# - Pulls from GitHub every 5 minutes
# - Syncs agents with proper YAML format
# - Logs activity to ~/.claude/agent-sync.log
```

#### 3. Manual Update
```bash
cd ~/agents
git pull origin main
# Git hooks auto-sync, or manually run:
./claude-code-sync-fixed.sh
```

## 📁 Technical Details

### Agent Location & Format
Agents are synced to: `~/.claude/agents/` (Personal agents directory)

Each agent includes required YAML frontmatter:
```yaml
---
name: "agent-name"
description: "Agent description"
version: "1.0"
tools: ["*"]  # All agents have access to all tools
---
```

### What the Sync Script Does
- ✅ Auto-discovers all agent files
- ✅ Maps names to Claude Code format (e.g., `go-agent` → `go-specialist`)
- ✅ Adds proper YAML frontmatter
- ✅ Validates format compliance
- ✅ Generates agent-registry.json for tracking

## 🛠️ Troubleshooting

### Verify Installation
```bash
# Check agents are synced
ls -la ~/.claude/agents/

# Verify YAML frontmatter
head -6 ~/.claude/agents/go-specialist.md

# Check git hooks
ls -la .git/hooks/post-*

# Service status (if installed)
./agent-service-control.sh status
```

### Common Issues

#### Agents Not Available in Task Tool
```bash
# Run the enhanced sync script
./claude-code-sync-fixed.sh
```

#### Git Hooks Not Working
```bash
# Reinstall hooks
./setup-git-hooks.sh
```

#### Force Complete Resync
```bash
rm -rf ~/.claude/agents/*
./claude-code-sync-fixed.sh
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
