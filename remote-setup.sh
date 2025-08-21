#!/bin/bash

# Claude Agents Remote Setup Script
# This script sets up any remote system to sync with the agents repository
# Usage: curl -sSL https://raw.githubusercontent.com/datascore/claude_code_agents/main/remote-setup.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/datascore/claude_code_agents.git"
AGENTS_DIR="${AGENTS_DIR:-$HOME/agents}"
SYNC_SCRIPT_URL="https://raw.githubusercontent.com/datascore/claude_code_agents/main/sync-agents.sh"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Claude Code Agents - Remote Setup Script           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo -e "${GREEN}Detected OS: ${OS}${NC}"

# Check for required tools
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}Git is not installed!${NC}"
    echo "Please install git first:"
    case $OS in
        linux)
            echo "  Ubuntu/Debian: sudo apt-get install git"
            echo "  RHEL/CentOS: sudo yum install git"
            ;;
        macos)
            echo "  macOS: brew install git"
            ;;
        *)
            echo "  Please install git for your system"
            ;;
    esac
    exit 1
fi

echo -e "${GREEN}✓ Git is installed${NC}"

# Check if agents directory exists
if [ -d "$AGENTS_DIR/.git" ]; then
    echo -e "${YELLOW}Agents directory already exists at $AGENTS_DIR${NC}"
    echo -e "${YELLOW}Updating existing installation...${NC}"
    cd "$AGENTS_DIR"
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null
    echo -e "${GREEN}✓ Updated to latest version${NC}"
else
    echo -e "${YELLOW}Setting up new installation...${NC}"
    
    # Clone the repository
    echo -e "${BLUE}Cloning agents repository...${NC}"
    git clone "$REPO_URL" "$AGENTS_DIR"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Repository cloned successfully${NC}"
    else
        echo -e "${RED}Failed to clone repository${NC}"
        exit 1
    fi
fi

# Download sync script
echo -e "${BLUE}Setting up sync script...${NC}"
cd "$AGENTS_DIR"
if [ ! -f "sync-agents.sh" ]; then
    curl -sSL "$SYNC_SCRIPT_URL" -o sync-agents.sh
fi
chmod +x sync-agents.sh

# Set up environment variables
echo -e "${BLUE}Configuring environment...${NC}"

# Add to appropriate shell config
SHELL_CONFIG=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.profile" ]; then
    SHELL_CONFIG="$HOME/.profile"
fi

if [ -n "$SHELL_CONFIG" ]; then
    # Check if already configured
    if ! grep -q "AGENT_REPO_URL" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Claude Agents Configuration" >> "$SHELL_CONFIG"
        echo "export AGENT_REPO_URL='$REPO_URL'" >> "$SHELL_CONFIG"
        echo "export AGENTS_DIR='$AGENTS_DIR'" >> "$SHELL_CONFIG"
        echo "alias sync-agents='$AGENTS_DIR/sync-agents.sh --sync'" >> "$SHELL_CONFIG"
        echo "alias agents-status='$AGENTS_DIR/sync-agents.sh --status'" >> "$SHELL_CONFIG"
        echo -e "${GREEN}✓ Environment variables added to $SHELL_CONFIG${NC}"
    else
        echo -e "${YELLOW}Environment already configured${NC}"
    fi
fi

# Set up automatic sync based on OS
echo -e "${BLUE}Setting up automatic sync...${NC}"

case $OS in
    linux)
        # Set up cron job for Linux
        if command -v crontab &> /dev/null; then
            # Check if cron job already exists
            if ! crontab -l 2>/dev/null | grep -q "sync-agents.sh"; then
                (crontab -l 2>/dev/null; echo "0 * * * * $AGENTS_DIR/sync-agents.sh --sync >> $AGENTS_DIR/.sync.log 2>&1") | crontab -
                echo -e "${GREEN}✓ Hourly sync configured via cron${NC}"
            else
                echo -e "${YELLOW}Cron job already exists${NC}"
            fi
        else
            echo -e "${YELLOW}Cron not available. Manual sync required.${NC}"
        fi
        ;;
    macos)
        # Use launchd for macOS
        $AGENTS_DIR/sync-agents.sh --auto
        echo -e "${GREEN}✓ Automatic sync configured via launchd${NC}"
        ;;
    *)
        echo -e "${YELLOW}Automatic sync not configured. Please sync manually.${NC}"
        ;;
esac

# Display summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  Setup Complete! ✓                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Repository location:${NC} $AGENTS_DIR"
echo -e "${BLUE}Available agents:${NC}"

# List available agents
for agent in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent" ] && [ "$(basename "$agent")" != "README.md" ]; then
        agent_name=$(basename "$agent" .md)
        echo -e "  ${GREEN}•${NC} $agent_name"
    fi
done

echo ""
echo -e "${YELLOW}Quick Commands:${NC}"
echo -e "  ${GREEN}sync-agents${NC}     - Sync with latest updates"
echo -e "  ${GREEN}agents-status${NC}   - Check sync status"
echo -e "  ${GREEN}cd $AGENTS_DIR${NC}  - Go to agents directory"
echo ""
echo -e "${BLUE}To use an agent:${NC}"
echo -e "  cat $AGENTS_DIR/[agent-name].md"
echo ""
echo -e "${YELLOW}Note:${NC} Restart your shell or run: source $SHELL_CONFIG"
echo ""

# Export for current session
export AGENT_REPO_URL="$REPO_URL"
export AGENTS_DIR="$AGENTS_DIR"

# Final sync
echo -e "${BLUE}Running initial sync...${NC}"
$AGENTS_DIR/sync-agents.sh --sync

echo -e "${GREEN}Ready to use Claude Agents!${NC}"
