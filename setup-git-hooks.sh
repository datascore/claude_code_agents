#!/bin/bash
# Setup git hooks for automatic agent syncing

echo "🔧 Setting up Git hooks for automatic agent syncing..."

REPO_DIR="$(pwd)"
HOOKS_DIR="$REPO_DIR/.git/hooks"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Create post-merge hook
echo "📝 Creating post-merge hook..."
cat > "$HOOKS_DIR/post-merge" << 'EOF'
#!/bin/bash
# Git hook: post-merge
# Automatically sync agents to Claude Code after git pull/merge

echo "🔄 Git merge detected - syncing agents to Claude Code..."

# Get the repository directory
REPO_DIR="$(git rev-parse --show-toplevel)"

# Run the sync script if it exists
if [ -f "$REPO_DIR/claude-code-sync-fixed.sh" ]; then
    cd "$REPO_DIR"
    ./claude-code-sync-fixed.sh
    echo "✅ Agents synced to Claude Code"
elif [ -f "$REPO_DIR/sync-agents.sh" ]; then
    cd "$REPO_DIR"
    ./sync-agents.sh
    echo "✅ Agents synced (legacy script)"
else
    echo "⚠️ No sync script found"
fi

echo "💡 Remember to restart Claude Code or start a new conversation to use updated agents"
EOF

chmod +x "$HOOKS_DIR/post-merge"
echo "✅ post-merge hook installed"

# Create post-commit hook
echo "📝 Creating post-commit hook..."
cat > "$HOOKS_DIR/post-commit" << 'EOF'
#!/bin/bash
# Git hook: post-commit
# Automatically sync agents to Claude Code after local commits

echo "🔄 New commit detected - syncing agents to Claude Code..."

# Get the repository directory
REPO_DIR="$(git rev-parse --show-toplevel)"

# Check if the commit modified any agent files
MODIFIED_AGENTS=$(git diff-tree --no-commit-id --name-only -r HEAD | grep -E '\.md$' | grep -v -E 'README|CATALOG|WORKFLOW|SETUP|loader|mapper')

if [ -n "$MODIFIED_AGENTS" ]; then
    echo "📝 Modified agents detected:"
    echo "$MODIFIED_AGENTS" | sed 's/^/   - /'
    
    # Run the sync script
    if [ -f "$REPO_DIR/claude-code-sync-fixed.sh" ]; then
        cd "$REPO_DIR"
        ./claude-code-sync-fixed.sh
        echo "✅ Agents synced to Claude Code"
    elif [ -f "$REPO_DIR/sync-agents.sh" ]; then
        cd "$REPO_DIR"
        ./sync-agents.sh
        echo "✅ Agents synced (legacy script)"
    else
        echo "⚠️ No sync script found"
    fi
else
    echo "ℹ️ No agent files modified - skipping sync"
fi
EOF

chmod +x "$HOOKS_DIR/post-commit"
echo "✅ post-commit hook installed"

echo ""
echo "✅ Git hooks successfully installed!"
echo ""
echo "🎯 What the hooks do:"
echo "   • post-merge: Syncs agents after 'git pull'"
echo "   • post-commit: Syncs agents after local commits (if agents were modified)"
echo ""
echo "📋 The hooks will:"
echo "   1. Detect when agents are added/modified"
echo "   2. Run claude-code-sync-fixed.sh automatically"
echo "   3. Update ~/.config/claude/agents/ with proper YAML format"
echo ""
echo "💡 Note: Hooks are local to your repository and not pushed to GitHub"
