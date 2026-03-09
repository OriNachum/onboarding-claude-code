---
title: "Automated Briefings"
parent: "User Stories"
nav_order: 9
permalink: /stories/automated-briefings/
---

# Automated Daily Briefings with /loop

> **Level: 🌿 Intermediate**

[← Back to References](../loop.md)

## The Scenario

You're a developer with an always-on dev machine (a home server, a cloud VM, or just a laptop that stays open). You want two daily routines automated:

1. **Morning news digest** — fetches from tech news sources and prepares a concise briefing when you start your day
2. **Nightly work summary** — scans your git activity, summarizes what you accomplished, and posts it to a Slack channel

You'll use `/loop` to set these up quickly, hit a "warning moment" when you forget about them, and eventually graduate the nightly summary to GitHub Actions while keeping the morning digest as a personal `/loop`.

---

## The Walkthrough

### Step 1: Create a Morning-Digest Skill

First, you create a skill that fetches and summarizes tech news. You write a Markdown file:

```markdown
<!-- skills/morning-digest/SKILL.md -->
---
description: Fetch and summarize morning tech news from configured sources
---

# Morning Digest

Fetch today's top stories from these sources:

1. Hacker News front page (https://news.ycombinator.com)
2. The latest release notes for key dependencies (check GitHub releases for react, next.js, and typescript)
3. Anthropic's blog for Claude updates (https://www.anthropic.com/news)

Use WebFetch to pull each source. For each:
- Extract the top 5 most relevant items
- Write a one-sentence summary of each
- Flag anything that directly affects our tech stack (TypeScript, React, Next.js)

Format as a concise morning briefing. Keep it under 20 items total.
```

> **What's Happening:** [Skills](../skills.md) are Markdown instruction files. The `description` field lets Claude auto-match this skill to relevant requests. WebFetch is a [built-in tool](../built-ins.md) for fetching web content.

### Step 2: Start the Morning Loop

With the skill in place, you start the loop:

```text
/loop 24h /morning-digest
```

The first run executes immediately — you get today's briefing right away. Then it repeats every 24 hours.

> **What's Happening:** `/loop` runs the command immediately, then waits for the interval before repeating. See [Loop](../loop.md) for full syntax and behavior. Since this is a 24-hour loop, it will run once per day as long as your session stays alive.

### Step 3: Create a Nightly-Summary Skill

Next, you create a skill that summarizes your day's work:

```markdown
<!-- skills/nightly-summary/SKILL.md -->
---
description: Summarize today's git activity and post to Slack
---

# Nightly Work Summary

Generate a summary of today's development work:

1. Run `git log --author="$(git config user.name)" --since="yesterday" --oneline --all` to get all commits from today
2. For each commit, read the changed files and summarize what was done
3. Group changes by theme (bug fixes, features, refactoring, docs)
4. Write a concise summary with bullet points

Then post the summary to Slack using this webhook:
- URL: Read the webhook URL from ~/.config/nightly-summary/slack-webhook.txt
- Format as a Slack message with the summary as the body
- Use WebFetch to POST to the webhook

If there are no commits today, post "No commits today — rest day or deep thinking day."
```

> **What's Happening:** The skill uses `git log` to find your commits, then sends a formatted summary to Slack via a webhook. Storing the webhook URL in a config file keeps it out of version control. See [Best Practices](../best-practices.md) for prompt structuring tips.

### Step 4: Start the Nightly Loop

You start the nightly summary in a separate session (or the same long-running one):

```text
/loop 24h /nightly-summary
```

Now you have two 24-hour loops running: one for morning news, one for end-of-day summaries.

> **What's Happening:** Each `/loop` runs in its conversation context. If you want them truly independent, run them in separate terminal sessions. Both will keep running as long as the sessions are alive.

### Step 5: The Warning Moment

A week later, you check your Anthropic usage dashboard and notice a spike. You'd forgotten about both loops — they've been running dutifully every 24 hours, each iteration fetching web content, running git commands, and posting to Slack. That's 14 iterations you didn't think about, each consuming tokens.

You also notice the Slack channel has a nightly summary for Saturday and Sunday — days you didn't work — each posting "No commits today."

**Lesson learned:** loops are easy to forget. You need awareness.

You set up a weekly reminder:

```text
/loop 1w list all active /loop automations and send a reminder to Discord with the list and their estimated weekly token cost
```

> **What's Happening:** This is the key warning from the [Loop reference](../loop.md): loops that are forgotten waste tokens silently. The weekly reminder loop is a meta-automation — a loop that monitors your other loops. You can also use `/tasks` anytime to check what's running.

### Step 6: Graduating to CI

After running the nightly summary for a month, you're confident in the pattern. But it has reliability issues: if your laptop sleeps, the loop stops. If the session crashes, you lose the automation. The nightly summary is something you and your team depend on — it needs to be reliable.

You migrate it to a GitHub Actions cron job:

```yaml
# .github/workflows/nightly-summary.yml
name: Nightly Work Summary

on:
  schedule:
    - cron: '0 22 * * 1-5'  # 10 PM, weekdays only
  workflow_dispatch:

jobs:
  summarize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for git log

      - uses: anthropics/claude-code-action@v1
        with:
          model: sonnet
          prompt: |
            Summarize today's git activity:
            1. Run git log for commits from today
            2. Group by theme (features, fixes, refactoring)
            3. Post summary to Slack webhook
          allowed_tools: "Bash(git log:*),Read,WebFetch"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
```

The cron schedule handles weekdays only (no more weekend "no commits" noise), it survives machine reboots, and the team can see the workflow in the Actions tab.

But you **keep the morning digest as a `/loop`**. It's personal, interactive (you sometimes ask follow-up questions about articles), and doesn't need production reliability.

> **What's Happening:** [GitHub Actions](../github-actions.md) provides the reliability that `/loop` can't — scheduled execution on infrastructure that doesn't depend on your laptop being open. The graduation path is: prototype with `/loop`, prove the pattern, then migrate to CI for anything the team depends on.

---

## Key Takeaways

- **Start with `/loop` to experiment.** It takes seconds to set up a recurring automation. Don't over-engineer — prove the pattern works first.
- **Graduate to CI for production.** Once a `/loop` pattern is proven and others depend on it, migrate to [GitHub Actions](../github-actions.md) for reliability.
- **Always set up reminders for running loops.** A weekly `/loop` that audits your other loops prevents silent token drain.
- **Use webhooks for visibility.** Posting to Slack, Discord, or any notification channel ensures you know your loops are running — and what they're producing.
- **Keep personal loops as loops.** Not everything needs CI. Interactive, personal automations like morning digests are a great fit for `/loop` long-term.
- **Weekday-only logic matters.** When graduating to CI, use cron expressions to skip weekends and holidays. `/loop` doesn't have this nuance built in.
