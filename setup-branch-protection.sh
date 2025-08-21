#!/bin/bash

# Script to configure branch protection rules for the main branch
# This ensures only datascore can push changes

echo "🔒 Setting up branch protection for datascore/claude_code_agents"
echo ""
echo "This script will configure branch protection rules to ensure:"
echo "  - Only datascore can push to main branch"
echo "  - No force pushes allowed"
echo "  - Branch deletion protection"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo ""
    echo "Please configure branch protection manually:"
    echo "1. Go to: https://github.com/datascore/claude_code_agents/settings/branches"
    echo "2. Click 'Add rule'"
    echo "3. Branch name pattern: main"
    echo "4. Enable:"
    echo "   ✅ Restrict who can push to matching branches"
    echo "   ✅ Restrict pushes that create matching branches"
    echo "   ✅ Include administrators"
    echo "   ✅ Allow specified actors to bypass: datascore"
    echo "5. Click 'Create'"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "Please authenticate with GitHub first:"
    echo "Run: gh auth login"
    exit 1
fi

# Configure branch protection using GitHub API
echo "Configuring branch protection..."

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/datascore/claude_code_agents/branches/main/protection \
  -f required_status_checks='null' \
  -f enforce_admins=true \
  -f required_pull_request_reviews='null' \
  -f restrictions='{"users":["datascore"],"teams":[],"apps":[]}' \
  -f allow_force_pushes=false \
  -f allow_deletions=false \
  -f block_creations=false \
  -f required_conversation_resolution=false \
  -f lock_branch=false \
  -f allow_fork_syncing=false 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Branch protection configured successfully!"
    echo ""
    echo "Settings applied:"
    echo "  ✅ Only datascore can push to main"
    echo "  ✅ Force pushes disabled"
    echo "  ✅ Branch deletion protected"
    echo "  ✅ Admin restrictions enforced"
else
    echo "⚠️  Could not configure via API. Please set up manually:"
    echo ""
    echo "Manual Setup Instructions:"
    echo "=========================="
    echo "1. Go to: https://github.com/datascore/claude_code_agents/settings/branches"
    echo "2. Click 'Add rule' (or edit existing rule for 'main')"
    echo "3. Set Branch name pattern: main"
    echo "4. Check these options:"
    echo "   ✅ Restrict who can push to matching branches"
    echo "      - Add 'datascore' as allowed user"
    echo "   ✅ Include administrators"
    echo "   ✅ Do not allow force pushes"
    echo "   ✅ Do not allow deletions"
    echo "5. Click 'Save changes'"
fi

echo ""
echo "📝 Additional Notes:"
echo "- Others can still fork your repository (it's public)"
echo "- They can submit pull requests for you to review"
echo "- Only you can merge pull requests to main"
echo "- Consider requiring PR reviews even for yourself for extra safety"
