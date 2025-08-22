# AGENTS MANIFEST - DO NOT MODIFY

This file explicitly identifies which files in this repository are AGENTS vs DOCUMENTATION.

## ⚠️ IMPORTANT FOR CLAUDE CODE
- The files listed below are AGENTS and should be treated as such
- DO NOT rename these files
- DO NOT treat documentation files as agents
- Use this manifest as the source of truth for agent identification

## 🤖 AGENT FILES (15 total)
These files contain agent instructions and should be synced to ~/.claude/agents/:

1. `api-design-agent.md` → Maps to: `api-design-architect`
2. `asterisk-expert-agent.md` → Maps to: `asterisk-specialist`
3. `database-engineer-agent.md` → Maps to: `database-architect`
4. `devops-agent.md` → Maps to: `devops-infrastructure-specialist`
5. `gcp-expert-agent.md` → Maps to: `gcp-cloud-architect`
6. `go-agent.md` → Maps to: `go-specialist`
7. `javascript-expert-agent.md` → Maps to: `javascript-specialist`
8. `php-agent.md` → Maps to: `php-specialist`
9. `pr-manager-agent.md` → Maps to: `pr-lifecycle-manager`
10. `project-comprehension-agent.md` → Maps to: `project-comprehension-specialist`
11. `qa-test-orchestrator.md` → Maps to: `qa-test-orchestrator`
12. `qa-testing-agent.md` → Maps to: `code-quality-auditor` AND `code-review-auditor` (creates 2 files)
13. `react-agent.md` → Maps to: `react-specialist`
14. `vicidial-expert-agent.md` → Maps to: `vicidial-specialist`
15. `webrtc-expert-system.md` → Maps to: `webrtc-expert-system`

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
The mapping to Claude Code names happens during the sync process only.

## 🔧 SYNC PROCESS
```bash
./sync.sh
```
This script reads the agent files listed above and copies them to `~/.claude/agents/` with:
- Proper name mapping as shown above
- Required YAML frontmatter for Claude Code
- All agents get `tools: ["*"]` access

---
Last Updated: 2024-08-22
Total Agents: 15
Total Files After Sync: 16 (due to qa-testing-agent creating 2 files)
