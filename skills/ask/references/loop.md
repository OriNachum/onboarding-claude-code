---
title: "Loop"
parent: "Automation"
nav_order: 4
permalink: /loop/
---

# Loop

> **Level: 🌿 Intermediate**

[← Back to Automating Your Workflows](automating-your-workflows.md)

`/loop` is a session-scoped scheduling primitive that runs a prompt or slash command on a recurring interval. It's not a fourth automation mechanism — it's a convenience layer that complements hooks, skills, and sub agents by adding time-based repetition within your current working session.

For the official reference, see [Run prompts on a schedule](https://code.claude.com/docs/en/scheduled-tasks).

---

## When to Use /loop

Use `/loop` when you need something to happen repeatedly during your current session:

- **Polling** — check deployment status, CI pipeline progress, or service health every few minutes
- **Monitoring** — watch for file changes, log errors, or resource usage while you work
- **Periodic checks** — run a review skill or summarize recent changes at regular intervals
- **Recurring skill runs** — invoke a skill on a schedule (e.g., `/loop 30m /review` to periodically review uncommitted changes)

If you need something to run *once in response to an event*, use [Hooks](hooks.md). If you need something to run *on demand*, use [Skills](skills.md). If you need *delegation*, use [Sub Agents](sub-agents.md). `/loop` is specifically for *"do this repeatedly on a timer while I work."*

---

## Syntax

```text
/loop [interval] [command or prompt]
```

- **interval** — how often to repeat (e.g., `5m`, `15m`, `30m`, `1h`). Defaults to `10m` if omitted. Supported units: `s`, `m`, `h`, `d`.
- **command or prompt** — any slash command (like `/review`) or a natural-language prompt.

Examples:

```text
/loop 5m check if the deploy succeeded
/loop 15m /review
/loop 30m summarize new errors in the logs
/loop 1h check test results and flag any regressions
/loop                          # runs the default (10m) with the next prompt you type
```

The first run executes immediately, then repeats at the specified interval.

---

## How It Works

1. **First run** — the command or prompt executes immediately when you start the loop.
2. **Wait** — Claude waits for the specified interval.
3. **Repeat** — the command runs again. Results accumulate in your conversation context.
4. **Stop** — use `/tasks` to view and stop active loops, or end the session.

Each iteration runs in the same conversation, so Claude has full context of previous iterations. This is useful for trend detection ("the error count has been increasing over the last three checks") but means context grows over time.

---

## Limitations

> **Read this before using /loop.** These are hard constraints of the scheduling system.

| Constraint | Detail |
|---|---|
| **Session-scoped** | Tasks die when your terminal closes, the session exits, or the machine restarts. There is no persistence across sessions. |
| **3-day auto-expiry** | Recurring tasks automatically expire 3 days after creation — the task fires one final time, then self-deletes. |
| **50 task limit** | Maximum 50 scheduled tasks per session. |
| **Fires only when idle** | If Claude is busy when the interval elapses, the task waits. There is no catch-up for missed intervals — it fires once when Claude becomes idle. |
| **Minute granularity** | The scheduler is cron-based; intervals under 1 minute are rounded up to the nearest minute. |
| **Jitter** | Up to 10% of the period (capped at 15 minutes) is added to fire times to prevent thundering-herd effects. |
| **Disable flag** | Set `CLAUDE_CODE_DISABLE_CRON=1` to disable the scheduler entirely. |

**What this means in practice:**

- The `d` unit exists but is impractical — `/loop 1d` fires roughly 3 times before auto-expiry.
- Anything longer than a few hours is unreliable. Best practice: intervals from minutes to a few hours within a single working session.
- For persistent, cross-session scheduling, use [Desktop scheduled tasks](#desktop-scheduled-tasks) or [GitHub Actions](github-actions.md).

Source: [Run prompts on a schedule](https://code.claude.com/docs/en/scheduled-tasks)

---

## Warnings

> **Read this section before using /loop in any long-running scenario.**

`/loop` is powerful but easy to forget about. Each iteration consumes tokens and costs money — a loop you forget about can silently drain your usage quota.

**Token cost is cumulative.** A loop running every 10 minutes for 4 hours is 24 iterations. If each iteration uses 1,000 tokens, that's 24,000 tokens you may not have intended to spend.

**Write-capable loops are dangerous if forgotten.** A loop that modifies files, commits code, or posts messages will keep doing so unattended. Always be deliberate about what actions a loop performs.

**Context accumulates.** Each iteration adds to the conversation context. Long-running loops will eventually trigger compaction or hit context limits. Keep per-iteration output minimal.

**Best practice: check `/tasks` regularly.** Run `/tasks` to see what's active. This is the simplest way to stay aware of running loops and stop any you've forgotten about.

**One-time reminders help too.** You can set natural-language reminders like `remind me in 2 hours to check if the migration completed` — these fire once and don't recur, making them a good complement to loops.

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

### Periodic Progress Check

Summarize recent work at regular intervals during a long session:

```text
/loop 1h summarize my recent git commits and open file changes since the last check
```

---

## /loop as a Session Prototyping Tool

`/loop` is ideal for proving that a recurring pattern works before committing to persistent infrastructure. Think of it as the prototyping stage: you validate the prompt, the cadence, and the output format in a live session, then graduate to something more durable.

| Aspect | /loop | Desktop scheduled tasks | GitHub Actions cron |
|---|---|---|---|
| **Setup time** | Seconds — just type the command | Minutes — configure OS scheduler and a Claude invocation | Minutes to hours — write YAML, configure secrets, push |
| **Persistence** | Dies with session (3-day max) | Survives reboots, runs on your machine | Runs on GitHub's infrastructure |
| **Reliability** | Depends on session staying alive | Depends on your machine being on | Production-grade, team-visible |
| **Cost model** | Claude tokens per iteration | Claude tokens per invocation | GitHub Actions minutes + Claude tokens |
| **Best for** | Prototyping, within-session monitoring | Personal recurring tasks that outlive a session | Production workflows, team-wide automation, compliance |
| **Visibility** | Only you see it (unless you add notifications) | Local logs, optional notifications | Team-visible in Actions tab, with logs and badges |

### Desktop Scheduled Tasks {#desktop-scheduled-tasks}

For recurring tasks that should survive beyond your current session but don't need CI infrastructure, use your OS scheduler:

- **macOS**: `launchd` (via `launchctl`) or `cron`
- **Linux**: `cron` or `systemd` timers
- **Windows**: Task Scheduler

These can invoke `claude` CLI directly on a schedule, giving you persistence without the overhead of GitHub Actions.

**The graduation path:** Start with `/loop` to prove a pattern works within one session. If you need it to survive reboots, move to a Desktop scheduled task. If the team depends on it, graduate to a [GitHub Actions workflow](github-actions.md).

---

## Practical Tips

### Context Management

- Keep per-iteration output concise to slow context growth.
- For loops lasting more than an hour or two, instruct Claude to summarize rather than dump raw output.
- Consider using `/compact` between manual interactions if a loop has been running for a while.

### Combining with Other Mechanisms

`/loop` layers naturally on top of the three automation mechanisms:

- **Loop + Skill** — run a skill repeatedly: `/loop 1h /deploy-check`
- **Loop + Hooks** — hooks still fire on every tool use within each loop iteration, so your guardrails and validation remain active
- **Loop + Sub Agents** — each iteration can spawn sub agents for parallel work
- **Loop + Webhooks** — send results to Slack, Discord, or any HTTP endpoint for visibility

### When NOT to Use /loop

- **Anything that should survive beyond the current session** — use [Desktop scheduled tasks](#desktop-scheduled-tasks) or [GitHub Actions](github-actions.md) instead. `/loop` dies when your session ends, and auto-expires after 3 days regardless.
- **Event-driven tasks** — if you need to react to a specific event (file save, tool use, PR comment), use [Hooks](hooks.md) instead. Polling is wasteful when events are available.
- **Production automation** — for anything the team depends on, use [GitHub Actions](github-actions.md).
- **High-frequency intervals** — loops under 1 minute are rounded up and burn tokens quickly.
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
| Prove a prompt works in one session, then move to CI or Desktop | `/loop` → then graduate to Desktop scheduled tasks or GitHub Actions |

---

## Next Steps

- [Skills](skills.md) — create reusable skills that `/loop` can invoke on a schedule
- [Built-ins](built-ins.md) — see all built-in commands, including `/tasks` for managing active loops
- [Automating Your Workflows](automating-your-workflows.md) — understand how `/loop` fits with hooks, skills, and sub agents
- [GitHub Actions](github-actions.md) — graduate proven `/loop` patterns to production CI
