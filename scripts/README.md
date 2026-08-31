# scripts

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
