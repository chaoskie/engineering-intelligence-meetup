# The task

You are a developer on the FlowMetrics billing team. A ticket lands on your
desk. You give it to your AI assistant twice: once with nothing but the code,
and once with your table's constitution loaded as the assistant's rules. The
interesting part is the difference between the two.

The ticket touches decisions this team already made. Your assistant has never
heard of any of them.

**One rule all evening: do not help the assistant.** No hints, no
corrections, no "you forgot something". The moment you steer it, you are
measuring yourself instead of the constitution.

---

## Part A: run 1, without a harness

1. Clone the repo and install, once per laptop:

   ```bash
   git clone https://github.com/the-experts/engineering-intelligence-meetup.git
   cd engineering-intelligence-meetup/app
   npm install
   cd ..
   ```

2. Make your branch for this run. It stays on your laptop, you never push it:

   ```bash
   git switch -c run-without main
   ```

3. Start a **fresh** assistant session with **no rules file**, and open
   `app/` as the project root. Not the repo root: a developer who was asked
   to change the service would open the service.

4. Copy the feature request below into the assistant. Only that block.

5. Let it finish. Hands off.

6. Commit whatever it produced, and do not push:

   ```bash
   git add -A && git commit -m "run without a harness"
   ```

7. Score it:

   ```bash
   git fetch origin scorer
   git show origin/scorer:score.sh > /tmp/score.sh
   sh /tmp/score.sh
   ```

   Works on macOS and Linux as is. On Windows, run it in Git Bash, which
   comes with Git for Windows; `/tmp` exists there too.

   Write the score on the sheet your facilitator hands out.

8. Go back to the starting point and wait for part B:

   ```bash
   git switch main
   ```

---

## The feature request

Copy everything between the lines into your assistant, nothing else. Not this
file, not the steps around it. Just this.

--------------------------------------------------------------------------

The payment provider is flaky at month end. Add a retry with exponential
backoff to the charge call in the payment client (`payment-client.ts`), so a
transient failure is retried a few times before the billing run fails. Also
expose a `/metrics` endpoint on the service that shows how many billing runs
succeeded or failed and how many payment retries happened. Add tests.

--------------------------------------------------------------------------

That is the whole ticket. A real one would not say more.

---

## Part B: write your table's constitution

Between the two runs you write the rules. This is the part that decides the
second score.

```bash
git switch -c table-<name> main
mkdir -p tables/<name>
cp templates/TEAM-CONSTITUTION.md tables/<name>/TEAM-CONSTITUTION.md
```

Fill it in as a table. It is about **your** team: your incidents, your
conventions, your tooling. `templates/PROMPTS.md` has a prompt that
interviews you and writes the file from your answers if you would rather talk
than type.

Do not clone the wiki yet, and do not ask an assistant to write your
constitution out of FlowMetrics documents. A constitution copied from a
knowledge base you have not read is not a constitution, and it is not the
exercise.

---

## Part C: run 2, with your harness

1. Now clone the wiki next to the repo. The address is on the slide.

   ```bash
   cd ..
   git clone <wiki-url>
   cd engineering-intelligence-meetup
   ```

2. Branch again from the same starting point:

   ```bash
   git switch -c run-with main
   ```

3. Fresh session again, this time with the **repo root** open and your
   `tables/<name>/TEAM-CONSTITUTION.md` loaded as the assistant's rules. The
   README table shows how per tool.

4. Copy the same feature request, word for word. Hands off again.

5. Commit and score:

   ```bash
   git add -A && git commit -m "run with our constitution"
   sh /tmp/score.sh
   ```

6. Put both scores at the top of your `TEAM-CONSTITUTION.md`, with one line
   on which traps flipped and why you think they did.

7. Push your table branch and open a pull request:

   ```bash
   git switch table-<name>
   git add tables/<name> && git commit -m "Table <name>: constitution and scores"
   git push -u origin table-<name>
   gh pr create --fill
   ```

---

## Scoring

The scorer checks the seven traps mechanically and prints PASS, FAIL
or CHECK per trap. PASS and FAIL you can trust. CHECK means the script will
not guess and you decide, which is rare and takes a minute.

```bash
sh /tmp/score.sh        # the branch you are on
the scorer run-without  # any other branch
```

Both run branches come off `main`, so the two scores are independent. Both
branches stay on your laptop: every table uses those same two names. The only
branch that leaves your machine is `table-<name>`.

The assistant's code is not the deliverable. Your constitution and the two
scores are.
