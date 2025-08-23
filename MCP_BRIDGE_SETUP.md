# MCP Bridge Setup for Custom Agents
## Making Your 16 Custom Agents Work with Claude Code's Task Tool

### 🎯 The Problem

Claude Code's Task tool only recognizes 3 built-in agent types:
- `coder` - General coding agent
- `computer-user` - Computer use capabilities 
- `general-purpose` - General assistant

Your custom agents in `~/.claude/agents/` are NOT directly accessible via the Task tool due to architectural separation.

### 🚀 The Solution: MCP Server Bridge

Create a bridge using the Model Context Protocol (MCP) that exposes your custom agents as tools that the Task system can access.

## Implementation Guide

### Step 1: Create the MCP Agent Bridge Server

Create `~/.claude/mcp-agent-bridge.js`:

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { 
  CallToolRequestSchema, 
  ListToolsRequestSchema 
} = require('@modelcontextprotocol/sdk/types.js');

class AgentBridgeServer {
  constructor() {
    this.server = new Server(
      {
        name: 'custom-agents-bridge',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    
    this.agentsDir = process.env.AGENTS_DIR || path.join(process.env.HOME, '.claude', 'agents');
    this.agents = new Map();
    
    this.setupHandlers();
    this.loadAgents();
  }

  loadAgents() {
    try {
      const files = fs.readdirSync(this.agentsDir);
      
      for (const file of files) {
        if (file.endsWith('.md')) {
          const filePath = path.join(this.agentsDir, file);
          const content = fs.readFileSync(filePath, 'utf-8');
          
          // Parse YAML frontmatter
          const yamlMatch = content.match(/^---\n([\s\S]*?)\n---/);
          if (yamlMatch) {
            const yamlContent = yamlMatch[1];
            const nameMatch = yamlContent.match(/name:\s*(.+)/);
            const descMatch = yamlContent.match(/description:\s*(.+)/);
            const toolsMatch = yamlContent.match(/tools:\s*(.+)/);
            
            if (nameMatch) {
              const agentName = nameMatch[1].trim();
              const description = descMatch ? descMatch[1].trim() : 'Custom agent';
              const tools = toolsMatch ? toolsMatch[1].trim() : '';
              
              // Extract the actual agent prompt (after frontmatter)
              const agentPrompt = content.replace(/^---[\s\S]*?---\n/, '').trim();
              
              this.agents.set(agentName, {
                name: agentName,
                description: description,
                tools: tools,
                prompt: agentPrompt,
                filePath: filePath
              });
              
              console.error(`Loaded agent: ${agentName}`);
            }
          }
        }
      }
      
      console.error(`Total agents loaded: ${this.agents.size}`);
    } catch (error) {
      console.error('Error loading agents:', error);
    }
  }

  setupHandlers() {
    // List all available custom agents as tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      const tools = Array.from(this.agents.values()).map(agent => ({
        name: agent.name,
        description: agent.description,
        inputSchema: {
          type: 'object',
          properties: {
            task: {
              type: 'string',
              description: 'The task to delegate to the agent'
            },
            context: {
              type: 'string',
              description: 'Additional context for the agent',
              optional: true
            }
          },
          required: ['task']
        }
      }));
      
      return { tools };
    });

    // Handle agent execution requests
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      
      const agent = this.agents.get(name);
      if (!agent) {
        throw new Error(`Agent not found: ${name}`);
      }
      
      // Construct the delegated task with agent context
      const delegatedPrompt = `
${agent.prompt}

Task: ${args.task}
${args.context ? `\nAdditional Context: ${args.context}` : ''}

Please complete this task using your specialized expertise.
Available tools: ${agent.tools}
`;
      
      return {
        content: [
          {
            type: 'text',
            text: `Delegating to ${agent.name}:\n\n${delegatedPrompt}`
          }
        ]
      };
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('MCP Agent Bridge Server running...');
  }
}

// Start the server
const server = new AgentBridgeServer();
server.run().catch(console.error);
```

### Step 2: Install MCP Dependencies

```bash
# Create package.json in ~/.claude/
cd ~/.claude
npm init -y
npm install @modelcontextprotocol/sdk
chmod +x mcp-agent-bridge.js
```

### Step 3: Configure MCP in Claude Code

Create `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "custom-agents-bridge": {
      "command": "node",
      "args": ["/home/user/.claude/mcp-agent-bridge.js"],
      "env": {
        "AGENTS_DIR": "/home/user/.claude/agents"
      }
    }
  }
}
```

**For macOS**, use `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "custom-agents-bridge": {
      "command": "node",
      "args": ["/Users/datascore/.claude/mcp-agent-bridge.js"],
      "env": {
        "AGENTS_DIR": "/Users/datascore/.claude/agents"
      }
    }
  }
}
```

### Step 4: Test the MCP Bridge

```bash
# Test the bridge server directly
node ~/.claude/mcp-agent-bridge.js

# You should see:
# Loaded agent: api-design-agent
# Loaded agent: typescript-specialist
# ... (all 16 agents)
# MCP Agent Bridge Server running...
```

### Step 5: Restart Claude Code

After configuration, restart Claude Code to load the MCP server.

## Usage Patterns

### Pattern 1: Direct MCP Tool Access

Once configured, your agents appear as MCP tools:

```python
# These will now be available:
custom-agents-bridge:typescript-specialist
custom-agents-bridge:react-agent
custom-agents-bridge:database-engineer-agent
# ... all 16 agents
```

### Pattern 2: Task Tool with General-Purpose Routing

Since Task tool can't directly call custom agents, use this pattern:

```python
# Use general-purpose with explicit routing instructions
Task(
  subagent_type='general-purpose',
  task='''
  Using the typescript-specialist approach:
  - Add TypeScript to this JavaScript project
  - Configure strict type checking
  - Migrate existing code with proper types
  - Set up build tooling
  '''
)
```

### Pattern 3: Meta-Agent Routing

Create a routing agent that knows about all your custom agents:

```python
Task(
  subagent_type='general-purpose',
  task='''
  Act as a meta-agent router. Analyze this task and delegate to the appropriate specialist:
  
  Available specialists:
  - typescript-specialist: TypeScript and type systems
  - react-agent: React and frontend
  - database-engineer-agent: Database and SQL
  - devops-agent: CI/CD and infrastructure
  [... list all agents ...]
  
  Task: [Your actual task here]
  
  Route this to the most appropriate specialist and execute.
  '''
)
```

## Architecture Overview

```
┌─────────────────┐
│   Task Tool     │
│  (3 built-in)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ general-purpose │
│     agent       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   MCP Bridge    │
│    Server       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Your 16 Custom │
│     Agents      │
│ ~/.claude/agents│
└─────────────────┘
```

## Troubleshooting

### Issue: Agents not appearing as MCP tools

**Solution**: Check Claude Code logs
```bash
# macOS
tail -f ~/Library/Logs/Claude/mcp*.log

# Linux
tail -f ~/.config/Claude/logs/mcp*.log
```

### Issue: MCP server not starting

**Solution**: Test manually
```bash
# Test with explicit paths
NODE_PATH=/usr/local/lib/node_modules node ~/.claude/mcp-agent-bridge.js

# Check for errors
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | node ~/.claude/mcp-agent-bridge.js
```

### Issue: Task tool still doesn't see agents

**Solution**: The Task tool is hardcoded to only use its 3 built-in types. Use Pattern 2 or 3 above for routing through general-purpose.

## Implementation Status Checklist

- [ ] Create MCP bridge server (`mcp-agent-bridge.js`)
- [ ] Install MCP SDK dependencies
- [ ] Configure `claude_desktop_config.json`
- [ ] Test bridge server manually
- [ ] Restart Claude Code
- [ ] Verify MCP tools appear
- [ ] Test with Task tool using routing patterns

## Benefits of This Approach

1. **Preserves Investment**: All your custom agents remain useful
2. **Official Protocol**: Uses Anthropic's MCP standard
3. **Maintainable**: Easy to add new agents
4. **Flexible**: Multiple usage patterns available
5. **Debuggable**: Clear logging and error messages

## Alternative: Direct File Inclusion

If MCP setup is too complex, you can also:

1. Copy agent content directly into your prompts
2. Use the `@` reference to include agent files
3. Build a command-line tool that reads agents

```bash
# Simple CLI tool
cat ~/.claude/agents/typescript-specialist.md | head -20
# Copy the "You are..." section into your prompt
```

## Summary

While the Task tool can't directly access custom agents, this MCP bridge provides a robust solution that:
- Makes all 16 agents accessible via MCP protocol
- Maintains agent metadata and descriptions
- Enables routing through general-purpose agent
- Follows Anthropic's official integration patterns

This bridge transforms the limitation into a feature, giving you more control over agent delegation while maintaining compatibility with Claude Code's architecture.

---
*Last Updated: 2025-08-23*
*Compatible with: Claude Code 0.7.2+*
*MCP Protocol: v1.0.0*
