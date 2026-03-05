# Onboarding Claude Code

Sources, workflows, and a path to start working with Claude Code. Return here for new material, features, and guides.

## Install as a Claude Code Plugin

This repo is also a **Claude Code plugin**. Install it to get interactive onboarding skills directly inside Claude Code.

### Quick install (from GitHub)

```
claude --plugin-dir /path/to/onboarding-claude-code
```

Or clone and point to it:

```bash
git clone https://github.com/OriNachum/onboarding-claude-code.git
claude --plugin-dir ./onboarding-claude-code
```

### Available skills

Once installed, you can invoke these skills:

| Skill | What it does |
|---|---|
| `/onboarding-claude-code:guide` | See all skills and where to start |
| `/onboarding-claude-code:setup` | Walk through initial setup step by step |
| `/onboarding-claude-code:first-session` | Guide your first real working session |
| `/onboarding-claude-code:best-practices` | Self-testing, context management, prompting |
| `/onboarding-claude-code:automate` | Hooks, Skills, Sub Agents — when to use each |
| `/onboarding-claude-code:configure` | Ongoing CLAUDE.md and settings refinement |

### For teams

Add this plugin to your project's `.claude/settings.json` so every team member gets it automatically:

```json
{
  "extraKnownMarketplaces": {
    "onboarding-claude-code": {
      "source": {
        "source": "github",
        "repo": "OriNachum/onboarding-claude-code"
      }
    }
  }
}
```

---

## Reading the Docs

The skills above are distilled from the full documentation below. For deeper reading, browse the docs directly.

## Where to Start

If you're new to Claude Code, start with **Setting Your Environment** to get up and running, then move to **Starting to Work** for your first session.

If you already have Claude Code installed, jump to whichever guide matches what you need right now.

---

## Documentation Map

```
docs/
├── Getting Started
│   ├── setting-your-environment.md .... Initial setup and installation
│   ├── choosing-your-model.md ......... Picking the right model and effort level
│   └── starting-to-work.md ........... Your first session: Plan Mode, Accept Edits, Normal
│
├── Working Effectively
│   ├── configuring-your-claude.md ..... Ongoing configuration — building your agent's personality
│   ├── best-practices.md ............. Self-testing loops, context management, effective prompting
│   └── built-ins.md .................. Built-in commands, tools, and defaults
│
├── Automation Deep Dives
│   ├── automating-your-workflows.md ... Overview — the three mechanisms and how they combine
│   ├── hooks.md ....................... Lifecycle event automation
│   ├── skills.md ..................... Reusable prompt-driven workflows
│   ├── sub-agents.md ................. Specialist agents and worktree isolation
│   └── team-mode.md .................. Agent Teams (experimental)
│
└── Configuration & Extensions
    └── plugins.md ..................... Installing, creating, and sharing plugins
```

---

## Suggested Reading Order

For a full onboarding path, follow this sequence:

1. [Setting Your Environment](docs/setting-your-environment.md) — get Claude Code installed and configured
2. [Choosing Your Model](docs/choosing-your-model.md) — understand the models and when to use each
3. [Starting to Work](docs/starting-to-work.md) — learn the three operating modes
4. [Built-ins](docs/built-ins.md) — know what Claude Code ships with out of the box
5. [Configuring Your Claude](docs/configuring-your-claude.md) — shape Claude's personality and defaults over time
6. [Best Practices](docs/best-practices.md) — self-testing, context management, and course-correction
7. [Automating Your Workflows](docs/automating-your-workflows.md) — the overview that ties hooks, skills, and sub agents together
8. [Hooks](docs/hooks.md) → [Skills](docs/skills.md) → [Sub Agents](docs/sub-agents.md) — deep dives into each mechanism
9. [Agent Teams](docs/team-mode.md) — experimental multi-agent coordination
10. [Plugins](docs/plugins.md) — package and share your automation

---

## Quick Links

| I want to... | Go to |
|---|---|
| Install Claude Code | [Setting Your Environment](docs/setting-your-environment.md) |
| Pick the right model | [Choosing Your Model](docs/choosing-your-model.md) |
| Start my first session | [Starting to Work](docs/starting-to-work.md) |
| See what's built in | [Built-ins](docs/built-ins.md) |
| Customize Claude's behavior | [Configuring Your Claude](docs/configuring-your-claude.md) |
| Write better prompts | [Best Practices](docs/best-practices.md) |
| Automate repetitive work | [Automating Your Workflows](docs/automating-your-workflows.md) |
| Run tasks on lifecycle events | [Hooks](docs/hooks.md) |
| Create reusable workflows | [Skills](docs/skills.md) |
| Delegate to specialist agents | [Sub Agents](docs/sub-agents.md) |
| Run multiple agents in parallel | [Agent Teams](docs/team-mode.md) |
| Share my setup with a team | [Plugins](docs/plugins.md) |

---

## Contributing

This repo is a living guide. If you find something missing, outdated, or confusing, open an issue or a PR.

For agents working on this repo, see [CLAUDE.md](CLAUDE.md) for instructions on how to navigate and contribute to the documentation.
