# Setting Up Remote Claude Systems

This guide explains how to configure any remote Claude system to sync with the datascore/claude_code_agents repository.

## 🚀 Quick Setup (One Command)

Run this single command on any Linux/macOS system:

```bash
curl -sSL https://raw.githubusercontent.com/datascore/claude_code_agents/main/remote-setup.sh | bash
```

This will:
- Clone the repository to `~/agents`
- Set up the sync script
- Configure automatic hourly updates
- Add convenient aliases to your shell

## 📋 Manual Setup Options

### Option 1: Basic Clone
```bash
git clone https://github.com/datascore/claude_code_agents.git ~/agents
cd ~/agents
```

### Option 2: With Sync Script
```bash
# Clone repository
git clone https://github.com/datascore/claude_code_agents.git ~/agents

# Set up environment
export AGENT_REPO_URL='https://github.com/datascore/claude_code_agents.git'
export AGENTS_DIR="$HOME/agents"

# Run sync
cd ~/agents
./sync-agents.sh --sync
```

### Option 3: Direct File Access
If you just need a specific agent without cloning:
```bash
# Download a specific agent
curl -O https://raw.githubusercontent.com/datascore/claude_code_agents/main/react-agent.md
```

## 🔄 Keeping Remote Systems Updated

### Automatic Updates (Recommended)

**Linux (Cron):**
```bash
# Add to crontab
crontab -e
# Add this line:
0 * * * * cd ~/agents && git pull origin main
```

**macOS (LaunchAgent):**
```bash
cd ~/agents
./sync-agents.sh --auto
```

### Manual Updates
```bash
cd ~/agents
git pull origin main
# OR
./sync-agents.sh --sync
```

## 🐳 Docker Setup

For containerized environments:

```dockerfile
FROM ubuntu:latest

# Install git
RUN apt-get update && apt-get install -y git curl

# Clone agents repository
RUN git clone https://github.com/datascore/claude_code_agents.git /agents

# Set environment
ENV AGENTS_DIR=/agents
ENV AGENT_REPO_URL=https://github.com/datascore/claude_code_agents.git

# Add sync script to PATH
RUN chmod +x /agents/sync-agents.sh
RUN ln -s /agents/sync-agents.sh /usr/local/bin/sync-agents

# Update on container start
ENTRYPOINT ["/agents/sync-agents.sh", "--sync"]
```

## 🖥️ SSH Remote Setup

To set up on a remote server via SSH:

```bash
# Connect to remote server
ssh user@remote-server

# Run setup
curl -sSL https://raw.githubusercontent.com/datascore/claude_code_agents/main/remote-setup.sh | bash

# Or manually
git clone https://github.com/datascore/claude_code_agents.git ~/agents
echo "0 * * * * cd ~/agents && git pull" | crontab -
```

## 🔧 Environment Variables

Add to `.bashrc`, `.zshrc`, or `.profile`:

```bash
# Claude Agents Configuration
export AGENT_REPO_URL='https://github.com/datascore/claude_code_agents.git'
export AGENTS_DIR="$HOME/agents"
alias sync-agents='~/agents/sync-agents.sh --sync'
alias agents-status='~/agents/sync-agents.sh --status'
```

## 📱 Available Commands After Setup

- `sync-agents` - Pull latest updates
- `agents-status` - Check sync status
- `cd ~/agents` - Go to agents directory
- `ls ~/agents/*.md` - List all agents

## 🤖 Using Agents in Claude

### Copy to Clipboard (macOS)
```bash
cat ~/agents/react-agent.md | pbcopy
```

### Copy to Clipboard (Linux)
```bash
cat ~/agents/react-agent.md | xclip -selection clipboard
```

### View Agent Content
```bash
cat ~/agents/[agent-name].md
```

## 📊 Available Agents

After setup, you'll have access to:
- `api-design-agent` - API architecture and design
- `asterisk-expert-agent` - Asterisk PBX specialist
- `database-engineer-agent` - Database optimization
- `devops-agent` - DevOps automation
- `gcp-expert-agent` - Google Cloud Platform
- `go-agent` - Go language expert
- `javascript-expert-agent` - JavaScript/Node.js
- `php-agent` - PHP development
- `pr-manager-agent` - Pull request management
- `react-agent` - React/TypeScript specialist
- `vicidial-expert-agent` - VICIdial platform
- `webrtc-expert-system` - WebRTC architect

## 🔍 Verification

To verify the setup worked:

```bash
# Check if repository exists
ls -la ~/agents

# Check current version
cd ~/agents && git log -1 --oneline

# Test sync
~/agents/sync-agents.sh --status
```

## 🆘 Troubleshooting

### Permission Denied
```bash
chmod +x ~/agents/sync-agents.sh
```

### Git Not Installed
```bash
# Ubuntu/Debian
sudo apt-get install git

# RHEL/CentOS
sudo yum install git

# macOS
brew install git
```

### Can't Connect to GitHub
```bash
# Test connection
ping github.com

# Use HTTPS instead of SSH
git remote set-url origin https://github.com/datascore/claude_code_agents.git
```

## 📞 Support

Repository: https://github.com/datascore/claude_code_agents
Maintainer: datascore
