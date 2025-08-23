# Changelog

## [2025-08-23] - Major Updates for Claude Code Compliance

### 🎯 Summary
Complete overhaul of agent system to meet 2025 Anthropic standards with 16 specialized agents, all fully compliant with Claude Code requirements.

### ✅ Key Achievements

#### 1. **Added TypeScript Specialist Agent**
- Created comprehensive `typescript-specialist.md`
- Covers advanced type systems, migrations, and patterns
- Includes React/Node.js integration examples

#### 2. **Fixed Claude Code Format Compliance**
- Updated all agents to proper format: YAML → "You are..." → Expertise
- Removed unnecessary headers between frontmatter and role description
- Ensured YAML `name` fields match filenames exactly
- Tools specified as comma-separated list (not array)

#### 3. **Enhanced Proactive Agent Selection**
- Added "MUST BE USED" triggers to all descriptions
- Included "Proactively" action words for automatic delegation
- Clear domain boundaries for each agent's expertise

#### 4. **Repository Improvements**
- Clarified user-level only installation (`~/.claude/agents/`)
- Removed problematic `mkdir` commands from troubleshooting
- Added Claude Code installation check to sync script
- Updated documentation to reflect all changes

### 📊 Current State
- **Total Agents**: 16
- **Compliance**: 100% (all meet 2025 Anthropic standards)
- **Location**: User-level only (`~/.claude/agents/`)
- **Availability**: Across all Claude Code projects

### 🤖 Complete Agent List

| Agent | Domain | Proactive Triggers |
|-------|--------|-------------------|
| `api-design-agent` | REST, GraphQL, API design | API patterns, endpoints, OpenAPI specs |
| `asterisk-expert-agent` | Asterisk PBX, VoIP | SIP, dialplans, telephony configs |
| `database-engineer-agent` | Database, SQL/NoSQL | Queries, schemas, migrations |
| `devops-agent` | CI/CD, Docker, K8s | Deployments, pipelines, infrastructure |
| `gcp-expert-agent` | Google Cloud Platform | GCP services, BigQuery, cloud arch |
| `go-agent` | Go programming | Go code, concurrency, modules |
| `javascript-expert-agent` | JavaScript, Node.js | ES6+, async patterns, frameworks |
| `php-agent` | PHP, Laravel | PHP code, composer, frameworks |
| `pr-manager-agent` | Pull requests | PR workflows, review processes |
| `project-comprehension-agent` | Codebase analysis | Project structure, dependencies |
| `qa-test-orchestrator` | Test automation | Test suites, QA strategies |
| `qa-testing-agent` | Code quality | Tests, coverage, quality assurance |
| `react-agent` | React, frontend | Components, hooks, state management |
| `typescript-specialist` | TypeScript | Type systems, migrations, patterns |
| `vicidial-expert-agent` | ViciDial platform | Campaign setup, agent management |
| `webrtc-expert-system` | WebRTC, real-time | Media streams, peer connections |

### 🔧 Technical Details

#### YAML Frontmatter Format
```yaml
---
name: agent-name
description: MUST BE USED for [domain]. Proactively [actions]
tools: Read, Write, Edit, Bash, Grep, Find, SearchCodebase, CreateFile, RunCommand, Task
---
You are [role description]...
```

#### Sync Script Features
- Validates Claude Code installation before syncing
- Extracts role descriptions from source files
- Adds compliant YAML frontmatter automatically
- Cleans old agents before syncing new ones

### 📝 Commits Today
1. Added TypeScript specialist agent
2. Fixed agent format for Claude Code compliance
3. Updated README with correct format documentation
4. Clarified user-level only installation
5. Removed problematic mkdir commands
6. Added proactive triggers for automatic delegation

### 🚀 Usage
```bash
# Clone and sync agents
git clone https://github.com/datascore/claude_code_agents.git ~/agents
cd ~/agents
./sync.sh

# Use in Claude Code
Task(subagent_type: 'typescript-specialist', task: 'Add TypeScript to my project')
```

### 📚 Resources
- Repository: https://github.com/datascore/claude_code_agents
- Total Files: 16 agent files + documentation
- License: MIT

---
*Last Updated: 2025-08-23*
