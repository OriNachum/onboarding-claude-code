---
description: Guide to Claude Code plugins — installing from marketplaces, creating your own, packaging skills/agents/hooks for sharing. Use when a developer wants to discover plugins or package their own work for distribution.
---

# Plugins — Install, Create, and Share

You are helping a developer work with the Claude Code plugin system — either finding and installing existing plugins, or packaging their own skills/agents/hooks into a shareable plugin.

## What plugins are

Plugins are shareable bundles of skills, agents, hooks, MCP servers, and LSP servers. They're the distribution layer — how you share automation with teammates or the community.

Think of it as: standalone config in `.claude/` is for personal use. Plugins are for sharing.

## Installing plugins

### From the built-in marketplace
```
/plugin
```
This opens an interactive browser where you can search, install, enable, and disable plugins.

### Key plugins to know about
- **LSP plugins** — give Claude precise code intelligence (go-to-definition, find references, type errors). Pre-built for TypeScript, Python, Rust, and more.
- **Community plugins** — browse via `/plugin` for formatting, deployment, testing, and more.

### From a team marketplace
If your team has a custom marketplace, it may be auto-configured via `extraKnownMarketplaces` in your project's `.claude/settings.json`.

## Creating a plugin

### 1. Plugin structure
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (required)
├── skills/
│   └── my-skill/
│       └── SKILL.md         # /my-plugin:my-skill
├── agents/
│   └── reviewer.md          # Custom sub agent
├── hooks/
│   └── hooks.json           # Lifecycle hooks
└── settings.json            # Default settings
```

**Important:** Don't put skills/, agents/, or hooks/ inside `.claude-plugin/`. Only `plugin.json` goes there. Everything else at root.

### 2. The manifest
```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

### 3. Test locally
```bash
claude --plugin-dir ./my-plugin
```

### 4. Validate
```bash
claude plugin validate ./my-plugin
```

## Namespacing

Plugin skills are namespaced: `/plugin-name:skill-name`. Two plugins can both have a `review` skill without conflicting.

## Converting standalone config to a plugin

If they already have skills in `.claude/`:
1. Create plugin directory with `.claude-plugin/plugin.json`
2. Copy `.claude/skills/` → `my-plugin/skills/`
3. Copy `.claude/agents/` → `my-plugin/agents/`
4. Move hooks from settings → `my-plugin/hooks/hooks.json`
5. Test with `--plugin-dir`

## Distributing a plugin

Three options:
1. **Official Anthropic marketplace** — submit at `claude.ai/settings/plugins/submit`. Reviewed by Anthropic.
2. **Custom marketplace** — create a `marketplace.json`, host on GitHub, share via `/plugin marketplace add owner/repo`.
3. **Direct sharing** — others clone your repo and use `--plugin-dir`.

## For teams

Add to your project's `.claude/settings.json`:
```json
{
  "extraKnownMarketplaces": {
    "team-plugins": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

Team members are automatically prompted to install when they open the project.

## Related skills
- `/onboarding-claude-code:skills-guide` — creating the skills that go into plugins
- `/onboarding-claude-code:hooks` — creating hooks for plugins
- `/onboarding-claude-code:sub-agents` — creating agents for plugins
- `/onboarding-claude-code:automate` — overview of automation mechanisms
