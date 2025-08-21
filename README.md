# Claude Code Agents Repository

A centralized repository for managing and synchronizing Claude/Anthropic agent prompts across multiple instances.

**Repository**: https://github.com/datascore/claude_code_agents

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

### Getting the Agents on a New Machine

#### Option 1: Clone with Git (Recommended)
```bash
# Using HTTPS
git clone https://github.com/datascore/claude_code_agents.git ~/agents

# OR using SSH (if you have SSH keys set up)
git clone git@github.com:datascore/claude_code_agents.git ~/agents

cd ~/agents
```

#### Option 2: Using Sync Script
```bash
# Download the sync script
curl -O https://raw.githubusercontent.com/datascore/claude_code_agents/main/sync-agents.sh
chmod +x sync-agents.sh

# Set environment variables
export AGENT_REPO_URL='https://github.com/datascore/claude_code_agents.git'
export AGENTS_DIR="$HOME/agents"

# Run initial sync
./sync-agents.sh --sync
```

### Keeping Your Local Copy Updated

```bash
# Manual update
cd ~/agents
git pull origin main

# OR use the sync script
./sync-agents.sh --sync

# Set up automatic hourly updates (macOS)
./sync-agents.sh --auto
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
├── .github/                    # GitHub configuration
│   ├── workflows/              # GitHub Actions workflows
│   │   ├── pr-validation.yml   # PR validation and checks
│   │   ├── automated-review.yml # Automated code review
│   │   ├── pr-metrics.yml      # PR metrics tracking
│   │   └── deploy-notify.yml   # Deployment notifications
│   ├── ISSUE_TEMPLATE/         # Issue templates
│   │   ├── bug_report.md       # Bug report template
│   │   └── feature_request.md  # Feature request template
│   ├── pull_request_template.md # PR template
│   └── CODEOWNERS              # Code ownership rules
├── .git/                       # Git repository
├── .backups/                   # Local backups (git-ignored)
├── .sync.log                   # Sync history (git-ignored)
└── *.md                        # Agent prompt files
```

## 🔐 Security & Access Control

### Repository Access Model

**This is a PUBLIC repository with restricted write access:**
- ✅ **Everyone can**: View, clone, fork, and use the agents
- ❌ **Only datascore can**: Push changes, merge PRs, modify branches
- 📝 **Others can**: Submit pull requests for review

### Branch Protection

The `main` branch is protected:
- Only `datascore` can push directly
- Force pushes are disabled
- Branch deletion is protected
- All changes from others must go through pull requests

### For Contributors

If you want to suggest improvements:
1. Fork the repository
2. Make changes in your fork
3. Submit a pull request
4. Wait for review and approval

### Security Considerations

1. **Public Repository**: This repository is intentionally public for sharing
2. **Access Tokens**: Contributors should use personal access tokens
3. **Environment Variables**: Don't commit sensitive data
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

### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

3. **Push to GitHub**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request**:
   - Go to https://github.com/datascore/claude_code_agents
   - Click "New pull request"
   - Select your branch
   - Fill out the PR template
   - Submit for review

### PR Guidelines

- Link related issues in PR description
- Keep PRs focused and under 500 lines
- Ensure all checklist items are addressed
- Wait for automated checks to pass
- Address review feedback promptly

### GitHub Actions & Automation

This repository includes automated workflows:

- **PR Validation**: Automatically checks PR size, linked issues, and template compliance
- **Automated Review**: Runs Black formatting checks and spell checking
- **PR Metrics**: Tracks metrics and generates weekly reports
- **Auto-labeling**: PRs are automatically labeled based on content

### Code Standards

1. Python code must be formatted with Black
2. Keep prompts well-structured and documented
3. Follow the existing format for new agents
4. Test thoroughly before pushing
5. Update this README when adding new features

## 📄 License

[Your license here]

---

**Repository**: https://github.com/datascore/claude_code_agents  
**Maintainer**: datascore  
**Last Updated**: 2025-01-21
