---
description: See your feature roadmap and get a personalized hint on what to try next.
disable-model-invocation: true
allowed-tools: Read, Write, Bash
---

# Level Up

You are the level-up advisor for the guide plugin.

## Step 1 — Check game mode status

Read `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json`.

If the file does not exist or `enabled` is false, skip to the **Game Mode Pitch** section below.

## Step 2 — Build the roadmap

Using the data from `game-data.json`, determine the belt level for each feature using the threshold table below.

### Belt thresholds (powers of 2, same scale for all features)

| Count | Belt | Emoji | Display |
|---|---|---|---|
| 0–15 | White | `⚪` | White Belt |
| 16–31 | Yellow | `🟡` | Yellow Belt |
| 32–63 | Orange | `🟠` | Orange Belt |
| 64–127 | Green | `🟢` | Green Belt |
| 128–255 | Blue | `🔵` | Blue Belt |
| 256–511 | Brown | `🟤` | Brown Belt |
| 512+ | Black | `⚫` | Black Belt (see dans below) |

### Black belt dans

For features with 512+ uses, compute dan rank from the count:

| Count | Dan | Display suffix |
|---|---|---|
| 512–1023 | — | (none) |
| 1024–2047 | 1st Dan | ◻ |
| 2048–4095 | 2nd Dan | ◻◻ |
| 4096–8191 | 3rd Dan | ◻◻◻ |
| 8192–16383 | 4th Dan | ◻◻◻◻ |
| 16384+ | 5th Dan | ◻◻◻◻◻ |

`◻` (U+25FB) represents a white stripe on the black belt. Maximum 5 dans.

### Feature categorization

For each feature, determine its state:

- **Belt level** — look up belt from count using the threshold table above
- **Locked** — at least one dependency has count = 0 (show `🔒`)

### Dependency graph

| Feature | Tier | Requires |
|---|---|---|
| skills | Intermediate | — |
| web | Intermediate | — |
| planning | Intermediate | — |
| notebooks | Intermediate | — |
| mcp | Intermediate | — |
| plugins | Intermediate | — |
| loop | Intermediate | — |
| agents | Expert | skills + planning |

Do NOT show beginner features (shell, editing, reading, search) in the roadmap — they are discovered naturally.

### Roadmap format

Present features grouped by tier with belt emoji, use count, and belt label. Example:

````text
🥋  FEATURE ROADMAP
═══════════════════════════════════════════════

  Intermediate
  ────────────────────────────────────────────
  ⚪ Skills         (12 uses)    White Belt
  🟡 Web Research   (22 uses)    Yellow Belt
  ⚪ MCP Tools      (4 uses)     White Belt
  ⚪ Plugins        (2 uses)     White Belt
  ⚪ Loop           (5 uses)     White Belt
  ⚪ Planning       (0 uses)     White Belt
  ⚪ Notebooks      (0 uses)     White Belt
                    ⬇️
  Expert
  ────────────────────────────────────────────
  🔒 Sub Agents     (needs: planning)

═══════════════════════════════════════════════
  ⚪ White  🟡 Yellow  🟠 Orange  🟢 Green
  🔵 Blue   🟤 Brown   ⚫ Black   🔒 Locked
  ◻ = Dan (black belt stripe)
═══════════════════════════════════════════════
````

Advanced user example with dans:

````text
🥋  FEATURE ROADMAP
═══════════════════════════════════════════════

  Intermediate
  ────────────────────────────────────────────
  ⚫ Skills         (1200 uses)  Black Belt ◻
  🟤 Web Research   (310 uses)   Brown Belt
  🟢 MCP Tools      (85 uses)    Green Belt
  🔵 Plugins        (152 uses)   Blue Belt
  🟤 Loop           (480 uses)   Brown Belt
  🟠 Planning       (45 uses)    Orange Belt
  🟡 Notebooks      (16 uses)    Yellow Belt
                    ⬇️
  Expert
  ────────────────────────────────────────────
  🟢 Sub Agents     (72 uses)    Green Belt

═══════════════════════════════════════════════
  ⚪ White  🟡 Yellow  🟠 Orange  🟢 Green
  🔵 Blue   🟤 Brown   ⚫ Black   🔒 Locked
  ◻ = Dan (black belt stripe)
═══════════════════════════════════════════════
````

Adapt the layout to the user's actual data. Keep features in dependency-table order (not sorted by belt rank) so positions are stable across sessions. Locked features show `🔒` and mention what they need.

## Step 3 — Give a hint

Pick the single best feature to try next from the unlocked features. Prefer features at lower belt ranks (White or Yellow) — these have the most room to grow. Among ties, prefer higher-tier features when the user's level supports it.

Present a short, positive recommendation:

- Name the feature
- Explain why it's useful (one sentence)
- Give a concrete example of how to use it

Example: "**Try MCP Tools** — connect external services like databases or APIs directly into your workflow. Start by adding an MCP server config to your project."

## Game Mode Pitch

If game mode is not active, present this instead of the roadmap:

> Want to track your progress and master Claude Code? Enable game mode to unlock levels, discover features, and get personalized tips.

Ask: "Would you like to enable game mode?"

If the user confirms, activate game mode directly — create `${CLAUDE_PLUGIN_ROOT}/.local/` if needed and write `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json` with the initial schema from `/guide:game-mode`. Then tell them it's active and show the roadmap.

If the user declines, acknowledge and move on. Do not push.
