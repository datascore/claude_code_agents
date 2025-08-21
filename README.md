# Claude Agent Prompts Repository

A centralized repository for managing and synchronizing Claude/Anthropic agent prompts across multiple instances.

## 📦 Repository Contents

This repository contains specialized agent prompts for various domains:

### Development Agents
- **react-agent** - React/TypeScript specialist
- **go-agent** - Go language expert
- **php-agent** - PHP development specialist
- **javascript-expert-agent** - JavaScript/Node.js expert
- **api-design-agent** - API architecture and design

### Infrastructure & Operations
- **devops-agent** - DevOps and infrastructure automation
- **database-engineer-agent** - Database architecture and optimization
- **gcp-expert-agent** - Google Cloud Platform specialist

### Communication Systems
- **asterisk-expert-agent** - Asterisk PBX/telephony specialist
- **vicidial-expert-agent** - VICIdial call center platform expert
- **webrtc-expert-system** - WebRTC real-time communications architect

### Management
- **pr-manager-agent** - Pull request and code review management

## 🚀 Quick Start

### Initial Setup

1. **Create a GitHub repository** for your agents:
   - Go to https://github.com/new
   - Name it something like `claude-agent-prompts`
   - Make it private if these prompts are proprietary
   - Don't initialize with README (we already have one)

2. **Set up your local repository**:
```bash
cd /Users/datascore/agents

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit of Claude agent prompts"

# Push to GitHub
git branch -M main
git push -u origin main
```

3. **Set environment variable** for easy syncing:
```bash
# Add to your ~/.zshrc or ~/.bashrc
export AGENT_REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
export AGENTS_DIR="$HOME/agents"
```

## 🔄 Synchronization Methods

### Method 1: Bash Script (Recommended for automation)

The `sync-agents.sh` script provides robust synchronization with backup capabilities.

**Basic usage:**
```bash
# Sync with remote repository
./sync-agents.sh --sync

# Check status
./sync-agents.sh --status

# Create backup
./sync-agents.sh --backup

# Set up automatic hourly sync (macOS)
./sync-agents.sh --auto
```

**Features:**
- Automatic backup before sync
- Stashes local changes
- Colored output for better readability
- Automatic sync via launchd (macOS)
- Keeps last 5 backups

### Method 2: Python Module (Recommended for programmatic access)

The `sync_agents.py` module provides a Python API for managing agents.

**Command-line usage:**
```bash
# Sync repository
python3 sync_agents.py --sync

# Force sync (overrides local changes)
python3 sync_agents.py --sync --force

# Check status
python3 sync_agents.py --status

# List all agents
python3 sync_agents.py --list

# Get specific agent content
python3 sync_agents.py --get react-agent
```

**Python API usage:**
```python
from sync_agents import AgentSync

# Initialize
sync = AgentSync()

# Check for updates
if sync.check_for_updates():
    # Sync with remote
    success, changed_files = sync.sync()
    print(f"Updated {len(changed_files)} files")

# List available agents
agents = sync.list_agents()
for agent in agents:
    print(f"{agent['name']}: {agent['role']}")

# Get specific agent content
react_prompt = sync.get_agent('react-agent')
```

### Method 3: Git Commands (Manual)

For manual control:
```bash
# Pull latest changes
cd ~/agents
git pull origin main

# Check status
git status

# Push local changes
git add .
git commit -m "Update agent prompts"
git push origin main
```

## 🤖 Integration with Claude Instances

### For Claude Desktop/Web

1. **Manual sync before starting**:
```bash
~/agents/sync-agents.sh --sync
```

2. **Copy agent content**:
```bash
# View agent content
cat ~/agents/react-agent.md | pbcopy  # Copies to clipboard on macOS
```

### For Automated Systems

1. **Environment setup**:
```python
import os
import sys
sys.path.append(os.path.expanduser('~/agents'))
from sync_agents import AgentSync

# Auto-sync on startup
sync = AgentSync()
sync.sync()

# Load specific agent
agent_content = sync.get_agent('api-design-agent')
```

2. **Scheduled sync** (crontab):
```bash
# Add to crontab (crontab -e)
0 * * * * /Users/datascore/agents/sync-agents.sh --sync
```

## 📁 Directory Structure

```
agents/
├── README.md                    # This file
├── sync-agents.sh              # Bash sync script
├── sync_agents.py              # Python sync module
├── .gitignore                  # Git ignore rules
├── .git/                       # Git repository
├── .backups/                   # Local backups (git-ignored)
├── .sync.log                   # Sync history (git-ignored)
└── *.md                        # Agent prompt files
```

## 🔐 Security Considerations

1. **Private Repository**: Keep your repository private if prompts contain proprietary information
2. **Access Tokens**: Use personal access tokens instead of passwords for GitHub
3. **Environment Variables**: Don't commit sensitive data; use environment variables
4. **Backup Strategy**: Local backups are kept in `.backups/` (git-ignored)

## 🛠️ Troubleshooting

### Common Issues

**1. Permission denied when pushing:**
```bash
# Set up SSH key or use personal access token
git remote set-url origin https://YOUR_TOKEN@github.com/USERNAME/REPO.git
```

**2. Merge conflicts:**
```bash
# The sync script automatically stashes local changes
# To manually resolve:
git stash
git pull origin main
git stash pop
# Resolve any conflicts, then commit
```

**3. Auto-sync not working (macOS):**
```bash
# Check launchd status
launchctl list | grep claude.agents

# Reload the service
launchctl unload ~/Library/LaunchAgents/com.claude.agents.sync.plist
launchctl load ~/Library/LaunchAgents/com.claude.agents.sync.plist
```

## 📝 Best Practices

1. **Version Control**: Commit changes with descriptive messages
2. **Testing**: Test agent prompts locally before pushing
3. **Documentation**: Keep agent descriptions updated
4. **Backup**: Regular backups are automatic, but manual backups before major changes are recommended
5. **Review**: Review changes before syncing to production instances

## 🔄 Workflow Example

### Daily Workflow
```bash
# Morning: Pull latest updates
cd ~/agents
./sync-agents.sh --sync

# Work with agents...
# Make changes to prompts...

# Evening: Push your changes
git add .
git commit -m "Improve React agent error handling patterns"
git push origin main
```

### Team Workflow
1. Create feature branches for major prompt updates
2. Use pull requests for review
3. Test prompts in development before merging to main
4. Auto-sync production instances from main branch

## 📚 Additional Resources

- [Claude Documentation](https://docs.anthropic.com)
- [Git Documentation](https://git-scm.com/doc)
- [GitHub CLI](https://cli.github.com/) - For advanced automation

## 🤝 Contributing

1. Keep prompts well-structured and documented
2. Follow the existing format for new agents
3. Test thoroughly before pushing
4. Update this README when adding new features

## 📄 License

[Your license here]

---

**Last Updated**: Auto-generated on sync
**Maintainer**: [Your name/team]
**Contact**: [Your contact info]
