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
- **Never sleep-poll** (`sleep` / `Bash(sleep …)`) to wait for a background agent or task — it blocks harness notifications and causes infinite loops
- If you need an agent's result to continue: use `run_in_background: false` (synchronous); the result is returned directly as the tool value
- If background is needed: stop after spawning and wait passively — the harness sends a `<task-notification>` automatically when done

### Search
- Use the `smart-search-cli` skill only for **web / external research** (finding libraries, looking up docs, researching approaches online) — invoke it via Skill before any other web search
- For **codebase search** (reading files, finding symbols, understanding the local repo), use file tools, Grep, LSP, or Explore agents directly — do NOT invoke `smart-search-cli`

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
- Indentation: tabs (tab width 2)
- Quotes: double quotes
- Semicolons: yes
- Trailing commas: none
- Print width: no line wrapping — keep statements on one line

### Skills
- Always use `bunx skills` to manage skills (install, update, remove) unless explicitly told otherwise
- `bunx skills update` installs NEW skills from the package, not just updates — never use `-y`; review `ls ~/.agents/skills/` after
- `bunx skills remove -a '*'` is broken — remove the dir in `~/.agents/skills/` and its symlinks manually

### Servers
- Start in tmux via `Bash`: `tmux new-session -d -s <name>`, then `tmux send-keys` to run the server
- Check existing sessions first: `tmux list-sessions`
- Name descriptively: `dev-server`, `api-server`
- Before creating a tmux session, carefully choose the session name; never overwrite existing sessions
- Prefer adding a new window to the current tmux session over creating a new session, unless told otherwise

### Background tasks & TaskOutput

- `TaskOutput` fails → check session history for the launch tool result, then `Read` its output file path directly (skip for local_agent tasks — JSONL overflow; use the agent's return value instead)
- Need result immediately → use `run_in_background: false`
- Background tasks → wait passively for `<task-notification>`; never `sleep`-poll

### Codex CLI (`codex exec`)
- **Read-only review runs:** `devil-review` (and any read-only Codex review) uses `-c sandbox_mode="read-only" -c approval_policy="never"` instead of `--yolo`, to hard-enforce the no-modify contract. `--sandbox read-only` is not available on `codex exec resume`, so the `-c` overrides are used on both `exec` and `resume`. `--yolo` remains correct for task/delegation runs where Codex is expected to write.
- Always pipe input via stdin: `codex exec --yolo "<prompt>" < /path/to/file` — avoids bubblewrap sandbox filesystem restrictions and closes stdin naturally at EOF
- If there is no input file, write content to `/tmp` first, then pipe it in — never use `< /dev/null` (empty stdin) as it prevents codex from reading any input
- Always run with `run_in_background: true` — codex runs are long. The output file streams live; read it directly when you want a peek
- Don't pipe through `tail`/`head` — those buffer until upstream closes, hiding live output. `tee` is fine: use `stdbuf -oL codex exec ... 2>&1 | tee "$OUT"` to get both shell-window visibility and a peekable file simultaneously; capture Codex's exit code with `${PIPESTATUS[0]}`

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

### Design principles
- Do not preserve backward compatibility. Remove obsolete paths instead of adding compatibility layers, fallbacks, or migrations.
- Choose the simplest implementation that fully meets the current requirements. Avoid speculative abstractions, configuration, and indirection.
- Grow the system in layers. Start from the smallest version that works end to end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall complexity or improve reliability. Do not reimplement common functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Do not assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later.

## Safety

### High-risk operations
- Deleting files, pushing to remotes, modifying environment config / CI pipelines / databases → require secondary confirmation
- Never execute arbitrarily

### Blockers
- Stop and report when motivation is unclear, prerequisites are invalid, info is missing, or solutions conflict
- Never proceed on guesswork
