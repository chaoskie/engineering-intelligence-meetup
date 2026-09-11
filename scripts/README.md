# scripts

`score.sh` scores a run against the seven traps and prints PASS, FAIL or
CHECK per trap with the reason. PASS and FAIL are mechanical; CHECK means it
will not guess and you decide. It never counts a CHECK as a point.

```bash
scripts/score.sh                 # the branch you are on, working tree included
scripts/score.sh run-without     # any other branch, read from git
```

`seed-history.sh` rebuilds the FlowMetrics history: about twenty backdated
commits, each referencing the ADR or incident it came from. `main` already
carries that history, so you do not need to run this. It exists so the
history is reproducible, and it builds into a separate branch
(`flowmetrics-history`) in a scratch clone, never touching your working tree:

```bash
scripts/seed-history.sh
git log --date=short --format='%ad %an %s' flowmetrics-history
```

`collaborators.sh` manages push access for participants (outside
collaborators with push permission; no org membership needed). Collect
GitHub usernames in the prerequisites mail, invite the day before with
`scripts/collaborators.sh add-file usernames.txt`, and revoke everyone the
day after with `scripts/collaborators.sh remove-all`. Needs `gh` logged in
with admin rights on the repo.
