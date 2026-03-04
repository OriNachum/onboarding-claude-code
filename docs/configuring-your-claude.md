# Configuring Your Claude

[← Back to Automating Your Workflows](automating-your-workflows.md)

Claude Code is deeply customizable. This guide walks you through the layers of configuration — from teaching Claude about your project, to setting up permissions, to connecting external tools — so you can make Claude truly yours.

## The Configuration Layers

Think of Claude Code's configuration as concentric rings, from most personal to most shared:

| Layer | What it does | Where it lives | Shared with team? |
|---|---|---|---|
| **CLAUDE.md** | Teaches Claude about your project | `./CLAUDE.md` or `.claude/CLAUDE.md` | Yes (committed to git) |
| **CLAUDE.local.md** | Your personal project preferences | `./CLAUDE.local.md` | No (gitignored) |
| **User settings** | Your global preferences | `~/.claude/settings.json` | No |
| **Project settings** | Team's shared config | `.claude/settings.json` | Yes |
| **Local settings** | Your project overrides | `.claude/settings.local.json` | No |
| **Skills** | Reusable prompts and workflows | `.claude/skills/` | Yes |
| **Agents** | Specialist sub agents | `.claude/agents/` | Yes |
| **MCP servers** | External tool integrations | `.mcp.json` | Yes |
| **Plugins** | Bundled extensions | Via `/plugin` | Yes |

## Step 1: Teach Claude About Your Project (CLAUDE.md)

This is the single most impactful thing you can do. CLAUDE.md is a file Claude reads at the start of every session. It's your chance to tell Claude things it can't figure out by reading code alone.

### Generate a starting point

```
/init
```

Claude analyzes your codebase and generates a CLAUDE.md with build commands, test instructions, and conventions it discovers. Refine from there.

### What to include

- **Build and test commands**: `npm run test`, `cargo build --release`
- **Coding conventions** that differ from defaults: "Use 2-space indentation", "Prefer named exports"
- **Architectural decisions**: "We use the repository pattern for data access"
- **Workflow rules**: "Always run `npm run lint` before committing"
- **Common gotchas**: "The auth module requires a running Redis instance"

### What NOT to include

- Things Claude can figure out by reading code (standard patterns, obvious structure)
- Long tutorials or explanations (link to docs instead)
- Information that changes frequently
- File-by-file descriptions of the codebase

### Keep it concise

Target under 200 lines. Every line of CLAUDE.md consumes context tokens in every session. If Claude keeps ignoring a rule, the file is probably too long and the rule is getting lost.

### Import other files

```markdown
See @README.md for project overview and @package.json for available scripts.

# Additional context
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

### Path-specific rules

For larger projects, use `.claude/rules/` to scope instructions to specific file types:

```markdown
# .claude/rules/api-design.md
---
paths:
  - "src/api/**/*.ts"
---

All API endpoints must include input validation.
Use the standard error response format.
```

## Step 2: Set Up Permissions

Permissions control what Claude can do without asking. Configure them once, and you'll stop clicking "approve" on every safe command.

### Pre-approve safe commands

Add to `.claude/settings.json` (shared with team):

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run test *)",
      "Bash(npm run lint *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  }
}
```

### Protect sensitive files

The `deny` rules above prevent Claude from reading your `.env` files and secrets. This is important — Claude should never see API keys or credentials.

### Choose your default mode

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

See [Starting to Work](starting-to-work.md) for when to use each mode.

## Step 3: Choose Your Model

Set your preferred model in settings or switch during a session:

```json
{
  "model": "sonnet"
}
```

Or use the hybrid approach:

```json
{
  "model": "opusplan"
}
```

This uses Opus for planning and Sonnet for implementation. See [Choosing Your Model](choosing-your-model.md) for detailed guidance.

## Step 4: Connect External Tools (MCP)

MCP (Model Context Protocol) servers give Claude access to external tools and data. Common integrations:

- **GitHub** (issues, PRs, repos)
- **Slack** (messages, channels)
- **Databases** (query, explore schemas)
- **Figma** (designs, components)
- **Notion** (docs, knowledge base)

### Add an MCP server

```bash
claude mcp add github -- gh copilot mcp
```

Or configure in `.mcp.json` at your project root for team sharing.

### Use CLI tools first

Before reaching for MCP, check if a CLI tool exists. Claude works well with `gh` (GitHub), `aws`, `gcloud`, `kubectl`, and most CLI tools. Try: "Use `gh` to list open PRs."

## Step 5: Install Useful Plugins

Plugins bundle skills, agents, hooks, and MCP servers into installable packages.

```
/plugin
```

**Recommended first plugins:**

- **Code Intelligence (LSP)**: If you use TypeScript, Python, or Rust, install the LSP plugin for your language. This gives Claude precise type checking and navigation.
- Browse the marketplace for your stack — there are plugins for formatting, testing, deployment, and more.

See [Plugins](plugins.md) for more details.

## Step 6: Set Up Auto Memory

Auto memory lets Claude learn from your corrections across sessions. It's on by default — Claude saves notes about build commands, debugging insights, and patterns it discovers.

Check what Claude has learned:

```
/memory
```

You can view, edit, or delete anything Claude has saved. It's all plain Markdown in `~/.claude/projects/<project>/memory/`.

## Step 7: Customize Your Experience

### Status line

Configure a custom status line to show useful context (git branch, model, token usage):

```
/statusline
```

### Theme

```
/theme
```

### Output style

```
/output-style explanatory
```

Choose between standard, explanatory (adds educational insights), or learning (pauses to ask you to write code pieces).

### Spinner text

Customize what Claude says while thinking:

```json
{
  "spinnerVerbs": {
    "mode": "append",
    "verbs": ["Pondering", "Crafting", "Contemplating"]
  }
}
```

## Configuration Scope Reference

Settings apply in order of precedence (highest to lowest):

1. **Managed settings** (enterprise IT) — cannot be overridden
2. **Command line arguments** — temporary session overrides
3. **Local project settings** (`.claude/settings.local.json`) — personal, gitignored
4. **Project settings** (`.claude/settings.json`) — shared with team
5. **User settings** (`~/.claude/settings.json`) — personal, all projects

Array settings (like permission rules) merge across scopes. Non-array settings use the highest-precedence value.

Run `/status` to see which settings sources are active and where they come from.

## Quick Setup Checklist

- [ ] Run `/init` to generate CLAUDE.md
- [ ] Refine CLAUDE.md with your project's conventions and gotchas
- [ ] Set up permission allow/deny rules in `.claude/settings.json`
- [ ] Choose your model (`/model` or settings)
- [ ] Install LSP plugin for your language (`/plugin`)
- [ ] Install the `gh` CLI if you use GitHub
- [ ] Run `/statusline` to set up your status line
- [ ] Try `/theme` to pick a color scheme you like

## Next Steps

- See [Choosing Your Model](choosing-your-model.md) for model and effort level guidance
- See [Starting to Work](starting-to-work.md) for permission mode selection
- See [Automating Your Workflows](automating-your-workflows.md) for hooks, skills, and sub agents
- See the [official settings reference](https://code.claude.com/docs/en/settings) for all available settings
- See the [official memory docs](https://code.claude.com/docs/en/memory) for CLAUDE.md and auto memory details
