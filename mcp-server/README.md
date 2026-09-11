# Wiki MCP server

A dependency-free MCP server (stdio) with two tools over a clone of the
FlowMetrics wiki repository. You get the address of that repository in part C
of the assignment; it is on the slide. Nothing here needs it before then:

- `search(query, limit?)`: keyword search over the markdown docs, returns
  paths, titles and snippets. Documents carry status headers; superseded
  and stale ones are in the index on purpose.
- `findings(pattern?, adr_ref?, category?)`: filter and count the structured
  findings. Try `pattern: "config-drift"`. Keyword search finds knowledge;
  it cannot count. This tool can.

Wiki location, in order: first argument, then the `WIKI_DIR` environment
variable, else `../flowmetrics-wiki` relative to the meetup repo, which is
where it lands if you clone it next to this one.

Run the tests: `cd mcp-server && npm test`. Needs the wiki cloned next to
the repo, so this only works from part C onwards. No install needed.

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
