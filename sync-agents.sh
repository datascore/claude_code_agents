#!/bin/bash

# Claude Agent Prompts Sync Script
# This script automatically pulls the latest agent prompts from GitHub

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="${AGENT_REPO_URL:-}"  # Set via environment variable or update here
AGENTS_DIR="${AGENTS_DIR:-$HOME/agents}"
LOG_FILE="${AGENTS_DIR}/.sync.log"
BACKUP_DIR="${AGENTS_DIR}/.backups"

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to create backup
create_backup() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    print_message "$YELLOW" "Creating backup: $backup_name"
    
    # Copy all .md files to backup
    cp -r "$AGENTS_DIR"/*.md "$BACKUP_DIR/$backup_name/" 2>/dev/null || true
    
    # Keep only last 5 backups
    ls -dt "$BACKUP_DIR"/*/ | tail -n +6 | xargs rm -rf 2>/dev/null || true
}

# Function to check for updates
check_for_updates() {
    cd "$AGENTS_DIR" || exit 1
    
    # Fetch latest changes without merging
    git fetch origin main --quiet 2>/dev/null || git fetch origin master --quiet 2>/dev/null
    
    # Check if we're behind
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
    
    if [ "$LOCAL" = "$REMOTE" ]; then
        return 1  # No updates
    else
        return 0  # Updates available
    fi
}

# Function to sync repository
sync_repository() {
    print_message "$GREEN" "=== Claude Agent Prompts Sync ==="
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting sync" >> "$LOG_FILE"
    
    # Check if agents directory exists
    if [ ! -d "$AGENTS_DIR" ]; then
        print_message "$YELLOW" "Agents directory not found. Creating and cloning..."
        mkdir -p "$AGENTS_DIR"
        
        if [ -z "$REPO_URL" ]; then
            print_message "$RED" "ERROR: AGENT_REPO_URL environment variable not set"
            print_message "$YELLOW" "Please set: export AGENT_REPO_URL='https://github.com/yourusername/your-agents-repo.git'"
            exit 1
        fi
        
        git clone "$REPO_URL" "$AGENTS_DIR"
        print_message "$GREEN" "✓ Repository cloned successfully"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Repository cloned" >> "$LOG_FILE"
        return 0
    fi
    
    cd "$AGENTS_DIR" || exit 1
    
    # Check if it's a git repository
    if [ ! -d ".git" ]; then
        print_message "$RED" "ERROR: $AGENTS_DIR is not a git repository"
        exit 1
    fi
    
    # Check for local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        print_message "$YELLOW" "Local changes detected. Creating backup..."
        create_backup
        
        # Stash local changes
        git stash push -m "Auto-stash before sync $(date +%Y%m%d_%H%M%S)"
        print_message "$YELLOW" "Local changes stashed"
    fi
    
    # Check for updates
    if check_for_updates; then
        print_message "$YELLOW" "Updates available. Pulling latest changes..."
        
        # Pull latest changes
        if git pull origin main --quiet 2>/dev/null || git pull origin master --quiet 2>/dev/null; then
            print_message "$GREEN" "✓ Successfully updated to latest version"
            
            # Show what changed
            echo ""
            print_message "$GREEN" "Changed files:"
            git diff --name-status HEAD@{1} HEAD
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Updated successfully" >> "$LOG_FILE"
        else
            print_message "$RED" "ERROR: Failed to pull updates"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Pull failed" >> "$LOG_FILE"
            exit 1
        fi
    else
        print_message "$GREEN" "✓ Already up to date"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Already up to date" >> "$LOG_FILE"
    fi
}

# Function to show status
show_status() {
    cd "$AGENTS_DIR" || exit 1
    
    print_message "$GREEN" "=== Repository Status ==="
    echo "Directory: $AGENTS_DIR"
    echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'Not configured')"
    echo "Branch: $(git branch --show-current)"
    echo "Last commit: $(git log -1 --format='%h - %s (%cr)' 2>/dev/null || echo 'No commits')"
    echo ""
    
    # Check for local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        print_message "$YELLOW" "Local modifications detected:"
        git status --short
    fi
    
    # Show last sync from log
    if [ -f "$LOG_FILE" ]; then
        echo ""
        print_message "$GREEN" "Last sync: $(tail -1 "$LOG_FILE" | cut -d' ' -f1-3)"
    fi
}

# Function to setup automatic sync
setup_auto_sync() {
    print_message "$GREEN" "=== Setting Up Automatic Sync ==="
    
    # Create launchd plist for macOS
    local plist_path="$HOME/Library/LaunchAgents/com.claude.agents.sync.plist"
    
    cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.agents.sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>$AGENTS_DIR/sync-agents.sh</string>
        <string>--sync</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer> <!-- Run every hour -->
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$AGENTS_DIR/.sync.stdout</string>
    <key>StandardErrorPath</key>
    <string>$AGENTS_DIR/.sync.stderr</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>AGENT_REPO_URL</key>
        <string>$REPO_URL</string>
        <key>AGENTS_DIR</key>
        <string>$AGENTS_DIR</string>
    </dict>
</dict>
</plist>
EOF
    
    # Load the launch agent
    launchctl unload "$plist_path" 2>/dev/null || true
    launchctl load "$plist_path"
    
    print_message "$GREEN" "✓ Automatic sync configured (runs every hour)"
    print_message "$YELLOW" "To disable: launchctl unload $plist_path"
}

# Main script logic
case "${1:-}" in
    --sync|-s)
        sync_repository
        ;;
    --status)
        show_status
        ;;
    --auto)
        setup_auto_sync
        ;;
    --backup)
        create_backup
        print_message "$GREEN" "✓ Backup created"
        ;;
    --help|-h)
        echo "Claude Agent Prompts Sync Script"
        echo ""
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  --sync, -s    Sync with remote repository (default)"
        echo "  --status      Show repository status"
        echo "  --auto        Setup automatic sync (macOS)"
        echo "  --backup      Create manual backup"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "Environment variables:"
        echo "  AGENT_REPO_URL  - GitHub repository URL"
        echo "  AGENTS_DIR      - Local agents directory (default: ~/agents)"
        ;;
    *)
        sync_repository
        ;;
esac
