---
description: Help pick the right Claude model and effort level for the task at hand — Opus for deep reasoning, Sonnet for daily work, Haiku for quick queries. Use when unsure which model to use or when optimizing cost vs quality.
disable-model-invocation: true
---

# Choosing Your Model

You are helping a developer pick the right Claude model for their work. Ask what they're trying to do, then recommend the best fit.

## The three models

### Claude Opus 4

The most capable model. Use for:
- Complex architecture decisions and multi-file refactors
- Deep debugging that requires understanding large codebases
- Tasks where getting it right the first time saves significant rework
- Writing nuanced technical documentation

Tradeoff: uses more context, costs more, and can be slower. Don't use Opus for quick edits or simple tasks — it's overkill.

### Claude Sonnet 4

The default and usually the right choice. Use for:
- Day-to-day coding: writing features, fixing bugs, writing tests
- Code reviews and refactoring
- Most prompt-driven workflows
- Tasks where speed and cost matter

This is what most developers should use most of the time. Start here unless you have a specific reason to use Opus.

### Claude Haiku

Fast and lightweight. Use for:
- Quick questions about syntax or APIs
- Simple text transformations
- Generating boilerplate
- Tasks where you need a fast answer, not a perfect one

Not recommended for code generation, complex reasoning, or multi-step tasks.

## How to switch models

Show them the commands:
- `/model` — interactive model picker
- `/model claude-sonnet-4-20250514` — set a specific model
- Set in `~/.claude/settings.json` for a persistent default

## Effort levels

Beyond model choice, Claude Code supports effort levels that control how much thinking the model does:

- **Low effort** — quick responses, less reasoning. Good for simple tasks.
- **Medium effort** — balanced. The default.
- **High effort** — deep reasoning, more thorough. Good for complex problems.

Set with `/config` or in settings. Higher effort + Opus = maximum capability but maximum cost.

## Decision helper

Ask what they're working on and guide them:

| Task | Recommended |
|---|---|
| Quick syntax question | Haiku |
| Writing a new feature | Sonnet (default) |
| Complex multi-file refactor | Opus or Sonnet + high effort |
| Debugging a subtle race condition | Opus |
| Writing unit tests | Sonnet |
| Architecture planning | Opus |
| Code review | Sonnet |
| Boilerplate generation | Sonnet or Haiku |

## Related skills
- `/onboarding:setup` — includes model selection in initial setup
- `/onboarding:best-practices` — context management (model choice affects context usage)
- `/onboarding:configure` — where to set model defaults
