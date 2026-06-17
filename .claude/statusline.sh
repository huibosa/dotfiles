#!/usr/bin/env bash
# Claude Code custom status line

set -euo pipefail

input=$(cat)

# Parse all input fields in a single jq call (was 8 separate calls)
mapfile -t _f < <(printf '%s' "$input" | jq -r '
  .model.id // "",
  (.session_id // "default"),
  (.effort.level // ""),
  (.context_window.used_percentage // 0),
  (.context_window.current_usage.input_tokens // 0),
  (.context_window.current_usage.output_tokens // 0),
  (.context_window.current_usage.cache_read_input_tokens // 0),
  (.context_window.current_usage.cache_creation_input_tokens // 0),
  (.cwd // "")
')
model_id="${_f[0]}"
session_id="${_f[1]}"
effort="${_f[2]}"
used_pct="${_f[3]}"
curr_input="${_f[4]}"
curr_output="${_f[5]}"
cache_read="${_f[6]}"
cache_write="${_f[7]}"
cwd="${_f[8]}"
ctx_tokens=$((curr_input + cache_read + cache_write))

# Hook input puts the routed/aliased name in .model.id (e.g.
# "custom-model-a1[1m]"); the JSONL transcript records the bare base name
# (e.g. "custom-model-a1"). Strip the trailing [...] for JSONL matching.
model_base="${model_id%%\[*}"

state_file="/tmp/claude-sl-${session_id}.json"
legacy_state_file="/tmp/claude-sl-${session_id}"
claude_projects_dir="${HOME}/.claude/projects"

read_state() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  local raw
  raw=$(jq -r '
    .last_cost // "0.000000",
    (.last_ctx_tokens // 0),
    (.last_used_pct // 0),
    (.last_input // 0),
    (.last_output // 0),
    (.last_cache_read // 0),
    (.last_cache_write // 0),
    (.last_cwd // "")
  ' "$file" 2>/dev/null) || return 1
  mapfile -t _s <<< "$raw"
  [[ ${#_s[@]} -eq 8 ]] || return 1
  state_last_cost="${_s[0]}"
  state_last_ctx="${_s[1]}"
  state_last_pct="${_s[2]}"
  state_last_input="${_s[3]}"
  state_last_output="${_s[4]}"
  state_last_cache_read="${_s[5]}"
  state_last_cache_write="${_s[6]}"
  state_last_cwd="${_s[7]}"
}

write_state() {
  local file="$1"
  local content="$2"
  printf '%s\n' "$content" > "$file"
}

display="$model_id"
# Map custom model IDs to canonical Anthropic names (display only)
case "$model_base" in
  custom-model-a2) display="claude-sonnet-4-6" ;;
  custom-model-a4) display="claude-opus-4-8"   ;;
  custom-model-a6) display="claude-fable-5"    ;;
esac

warn=0
currency=""
p_in=0; p_out=0; p_cr=0; p_cw=0

case "$model_id" in
  custom-model-a1*)
    currency='$'; p_in=5;  p_out=25;  p_cr=0.50; p_cw=6.25 ;;
  custom-model-a4*)
    currency='$'; p_in=5;  p_out=25;  p_cr=0.50; p_cw=6.25 ;;
  custom-model-a3*)
    currency='$'; p_in=5;  p_out=25;  p_cr=0.50; p_cw=6.25 ;;
  custom-model-a2*)
    currency='$'; p_in=3;  p_out=15;  p_cr=0.30; p_cw=3.75 ;;
  custom-model-a6*)
    currency='$'; p_in=10; p_out=50;  p_cr=1.00; p_cw=12.50 ;;
  glm-5.1*)
    currency='$'
    total_current_input=$((curr_input + cache_read + cache_write))
    if [[ $total_current_input -le 32000 ]]; then
      p_in=0.83; p_out=3.31; p_cr=0.18; p_cw=0
    else
      p_in=1.10; p_out=3.86; p_cr=0.28; p_cw=0
    fi ;;
  glm-5.2*)
    currency='$'; p_in=1.18; p_out=4.14; p_cr=0.30; p_cw=0 ;;
  deepseek-v4-pro*)
    currency='$'; p_in=1.66; p_out=3.31; p_cr=0.14; p_cw=0 ;;
  deepseek-v4-flash*)
    currency='$'; p_in=0.14; p_out=0.55; p_cr=0; p_cw=0 ;;
  kimi-k2.6*)
    currency='$'; p_in=0.90; p_out=3.72; p_cr=0.15; p_cw=0 ;;
  *)
    warn=1 ;;
esac

state_last_cost="0.000000"
state_last_ctx=0
state_last_pct=0
state_last_input=0
state_last_output=0
state_last_cache_read=0
state_last_cache_write=0
state_last_cwd=""
if ! read_state "$state_file"; then
  rm -f "$legacy_state_file"
fi
# cwd is only populated during active tool calls; fall back to last known value.
[[ -z "$cwd" ]] && cwd="$state_last_cwd"

# Cumulative usage from JSONL (single Python invocation).
# Each turn writes one JSONL line per content block (thinking, tool_use, text)
# and every line carries the *same* message.usage object from one API
# response. Deduplicate by message.id so each API call is counted once;
# without this the summer over-counts by ~2-3x. Also filter by current model
# (multi-model sessions otherwise get foreign-model tokens re-priced at the
# current model's rates) and skip isSidechain as defence.
usage_json=$(python3 - "$session_id" "$claude_projects_dir" "$model_base" <<'PY'
import json, sys
from pathlib import Path

session_id = sys.argv[1]
projects_dir = Path(sys.argv[2])
model_base = sys.argv[3] if len(sys.argv) > 3 else ""
result = {"input": 0, "output": 0, "cache_read": 0, "cache_write": 0, "messages": 0, "found": False}
seen_ids = set()

if projects_dir.exists():
    matches = sorted(projects_dir.glob(f"**/{session_id}.jsonl"), key=lambda p: len(p.parts))
    root = matches[0] if matches else None
    if root and root.is_file():
        result["found"] = True
        with root.open() as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if obj.get("type") != "assistant":
                    continue
                if obj.get("isSidechain") or obj.get("sidechain"):
                    continue
                msg = obj.get("message")
                if not isinstance(msg, dict):
                    continue
                if model_base and msg.get("model") != model_base:
                    continue
                msg_id = msg.get("id")
                if msg_id is not None:
                    if msg_id in seen_ids:
                        continue
                    seen_ids.add(msg_id)
                usage = msg.get("usage")
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

# Parse all usage_json fields in one jq call (was 4 separate calls)
mapfile -t _u < <(printf '%s' "$usage_json" | jq -r '.found, .input, .output, .cache_read, .cache_write')
usage_found="${_u[0]}"
cumulative_in="${_u[1]}"
cumulative_out="${_u[2]}"
cumulative_cache="${_u[3]}"
cumulative_cache_write="${_u[4]}"

# Authoritative cumulative cost from hook input — same number /status shows.
# (Earlier versions of this script tried .cost.usage_by_model, but that field
# does not exist in Claude Code 2.1.x; .cost.total_cost_usd is what's there.)
# When this is set, the awk block below uses it verbatim instead of computing
# cost from per-token math.
stats_cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // ""' 2>/dev/null || true)

if [[ "$usage_found" != "true" ]]; then
  cumulative_in=0; cumulative_out=0; cumulative_cache=0; cumulative_cache_write=0
fi

# Single awk call: all token formatting + cost calculations (was ~13 separate awk calls)
mapfile -t _fmt < <(awk \
  -v warn="$warn" \
  -v ctx="$ctx_tokens"  -v ctx_s="$state_last_ctx" \
  -v pct="$used_pct"    -v pct_s="$state_last_pct" \
  -v ci="$curr_input"   -v co="$curr_output" \
  -v cr="$cache_read"   -v cw="$cache_write" \
  -v pi="$p_in" -v po="$p_out" -v pcr="$p_cr" -v pcw="$p_cw" \
  -v cum_in="$cumulative_in"    -v cum_out="$cumulative_out" \
  -v cum_cr="$cumulative_cache" -v cum_cw="$cumulative_cache_write" \
  -v sc="$stats_cost" \
  -v st_in="$state_last_input"  -v st_out="$state_last_output" \
  -v st_cr="$state_last_cache_read" -v st_cw="$state_last_cache_write" \
'function fmt(n) {
    if (n >= 1000000) return sprintf("%.1fM", n/1000000)
    if (n >= 1000)    return sprintf("%.1fk", n/1000)
    if (n == 0)       return "0k"
    return sprintf("%d", n)
}
BEGIN {
    ctx_v = (ctx+0 == 0 && ctx_s+0 > 0) ? ctx_s+0 : ctx+0
    pct_v = (ctx+0 == 0 && ctx_s+0 > 0) ? pct_s+0 : pct+0
    in_l  = (ci+0 == 0 && st_in+0  > 0) ? st_in+0  : ci+0
    out_l = (co+0 == 0 && st_out+0 > 0) ? st_out+0 : co+0
    cr_l  = (cr+0 == 0 && st_cr+0  > 0) ? st_cr+0  : cr+0
    cw_l  = (cw+0 == 0 && st_cw+0  > 0) ? st_cw+0  : cw+0
    # Cumulative cost (cc) prefers hook-input authoritative value (sc); falls
    # back to per-token math only when sc is absent and pricing is known.
    # Last-turn cost (lc) is per-token math when pricing is known; zero for
    # unknown models since the hook input has no per-turn cost.
    if (warn+0) {
        lc = "0.000000"
        cc = (sc != "" && sc != "null") ? sprintf("%.6f", sc+0) : "0.000000"
    } else {
        lc = sprintf("%.6f", (ci*pi + co*po + cr*pcr + cw*pcw) / 1000000)
        cc = (sc != "" && sc != "null") \
            ? sprintf("%.6f", sc+0) \
            : sprintf("%.6f", (cum_in*pi + cum_out*po + cum_cr*pcr + cum_cw*pcw) / 1000000)
    }
    cc2 = sprintf("%.2f", cc+0)
    printf "%s\n%.1f%%\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
        fmt(ctx_v), pct_v, lc, cc,
        fmt(cum_in+0), fmt(cum_out+0),
        fmt(in_l), fmt(out_l),
        fmt(cum_cr+0), fmt(cr_l),
        fmt(cum_cw+0), fmt(cw_l),
        cc2
}')
ctx_fmt="${_fmt[0]}"
ctx_pct="${_fmt[1]}"
last_cost="${_fmt[2]}"
cumulative_cost="${_fmt[3]}"
in_fmt="${_fmt[4]}"
out_fmt="${_fmt[5]}"
in_last_fmt="${_fmt[6]}"
out_last_fmt="${_fmt[7]}"
cache_read_cum_fmt="${_fmt[8]}"
cache_read_last_fmt="${_fmt[9]}"
cache_write_cum_fmt="${_fmt[10]}"
cache_write_last_fmt="${_fmt[11]}"
cost_display="${_fmt[12]}"

# Write state — pure printf, no jq spawn (was jq -n)
printf '{"last_cost":"%s","last_ctx_tokens":%s,"last_used_pct":%s,"last_input":%s,"last_output":%s,"last_cache_read":%s,"last_cache_write":%s,"last_cwd":"%s"}\n' \
    "$last_cost" "$ctx_tokens" "$used_pct" "$curr_input" "$curr_output" "$cache_read" "$cache_write" "$cwd" > "$state_file"

[[ -n "$effort" ]] && model_seg="${display}"$'\033[30m:\033[0m'"${effort}" || model_seg="${display}"
ctx_seg=$'\033[33m'"${ctx_fmt}(${ctx_pct})"$'\033[0m'

if [[ $warn -eq 1 ]]; then
  if [[ -n "$stats_cost" && "$stats_cost" != "null" ]]; then
    cost_fmt="[! unknown: ${model_id}] \$${cost_display}"
  else
    cost_fmt="[! unknown: ${model_id}]"
  fi
else
  cost_fmt="${currency}${cost_display}"
fi

sep=$'\033[30m•\033[0m'
sl=$'\033[30m/\033[0m'
io_seg="↑${in_fmt}(+${in_last_fmt})${sl}↓${out_fmt}(+${out_last_fmt})"
cache_seg="R${cache_read_cum_fmt}(+${cache_read_last_fmt})${sl}W${cache_write_cum_fmt}(+${cache_write_last_fmt})"

# Git line-change stats: lines added/removed vs HEAD in the session's cwd.
diff_seg=""
if [[ -n "$cwd" ]] && git -C "$cwd" rev-parse --git-dir &>/dev/null; then
  diff_stats=$(git -C "$cwd" diff HEAD --numstat 2>/dev/null \
    | awk '$1 ~ /^[0-9]+$/ {a+=$1; d+=$2} END {if(a+d>0) printf "\033[32m+%d\033[30m/\033[31m-%d\033[0m", a, d}')
  [[ -n "$diff_stats" ]] && diff_seg="$diff_stats"
fi

out_line="$model_seg $sep $ctx_seg $sep $io_seg $sep $cache_seg"
[[ -n "$diff_seg" ]] && out_line="$out_line $sep $diff_seg"
out_line="$out_line $sep $cost_fmt"
printf "%s" "$out_line"
