# The scorer

This branch exists so the scorer is not sitting in the working tree while an
assistant is solving the task. It names all seven traps, which is exactly what
run 1 is supposed to find out the hard way.

Fetch and run it from a checkout of `main`:

```bash
git fetch origin scorer
git show origin/scorer:score.sh > /tmp/score.sh
sh /tmp/score.sh            # scores the current branch
sh /tmp/score.sh run-with   # or a named branch
```

Facilitators: the printed score sheet carries the same seven traps in prose
and is the primary tool at the table. This is the fast path for people who
would rather let a script count.
