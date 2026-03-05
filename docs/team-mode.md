# Running Multiple Agents in Parallel

[← Back to Automating Your Workflows](automating-your-workflows.md)

When you need multiple Claudes working at the same time, there are two separate concepts to understand: **how agents are spawned** (sub agents vs agent teams) and **how they're isolated** (worktrees). These aren't alternatives to each other — they layer together.

---

## Two Concepts, Not Three

### Worktrees — The Isolation Layer

Git worktrees give each agent its own copy of the codebase so their file changes don't collide. Worktrees are *not* an alternative to sub agents or agent teams — they're a layer that works *alongside* both.

- A **sub agent** can run in a worktree (`isolation: worktree` in the agent frontmatter)
- **Agent team** teammates can each work in their own worktree to avoid file conflicts
- **You** can open multiple terminals with `claude --worktree` and manage them yourself

Worktrees solve the *isolation* problem. Sub agents and agent teams solve the *coordination* problem.

### Two Ways to Spawn Parallel Agents

| | [Sub Agents](sub-agents.md) | Agent Teams |
|---|---|---|
| **What they are** | Helper agents spawned within your session | Multiple full Claude Code instances coordinated by a lead |
| **Communication** | One-way: report results back to the main agent | Multi-way: shared task list + direct messaging between teammates |
| **Context** | Own context window, results summarized back | Own context window, fully independent sessions |
| **Coordination** | Main agent manages all work | Teammates self-coordinate, claim tasks, message each other |
| **Can talk to each other?** | No — helpers never see each other | Yes — teammates message each other directly |
| **Token cost** | Lower: results summarized back | Higher: each teammate is a separate Claude instance |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |

Think of it this way: **sub agents** are specialists you send off to do a job — they come back with an answer. **Agent teams** are colleagues working in the same room — they can talk to each other, challenge each other's ideas, and coordinate their work without going through you.

Both can use worktrees for file isolation. Neither *requires* worktrees, but parallel work that modifies files should use them to prevent conflicts.

---

## Worktrees in Practice

### Starting a worktree session manually

```bash
# Start Claude in a named worktree (creates branch worktree-feature-auth)
claude --worktree feature-auth

# In another terminal, start a second session
claude --worktree bugfix-123

# Or let Claude pick a random name
claude --worktree
```

Worktrees are created at `<repo>/.claude/worktrees/<name>` and branch from your default remote branch. You can also ask Claude during a session to "work in a worktree" and it will create one automatically.

### Worktrees with sub agents

Add `isolation: worktree` to a sub agent's frontmatter so it works in its own copy of the codebase:

```markdown
# .claude/agents/refactorer.md
---
name: refactorer
description: Refactors code modules independently
tools: Read, Edit, Bash, Grep, Glob
model: sonnet
isolation: worktree
---

Refactor the specified module...
```

Or ask Claude: "use worktrees for your agents." Each sub agent gets its own worktree that's automatically cleaned up when it finishes without changes.

### Worktrees with agent teams

When setting up a team, tell the lead to use worktrees to prevent file conflicts:

```
Create an agent team to implement these three modules in parallel.
Each teammate should work in its own worktree to avoid conflicts.
```

### Cleanup

When you exit a worktree session, Claude handles cleanup based on whether you made changes. No changes: the worktree and branch are removed automatically. Commits or uncommitted changes exist: Claude prompts you to keep or remove it.

Add `.claude/worktrees/` to your `.gitignore` to prevent worktree contents from showing as untracked files.

### Manual worktree management

For more control over location and branch, create worktrees with Git directly:

```bash
# Create a worktree with a new branch
git worktree add ../project-feature-a -b feature-a

# Start Claude in the worktree
cd ../project-feature-a && claude

# Clean up when done
git worktree remove ../project-feature-a
```

Remember to install dependencies (e.g., `npm install`) in each new worktree.

---

## Sub Agents for Parallel Work

Sub agents are the simpler option for parallelism. Claude spawns them, they work in their own context, and they report results back. The main agent synthesizes everything. See [Sub Agents](sub-agents.md) for full details on creating and configuring them.

### When sub agents are enough

Most parallel work fits the sub agent model. Use them when:

- You care about the *result*, not the *process* (code review findings, test results, research summaries)
- Tasks are independent — each helper doesn't need to know what the others are doing
- You want Claude to manage the delegation automatically

### When to add worktree isolation

If your sub agents will modify files (not just read and analyze), add `isolation: worktree` to prevent them from overwriting each other's changes. Read-only sub agents (reviewers, researchers) don't need worktrees.

---

## Agent Teams for Coordinated Work

Agent teams are the more powerful option: multiple full Claude Code sessions that share a task list and communicate directly. One session acts as the lead, and teammates are independent instances that can message each other.

> **Note:** Agent teams are experimental and disabled by default. Enable them in your settings before use.

### How agent teams differ from sub agents

The key difference is communication. Sub agents only report back to the main agent — they never see each other. Agent team teammates share a task list, claim work, and message each other directly. This makes agent teams better when workers need to *discuss*, *challenge*, and *coordinate* — not just deliver results independently.

Agent teams also cost significantly more tokens, since each teammate is a separate Claude instance with its own full context window.

### Enable agent teams

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Start a team

Describe the task and team structure in natural language:

```
I'm designing a CLI tool that helps developers track TODO comments.
Create an agent team to explore this from different angles:
one teammate on UX, one on technical architecture, one playing devil's advocate.
```

You can also specify count and model:

```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Display modes

**In-process** (default): All teammates run inside your main terminal. Use `Shift+Down` to cycle through teammates. Works in any terminal.

**Split panes**: Each teammate gets its own pane via `tmux` or iTerm2. You can see everyone's output at once and click into a pane to interact directly.

```json
{
  "teammateMode": "in-process"
}
```

Or per session: `claude --teammate-mode in-process`

### Interacting with the team

- **Message teammates directly**: `Shift+Down` to cycle (in-process) or click pane (split mode)
- **View the task list**: `Ctrl+T`
- **Require plan approval**: "Spawn an architect teammate to refactor auth. Require plan approval before they make any changes."

### Task coordination

Tasks have three states: pending, in progress, completed. Tasks can depend on other tasks. The lead creates tasks; teammates self-claim or get assigned. Task claiming uses file locking to prevent race conditions.

### Quality gates with hooks

- **TeammateIdle**: Fires when a teammate is about to go idle. Exit with code 2 to send feedback and keep them working.
- **TaskCompleted**: Fires when a task is being marked complete. Exit with code 2 to prevent completion and send feedback.

### Shutting down

```
Ask the researcher teammate to shut down
```

When done: `Clean up the team`. Always use the lead to clean up.

### Best practices

**Give teammates enough context.** They load project context (CLAUDE.md, MCP, skills) but don't inherit the lead's conversation history. Include details in the spawn prompt.

**Start with 3–5 teammates.** Aim for 5–6 tasks per teammate. Scale up only when work genuinely benefits from more parallelism.

**Avoid file conflicts.** Use worktrees, or break work so each teammate owns different files.

**Start with research and review.** If you're new to agent teams, begin with read-only tasks (reviewing a PR, researching a library) before trying parallel implementation.

---

## Choosing Your Approach

| Scenario | Approach |
|---|---|
| Independent tasks, you want full control | `claude --worktree` in multiple terminals |
| Focused tasks where only results matter | Sub agents (add `isolation: worktree` if they edit files) |
| Tasks that need discussion and coordination | Agent teams (with worktrees for file isolation) |
| Code review from multiple angles | Agent team with 3 reviewers (security, performance, tests) |
| Run tests + fix failures in isolation | Sub agent with worktree isolation |
| Competing hypotheses for a bug | Agent team where teammates debate and disprove each other |
| Feature + bug fix in parallel | Two `--worktree` sessions (simplest) |

The common thread: **worktrees for isolation, sub agents or agent teams for coordination.** Start with the simplest option that fits your task.

---

## Troubleshooting

### Worktree issues

If `--worktree` fails, check that you're inside a git repository and that the `.claude/worktrees/` directory is writable. For non-git version control, configure `WorktreeCreate` and `WorktreeRemove` hooks.

### Agent team issues

**Teammates not appearing**: Press `Shift+Down` — they may be running but not visible. Check that your task warranted a team.

**Too many permission prompts**: Pre-approve common operations in permission settings before spawning teammates.

**Lead finishes before teammates**: Tell it: "Wait for your teammates to complete their tasks before proceeding."

**Orphaned tmux sessions**: `tmux ls` then `tmux kill-session -t <name>`.

**Current limitations**: No session resumption with in-process teammates, one team per session, no nested teams, lead is fixed for the session, split panes require tmux or iTerm2.

---

## Next Steps

- See [Sub Agents](sub-agents.md) for creating specialist agents
- See [Hooks](hooks.md) for TeammateIdle and TaskCompleted quality gates
- See [Automating Your Workflows](automating-your-workflows.md) for the full automation overview
- See the [official agent teams docs](https://code.claude.com/docs/en/agent-teams) for the complete reference
- See the [official worktrees section](https://code.claude.com/docs/en/common-workflows) in Common Workflows for additional details
