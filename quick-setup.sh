#!/bin/bash
# Quick Setup Script for Claude Code Servers
# One command to set up everything

set -e

echo "🚀 Claude Code Agents - Quick Setup"
echo "===================================="
echo ""

# Check if we're in the agents directory
if [ ! -f "claude-code-sync-fixed.sh" ]; then
    echo "❌ Error: Must run from the agents repository directory"
    echo "   Please cd to the cloned repository first"
    exit 1
fi

echo "📦 Step 1: Running initial sync..."
./claude-code-sync-fixed.sh

echo ""
echo "🔗 Step 2: Installing git hooks..."
./setup-git-hooks.sh

echo ""
echo "🤔 Step 3: Install background sync service?"
echo "   This will sync agents from GitHub every 5 minutes"
read -p "   Install background service? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📡 Installing background sync service..."
    ./agent-service-control.sh install
    echo "✅ Background service installed and running"
else
    echo "⏭️  Skipping background service (you can install it later)"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo "✅ Setup Complete!"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "📋 What's been set up:"
echo "   ✓ Agents synced to ~/.config/claude/agents/"
echo "   ✓ All agents have proper YAML frontmatter"
echo "   ✓ Git hooks installed for automatic syncing"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   ✓ Background sync service running"
fi
echo ""
echo "🎯 Available agents in Claude Code:"
ls -1 ~/.config/claude/agents/*.md 2>/dev/null | wc -l | xargs echo "   Total agents:"
echo ""
echo "💡 Next steps:"
echo "   1. Start using agents with Task() in Claude Code"
echo "   2. Pull updates with: git pull (auto-syncs via hooks)"
echo "   3. Check status anytime: ./agent-service-control.sh status"
echo ""
echo "📝 Example usage:"
echo '   Task(subagent_type: "go-specialist", task: "Review this code")'
echo ""
echo "Happy coding! 🚀"
