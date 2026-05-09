#!/usr/bin/env bash

set -euo pipefail

input=$(cat)

session_id=$(printf '%s' "$input" | jq -r '.session_id // "default"')
columns=$(printf '%s' "$input" | jq -r '.columns // 120')
tasks=$(printf '%s' "$input" | jq -c '.tasks // []')
state_file="/tmp/claude-sl-${session_id}.json"
claude_projects_dir="${HOME}/.claude/projects"

if [[ "$tasks" == "[]" || -z "$tasks" ]]; then
  exit 0
fi

python3 - "$tasks" "$columns" "$state_file" "$session_id" "$claude_projects_dir" <<'PY'
import json
import sys
from pathlib import Path

try:
    tasks = json.loads(sys.argv[1])
except Exception:
    tasks = []
columns = int(sys.argv[2] or 120)
state_file = Path(sys.argv[3])
session_id = sys.argv[4]
projects_dir = Path(sys.argv[5])
sep = '\033[30m•\033[0m'


def fmt_tok(n: int) -> str:
    if n >= 1_000_000:
        return f"{n/1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n/1_000:.1f}k"
    if n == 0:
        return "0k"
    return str(n)


def trim_label(text: str, max_len: int) -> str:
    if max_len < 10:
        max_len = 10
    if len(text) <= max_len:
        return text
    return text[: max_len - 1] + '…'


def model_display(model_id: str) -> str:
    if model_id.startswith('custom-model-a1'):
        return 'Opus'
    if model_id.startswith('custom-model-a2') or model_id == 'sonnet':
        return 'Sonnet'
    if model_id.startswith('glm-5.1'):
        return 'GLM-5.1'
    if model_id.startswith('deepseek-v4-pro'):
        return 'DeepSeek-v4-pro'
    if model_id.startswith('deepseek-v4-flash'):
        return 'deepseek-v4-flash'
    return model_id


def read_state(path: Path):
    if not path.is_file():
        return {}
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def parse_usage_file(file_path: Path):
    totals = {
        'input': 0,
        'output': 0,
        'cache_read': 0,
        'cache_write': 0,
        'last_input': 0,
        'last_output': 0,
        'last_cache_read': 0,
        'last_cache_write': 0,
        'model': '',
        'messages': 0,
    }
    try:
        handle = file_path.open()
    except Exception:
        return totals
    with handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            if obj.get('type') != 'assistant':
                continue
            message = obj.get('message', {})
            usage = message.get('usage')
            if not isinstance(usage, dict):
                continue
            totals['messages'] += 1
            totals['input'] += int(usage.get('input_tokens', 0) or 0)
            totals['output'] += int(usage.get('output_tokens', 0) or 0)
            totals['cache_read'] += int(usage.get('cache_read_input_tokens', 0) or 0)
            totals['cache_write'] += int(usage.get('cache_creation_input_tokens', 0) or 0)
            totals['last_input'] = int(usage.get('input_tokens', 0) or 0)
            totals['last_output'] = int(usage.get('output_tokens', 0) or 0)
            totals['last_cache_read'] = int(usage.get('cache_read_input_tokens', 0) or 0)
            totals['last_cache_write'] = int(usage.get('cache_creation_input_tokens', 0) or 0)
            model = message.get('model')
            if model:
                totals['model'] = model
    return totals


def build_subagent_index(session_id: str, projects_dir: Path):
    index = []
    if not projects_dir.exists():
        return index
    matches = sorted(projects_dir.glob(f"**/{session_id}.jsonl"), key=lambda p: len(p.parts))
    root = matches[0] if matches else None
    if root is None or not root.is_file():
        return index
    subagent_dir = root.with_suffix('') / 'subagents'
    if not subagent_dir.is_dir():
        return index
    for meta_path in sorted(subagent_dir.glob('*.meta.json')):
        stem = meta_path.stem.replace('.meta', '')
        jsonl_path = subagent_dir / f'{stem}.jsonl'
        try:
            meta = json.loads(meta_path.read_text())
        except Exception:
            meta = {}
        totals = parse_usage_file(jsonl_path) if jsonl_path.is_file() else parse_usage_file(Path('/nonexistent'))
        index.append({
            'id': stem,
            'agent_type': str(meta.get('agentType') or ''),
            'name': str(meta.get('name') or ''),
            'description': str(meta.get('description') or ''),
            'totals': totals,
        })
    return index


def match_subagent(task: dict, subagents: list[dict]):
    label = str(task.get('label') or task.get('name') or task.get('description') or '')
    description = str(task.get('description') or '')
    task_name = str(task.get('name') or '')
    candidates = [label, description, task_name]

    for subagent in subagents:
        for candidate in candidates:
            if candidate and candidate == subagent.get('description'):
                return subagent
        for candidate in candidates:
            if candidate and candidate == subagent.get('name'):
                return subagent

    lowered = [value.lower() for value in candidates if value]
    for subagent in subagents:
        description_lower = subagent.get('description', '').lower()
        name_lower = subagent.get('name', '').lower()
        for candidate in lowered:
            if candidate and (candidate in description_lower or description_lower in candidate):
                return subagent
            if candidate and name_lower and (candidate in name_lower or name_lower in candidate):
                return subagent

    return None


state = read_state(state_file)
main = state.get('main', {}) if isinstance(state, dict) else {}
last_ctx_tokens = int(main.get('last_ctx_tokens', 0) or main.get('ctx_tokens', 0) or 0)
last_used_pct = float(main.get('last_used_pct', main.get('used_pct', 0)) or 0)
last_cache_read = int(main.get('last_cache_read', 0) or 0)
last_cost = str(main.get('last_cost', '0.000000') or '0.000000')
currency = str(main.get('currency', '') or '')
effective_rate = float(main.get('effective_rate', 0) or 0)
main_model_display = str(main.get('display', main.get('model_id', '')) or '')
main_effort = str(main.get('effort', '') or '')

subagents = build_subagent_index(session_id, projects_dir)

for task in tasks:
    task_id = str(task.get('id', '') or '')
    task_type = str(task.get('type') or 'Subagent')
    task_label = str(task.get('label') or task.get('name') or task_type or 'subagent')
    token_count = int(task.get('tokenCount', 0) or 0)

    matched = match_subagent(task, subagents)
    if matched:
        label = matched.get('agent_type') or matched.get('name') or task_type or 'Subagent'
        totals = matched.get('totals', {})
        model_name = model_display(totals.get('model') or main_model_display or task_type)
        effort = main_effort
        ctx_tokens = totals.get('last_input', 0) + totals.get('last_cache_read', 0) + totals.get('last_cache_write', 0)
        used_pct = last_used_pct
        total_cache = totals.get('cache_read', 0)
        last_response_cache = totals.get('last_cache_read', 0)
        if effective_rate > 0 and token_count > 0 and currency:
            cost_seg = f"~{currency}{(token_count * effective_rate) / 1_000_000:.2f}"
        elif currency and last_cost not in {'', '0.000000'} and totals.get('messages', 0):
            est_cost = (totals.get('input', 0) + totals.get('output', 0) + totals.get('cache_read', 0)) * effective_rate / 1_000_000
            cost_seg = f"~{currency}{est_cost:.2f}"
        else:
            cost_seg = ''
    else:
        label = task_type if task_type and task_type != 'local_agent' else trim_label(task_label, columns - 55)
        model_name = model_display(main_model_display or label)
        effort = main_effort
        ctx_tokens = token_count if token_count > 0 else last_ctx_tokens
        used_pct = last_used_pct
        total_cache = last_cache_read
        last_response_cache = last_cache_read
        if effective_rate > 0 and token_count > 0 and currency:
            cost_seg = f"~{currency}{(token_count * effective_rate) / 1_000_000:.2f}"
        elif currency and last_cost not in {'', '0.000000'}:
            cost_seg = f"~{currency}{float(last_cost):.2f}"
        else:
            cost_seg = ''

    model_seg = model_name
    if effort:
        model_seg = f"{model_seg}:{effort}"
    ctx_seg = f"ctx:{fmt_tok(ctx_tokens)} ({used_pct:.1f}%)"
    cache_seg = f"cache:{fmt_tok(total_cache)} (+{fmt_tok(last_response_cache)})"
    parts = [f"[{label}] {model_seg}", sep, ctx_seg, sep, cache_seg]
    if cost_seg:
        parts.extend([sep, cost_seg])
    content = ' '.join(parts)
    print(json.dumps({'id': task_id, 'content': content}))
PY
