#!/usr/bin/env bash
# Lightweight schema migration — adds missing fields, updates pluginVersion
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
DATA_FILE="${PLUGIN_ROOT}/.local/game-data.json"

# Exit if data file doesn't exist
[ -f "$DATA_FILE" ] || exit 0

# Read current plugin version from manifest
PLUGIN_VERSION="$(jq -r '.version' "${PLUGIN_ROOT}/.claude-plugin/plugin.json")"

# Check if migration is needed
CURRENT_VERSION="$(jq -r '.pluginVersion // "unknown"' "$DATA_FILE")"
[ "$CURRENT_VERSION" = "$PLUGIN_VERSION" ] && exit 0

# Define expected feature categories
EXPECTED='["shell","editing","reading","search","agents","skills","plugins","web","planning","mcp","notebooks"]'

# Add missing fields and categories, preserve all existing data
TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
jq --arg ver "$PLUGIN_VERSION" --argjson feats "$EXPECTED" '
  .pluginVersion = $ver |
  reduce ($feats[]) as $f (.;
    if .features[$f] == null then
      .features[$f] = {"count": 0, "lastUsed": null}
    else . end
  ) |
  .tokens //= {"read": 0, "write": 0, "total": 0} |
  .sessionCount //= 0 |
  .suggestedFeatures //= [] |
  .migrations //= []
' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"
