# Agent Instructions

## Workflow

### Planning
- Non-trivial code: describe the plan, wait for approval
- Unclear requirements: ask before proceeding
- Tasks touching >3 files: decompose into reviewable units first

### Bug fixing
1. Write a reproduction test
2. Fix until the test passes
3. Verify no regressions

### Parallel work
- Use forks (Agent without `subagent_type`) for research that would bloat your context
- When background tasks or subagents are running, wait for all to complete before delivering the final answer; never speculate on in-flight results

### Search modes (only when explicitly invoked)
- **[search-mode]** — exhaustive fan-out: multiple Explore agents in parallel plus direct Grep / ripgrep / AST-grep
- **[analyze-mode]** — context first: 1-2 Explore agents plus targeted Grep / AST-grep / LSP
- Default (no mode named): single targeted search

### Continuous improvement
- If the same mistake recurs, propose a new rule for CLAUDE.md
- Don't add a rule for every one-off correction

## Tooling

### Python
- Use `uv` for venvs and dependencies (`uv venv`, `uv pip install`, `uv run`)
- One-time scripts: `uv run --with <package>`

### JavaScript / TypeScript
- Use `bun` over `npm` (`bun install`, `bun add`, `bun run`, `bun add -g`, `bunx`)

### Skills
- Always use `bunx skills` to manage skills (install, update, remove) unless explicitly told otherwise

### Servers
- Start in tmux via `Bash`: `tmux new-session -d -s <name>`, then `tmux send-keys` to run the server
- Check existing sessions first: `tmux list-sessions`
- Name descriptively: `dev-server`, `api-server`

### Git worktrees
- Default location: `.worktrees/` at project root
- Add `.worktrees/` to `.gitignore`

### File locations
- Temp / scratch scripts → `/tmp` unless user specifies
- User-local tools (when the system package manager can't supply the version) → `~/.local/bin`

## Code quality

### Testing
Write tests for:
- Core business logic (input → expected output)
- Regression-prone boundaries / error paths
- External integrations (minimize mocking)

Skip tests that:
- Chase coverage without exercising logic
- Duplicate existing cases
- Assert implementation details (colors, class names)
- Cover deprecated features
- Mock so heavily the test is distorted
- Verify nothing of business value

### Scope control
- Localized defect → minimum necessary fix
- Structural defect → propose a root-cause solution; pause and confirm if scope is large or interfaces change
- Don't expand requirements (no unsolicited fallbacks)
- Report security / data / performance risks separately, after the main change

### Dependencies
- Prefer existing project deps and the standard library
- A new third-party dep requires justification and explicit approval

### Logging
- Log at boundaries: input params, branch decisions, exceptions
- Never log inside loops or hot paths

### Documentation
- If docs are clearly outdated after a change, sync them

## Safety

### High-risk operations
- Deleting files, pushing to remotes, modifying env / CI / DB → require secondary confirmation
- Never execute arbitrarily

### Blockers
- Stop and report when motivation is unclear, prerequisites are invalid, info is missing, or solutions conflict
- Never proceed on guesswork
