# AGENTS MANIFEST - DO NOT MODIFY

This file explicitly identifies which files in this repository are AGENTS vs DOCUMENTATION.

## ⚠️ IMPORTANT FOR CLAUDE CODE
- The files listed below are AGENTS and should be treated as such
- DO NOT rename these files
- DO NOT treat documentation files as agents
- Use this manifest as the source of truth for agent identification

## 🤖 AGENT FILES (15 total)
These files contain agent instructions and should be synced to ~/.claude/agents/:

1. `api-design-agent.md`
2. `asterisk-expert-agent.md`
3. `database-engineer-agent.md`
4. `devops-agent.md`
5. `gcp-expert-agent.md`
6. `go-agent.md`
7. `javascript-expert-agent.md`
8. `php-agent.md`
9. `pr-manager-agent.md`
10. `project-comprehension-agent.md`
11. `qa-test-orchestrator.md`
12. `qa-testing-agent.md`
13. `react-agent.md`
14. `vicidial-expert-agent.md`
15. `webrtc-expert-system.md`

## 📄 DOCUMENTATION FILES (NOT AGENTS)
These files are documentation and should NOT be treated as agents:

- `README.md` - Repository documentation
- `AGENTS_MANIFEST.md` - This file
- Any other `.md` files not listed above

## 🎯 AGENT IDENTIFICATION RULES

A file is an AGENT if and only if:
1. It is explicitly listed in the AGENT FILES section above
2. It contains a `## Role` section defining the agent's expertise
3. It starts with "You are" describing the agent's role

## ⚠️ DO NOT MODIFY AGENT FILENAMES
The agent filenames in this repository are the canonical source. They should NOT be renamed.
Agents are copied to ~/.claude/agents/ with their ORIGINAL filenames.

## 🔧 SYNC PROCESS
```bash
./sync.sh
```
This script reads the agent files listed above and copies them to `~/.claude/agents/` with:
- Original filenames preserved (no renaming)
- Required YAML frontmatter for Claude Code
- All agents get `tools: ["*"]` access

---
Last Updated: 2024-08-22
Total Agents: 15
Total Files After Sync: 15 (agents keep original filenames)
