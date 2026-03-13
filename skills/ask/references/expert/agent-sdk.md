---
title: "Claude Agent SDK"
parent: "Integrations"
nav_order: 1
permalink: /agent-sdk/
---

# Claude Agent SDK

> **Level: 🌳 Expert** | **Source:** [Claude Agent SDK](https://docs.anthropic.com/en/docs/claude-code/sdk)
>
> **Rename notice:** The Claude Code SDK has been renamed to the **Claude Agent SDK**. The packages are now `@anthropic-ai/claude-agent-sdk` (TypeScript) and `claude-agent-sdk` (Python). If you're migrating from the old package names, see the [Migration Guide](https://platform.claude.com/docs/en/agent-sdk/migration-guide).

The Claude Agent SDK gives you programmatic access to Claude Code from TypeScript and Python. Instead of shelling out to the CLI, you get a native API with structured inputs/outputs, streaming, tool control, session management, and hooks — all from your own application code.

**Packages:**

- TypeScript: `@anthropic-ai/claude-agent-sdk` ([npm](https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk))
- Python: `claude-agent-sdk` ([PyPI](https://pypi.org/project/claude-agent-sdk/))

---

## When to Use the SDK

| Scenario | Best tool |
|---|---|
| Interactive coding session | CLI (`claude`) |
| PR review, issue triage in CI | [GitHub Actions](../intermediate/github-actions.md) |
| Connecting external tools to Claude | [MCP](../intermediate/mcp.md) |
| Lifecycle guardrails & automation | [Hooks](../intermediate/hooks.md) |
| Embedding Claude Code in your app, building custom tooling, orchestrating multi-turn workflows programmatically | **Agent SDK** |

Use the SDK when you need **programmatic control** — launching Claude from application code, processing structured outputs, managing sessions, or building custom agents on top of Claude Code.

---

## Getting Started: TypeScript

Install:

```bash
npm install @anthropic-ai/claude-agent-sdk
```

Minimal example:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

const messages = await query({
  prompt: "Explain what this project does",
  options: {
    maxTurns: 3,
  },
});

console.log(messages);
```

The `query()` function is the primary interface. It returns an array of conversation messages. You can stream results by setting `options.abortController` and using the async iterator form.

---

## Getting Started: Python

Install:

```bash
pip install claude-agent-sdk
```

Minimal example:

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    messages = []
    async for message in query(
        prompt="Explain what this project does",
        options=ClaudeAgentOptions(max_turns=3),
    ):
        messages.append(message)
    print(messages)

anyio.run(main)
```

The Python SDK mirrors the TypeScript API. It requires the Claude Code CLI to be installed (`npm install -g @anthropic-ai/claude-agent-sdk`).

---

## Key Concepts

### The `query()` API

Both SDKs expose a `query()` function as the primary interface:

- **`prompt`** — the user message to send
- **`options.maxTurns`** / **`max_turns`** — limit how many agentic turns Claude can take
- **`options.systemPrompt`** / **`system_prompt`** — custom system prompt
- **`options.cwd`** / **`cwd`** — working directory for file operations
- **`options.permissionMode`** / **`permission_mode`** — set permission behavior (e.g., `"bypassPermissions"` for CI)

### Built-in Tools

Claude Code's built-in tools (Read, Write, Edit, Bash, Glob, Grep, etc.) are available in SDK sessions — the same tools Claude uses in CLI mode. You can restrict which tools are allowed via the `allowedTools` / `allowed_tools` option.

### Hooks

[Hooks](../intermediate/hooks.md) work the same way in SDK sessions as in CLI sessions. Your `hooks.json` configuration fires on the same lifecycle events (PreToolUse, PostToolUse, Stop, etc.). You can also configure hooks programmatically via the options.

### Sub Agents

You can run [sub agents](sub-agents.md) from SDK sessions. The SDK supports the full agent delegation model — sub agents get their own context, tools, and permissions, just like when launched from the CLI.

### MCP Integration

[MCP servers](../intermediate/mcp.md) configured in your project are available in SDK sessions. You can also configure MCP servers programmatically via the options.

### Session Management

The SDK supports session continuity:

- **Resume** — continue a previous conversation by passing `options.sessionId` / `session_id`
- **Fork** — branch from a previous session to explore alternatives

This enables building multi-step workflows where each step picks up from the previous one.

### Permissions and Safety

In automated/CI contexts, use `options.permissionMode: "bypassPermissions"` (TypeScript) or `permission_mode="bypassPermissions"` (Python) — equivalent to `--dangerously-skip-permissions` in the CLI.

For production applications, prefer scoped tool restrictions via `allowedTools` / `allowed_tools` to limit what Claude can do.

### Structured Outputs

You can request structured output by passing a JSON schema via `options.outputFormat` / `output_format`. Claude will return a response conforming to the schema, useful for building pipelines that consume Claude's output programmatically.

---

## Cloud Provider Support

The SDK works with Claude on Bedrock, Vertex AI, and Azure Foundry via environment variables:

| Provider | Environment variables |
|---|---|
| **Amazon Bedrock** | `CLAUDE_CODE_USE_BEDROCK=1`, plus standard AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`) |
| **Google Vertex AI** | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| **Azure Foundry** | `CLAUDE_CODE_USE_AZURE=1`, plus Azure credentials |

These same environment variables work for both CLI and SDK usage.

---

## SDK vs Other Integration Methods

| Aspect | SDK | GitHub Actions | MCP | Hooks | CLI |
|---|---|---|---|---|---|
| **Primary use** | Embed in apps | CI/CD pipelines | Connect external tools | Lifecycle automation | Interactive use |
| **Language** | TypeScript, Python | YAML workflows | JSON config | Shell, HTTP, LLM prompts | Shell |
| **Structured output** | Yes (JSON schema) | Text only | N/A | N/A | Text / JSON |
| **Session management** | Resume, fork | Single-shot | N/A | N/A | Resume |
| **Tool control** | Programmatic | Via settings JSON | Server-defined | Event-based | Interactive |
| **Best for** | Custom tooling, pipelines, apps | Automated PR review, scheduled tasks | External services, databases | Guardrails, validation, logging | Day-to-day development |

---

## Real-World Example: Claude Code + Slack

[`claude-code-slack-vscode`](https://github.com/OriNachum/autonomous-intelligence) is a VS Code extension that bridges Claude Code with Slack using the Agent SDK. It demonstrates several advanced SDK patterns in a production context.

**What it does:** Lets you run Claude Code sessions from Slack threads, with bidirectional streaming of messages, permissions, and file uploads — all orchestrated through a VS Code extension.

**SDK features used:**

- **`query()`** — launches Claude sessions from TypeScript application code
- **`CanUseTool` permission callbacks** — custom permission flow where Slack Block Kit buttons and VS Code webview race to respond (first-response-wins)
- **Session management** — resume capability for long-running conversations
- **Hooks** — `Notification` and `SessionInit` events for lifecycle integration

**Architecture:**

```text
VS Code Extension
  └─► Agent SDK client (query())
        ├─► Claude Code session
        └─► Slack thread (bidirectional)
              ├─ Messages streamed to/from Slack
              ├─ Permission requests → Block Kit buttons
              └─ File uploads via Slack API
Python daemon (Docker) ─► Slack Socket Mode + file-based IPC
```

**Key pattern:** The permission flow is the most interesting part. When Claude requests tool approval, the `CanUseTool` callback sends a Block Kit message to Slack *and* shows a prompt in VS Code. Whichever responds first wins — the other is dismissed. This lets operators approve actions from their phone via Slack without needing VS Code open.

---

## Next Steps

- [Official SDK documentation](https://docs.anthropic.com/en/docs/claude-code/sdk) — full API reference, advanced options, and examples
- [GitHub Actions](../intermediate/github-actions.md) — if your use case is CI/CD, Actions may be simpler than the SDK
- [Hooks](../intermediate/hooks.md) — lifecycle automation that works in both CLI and SDK sessions
- [Sub Agents](sub-agents.md) — delegate tasks to specialist agents
- [Automating Your Workflows](../intermediate/automating-your-workflows.md) — overview of all automation mechanisms
