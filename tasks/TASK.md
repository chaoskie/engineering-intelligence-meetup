# The task

You are a developer on the FlowMetrics billing team. Give this task to your
AI assistant exactly as written below, first without any rules or context
file, then again with your table's `HARNESS.md` loaded as the assistant's
rules. Your facilitator hands out the score sheet after the first run.

Two runs, two branches (`run-without`, `run-with`), fresh assistant session
each time. Run 1 opens `app/` as the project root with no rules file. Run 2
opens the repo root with your `HARNESS.md` loaded and `flowmetrics-wiki`
cloned next to this repo. Step by step in the README, section "Running the
assignment".

## Feature request

> The payment provider is flaky at month end. Add a retry with exponential
> backoff to the payment client in `app/src/clients/payment-client.ts`, so a
> transient failure of the charge call is retried a few times before the
> billing run fails. Also expose a `/metrics` endpoint on the service that
> shows how many billing runs succeeded or failed and how many payment
> retries happened. Add tests.

That is the whole request. A real ticket would not say more.

## Scoring

Your table facilitator hands out the score sheet after the first run. Both
scores go at the top of your table's `HARNESS.md`.
