#!/usr/bin/env bash
# Claude Code custom status line

set -euo pipefail

input=$(cat)

model_id=$(printf '%s' "$input" | jq -r '.model.id // ""')
session_id=$(printf '%s' "$input" | jq -r '.session_id // "default"')
effort=$(printf '%s' "$input" | jq -r '.effort.level // ""')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0')
curr_input=$(printf '%s' "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
curr_output=$(printf '%s' "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
cache_read=$(printf '%s' "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_write=$(printf '%s' "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
ctx_tokens=$((curr_input + cache_read + cache_write))

state_file="/tmp/claude-sl-${session_id}.json"
legacy_state_file="/tmp/claude-sl-${session_id}"
claude_projects_dir="${HOME}/.claude/projects"

fmt_tok() {
  awk -v n="$1" 'BEGIN{
    if (n >= 1000000) printf "%.1fM", n/1000000
    else if (n >= 1000) printf "%.1fk", n/1000
    else if (n == 0) printf "0k"
    else printf "%d", n
  }'
}

sum_session_usage() {
  local sid="$1"
  local projects_dir="$2"
  local filter_model="${3:-}"

  python3 - "$sid" "$projects_dir" "$filter_model" <<'PY'
import json
import sys
from pathlib import Path

session_id = sys.argv[1]
projects_dir = Path(sys.argv[2])
filter_model = sys.argv[3] or None
result = {
    "input": 0,
    "output": 0,
    "cache_read": 0,
    "cache_write": 0,
    "messages": 0,
    "found": False,
}


def accumulate_usage(file_path: Path) -> None:
    with file_path.open() as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            if obj.get("type") != "assistant":
                continue
            message = obj.get("message", {})
            if filter_model and message.get("model") != filter_model:
                continue
            usage = message.get("usage")
            if not isinstance(usage, dict):
                continue
            result["messages"] += 1
            result["input"] += int(usage.get("input_tokens", 0) or 0)
            result["output"] += int(usage.get("output_tokens", 0) or 0)
            result["cache_read"] += int(usage.get("cache_read_input_tokens", 0) or 0)
            result["cache_write"] += int(usage.get("cache_creation_input_tokens", 0) or 0)


if projects_dir.exists():
    pattern = f"**/{session_id}.jsonl"
    matches = sorted(projects_dir.glob(pattern), key=lambda p: len(p.parts))
    root = matches[0] if matches else None
    if root and root.is_file():
        result["found"] = True
        accumulate_usage(root)
        subagent_dir = root.with_suffix("") / "subagents"
        if subagent_dir.is_dir():
            for subagent_file in sorted(subagent_dir.glob("*.jsonl")):
                accumulate_usage(subagent_file)

print(json.dumps(result))
PY
}

read_state() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return 1
  fi

  local data
  data=$(python3 - "$file" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
except Exception:
    sys.exit(1)

print(json.dumps(data))
PY
) || return 1

  state_last_cost=$(printf '%s' "$data" | jq -r '.last_cost // "0.000000"')
  state_last_ctx=$(printf '%s' "$data" | jq -r '.last_ctx_tokens // 0')
  state_last_pct=$(printf '%s' "$data" | jq -r '.last_used_pct // 0')
  state_last_input=$(printf '%s' "$data" | jq -r '.last_input // 0')
  state_last_output=$(printf '%s' "$data" | jq -r '.last_output // 0')
  state_last_cache_read=$(printf '%s' "$data" | jq -r '.last_cache_read // 0')
  state_last_cache_write=$(printf '%s' "$data" | jq -r '.last_cache_write // 0')
  return 0
}

write_state() {
  local file="$1"
  local content="$2"
  printf '%s\n' "$content" > "$file"
}

case "$model_id" in
  custom-model-a1*) display="Opus" ;;
  custom-model-a2*) display="Sonnet" ;;
  glm-5.1*)         display="GLM-5.1" ;;
  deepseek-v4-pro*) display="DeepSeek-v4-pro" ;;
  deepseek-v4-flash*) display="deepseek-v4-flash" ;;
  *) display="$model_id" ;;
esac

warn=0
currency=""
p_in=0; p_out=0; p_cr=0; p_cw=0

case "$model_id" in
  custom-model-a1*)
    currency='$'; p_in=5;  p_out=25;  p_cr=0.50; p_cw=6.25 ;;
  custom-model-a2*)
    currency='$'; p_in=3;  p_out=15;  p_cr=0.30; p_cw=3.75 ;;
  glm-5.1*)
    currency='¥'
    total_current_input=$((curr_input + cache_read + cache_write))
    if [[ $total_current_input -le 32000 ]]; then
      p_in=6;  p_out=24; p_cr=1.3; p_cw=0
    else
      p_in=8;  p_out=28; p_cr=2;   p_cw=0
    fi ;;
  deepseek-v4-pro*)
    currency='¥'; p_in=12; p_out=24; p_cr=1;    p_cw=0 ;;
  deepseek-v4-flash*)
    currency='¥'; p_in=1; p_out=4; p_cr=0; p_cw=0 ;;
  *)
    warn=1 ;;
esac

if [[ $warn -eq 0 ]]; then
  last_cost=$(awk -v ci="$curr_input" -v co="$curr_output" \
                 -v cr="$cache_read"  -v cw="$cache_write" \
                 -v pi="$p_in" -v po="$p_out" -v pcr="$p_cr" -v pcw="$p_cw" \
    'BEGIN{printf "%.6f", (ci*pi + co*po + cr*pcr + cw*pcw) / 1000000}')
else
  last_cost="0.000000"
fi

state_last_cost="0.000000"
state_last_ctx=0
state_last_pct=0
state_last_input=0
state_last_output=0
state_last_cache_read=0
state_last_cache_write=0
if ! read_state "$state_file"; then
  rm -f "$legacy_state_file"
fi

usage_json=$(python3 - "$session_id" "$claude_projects_dir" <<'PY'
import json
import sys
from pathlib import Path

session_id = sys.argv[1]
projects_dir = Path(sys.argv[2])
result = {
    "input": 0,
    "output": 0,
    "cache_read": 0,
    "cache_write": 0,
    "messages": 0,
    "found": False,
}

if projects_dir.exists():
    pattern = f"**/{session_id}.jsonl"
    matches = sorted(projects_dir.glob(pattern), key=lambda p: len(p.parts))
    root = matches[0] if matches else None
    if root and root.is_file():
        result["found"] = True
        with root.open() as handle:
            for raw_line in handle:
                line = raw_line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if obj.get("type") != "assistant":
                    continue
                usage = obj.get("message", {}).get("usage")
                if not isinstance(usage, dict):
                    continue
                result["messages"] += 1
                result["input"] += int(usage.get("input_tokens", 0) or 0)
                result["output"] += int(usage.get("output_tokens", 0) or 0)
                result["cache_read"] += int(usage.get("cache_read_input_tokens", 0) or 0)
                result["cache_write"] += int(usage.get("cache_creation_input_tokens", 0) or 0)

print(json.dumps(result))
PY
)
usage_found=$(printf '%s' "$usage_json" | jq -r '.found')
cumulative_in=$(printf '%s' "$usage_json" | jq -r '.input')
cumulative_out=$(printf '%s' "$usage_json" | jq -r '.output')
cumulative_cache=$(printf '%s' "$usage_json" | jq -r '.cache_read')
cumulative_cache_write=$(printf '%s' "$usage_json" | jq -r '.cache_write')

stats_panel_json=$(printf '%s' "$input" | jq -c '.cost.usage_by_model[]? | select(.model_id == $model_id)' --arg model_id "$model_id" 2>/dev/null || true)
if [[ -n "$stats_panel_json" ]]; then
  cumulative_in=$(printf '%s' "$stats_panel_json" | jq -r '.input_tokens // 0')
  cumulative_out=$(printf '%s' "$stats_panel_json" | jq -r '.output_tokens // 0')
  cumulative_cache=$(printf '%s' "$stats_panel_json" | jq -r '.cache_read_input_tokens // 0')
  cumulative_cache_write=$(printf '%s' "$stats_panel_json" | jq -r '.cache_creation_input_tokens // 0')
  if [[ $warn -eq 0 ]]; then
    cumulative_cost=$(printf '%s' "$stats_panel_json" | jq -r '.total_cost_usd // .cost_usd // empty')
    if [[ -z "$cumulative_cost" || "$cumulative_cost" == "null" ]]; then
      cumulative_cost=$(awk -v ci="$cumulative_in" -v co="$cumulative_out" \
                            -v cr="$cumulative_cache" -v cw="$cumulative_cache_write" \
                            -v pi="$p_in" -v po="$p_out" -v pcr="$p_cr" -v pcw="$p_cw" \
        'BEGIN{printf "%.6f", (ci*pi + co*po + cr*pcr + cw*pcw) / 1000000}')
    fi
  else
    cumulative_cost="0.000000"
  fi
else
  if [[ $warn -eq 0 ]]; then
    cumulative_cost=$(awk -v ci="$cumulative_in" -v co="$cumulative_out" \
                          -v cr="$cumulative_cache" -v cw="$cumulative_cache_write" \
                          -v pi="$p_in" -v po="$p_out" -v pcr="$p_cr" -v pcw="$p_cw" \
      'BEGIN{printf "%.6f", (ci*pi + co*po + cr*pcr + cw*pcw) / 1000000}')
  else
    cumulative_cost="0.000000"
  fi
fi

if [[ "$usage_found" != "true" && -z "$stats_panel_json" ]]; then
  cumulative_in=0
  cumulative_out=0
  cumulative_cache=0
  cumulative_cost="0.000000"
fi

state_payload=$(jq -n \
  --arg last_cost "$last_cost" \
  --argjson last_ctx_tokens "$ctx_tokens" \
  --argjson last_used_pct "$used_pct" \
  --argjson last_input "$curr_input" \
  --argjson last_output "$curr_output" \
  --argjson last_cache_read "$cache_read" \
  --argjson last_cache_write "$cache_write" \
  '{last_cost:$last_cost,last_ctx_tokens:$last_ctx_tokens,last_used_pct:$last_used_pct,last_input:$last_input,last_output:$last_output,last_cache_read:$last_cache_read,last_cache_write:$last_cache_write}')
write_state "$state_file" "$state_payload"

[[ -n "$effort" ]] && model_seg="${display}:${effort}" || model_seg="${display}"

ctx_fmt=$(fmt_tok "$ctx_tokens")
ctx_pct=$(awk -v p="$used_pct" 'BEGIN{printf "%.1f%%", p}')
if [[ $ctx_tokens -eq 0 ]] && [[ $state_last_ctx -gt 0 ]]; then
  ctx_fmt=$(fmt_tok "$state_last_ctx")
  ctx_pct=$(awk -v p="$state_last_pct" 'BEGIN{printf "%.1f%%", p}')
fi
ctx_seg="${ctx_fmt} (${ctx_pct})"

in_fmt=$(fmt_tok "$cumulative_in")
out_fmt=$(fmt_tok "$cumulative_out")
in_last_value=$curr_input
out_last_value=$curr_output
cache_last_value=$cache_read

if [[ $in_last_value -eq 0 ]] && [[ $state_last_input -gt 0 ]]; then
  in_last_value=$state_last_input
fi
if [[ $out_last_value -eq 0 ]] && [[ $state_last_output -gt 0 ]]; then
  out_last_value=$state_last_output
fi
if [[ $cache_last_value -eq 0 ]] && [[ $state_last_cache_read -gt 0 ]]; then
  cache_last_value=$state_last_cache_read
fi

in_last_fmt=$(fmt_tok "$in_last_value")
out_last_fmt=$(fmt_tok "$out_last_value")
cache_cum_fmt=$(fmt_tok "$cumulative_cache")
cache_last_fmt=$(fmt_tok "$cache_last_value")

if [[ $warn -eq 1 ]]; then
  cost_fmt="[! unknown: ${model_id}]"
else
  cost_fmt="${currency}$(awk -v c="$cumulative_cost" 'BEGIN{printf "%.2f", c}')"
fi

sep=$'\033[30m•\033[0m'
io_seg="in:${in_fmt} (+${in_last_fmt}) ${sep} out:${out_fmt} (+${out_last_fmt})"
cache_seg="cache:${cache_cum_fmt} (+${cache_last_fmt})"

printf "%s %s %s %s %s %s %s %s %s" "$model_seg" "$sep" "$ctx_seg" "$sep" "$io_seg" "$sep" "$cache_seg" "$sep" "$cost_fmt"
