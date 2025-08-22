#!/bin/bash
# Agent Service Control Script
# Manage the background agent sync service

SERVICE_NAME="com.datascore.agent-sync"
PLIST_FILE="$HOME/Library/LaunchAgents/${SERVICE_NAME}.plist"
SOURCE_PLIST="$(pwd)/com.datascore.agent-sync.plist"
SERVICE_SCRIPT="$(pwd)/agent-sync-service.sh"
LOG_FILE="$HOME/.claude/agent-sync.log"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    case $1 in
        success) echo -e "${GREEN}✓${NC} $2" ;;
        error) echo -e "${RED}✗${NC} $2" ;;
        info) echo -e "${YELLOW}ℹ${NC} $2" ;;
    esac
}

# Function to install the service
install_service() {
    echo "🔧 Installing Agent Sync Service..."
    
    # Make scripts executable
    chmod +x "$SERVICE_SCRIPT"
    chmod +x "$(pwd)/sync-to-claude-desktop.sh"
    
    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$HOME/Library/LaunchAgents"
    
    # Copy plist file to LaunchAgents
    cp "$SOURCE_PLIST" "$PLIST_FILE"
    
    # Load the service
    launchctl load "$PLIST_FILE" 2>/dev/null
    
    if launchctl list | grep -q "$SERVICE_NAME"; then
        print_status success "Service installed and started"
        print_status info "Log file: $LOG_FILE"
    else
        print_status error "Failed to start service"
        return 1
    fi
}

# Function to uninstall the service
uninstall_service() {
    echo "🗑️  Uninstalling Agent Sync Service..."
    
    # Unload the service
    launchctl unload "$PLIST_FILE" 2>/dev/null
    
    # Remove plist file
    rm -f "$PLIST_FILE"
    
    print_status success "Service uninstalled"
}

# Function to start the service
start_service() {
    echo "▶️  Starting Agent Sync Service..."
    
    if ! [ -f "$PLIST_FILE" ]; then
        print_status error "Service not installed. Run: $0 install"
        return 1
    fi
    
    launchctl start "$SERVICE_NAME"
    print_status success "Service started"
}

# Function to stop the service
stop_service() {
    echo "⏸️  Stopping Agent Sync Service..."
    
    launchctl stop "$SERVICE_NAME"
    print_status success "Service stopped"
}

# Function to check service status
check_status() {
    echo "📊 Agent Sync Service Status"
    echo "=============================="
    
    if launchctl list | grep -q "$SERVICE_NAME"; then
        print_status success "Service is installed"
        
        # Get PID if running
        PID=$(launchctl list | grep "$SERVICE_NAME" | awk '{print $1}')
        if [ "$PID" != "-" ]; then
            print_status success "Service is running (PID: $PID)"
        else
            print_status error "Service is not running"
        fi
    else
        print_status error "Service is not installed"
    fi
    
    # Check agent count
    if [ -d "$HOME/.claude/agents" ]; then
        AGENT_COUNT=$(ls -1 "$HOME/.claude/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
        print_status info "Agents available: $AGENT_COUNT"
    fi
    
    # Show recent log entries
    if [ -f "$LOG_FILE" ]; then
        echo ""
        echo "📜 Recent Activity:"
        tail -n 5 "$LOG_FILE"
    fi
}

# Function to view logs
view_logs() {
    echo "📜 Agent Sync Logs"
    echo "=================="
    
    if [ -f "$LOG_FILE" ]; then
        tail -f "$LOG_FILE"
    else
        print_status error "No log file found"
    fi
}

# Function to manually sync
manual_sync() {
    echo "🔄 Triggering Manual Sync..."
    
    if [ -f "./sync-to-claude-desktop.sh" ]; then
        ./sync-to-claude-desktop.sh
        print_status success "Manual sync completed"
    else
        print_status error "Sync script not found"
    fi
}

# Main script logic
case "$1" in
    install)
        install_service
        ;;
    uninstall)
        uninstall_service
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        stop_service
        sleep 2
        start_service
        ;;
    status)
        check_status
        ;;
    logs)
        view_logs
        ;;
    sync)
        manual_sync
        ;;
    *)
        echo "🤖 Claude Desktop Agent Service Control"
        echo "========================================"
        echo ""
        echo "Usage: $0 {install|uninstall|start|stop|restart|status|logs|sync}"
        echo ""
        echo "Commands:"
        echo "  install    - Install and start the background service"
        echo "  uninstall  - Remove the background service"
        echo "  start      - Start the service"
        echo "  stop       - Stop the service"
        echo "  restart    - Restart the service"
        echo "  status     - Check service status"
        echo "  logs       - View service logs (live)"
        echo "  sync       - Manually sync agents now"
        echo ""
        echo "The service will:"
        echo "  • Sync agents from GitHub every 5 minutes"
        echo "  • Keep Claude Desktop agents up to date"
        echo "  • Monitor agent health"
        echo "  • Log all activities"
        exit 1
        ;;
esac
