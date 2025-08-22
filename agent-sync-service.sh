#!/bin/bash
# Background Agent Sync Service
# Automatically syncs agents from GitHub and updates Claude Code

set -e

# Configuration
AGENTS_REPO_DIR="$HOME/agents"
CLAUDE_AGENTS_DIR="$HOME/.config/claude/agents"  # Claude Code directory
LOG_FILE="$HOME/.claude/agent-sync.log"
SYNC_INTERVAL=300  # 5 minutes

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to sync agents
sync_agents() {
    log_message "Starting agent sync..."
    
    # Pull latest from GitHub
    cd "$AGENTS_REPO_DIR"
    if git pull origin main >> "$LOG_FILE" 2>&1; then
        log_message "Successfully pulled latest changes from GitHub"
        
        # Run the fixed Claude Code sync
        if [ -f "./claude-code-sync-fixed.sh" ]; then
            ./claude-code-sync-fixed.sh >> "$LOG_FILE" 2>&1
            log_message "Successfully synced agents to Claude Code with correct YAML format"
        elif [ -f "./sync-agents.sh" ]; then
            # Fallback to legacy script
            ./sync-agents.sh >> "$LOG_FILE" 2>&1
            log_message "Synced agents (legacy script)"
        else
            log_message "ERROR: No sync script found!"
        fi
    else
        log_message "No changes from GitHub or error pulling"
    fi
}

# Function to check agent health
check_agent_health() {
    local agent_count=$(ls -1 "$CLAUDE_AGENTS_DIR"/*.md 2>/dev/null | wc -l)
    log_message "Agent health check: $agent_count agents available"
    
    if [ "$agent_count" -lt 10 ]; then
        log_message "WARNING: Expected at least 10 agents, found $agent_count"
        # Trigger immediate sync
        sync_agents
    fi
}

# Main loop
log_message "Agent Sync Service started (PID: $$)"
log_message "Monitoring: $AGENTS_REPO_DIR"
log_message "Syncing to: $CLAUDE_AGENTS_DIR"
log_message "Sync interval: ${SYNC_INTERVAL}s"

# Initial sync
sync_agents

# Continuous monitoring loop
while true; do
    sleep "$SYNC_INTERVAL"
    
    # Check if agents need updating
    check_agent_health
    
    # Regular sync
    sync_agents
done
