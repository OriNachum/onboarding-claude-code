# CLAUDE.md — Agent Instructions

This file tells Claude Code (and other AI agents) how to work with this repository.

---

## What This Repo Is

An onboarding guide for Claude Code users. All documentation lives in `docs/` as Markdown files. The `README.md` serves as the entry point with a documentation map and suggested reading order.

This repo serves two audiences: humans reading the docs on GitHub, and Claude Code users who install it as a plugin to get interactive onboarding skills.

This is a **documentation-only** repo — no application code, no build system, no tests. The content is meant to be read on GitHub (rendered Markdown) or as a GitHub Pages site.

---

## Repository Structure

```
onboarding-claude-code/
├── .claude-plugin/
│   └── plugin.json ............... Plugin manifest (name, version, metadata)
├── skills/
│   ├── guide/SKILL.md ............ Skill directory — shows all skills
│   ├── setup/SKILL.md ............ Initial setup walkthrough
│   ├── first-session/SKILL.md .... First working session guide
│   ├── best-practices/SKILL.md ... Self-testing, context, prompting
│   ├── automate/SKILL.md ......... Hooks, Skills, Sub Agents overview
│   └── configure/SKILL.md ........ Ongoing configuration guide
├── docs/ .......................... Full documentation (human-readable)
    ├── setting-your-environment.md ... Initial setup and installation
    ├── choosing-your-model.md ....... Model selection and effort levels
    ├── starting-to-work.md ......... First session — Plan Mode, Accept Edits, Normal
    ├── configuring-your-claude.md ... Ongoing config — building agent personality
    ├── best-practices.md ........... Self-testing, context management, prompting
    ├── built-ins.md ................ Built-in commands, tools, defaults
    ├── automating-your-workflows.md . Overview — three mechanisms + how they combine
    ├── hooks.md .................... Lifecycle event automation
    ├── skills.md ................... Reusable prompt-driven workflows
    ├── sub-agents.md ............... Specialist agents + worktree isolation
    ├── team-mode.md ................ Agent Teams (experimental)
    └── plugins.md .................. Installing, creating, sharing plugins
```

---

## How to Work on This Repo

### Writing style

- **Onboarding-focused.** Content should help someone start thinking about a topic, not be an exhaustive reference. Link to official Claude Code docs for depth.
- **Conversational, not formal.** Second person ("you"), active voice, short paragraphs.
- **Analogies over abstractions.** The docs use an IKEA furniture analogy to explain Hooks, Skills, and Sub Agents. Maintain this when relevant.
- **Cross-link everything.** Every doc page should link back to its parent overview and forward to related pages. Use relative paths (`hooks.md`, not full URLs).

### Key content rules

- **Slash commands are a subset of Skills** — never list them as a separate category.
- **Three automation mechanisms only:** Hooks, Skills, Sub Agents. Agent Teams are an operational mode, not a fourth mechanism — they do NOT belong in the comparison table in `automating-your-workflows.md`.
- **Worktrees are an isolation layer**, not a coordination mechanism. They work alongside both Sub Agents and Agent Teams. Worktree content lives in `sub-agents.md`.
- **Agent Teams are experimental.** Always flag them as such. They are architecturally distinct from Sub Agents (separate full Claude instances vs. helpers within a session).

### Navigation structure

Each doc page follows this pattern:
1. **Back link** at the top — points to parent page (usually `automating-your-workflows.md` or `README.md`)
2. **Content** — the guide itself
3. **Next Steps / Related** section at the bottom — links to related pages

The `automating-your-workflows.md` page serves as the hub for all automation docs. It contains an "All Documentation" index at the bottom that lists every page. If you add a new doc, add it to that index.

### Adding a new doc

1. Create the file in `docs/`
2. Add a back link at the top: `[← Back to ...](parent-page.md)`
3. Add the file to the "All Documentation" index in `automating-your-workflows.md`
4. Add the file to the Documentation Map tree in `README.md`
5. Add the file to the Repository Structure tree in this file (`CLAUDE.md`)
6. Cross-link from related pages

### Editing existing docs

- Read the full file before editing to understand the flow
- Preserve existing cross-links
- Maintain the IKEA analogy framework where it's used (Hooks = assembly events, Skills = the packages with tools, Sub Agents = the packages plus the handyperson who builds them)
- Keep the onboarding tone — if you're writing reference material, you're probably going too deep

---

## Plugin skills

The `skills/` directory contains SKILL.md files that Claude Code invokes when a user types `/onboarding-claude-code:skill-name`. Each skill is a distilled, actionable version of the corresponding doc page.

When adding a new skill:
1. Create `skills/skill-name/SKILL.md` with frontmatter (`description` is required)
2. Write instructions Claude should follow — conversational, step-by-step, interactive
3. End with "Related skills" linking to other `/onboarding-claude-code:*` skills
4. Update the guide skill (`skills/guide/SKILL.md`) to list the new skill
5. Update the skills table in `README.md`

Skills are NOT reference docs. They're instructions for Claude to follow interactively with the developer. Write them as "you are helping a developer do X" — Claude becomes the guide.

---

## Official References

When you need accurate technical details, consult the official Claude Code docs:

- General: `https://docs.anthropic.com/en/docs/claude-code`
- Agent Teams: `https://code.claude.com/docs/en/agent-teams`
- Best Practices: `https://code.claude.com/docs/en/best-practices`
- Common Workflows: `https://code.claude.com/docs/en/common-workflows`
- Settings: `https://code.claude.com/docs/en/settings`
- Memory: `https://code.claude.com/docs/en/memory`

---

## Commit Conventions

- Use clear, descriptive commit messages (e.g., "Add worktree isolation section to sub-agents.md")
- One logical change per commit when possible
- Commit directly to `main` — this is a docs repo, not a production application
