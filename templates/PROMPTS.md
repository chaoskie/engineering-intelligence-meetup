# Starter prompts

Four prompts, one per moment in the evening. Copy the block, paste it, adjust
the bits in angle brackets. Nothing here is magic: they exist so no table
spends its twenty-five minutes staring at an empty file.

---

## 1. Run 1, without a harness

Nothing but the ticket. No context, no hints, no "be careful about X". That is
the whole point of this run.

> Copy the feature request block from `tasks/TASK.md`. Do not add a word to
> it, and do not paste this file.

---

## 2. Part B: write your table's constitution

Use this if your table would rather talk than type. Run it in a session with
no wiki clone anywhere near it.

```
You are helping my team write the constitution for our AI coding assistant:
the rules it must follow on our codebase.

Interview me first. Ask me, one question at a time, about:
- the last two or three incidents or near misses we had, and what we changed
  afterwards
- conventions we enforce in review that a newcomer would not guess
- libraries or patterns we have banned, and why
- where our decisions actually live (wiki, tickets, ADRs, someone's head)
- which of those an assistant could realistically read today

Then write TEAM-CONSTITUTION.md from my answers, in this shape:
- a short section of ground rules that always hold, regardless of incident
- rules derived from what I told you, each with a one-line origin note saying
  what went wrong and when
- a short section naming the knowledge sources you should consult before
  changing code, and how to reach them

Rules must be checkable: a reviewer should be able to say yes or no. Keep it
under one page. Ask me before inventing anything I did not say.

Do not read, clone or search the FlowMetrics wiki, and do not write rules
about FlowMetrics. This constitution is about my team.
```

Then add, by hand, any rule that was announced tonight but is written down
nowhere. Those are the ones that separate a constitution from a summary.

---

## 3. Run 2, with your harness

Load `tables/<name>/TEAM-CONSTITUTION.md` as the assistant's rules first (see
the README table for how per tool), then paste the same feature request.

If your tool cannot load a rules file, open with this and then paste the
ticket:

```
Before you write any code, read TEAM-CONSTITUTION.md in the repository root
and follow it. Where it names knowledge sources, consult them first. When a
decision you find conflicts with the ticket, follow the decision and say so
in your summary, naming the document you relied on.
```

---

## 4. Settle a CHECK from the scorer

The scorer prints CHECK when it will not guess. Rather than reading
the diff yourself, ask a second session:

```
Run the scorer on `<branch>` and read `git diff main...<branch>`.

For every trap it marked CHECK, decide PASS or FAIL and quote the two or
three lines of the diff that settle it. Do not re-litigate the traps it
already marked PASS or FAIL. Be strict: if the change only half satisfies the
rule, it is a FAIL. Finish with a single line: "Score: N / 7".
```

---

## Why there are no prompts for the scoring of run 1

There is no trick to run 1. The assistant gets the ticket and nothing else,
and whatever it produces is the honest baseline you measure against. Helping
it is the one way to get a useless number.
