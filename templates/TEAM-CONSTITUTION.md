# Team constitution: table <name>

Copy this file to `tables/<table-name>/TEAM-CONSTITUTION.md`. Fill it in
during the breakout, load it as your assistant's rules file for run 2 of
`tasks/TASK.md`, then push branch `table-<name>` and open a pull request.

This file is your constitution: one part of a harness, the part that says what
always holds and what you learned the hard way.

Score without the constitution: _ / 7
Score with the constitution:    _ / 7
Traps that flipped and why (one line):

---

## 1. Which parts does a harness for your team need?

List them. Examples: rules, context, knowledge sources, guardrails, tracing
and governance, security, onboarding, review gates, connectors.

-

## 2. Per part: why does it need to be said, and what do you expect to gain?

One block per part. "Why" is ideally an incident or a recurring review
comment; "gain" is what changes on Monday if that part exists.

### <part>
- Why:
- Expected gain:

## 3. Which existing tools and services could you already connect or pull into your harness?

Issue tracker, ADR repo, CI, observability, wiki, code search, ticket
history, chat archive. Name the tool and what the assistant would read from it.

-

## 4. The one thing you would put in place next week

One sentence. Small enough to actually happen.

-

---

## Rules for the assistant

This section is your team's constitution: the part of the harness that says
what always holds and what was learned the hard way. Write the rules your
assistant should follow on this codebase. This is the part that gets loaded for the "with harness" run.
Short imperative rules with an origin note work best, for example:

- Before adding a dependency, check the wiki's `decisions/adr/` for a ban. (ADR-003)
