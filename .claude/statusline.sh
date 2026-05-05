#!/usr/bin/env bash
# Claude Code custom status line

input=$(cat)

# Parse fields
model_id=$(echo "$input"   | jq -r '.model.id // ""')
session_id=$(echo "$input" | jq -r '.session_id // "default"')
effort=$(echo "$input"     | jq -r '.effort.level // ""')
total_out=$(echo "$input"  | jq -r '.context_window.total_output_tokens // 0')
total_in=$(echo "$input"   | jq -r '.context_window.total_input_tokens // 0')
used_pct=$(echo "$input"   | jq -r '.context_window.used_percentage // 0')
curr_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
curr_output=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
cache_read=$(echo "$input"  | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

# Format token count as integer, k, or M
fmt_tok() {
  awk -v n="$1" 'BEGIN{
    if (n >= 1000000) printf "%.1fM", n/1000000
    else if (n >= 1000) printf "%.1fk", n/1000
    else if (n == 0) printf "0k"
    else printf "%d", n
  }'
}

# Map custom model IDs to friendly names
case "$model_id" in
  custom-model-a1*) display="Opus" ;;
  custom-model-a2*) display="Sonnet" ;;
  glm-5.1*)         display="GLM-5.1" ;;
  deepseek-v4-pro*) display="DeepSeek-v4-pro" ;;
  *) display="$model_id" ;;
esac

# ---- Per-model pricing (per million tokens) ----
# Opus/Sonnet: USD; GLM-5.1/DeepSeek: CNY
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
    # Tiered by total input length (input + cache_read + cache_write)
    total_input=$((curr_input + cache_read + cache_write))
    if [[ $total_input -le 32000 ]]; then
      p_in=6;  p_out=24; p_cr=1.3; p_cw=0
    else
      p_in=8;  p_out=28; p_cr=2;   p_cw=0
    fi ;;
  deepseek-v4-pro*)
    currency='¥'; p_in=12; p_out=24; p_cr=1;    p_cw=0 ;;
  *)
    warn=1 ;;
esac

# ---- Last-call cost (derived each invocation) ----
if [[ $warn -eq 0 ]]; then
  last_cost=$(awk -v ci="$curr_input" -v co="$curr_output" \
                 -v cr="$cache_read"  -v cw="$cache_write" \
                 -v pi="$p_in" -v po="$p_out" -v pcr="$p_cr" -v pcw="$p_cw" \
    'BEGIN{printf "%.6f", (ci*pi + co*po + cr*pcr + cw*pcw) / 1000000}')
else
  last_cost="0.000000"
fi

# ---- Cumulative tracking (state file per session) ----
# State layout: <prev_total_out> <cum_in> <cum_out> <cum_cache> <cum_cost>
state_file="/tmp/claude-sl-${session_id}"
prev_total_out=0
cumulative_in=0
cumulative_out=0
cumulative_cache=0
cumulative_cost="0.000000"

if [[ -f "$state_file" ]]; then
  # Reject state files that don't match the 5-field layout (e.g. older 3-field format)
  read -ra fields < "$state_file" 2>/dev/null
  if [[ ${#fields[@]} -eq 5 ]]; then
    prev_total_out=${fields[0]}
    cumulative_in=${fields[1]}
    cumulative_out=${fields[2]}
    cumulative_cache=${fields[3]}
    cumulative_cost=${fields[4]}
  fi
fi

if [[ $total_out -gt $prev_total_out ]]; then
  cumulative_in=$((cumulative_in + curr_input))
  cumulative_out=$((cumulative_out + curr_output))
  cumulative_cache=$((cumulative_cache + cache_read))
  cumulative_cost=$(awk -v a="$cumulative_cost" -v b="$last_cost" \
    'BEGIN{printf "%.6f", a+b}')

  printf '%s %s %s %s %s\n' \
    "$total_out" "$cumulative_in" "$cumulative_out" \
    "$cumulative_cache" "$cumulative_cost" > "$state_file"
fi

# ---- Model:effort segment ----
[[ -n "$effort" ]] && model_seg="${display}:${effort}" || model_seg="${display}"

# ---- Context segment: <ctx> (<ctx%>) ----
ctx_tokens=$(echo "$input" | jq -r '
  if .context_window.current_usage then
    (.context_window.current_usage.input_tokens // 0) +
    (.context_window.current_usage.cache_creation_input_tokens // 0) +
    (.context_window.current_usage.cache_read_input_tokens // 0)
  else 0 end')

ctx_fmt=$(fmt_tok "$ctx_tokens")
ctx_pct=$(awk -v p="$used_pct" 'BEGIN{printf "%.1f%%", p}')
ctx_seg="${ctx_fmt} (${ctx_pct})"

# ---- Metrics segments ----
in_fmt=$(fmt_tok "$cumulative_in")
out_fmt=$(fmt_tok "$cumulative_out")
cache_cum_fmt=$(fmt_tok "$cumulative_cache")
cache_last_fmt=$(fmt_tok "$cache_read")

if [[ $warn -eq 1 ]]; then
  cost_fmt="[! unknown: ${model_id}]"
else
  cost_fmt="${currency}$(awk -v c="$cumulative_cost" 'BEGIN{printf "%.2f", c}')"
fi

io_seg="in:${in_fmt} out:${out_fmt}"
cache_seg="cache:${cache_cum_fmt} (+${cache_last_fmt})"

sep=$'\033[30m•\033[0m'
printf "%s %s %s %s %s %s %s %s %s" "$model_seg" "$sep" "$ctx_seg" "$sep" "$io_seg" "$sep" "$cache_seg" "$sep" "$cost_fmt"
