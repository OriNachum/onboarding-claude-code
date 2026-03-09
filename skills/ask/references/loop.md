---
title: "Loop"
parent: "Automation"
nav_order: 4
permalink: /loop/
---

# Loop

> **Level: 🌿 Intermediate**

[← Back to Automating Your Workflows](automating-your-workflows.md)

`/loop` is a built-in scheduling primitive that runs a prompt or slash command on a recurring interval. It's not a fourth automation mechanism — it's a convenience layer that complements hooks, skills, and sub agents by adding time-based repetition.

---

## When to Use /loop

Use `/loop` when you need something to happen repeatedly while you work:

- **Polling** — check deployment status, CI pipeline progress, or service health every few minutes
- **Monitoring** — watch for file changes, log errors, or resource usage over time
- **Periodic digests** — summarize activity, generate reports, or compile updates at regular intervals
- **Recurring skill runs** — invoke a skill on a schedule (e.g., `/loop 30m /review` to periodically review uncommitted changes)

If you need something to run *once in response to an event*, use [Hooks](hooks.md). If you need something to run *on demand*, use [Skills](skills.md). If you need *delegation*, use [Sub Agents](sub-agents.md). `/loop` is specifically for *"do this repeatedly on a timer."*

---

## Syntax

```text
/loop [interval] [command or prompt]
```

- **interval** — how often to repeat (e.g., `5m`, `30m`, `1h`, `24h`). Defaults to `10m` if omitted.
- **command or prompt** — any slash command (like `/review`) or a natural-language prompt.

Examples:

```text
/loop 5m check if the deploy succeeded
/loop 30m /review
/loop 1h summarize new errors in the logs
/loop 24h /morning-digest
/loop                          # runs the default (10m) with the next prompt you type
```

The first run executes immediately, then repeats at the specified interval.

---

## Warnings

> **Read this section before using /loop in any long-running scenario.**

`/loop` is powerful but easy to forget about. Each iteration consumes tokens and costs money — a loop you forget about can silently drain your usage quota.

**Token cost is cumulative.** A loop running every 10 minutes for 8 hours is 48 iterations. If each iteration uses 1,000 tokens, that's 48,000 tokens you may not have intended to spend.

**Write-capable loops are dangerous if forgotten.** A loop that modifies files, commits code, or posts messages will keep doing so unattended. Always be deliberate about what actions a loop performs.

**Always pair long-running loops with awareness.** Set up notifications (Slack, Discord, terminal alerts) so you know a loop is still active. Consider adding a `/loop 1w` that reminds you of all running automations via a webhook.

**Context accumulates.** Each iteration adds to the conversation context. Long-running loops will eventually trigger compaction or hit context limits. For loops that run longer than a few hours, keep the per-iteration output minimal.

**Best practice: audit your loops.** Periodically run `/tasks` to see what's active. Set up a weekly reminder loop that lists all running automations:

```text
/loop 1w list all my active /loop automations and send a summary to Discord
```

---

## How It Works

1. **First run** — the command or prompt executes immediately when you start the loop.
2. **Wait** — Claude waits for the specified interval.
3. **Repeat** — the command runs again. Results accumulate in your conversation context.
4. **Stop** — use `/tasks` to view and stop active loops, or end the session.

Each iteration runs in the same conversation, so Claude has full context of previous iterations. This is useful for trend detection ("the error count has been increasing over the last three checks") but means context grows over time.

---

## Examples

### Deploy Monitoring

Watch a deployment roll out and notify you when it's done:

```text
/loop 2m check the deploy status with 'kubectl rollout status deployment/api' and notify me when it completes or fails
```

### CI Pipeline Watching

Poll a GitHub Actions run until it finishes:

```text
/loop 3m check if the CI run on the current branch passed. If it did, stop looping and summarize the results.
```

### Running a Skill on Schedule

Combine `/loop` with any skill for recurring execution:

```text
/loop 1h /review
/loop 30m /security-review
```

### Daily Digests

Set up a morning briefing that runs once per day:

```text
/loop 24h summarize the team's commits from the last 24 hours and post to #dev-updates via webhook
```

---

## /loop as a Lightweight Alternative to GitHub Actions

If you have an always-on dev machine (or a long-running terminal session), `/loop` can serve as a lightweight alternative to GitHub Actions cron jobs — especially during the experimentation phase.

| Aspect | /loop | GitHub Actions cron |
|---|---|---|
| **Setup time** | Seconds — just type the command | Minutes to hours — write YAML, configure secrets, push |
| **Reliability** | Depends on your session staying alive | Runs on GitHub's infrastructure, survives reboots |
| **Cost model** | Claude tokens per iteration | GitHub Actions minutes |
| **Best for** | Prototyping, personal automation, interactive tasks | Production workflows, team-wide automation, compliance |
| **Visibility** | Only you see it (unless you add notifications) | Team-visible in Actions tab, with logs and badges |

**The graduation path:** Start with `/loop` to prove a pattern works. Once you're confident in the prompt and the cadence, migrate it to a [GitHub Actions workflow](github-actions.md) for production reliability. Keep `/loop` for personal, interactive, or experimental automations.

---

## Practical Tips

### Context Management

- Keep per-iteration output concise to slow context growth.
- For long-running loops, instruct Claude to summarize rather than dump raw output.
- Consider using `/compact` between manual interactions if a loop has been running for hours.

### Combining with Other Mechanisms

`/loop` layers naturally on top of the three automation mechanisms:

- **Loop + Skill** — run a skill repeatedly: `/loop 1h /deploy-check`
- **Loop + Hooks** — hooks still fire on every tool use within each loop iteration, so your guardrails and validation remain active
- **Loop + Sub Agents** — each iteration can spawn sub agents for parallel work
- **Loop + Webhooks** — send results to Slack, Discord, or any HTTP endpoint for visibility

### When NOT to Use /loop

- **Event-driven tasks** — if you need to react to a specific event (file save, tool use, PR comment), use [Hooks](hooks.md) instead. Polling is wasteful when events are available.
- **Production automation** — for anything the team depends on, use [GitHub Actions](github-actions.md). `/loop` dies when your session ends.
- **High-frequency intervals** — loops under 1 minute are rarely useful and burn tokens quickly.
- **Tasks requiring fresh context** — if each run should be independent with no memory of previous runs, a loop isn't ideal since context accumulates. Use a cron job or GitHub Action instead.

---

## /loop vs Other Approaches

| Need | Best approach |
|---|---|
| Run something every N minutes while I work | `/loop` |
| React to a tool call or lifecycle event | [Hooks](hooks.md) |
| Run a reusable prompt on demand | [Skills](skills.md) |
| Delegate a one-off task to a specialist | [Sub Agents](sub-agents.md) |
| Run automation reliably in CI on a schedule | [GitHub Actions](github-actions.md) |
| Coordinate multiple agents on a shared task | [Agent Teams](team-mode.md) |
| Prototype a recurring workflow before CI | `/loop` → then graduate to GitHub Actions |

---

## Next Steps

- [Skills](skills.md) — create reusable skills that `/loop` can invoke on a schedule
- [Built-ins](built-ins.md) — see all built-in commands, including `/tasks` for managing active loops
- [Automating Your Workflows](automating-your-workflows.md) — understand how `/loop` fits with hooks, skills, and sub agents
- [GitHub Actions](github-actions.md) — graduate proven `/loop` patterns to production CI
