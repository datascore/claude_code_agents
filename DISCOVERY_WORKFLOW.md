# Discovery Document Workflow

## The Complete Flow: From Discovery to Implementation

### Step 1: You Provide Discovery Document
```
User: "Here, review this discovery document for [project name]"
```

### Step 2: Project Comprehension Agent Takes Over

#### Phase 1: Deep Document Analysis
The Project Comprehension Agent:
- Reads the discovery document thoroughly
- Extracts key requirements and objectives
- Identifies mentioned files, services, and components
- Notes all technical indicators (languages, frameworks, databases)

#### Phase 2: Codebase Research & Validation
```python
# The agent researches the actual codebase to understand:

1. VERIFY what actually exists:
   - "Discovery mentions 'freeswitch-esl-client/esl.go' - let me check if this file exists"
   - "It talks about human-detection-v2 - let me explore this service structure"
   - "Recording storage at /mnt/recordings - let me verify current storage setup"

2. UNDERSTAND current implementation:
   - Read the actual code files mentioned
   - Trace through function calls and dependencies
   - Map out the current architecture
   - Identify existing patterns and conventions

3. IDENTIFY gaps and impacts:
   - "Discovery wants to add FreeswitchProvider but I see there's already a TwilioProvider"
   - "The recording trigger needs to hook into EventHumanDetected - let me see how events work"
   - "They want to move from GCS to local storage - what's currently using GCS?"

4. DISCOVER hidden dependencies:
   - What other services consume these APIs?
   - What will break if we change this?
   - Are there database migrations needed?
   - What about backward compatibility?
```

#### Phase 3: Complete Understanding Formation
After researching, the agent builds:
```yaml
complete_understanding:
  what_discovery_wants:
    - Add recording capability to FreeSWITCH
    - Trigger on human/beep detection
    - Store recordings locally
    - Add transcription pipeline
    
  what_actually_exists:
    - Current FreeSWITCH ESL client (hardcoded numbers)
    - Human detection service (event-driven)
    - GCS storage for different purpose
    - Existing UI for recordings
    
  what_needs_to_change:
    - Modify: freeswitch-esl-client/esl.go
    - Create: FreeswitchProvider in human-detection-v2
    - Update: Recording storage location
    - Extend: UI to show transcripts
    
  what_could_break:
    - Existing recording features
    - Phone number routing
    - Storage capacity issues
    - API compatibility
```

#### Phase 4: Dynamic Agent Selection
Based on the complete understanding:
```python
# The agent discovers available specialists
available_agents = discover_all_agents()  # Scans ./agents/ directory

# Matches needs to capabilities
required_expertise = {
    'golang': ['freeswitch-esl-client', 'human-detection-v2'],
    'database': ['recording metadata', 'transcription storage'],
    'infrastructure': ['storage mount', 'service deployment'],
    'frontend': ['recordings UI', 'transcript display'],
    'testing': ['integration tests', 'e2e validation']
}

# Selects appropriate agents
selected_agents = match_agents_to_requirements(available_agents, required_expertise)
```

#### Phase 5: Comprehensive Project Plan
The agent creates:
```markdown
## Project Implementation Plan

### Pre-Implementation Validation
- [x] Discovery document understood
- [x] Current codebase researched
- [x] All files mentioned exist: ✓
- [x] Dependencies mapped
- [x] Breaking changes identified
- [x] Team agents selected

### Implementation Phases

#### Phase 1: Foundation (Week 1)
**Lead Agent**: devops-agent
**Research Completed**: 
- Current storage is GCS at gs://recordings
- FreeSWITCH runs on instances X, Y, Z
- Mount point /mnt/recordings doesn't exist yet

**Tasks**:
1. Create and mount storage volume
2. Configure FreeSWITCH ESL access
3. Setup monitoring

#### Phase 2: Backend Development (Week 2-3)
**Lead Agent**: go-agent
**Research Completed**:
- esl.go has hardcoded numbers on lines 45-67
- human-detection-v2 uses actor pattern
- Event system is in place, just needs new handlers

**Tasks**:
1. Modify freeswitch-esl-client/esl.go
   - Remove hardcoded numbers (lines 45-67)
   - Add dynamic recording method
   
2. Create FreeswitchProvider
   - Location: human-detection-v2/api-media-streams/internal/voice/
   - Pattern: Copy TwilioProvider structure
   - Integration: Hook into existing event system

[... continues with all phases ...]
```

## The Key Insight: Research-Driven SDD Creation

### Without Codebase Research (Bad):
```
Discovery: "Add recording to FreeSWITCH"
SDD Output: "We will create a recording feature"  ❌ Too vague, not actionable!
```

### With Deep Code Research (Good):
```
Discovery: "Add recording to FreeSWITCH"

Research Phase: 
  - Found: esl.go exists with hardcoded phone numbers at lines 45-67
  - Found: Event system in actor.go with EventHumanDetected at line 234
  - Found: TwilioProvider pattern at voice/twilio.go that we can mirror
  - Found: Existing recordings UI at components/Recordings.tsx
  - Found: Current GCS storage implementation in storage/gcs.go

Deep Code Review:
  - Analyzed: How ESL client currently connects and sends commands
  - Understood: Event propagation flow from detection to action
  - Mapped: All consumers of the current recording system
  - Identified: Database schema patterns in migrations/

SDD Output: 
  "After reviewing the codebase, here's the detailed design:
   
   1. ESL Client Modifications (freeswitch-esl-client/esl.go):
      - Current: Lines 45-67 contain hardcoded phone numbers
      - Change: Replace with dynamic parameter system
      - New Methods: AddRecordingCommand(sessionID, path string)
      - Integration: Maintain existing connection pooling pattern
   
   2. FreeswitchProvider Implementation (new file):
      - Location: human-detection-v2/api-media-streams/internal/voice/freeswitch.go
      - Pattern: Mirror TwilioProvider structure (found at voice/twilio.go)
      - Methods: StartRecording(), StopRecording(), GetRecordingStatus()
      - Connection: Use existing ESL WebSocket from lines 89-102
   
   3. Event Integration Points:
      - Hook: actor.go line 234 EventHumanDetected handler
      - Add: New case for EventBeepDetected at line 248
      - Maintain: Existing event ordering and state machine
   
   [Continues with complete technical specification...]" ✅
```

## Example Workflow

### 1. You Provide Discovery
```markdown
"We need to add call recording triggered by human detection in our FreeSWITCH system"
```

### 2. Agent Researches
```bash
# Agent automatically explores:
- grep -r "FreeSWITCH" .
- find . -name "*esl*"
- grep -r "EventHumanDetected" .
- ls -la /mnt/recordings
- docker ps | grep freeswitch
- Review human-detection-v2 service structure
- Check current storage configuration
```

### 3. Agent Understands
```markdown
FINDING: FreeSWITCH ESL client exists but needs modification
FINDING: Human detection events are already flowing
FINDING: Storage needs to be migrated from GCS to local
FINDING: UI exists but needs transcript display added
```

### 4. Agent Creates Detailed SDD
```markdown
Based on my deep code review of your codebase:

## Software Design Document: FreeSWITCH Recording Integration

### 1. ESL Client Analysis & Proposed Changes
File: freeswitch-esl-client/esl.go
Current Implementation:
  - Lines 45-67: Hardcoded phone number array
  - Lines 89-102: WebSocket connection management
  - Lines 156-189: Command execution pipeline
  
Proposed Modifications:
  - Replace hardcoded array with dynamic configuration
  - Add StartRecording(sessionID, path) method after line 189
  - Maintain existing error handling pattern from lines 201-210
  - Integration point: Existing command queue at line 178

### 2. New FreeswitchProvider Design
Location: human-detection-v2/api-media-streams/internal/voice/freeswitch.go (NEW)
Based on analysis of voice/twilio.go:
  - Implement Provider interface (defined at voice/provider.go:12)
  - Mirror TwilioProvider's connection management (twilio.go:34-67)
  - State machine: Follow pattern from twilio.go:89-125
  - Error handling: Use existing retry logic from twilio.go:145-162

### 3. Event System Integration
File: human-detection-v2/api-media-streams/internal/voice/actor.go
Current Event Flow:
  - Line 234: EventHumanDetected handler
  - Line 248: Available slot for new event handler
  - Line 267-289: State transition logic
  
Proposed Integration:
  - Insert recording trigger at line 235 (after human detection)
  - Add EventBeepDetected handler at line 248
  - Maintain state consistency using existing pattern at 267-289

[Document continues with complete technical specifications...]
```

### 5. SDD Review & Distribution
```markdown
The completed SDD is then:
1. Reviewed for completeness and accuracy
2. Validated against current codebase state
3. Distributed to relevant specialist agents who will:
   - go-agent: Reviews Go-specific implementation details
   - database-agent: Reviews data model design
   - devops-agent: Reviews infrastructure requirements
   - qa-orchestrator: Creates test plan from SDD
   
Each agent reads the SDD to understand what needs to be built,
but the SDD itself is the deliverable, not the implementation.
```

## The Magic: Context-Aware Implementation

Because the Project Comprehension Agent researches first:
- Agents receive context about YOUR specific codebase
- They follow YOUR patterns and conventions
- They understand YOUR architecture
- They know what not to break
- They can estimate accurately

## Summary: The SDD Creation Flow

1. **Discovery Document** → You provide the high-level "what"
2. **Deep Codebase Research** → Agent studies "how it currently works"
   - Reads actual code files
   - Traces function calls
   - Maps dependencies
   - Understands patterns
3. **Comprehensive Code Review** → Agent documents findings
   - Current implementation details
   - Exact line numbers and file paths  
   - Existing patterns to follow
   - Integration points available
4. **Gap Analysis** → Agent identifies "what needs to change or be added"
   - Specific modifications needed
   - New components to create
   - Dependencies to update
5. **Detailed SDD Creation** → Agent writes comprehensive design document
   - Technical specifications
   - Implementation guidelines
   - Architecture decisions
   - Risk assessments
6. **SDD Output** → The deliverable is the document, not the code

The Project Comprehension Agent is the architect who studies your codebase deeply and writes the blueprint (SDD) that others could follow to implement the changes!
