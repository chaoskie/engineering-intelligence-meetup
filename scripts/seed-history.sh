#!/usr/bin/env bash
# Rebuild the FlowMetrics story as git history.
#
# Rebuilds the FlowMetrics history: about twenty backdated commits whose
# messages reference the ADRs and incidents that live in the flowmetrics-wiki
# repository. This is how `main` got its history; the generated branch is
# `flowmetrics-history` so you can inspect or regenerate it without touching
# your current branch or working tree (it works in a scratch clone).
#
# Usage, from anywhere inside the repo:
#   scripts/seed-history.sh            # build branch flowmetrics-history
#   git log --date=short flowmetrics-history
#
# Idempotent: running it twice replaces the branch with the same content.
set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"
BRANCH="flowmetrics-history"
SRC_REF="${SRC_REF:-HEAD}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "snapshotting $SRC_REF into scratch clone"
git -C "$REPO" clone -q --no-local "$REPO" "$TMP/clone"
mkdir -p "$TMP/tree"
git -C "$REPO" archive "$SRC_REF" | tar -x -C "$TMP/tree"

cd "$TMP/clone"
git config user.name  "FlowMetrics Team"
git config user.email "team@flowmetrics.example"
git checkout -q --orphan "$BRANCH"
git rm -rfq --cached . >/dev/null 2>&1 || true
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +

# Author roster. Rotated per commit for variety.
AUTHORS=(
  "Mara Visser <mara@flowmetrics.example>"
  "Jonas Bakker <jonas@flowmetrics.example>"
  "Priya Nair <priya@flowmetrics.example>"
  "Tom de Wit <tom@flowmetrics.example>"
)
n=0

# add <date> <message> <paths...>: copy paths from the snapshot and commit.
add() {
  local date="$1" msg="$2"; shift 2
  local author="${AUTHORS[$((n % ${#AUTHORS[@]}))]}"; n=$((n + 1))
  for p in "$@"; do
    # Wiki documents moved to the flowmetrics-wiki repo; commits that only
    # referenced them stay as story commits without file changes.
    [ -e "$TMP/tree/$p" ] || continue
    mkdir -p "$(dirname "$p")"
    cp -r "$TMP/tree/$p" "$p"
  done
  git add -A
  GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" \
    git commit -q --allow-empty --author="$author" -m "$msg"
}

add "2024-02-12T10:00:00+01:00" "ADR-001: billing is one service, not a platform" \
  corpus/README.md corpus/adr/ADR-001-usage-billing-service-scope.md
add "2024-02-20T14:30:00+01:00" "ADR-002: TypeScript on Node, minimal dependencies

Scaffold the service: config, logger, health route." \
  corpus/adr/ADR-002-typescript-on-node.md app/package.json app/package-lock.json app/tsconfig.json .gitignore \
  app/src/config.ts app/src/lib/logger.ts app/src/routes/health.ts app/src/server.ts
add "2024-03-01T09:15:00+01:00" "CONV-001: module layout for clients, lib and routes" \
  corpus/standards/CONV-001-module-layout.md
add "2024-03-22T16:40:00+01:00" "Usage collector client and first pricing table" \
  app/src/clients/usage-client.ts app/src/billing.ts
add "2024-04-05T11:00:00+02:00" "Post-mortem INC-2024-04: staging pointed at production payments (F-002)" \
  corpus/runbooks/RUNBOOK-incident-response.md
add "2024-06-03T13:20:00+02:00" "ADR-004 and CONV-002: structured JSON logging after INC-2024-05" \
  corpus/adr/ADR-004-structured-logging.md corpus/standards/CONV-002-logging.md
add "2024-07-15T10:05:00+02:00" "ADR-005 and SEC-001: config from environment, secrets through the helper

Seven findings share the config-drift pattern. Introduce lib/secrets.ts
and .env.example; the API key from F-004 has been rotated." \
  corpus/adr/ADR-005-config-from-environment.md corpus/standards/SEC-001-secrets-handling.md \
  app/src/lib/secrets.ts app/.env.example
add "2024-09-10T15:45:00+02:00" "CONV-003: validate at the route after F-006" \
  corpus/standards/CONV-003-input-validation.md
add "2024-11-28T09:30:00+01:00" "ADR-003: ban third-party HTTP clients, add lib/http.ts over fetch

INC-2024-11: a client library update dropped the auth header on redirect.
All outbound HTTP now goes through one wrapper." \
  corpus/adr/ADR-003-no-third-party-http-clients.md app/src/lib/http.ts
add "2025-01-20T11:10:00+01:00" "ADR-006: billing runs are async, POST /billing/runs returns 202" \
  corpus/adr/ADR-006-billing-moves-to-async.md app/src/routes/billing.ts app/src/app.ts
add "2025-02-10T17:00:00+01:00" "ADR-007: idempotency keys on every payment provider call

INC-2025-02: a retried batch charged 212 tenants twice. Standard written up
in the wiki, owner Priya." \
  corpus/adr/ADR-007-idempotency-keys-on-payment-calls.md app/src/clients/payment-client.ts
add "2025-03-18T10:20:00+01:00" "CONV-004: shared retry helper with backoff, reuse it (INC-2025-03)

The collector had a hand-rolled retry loop without backoff. Extract
lib/retry.ts and move usage-client onto it." \
  corpus/standards/CONV-004-reuse-shared-helpers.md app/src/lib/retry.ts app/test/retry.test.ts
add "2025-04-02T14:00:00+02:00" "CONV-005: the enforcement ladder" \
  corpus/standards/CONV-005-enforcement-ladder.md
add "2025-05-06T09:50:00+02:00" "ADR-008: metrics on /metrics in Prometheus format (F-015)" \
  corpus/adr/ADR-008-metrics-endpoint-prometheus.md
add "2025-06-30T12:00:00+02:00" "SEC-001 tightened after F-014: never log secret prefixes" \
  corpus/ways-of-working/review-process.md
add "2025-09-15T10:30:00+02:00" "Run TypeScript directly on Node, drop the build step (ADR-002 revisited)" \
  app/test/billing.test.ts app/test/health.test.ts
add "2026-01-12T11:00:00+01:00" "Review incident runbook, add billing-run runbook" \
  corpus/runbooks/RUNBOOK-billing-run.md
add "2026-03-02T09:00:00+01:00" "Onboarding guide and definition of done" \
  corpus/ways-of-working/onboarding.md corpus/ways-of-working/definition-of-done.md
add "2026-05-11T15:30:00+02:00" "Findings registry: 25 post-mortem findings with pattern taxonomy" \
  corpus/findings.json
add "2026-08-31T16:45:00+02:00" "Meetup kit: task, harness template, table folders, README, scripts" \
  tasks templates tables harness README.md scripts $( [ -d "$TMP/tree/mcp-server" ] && echo mcp-server ) \
  $( [ -f "$TMP/tree/DRYRUN-NOTES.md" ] && echo DRYRUN-NOTES.md )

echo "built $(git rev-list --count HEAD) commits, pushing branch $BRANCH back to $REPO"
git push -q --force "$REPO" "$BRANCH:$BRANCH"
echo "done: git log --date=short --format='%ad %an %s' $BRANCH"
