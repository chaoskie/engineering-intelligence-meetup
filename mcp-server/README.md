# flowmetrics-wiki MCP server

A dependency-free MCP server (stdio) with two tools over a clone of the
`flowmetrics-wiki` repository:

- `search(query, limit?)`: keyword search over the markdown docs, returns
  paths, titles and snippets. Documents carry status headers; superseded
  and stale ones are in the index on purpose.
- `findings(pattern?, adr_ref?, category?)`: filter and count the structured
  findings. Try `pattern: "config-drift"`. Keyword search finds knowledge;
  it cannot count. This tool can.

Wiki location, in order: first argument, `WIKI_DIR`, else
`../flowmetrics-wiki` relative to the meetup repo (a clone next to it).

Run the tests: `cd mcp-server && npm test`. Needs the wiki cloned next to
the repo. No install needed.

## Connect it

Replace `/abs/path` with your clone path.

| Tool | Config |
| --- | --- |
| Claude Code | `claude mcp add flowmetrics-wiki -- node /abs/path/mcp-server/server.ts /abs/path/../flowmetrics-wiki` |
| Cursor, Codex CLI, OpenCode, Gemini CLI, Copilot (VS Code) | Add a stdio server named `flowmetrics-wiki` with command `node` and args `["/abs/path/mcp-server/server.ts", "/abs/path/../flowmetrics-wiki"]` in the tool's MCP config file. |

Then ask your assistant: "Why did FlowMetrics ban axios?", "How many
findings share the config-drift pattern?" and "How many times may a payment
call be retried?" and watch which tool it picks, and which document it
trusts.
