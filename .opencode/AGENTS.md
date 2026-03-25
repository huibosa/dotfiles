# OpenCode Agent Instructions

## Development Workflow Rules

### 1. Planning Phase
- **Before coding**: Describe the solution plan and wait for user approval
- **When requirements are unclear**: Ask clarifying questions before proceeding

### 2. Task Decomposition
- **For tasks modifying >3 files**: Break down into smaller, independent units first
- Each unit should be a logical, reviewable chunk

### 3. Code Completion
- **After completing code**: List potential issues and provide test cases
- Include edge cases and failure scenarios

### 4. Bug Fixing Protocol
- **When discovering a bug**: 
  1. First, write a reproduction test
  2. Fix the bug until the test passes
  3. Verify no regressions

### 5. Continuous Improvement
- **After each correction**: Add new rules to AGENTS.md to avoid repeating the same mistakes
- Document lessons learned for future reference

### 6. Background Task Coordination
- **When background tasks or subagents are running**: Wait for all of them to complete before delivering the final answer
- Do not provide incomplete responses or speculate on results still being computed
- Ensure all parallel work is collected and integrated before responding

### 7. Python Environment Management
- **Always use `uv` for virtual environment creation and dependency management**
- When encountering `ModuleNotFoundError` or missing dependencies, use `uv pip install` instead of `pip install`
- Create virtual environments with `uv venv` before running Python code
- Prefer `uv run` for executing Python scripts in isolated environments
- **For one-time scripts**: Use `uv run --with <package>` to run scripts without creating a persistent virtual environment
