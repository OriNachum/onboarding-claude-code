---
description: Guide to ongoing Claude Code configuration — CLAUDE.md refinement, settings layers, building your agent's personality over time. Use when a developer wants to improve how Claude works in their project.
---

# Configuring Your Claude

You are helping a developer refine their Claude Code configuration. This isn't initial setup — it's the ongoing process of teaching Claude how to work well in their specific project.

## Start with what's frustrating

Ask the developer: "What does Claude keep getting wrong, or what do you keep repeating?" Their answer reveals what belongs in configuration.

Common answers and where to configure them:
- "It uses the wrong coding style" → **CLAUDE.md** conventions section
- "It doesn't know our test commands" → **CLAUDE.md** commands section
- "It always asks about things it should know" → **CLAUDE.md** project context
- "I want it to auto-lint after edits" → **Hook** (PostToolUse)
- "I want a reusable review checklist" → **Skill** (`.claude/skills/review/`)
- "I want it to be more/less autonomous" → **Permission settings**

## CLAUDE.md — the most important config file

CLAUDE.md is read at the start of every session. Help them audit and improve theirs.

A strong CLAUDE.md includes:
1. **Project overview** — what the project does, in one paragraph
2. **Tech stack** — language, framework, key libraries
3. **Key commands** — how to build, test, lint, deploy
4. **Coding conventions** — naming, file organization, patterns to use/avoid
5. **Project-specific rules** — "Never modify the auth module directly", "Always add tests for new endpoints"

Help them review their current CLAUDE.md (or create one if missing) and add anything that would reduce repeated corrections.

## The three settings layers

Explain where different settings belong:

**`~/.claude/settings.json`** — global, applies to all projects. Good for personal preferences like model, theme, permissions you always want.

**`.claude/settings.json`** — project-level, committed to git. Good for team-wide settings like hooks, marketplace configs, shared permissions.

**`.claude/settings.local.json`** — project-level, NOT committed (add to .gitignore). Good for personal project overrides.

## Building agent personality over time

Configuration is a feedback loop:
1. Work a session
2. Notice what Claude gets wrong or what you repeat
3. Add it to CLAUDE.md or settings
4. Next session starts better

Encourage them to treat CLAUDE.md like code — version it, review changes, iterate.

## Related skills
- `/onboarding-claude-code:setup` — initial environment setup
- `/onboarding-claude-code:automate` — hooks, skills, and sub agents for automation
- `/onboarding-claude-code:best-practices` — effective working patterns
