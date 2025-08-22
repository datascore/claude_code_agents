# Agent Catalog & Organization

## Agent Categories

### 🎯 Core Agent Types (Generic & Reusable)

#### 1. **Planning & Comprehension Agents**
- **project-comprehension-agent** - Analyzes requirements, creates plans, orchestrates other agents
- **Use for**: SDDs, discovery documents, project planning, impact analysis

#### 2. **Language & Framework Agents** 
- **go-agent** - Go language expertise
- **javascript-expert-agent** - JavaScript/Node.js expertise  
- **php-agent** - PHP expertise
- **react-agent** - React/TypeScript frontend expertise
- **Use for**: Actual code implementation in specific languages

#### 3. **Infrastructure & Operations Agents**
- **devops-agent** - CI/CD, Docker, Kubernetes, monitoring
- **database-engineer-agent** - Database design, optimization, migrations
- **gcp-expert-agent** - Google Cloud Platform services
- **Use for**: Infrastructure setup, deployments, cloud services

#### 4. **Quality & Testing Agents**
- **qa-test-orchestrator** - Comprehensive test planning and orchestration
- **qa-testing-agent** - Browser automation, bug finding, chaos testing
- **pr-manager-agent** - Code review, PR process, git workflows
- **Use for**: Testing, quality assurance, code review

#### 5. **Design & Architecture Agents**
- **api-design-agent** - REST, GraphQL, API architecture
- **Use for**: System design, API contracts, architecture decisions

#### 6. **Domain-Specific Agents** (When needed)
- **asterisk-expert-agent** - Telephony/VoIP systems
- **vicidial-expert-agent** - Call center platforms
- **webrtc-expert-system** - Real-time communications
- **Use for**: Specialized domain knowledge

---

## 🔄 Generic Agent Selection Pattern

Instead of creating new specific agents, use this pattern:

### For Any Project:

```yaml
agent_selection:
  step_1_comprehension:
    agent: project-comprehension-agent
    output: "Project plan with agent assignments"
    
  step_2_implementation:
    select_by_language:
      golang: go-agent
      javascript: javascript-expert-agent
      typescript: react-agent
      php: php-agent
      python: "Use javascript-expert-agent (can handle Python too)"
      
    select_by_infrastructure:
      cloud: gcp-expert-agent
      containers: devops-agent
      databases: database-engineer-agent
      
  step_3_quality:
    code_review: pr-manager-agent
    testing: qa-test-orchestrator
    browser_testing: qa-testing-agent
    
  step_4_specialized: # Only if needed
    voip: asterisk-expert-agent
    webrtc: webrtc-expert-system
    call_center: vicidial-expert-agent
```

---

## 📋 When to Use Which Agent

### Starting a New Project
1. **Always start with**: `project-comprehension-agent`
2. **Then use language agents**: Based on tech stack
3. **Add infrastructure**: `devops-agent` + `database-engineer-agent`
4. **Include quality**: `qa-test-orchestrator` + `pr-manager-agent`
5. **Only add domain agents**: If specialized knowledge needed

### Code Implementation
- **Backend API**: `go-agent` or `javascript-expert-agent` + `api-design-agent`
- **Frontend**: `react-agent` or `javascript-expert-agent`
- **Database**: `database-engineer-agent`
- **Cloud**: `gcp-expert-agent` + `devops-agent`

### Quality & Review
- **Code Review**: `pr-manager-agent`
- **Test Planning**: `qa-test-orchestrator`
- **Bug Finding**: `qa-testing-agent`

---

## 🚫 Agents We DON'T Need to Create

Instead of creating these specific agents, use the generic ones:

❌ **Don't create**: aws-agent, azure-agent  
✅ **Instead use**: `gcp-expert-agent` (rename to `cloud-infrastructure-agent`)

❌ **Don't create**: nodejs-agent, express-agent  
✅ **Instead use**: `javascript-expert-agent`

❌ **Don't create**: mysql-agent, postgres-agent  
✅ **Instead use**: `database-engineer-agent`

❌ **Don't create**: docker-agent, kubernetes-agent  
✅ **Instead use**: `devops-agent`

❌ **Don't create**: unit-test-agent, integration-test-agent  
✅ **Instead use**: `qa-test-orchestrator`

---

## 🔨 Proposed Consolidation

### Rename for Clarity:
- `gcp-expert-agent` → `cloud-infrastructure-agent`
- `javascript-expert-agent` → `javascript-node-agent`
- `qa-test-orchestrator` → `testing-orchestrator`
- `pr-manager-agent` → `code-review-agent`

### Potential Merges:
- Merge `qa-testing-agent` into `testing-orchestrator`
- Merge `api-design-agent` into language agents (each can handle API design)

### Keep Separate (Domain-Specific):
- `asterisk-expert-agent`
- `vicidial-expert-agent`  
- `webrtc-expert-system`

---

## 📊 Final Simplified Structure

```
agents/
├── Planning & Architecture
│   └── project-comprehension-agent
│
├── Implementation
│   ├── go-agent
│   ├── javascript-node-agent
│   ├── php-agent
│   ├── react-agent
│   └── api-design-agent
│
├── Infrastructure
│   ├── cloud-infrastructure-agent
│   ├── database-engineer-agent
│   └── devops-agent
│
├── Quality
│   ├── testing-orchestrator
│   └── code-review-agent
│
└── Specialized (only when needed)
    ├── asterisk-expert-agent
    ├── vicidial-expert-agent
    └── webrtc-expert-system
```

This gives us **~12 core agents** that can handle 95% of projects, with specialized agents only for specific domains.

---

## 🎯 Usage Example

For your FreeSWITCH project:
```yaml
agents_used:
  - project-comprehension-agent    # Understand & plan
  - go-agent                       # Implement Go code
  - database-engineer-agent        # Design schema
  - devops-agent                   # Setup infrastructure
  - cloud-infrastructure-agent     # GCP storage
  - react-agent                    # Update UI
  - asterisk-expert-agent         # VoIP expertise (specialized)
  - testing-orchestrator          # Test everything
```

For a typical web app:
```yaml
agents_used:
  - project-comprehension-agent    # Understand & plan
  - javascript-node-agent          # Backend
  - react-agent                    # Frontend
  - database-engineer-agent        # Database
  - devops-agent                   # Deployment
  - testing-orchestrator          # Testing
  # No specialized agents needed!
```
