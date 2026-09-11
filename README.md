# Engineering Intelligence: the meetup starter kit

Material for the the/experts meetup "Engineering Intelligence. The next
skill in software engineering" (24 September 2026). Everything in this repo
is fictional: FlowMetrics is a made-up 40-person dev shop that bills API
usage. Nothing here refers to a real company or customer.

The evening's idea in one line: the model is a commodity, the leverage is the
harness a team builds around it. The harness is the whole environment around
the model: the knowledge it can reach, the rules and guardrails it works
under, the governance that records what it did, and the security boundary it
sits in. Tonight you write one part of that, your table's constitution, and
measure whether it changes what the assistant does.

## What is in here

| Path | What |
| --- | --- |
| `app/` | The FlowMetrics billing service. TypeScript on Node, express is the only dependency. Run it, read it, let your assistant change it. |
| (separate repo) the FlowMetrics wiki | FlowMetrics' institutional memory: ADRs, standards, runbooks, ways of working, meeting notes, `findings.json`. Lives outside this repo on purpose, see below. You get the address in part C. |
| `tasks/TASK.md` | The assignment, step by step. Start here. |
| `templates/TEAM-CONSTITUTION.md` | The breakout template: score header (out of 7), four questions, and your table's constitution. |
| `templates/PROMPTS.md` | Copy-paste prompts for each part, including one that interviews your table and drafts the constitution. |
| `scripts/score.sh` | Scores a run against the seven traps so you do not have to read the diff. |
| `tables/` | One folder per table. Your harness goes here. |
| `harness/` | The collective harness the room merges in the workshop: every table's constitution plus what surrounds it. |
| `scripts/seed-history.sh` | Rebuilds the FlowMetrics git history in a scratch clone so `git log` tells the story. |
| `mcp-server/` | Optional: a minimal MCP search tool over the wiki clone, for tables that want to connect a knowledge source. |

Why TypeScript: the meetup is language-agnostic and the interesting part is
the harness, not the app. TypeScript on a recent Node runs without a build
step, which keeps setup at "clone, npm install, go". A Java or Kotlin port is
welcome as a pull request.

## Before the evening

You need: a laptop, git, a GitHub account (for push access to this repo),
Node 22.18 or newer, and an AI coding assistant you can give a rules file to.
Claude Code, GitHub Copilot, Cursor, Codex CLI, Gemini CLI, Aider and
OpenCode all work. MCP support is a bonus for the connector segment, not a
requirement.

```bash
git clone https://github.com/the-experts/engineering-intelligence-meetup.git
cd engineering-intelligence-meetup/app
npm install
npm test
npm start          # GET http://localhost:3000/healthz
```

## Connect your assistant

The "with harness" run needs your table's `TEAM-CONSTITUTION.md` loaded as the
assistant's rules. The mechanics differ per tool:

| Tool | How |
| --- | --- |
| Claude Code | Copy or symlink your `TEAM-CONSTITUTION.md` to `CLAUDE.md` in the repo root, or `@`-mention it in the first prompt. |
| GitHub Copilot | Copy it to `.github/copilot-instructions.md`, or paste it into the chat as the first message. |
| Cursor | Copy it to `.cursor/rules/harness.md`. |
| Codex CLI, Gemini CLI, OpenCode, Aider | Copy it to `AGENTS.md` in the repo root (all four read that file), or paste it into the first prompt. |
| Anything else | Paste the rules section into the first prompt. It is a text file. |

Do not commit the copied `CLAUDE.md`, `AGENTS.md` or tool config; the
`.gitignore` already excludes them. Your table's `TEAM-CONSTITUTION.md` under `tables/`
is the source of truth.

## Running the assignment

**`tasks/TASK.md` is the assignment, with every command in order.** This
section is the short version.

Three parts, in this order:

- **A. Run 1, without a harness.** Fresh session, `app/` open as the project
  root, no rules file, branch `run-without`, paste the ticket, hands off,
  commit, `scripts/score.sh`.
- **B. Write your table's constitution.** From your own team's experience,
  not from FlowMetrics documents. `templates/PROMPTS.md` has a prompt that
  interviews you and drafts it.
- **C. Run 2, with your harness.** Now clone the wiki next to the repo, fresh
  session at the repo root, constitution loaded as rules, branch `run-with`,
  same ticket, commit, `scripts/score.sh`, push `table-<name>` and open a PR.

Order matters, and the wiki is the reason. FlowMetrics' knowledge does not
live in this repository; it lives in a second one, the way real teams keep
decisions in Confluence, Notion or a docs repo rather than next to the code.
You get that address in part C, on the slide. Cloning it earlier, or asking
an assistant to draft your constitution out of it, removes the thing the
evening is measuring.

**Scoring.** Run `scripts/score.sh` instead of reading the diff:

```bash
scripts/score.sh              # the branch you are on
scripts/score.sh run-without  # any other branch
```

It prints PASS, FAIL or CHECK per trap with a one-line reason. PASS and FAIL
are mechanical. CHECK means it will not guess and you decide; `PROMPTS.md`
has a prompt that asks a second session to settle those from the diff. Write
both scores at the top of your `TEAM-CONSTITUTION.md`.

Both run branches come off `main`, so the two scores are independent, and
both stay on your laptop: every table uses those same two names. What you
push is `table-<name>`, holding your folder under `tables/`. The agent's code
changes are not the deliverable; your constitution and the two scores are.

### Optional: connect the wiki as a knowledge source

From part C onwards, `mcp-server/` is a small MCP server with `search` and
`findings` tools over the wiki clone. See `mcp-server/README.md` for the
one-line config per tool. A table that connects it can test the difference
between "rules only" and "rules plus a searchable knowledge base".

## The evening's git flow

Per-table folders and per-table branches: no two tables ever write the same
file, so there are no merge conflicts to fight.

`main` is protected: no direct pushes, no force-pushes, no deletions. Every
table lands its work through a pull request. Per-table folders mean no two
tables ever touch the same file, so there is nothing to resolve.

**Breakout.** Pick a table name (one word, lowercase).

```bash
git switch -c table-<name> main
mkdir -p tables/<name>
cp templates/TEAM-CONSTITUTION.md tables/<name>/TEAM-CONSTITUTION.md
# ... fill it in, run the task without and with, put both scores at the top
git add tables/<name>
git commit -m "Table <name>: constitution and trap scores"
git push -u origin table-<name>     # a fork works too: push there and open the PR from it
gh pr create --fill                 # or open the PR in the browser
```

Your facilitator merges the pull requests at the end of the breakout, so the
whole room can pull every table's constitution from `main` in one go.

**Workshop round 1, merge (25 min).** Everyone pulls `main`, which now holds
every table's constitution. Each table lets its assistant merge all
`tables/*/TEAM-CONSTITUTION.md` into one `harness/` structure (rules,
knowledge, conventions, security, governance, connectors) and writes
contradictions to `harness/CONFLICTS.md`. Work on your own branch:

```bash
git switch main && git pull
git switch -c table-<name>-collective
# ... merge into harness/, commit
```

**Round 2, test (15 min).** Run the task once more with `harness/` loaded as
the rules. Record the score in `harness/SCORE.md`. If it scored lower than
your own table's file, write down why: that is the best material of the night.

**Round 3, tweak and push (20 min).**

```bash
# ... tweak harness/, re-run once, update SCORE.md
git push -u origin table-<name>-collective
gh pr create --fill
```

The strongest collective version gets merged to `main` after the evening and
the link goes out by mail.

**Cannot push?** Corporate laptop, no GitHub account, wifi trouble: zip your
`tables/<name>` folder (or your `harness/` folder in round 3) and hand it to a
facilitator on the USB stick or via the shared drive link on the slide. They
push it for you under your table name. Forking this repo and opening the pull
request from your fork needs no access from us at all.

## For the facilitators

The score sheet, the run of show and the measurement results live in a
separate private repository, not in this one and not on a side branch. An
assistant that can reach them scores full marks without a harness. Ask Lars
for access.

`main` is protected: pull requests only, no force-pushes, no deletions. Any `table-*` branch is open, and forks work without us granting anything.

## After the evening

The merged harness, every table's file and the scores stay in this repo.
Keep contributing rules: a rule with an origin note that stopped a real
mistake is worth a pull request.

## Licence

MIT for the code, CC BY 4.0 for the templates and for the wiki repository.
