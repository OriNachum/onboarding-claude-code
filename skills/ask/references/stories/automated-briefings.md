---
title: "Automated Briefings"
parent: "User Stories"
nav_order: 9
permalink: /stories/automated-briefings/
---

# Monitoring a Deploy with /loop

> **Level: 🌿 Intermediate**

[← Back to References](../loop.md)

## The Scenario

You're a developer about to kick off a major deploy that includes a database migration. The rollout will take a couple of hours, and you want to stay on top of it without manually checking status every few minutes. You'll use `/loop` to monitor the deploy during your afternoon session, hit a "warning moment" when context fills up, and eventually graduate the pattern to GitHub Actions for future deploys.

---

## The Walkthrough

### Step 1: Create a Deploy-Check Skill

First, you create a skill that checks deployment health. You write a Markdown file:

```markdown
<!-- skills/deploy-check/SKILL.md -->
---
description: Check deployment rollout status and report health
---

# Deploy Check

Check the current deployment status:

1. Run `kubectl rollout status deployment/api --timeout=10s` to check rollout progress
2. Run `kubectl get pods -l app=api --no-headers` to check pod status
3. Check for any CrashLoopBackOff or Error states in the pods
4. If the migration is running, check `kubectl logs job/db-migration --tail=5` for progress

Report a concise status:
- Rollout progress (e.g., "3/5 pods ready")
- Any pods in error states
- Migration status if applicable
- Overall health: ✅ Healthy, ⚠️ Degraded, or ❌ Failing
```

> **What's Happening:** [Skills](../skills.md) are Markdown instruction files. The `description` field lets Claude auto-match this skill to relevant requests. The skill uses `kubectl` commands to check deployment health — adjust these to match your infrastructure.

### Step 2: Start the Deploy Loop

With the skill in place, you kick off the deploy and start monitoring:

```text
/loop 5m /deploy-check
```

The first run executes immediately — you get a baseline health check right away. Then it repeats every 5 minutes, giving you a running status log without having to check manually.

> **What's Happening:** `/loop` runs the command immediately, then waits for the interval before repeating. Each iteration runs in the same conversation, so Claude can detect trends: "Pod restart count increased from 2 to 5 since the last check." See [Loop](../loop.md) for full syntax and the [Limitations](../loop.md#limitations) section for hard constraints.

### Step 3: Add an Error-Rate Watcher

The deploy is rolling out, but you also want to watch your error dashboard. You add a second loop:

```text
/loop 10m check the error rate at our monitoring endpoint and flag any spike above 1% — compare to the baseline from the first check
```

Now you have two loops running: deploy health every 5 minutes, error rate every 10 minutes. Both accumulate context in the same conversation, so Claude can correlate: "Error rate spiked to 2.3% — this coincides with the third pod coming online."

> **What's Happening:** You can run multiple loops in the same session. Each fires independently on its own interval. Use `/tasks` to see all active loops and stop any you no longer need.

### Step 4: Set a One-Time Reminder

The migration is expected to take about 2 hours. Rather than adding another loop, you set a one-time reminder:

```text
remind me in 2 hours to check if the database migration completed
```

This fires once at the specified time — no recurring cost, no context accumulation. It's a good complement to loops for time-boxed checkpoints.

> **What's Happening:** One-time reminders are part of the same scheduling system as `/loop` but fire only once. They're ideal for "check back on this later" moments. See [Run prompts on a schedule](https://code.claude.com/docs/en/scheduled-tasks) for details.

### Step 5: The Warning Moment

Two hours in, the deploy is complete and healthy. But you've been heads-down in another task and forgot about the loops. The conversation context has grown significantly — dozens of status checks, error rate reports, and kubectl output have accumulated. You notice Claude's responses are getting slower and a compaction warning appears.

You run `/tasks` and see both loops still active. You stop them:

```text
/tasks
```

Then you stop each one from the task list.

**Lesson learned:** Check `/tasks` periodically during long sessions with active loops. Context accumulates silently.

You also learn about the 3-day auto-expiry: even if you'd left these loops running and walked away, they would have self-deleted after 3 days. It's a safety net, but not a substitute for active management — 3 days of unchecked loops would waste significant tokens.

> **What's Happening:** This is the key warning from the [Loop reference](../loop.md): loops are easy to forget. Context grows with every iteration. The 3-day auto-expiry prevents runaway costs in the worst case, but you should stop loops as soon as they've served their purpose. `/tasks` is your primary tool for awareness.

### Step 6: Graduating to CI

The deploy went well, and the `/deploy-check` pattern proved valuable. But you don't want to manually set up loops every time you deploy. You migrate the pattern to a GitHub Actions workflow that triggers automatically:

```yaml
# .github/workflows/deploy-monitor.yml
name: Deploy Health Monitor

on:
  workflow_dispatch:
    inputs:
      duration:
        description: 'How long to monitor (minutes)'
        default: '30'

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          model: sonnet
          prompt: |
            Monitor the deployment health for ${{ inputs.duration }} minutes:
            1. Check kubectl rollout status every 2 minutes
            2. Check error rates against baseline
            3. Post a summary to Slack when monitoring completes
            4. If any critical issues are detected, post an alert immediately
          allowed_tools: "Bash(kubectl:*),WebFetch"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          KUBECONFIG: ${{ secrets.KUBECONFIG }}
```

Now deploy monitoring runs on GitHub's infrastructure. It doesn't depend on your terminal being open, the team can see results in the Actions tab, and it triggers consistently on every deploy.

**But you keep `/loop` for ad-hoc monitoring.** When you're debugging a specific issue or watching a one-off experiment, `/loop 2m check the error logs` is still the fastest way to set up temporary monitoring. No YAML, no push, no wait — just type and go.

> **What's Happening:** [GitHub Actions](../github-actions.md) provides the persistence and reliability that `/loop` can't — it survives session endings, machine reboots, and doesn't expire after 3 days. The graduation path: prototype with `/loop` in one session, prove the pattern works, then migrate to CI for anything that should run unattended. For personal recurring tasks that don't need CI, [Desktop scheduled tasks](../loop.md#desktop-scheduled-tasks) (cron, launchd, Task Scheduler) are an intermediate option.

---

## Key Takeaways

- **`/loop` is a session companion.** It's designed for minutes-to-hours monitoring within a single working session. It's the fastest way to set up temporary recurring checks — no config files, no deployment.
- **Graduate to CI for persistence.** Once a `/loop` pattern is proven and should run unattended, migrate to [GitHub Actions](../github-actions.md). For personal tasks, consider Desktop scheduled tasks (cron, launchd) as a middle ground.
- **Know the hard limits.** Session-scoped, 3-day auto-expiry, no catch-up for missed fires. These aren't bugs — they make `/loop` safe by default.
- **Check `/tasks` regularly.** This is the simplest way to stay aware of running loops and avoid context bloat or token waste.
- **Use one-time reminders for checkpoints.** Not everything needs a recurring loop. `remind me in 2 hours to...` fires once with zero ongoing cost.
- **Keep per-iteration output concise.** The biggest practical issue with loops is context accumulation. Instruct Claude to summarize rather than dump raw output.
