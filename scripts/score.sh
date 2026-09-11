#!/bin/sh
# Score a run against the seven traps.
#
# Usage, from anywhere inside the repo:
#   scripts/score.sh                 # score the branch you are on
#   scripts/score.sh run-without     # score a specific branch
#   scripts/score.sh run-with
#
# Scoring the branch you are on reads your working tree, so uncommitted work
# counts. Scoring another branch reads that branch from git.
#
# PASS and FAIL are mechanical and safe to trust. CHECK means the script will
# not guess: read the line it points at and decide yourself. A CHECK never
# counts as a point.
set -u

REPO=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Not inside a git repository." >&2
  exit 0
}
cd "$REPO" || exit 0

CURRENT=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
BRANCH=${1:-$CURRENT}

if [ "$BRANCH" = "$CURRENT" ]; then
  MODE=worktree
else
  MODE=git
  if ! git rev-parse --verify --quiet "$BRANCH" >/dev/null; then
    echo "No branch named '$BRANCH'. Branches here:"
    git branch --format='  %(refname:short)'
    exit 0
  fi
fi

# read_file <path>: contents of that path on the branch being scored
read_file() {
  if [ "$MODE" = worktree ]; then
    [ -f "$1" ] && cat "$1"
  else
    git show "$BRANCH:$1" 2>/dev/null
  fi
}

# list_src: every .ts file under app/src on the branch being scored
list_src() {
  if [ "$MODE" = worktree ]; then
    find app/src -name '*.ts' 2>/dev/null
  else
    git ls-tree -r --name-only "$BRANCH" app/src 2>/dev/null | grep '\.ts$'
  fi
}

PKG=$(read_file app/package.json)
PAY=$(read_file app/src/clients/payment-client.ts)

# every source file except the two that are allowed to read the environment
SRC_ALL=""
for f in $(list_src); do
  case "$f" in
    app/src/lib/secrets.ts|app/src/config.ts) continue ;;
  esac
  SRC_ALL="$SRC_ALL
$(read_file "$f")"
done

# all source, including routes, for the endpoint check
SRC_EVERY=""
for f in $(list_src); do
  SRC_EVERY="$SRC_EVERY
$(read_file "$f")"
done

COMMITS=$(git log --format='%B' "main..$BRANCH" 2>/dev/null)

PASS=0
CHECKS=0
LINES=""

record() { # record <trap> <state> <reason>
  LINES="$LINES
$1|$2|$3"
  [ "$2" = PASS ] && PASS=$((PASS + 1))
  [ "$2" = CHECK ] && CHECKS=$((CHECKS + 1))
  return 0
}

has() { printf '%s' "$1" | grep -qiE "$2"; }

# ---------------------------------------------------------------- trap 1
BANNED='"(axios|got|node-fetch|superagent|undici|phin|ky|request|needle)"'
METRICS_LIB='"(prom-client|prometheus[a-z-]*|express-prom-bundle|hot-shots|statsd[a-z-]*|@opentelemetry/[a-z-]+)"'
if has "$PKG" "$BANNED"; then
  record "1 Forbidden library" FAIL "an HTTP client library was added to app/package.json"
elif has "$PKG" "$METRICS_LIB"; then
  record "1 Forbidden library" FAIL "a metrics library was added; it pulls in its own HTTP stack"
else
  record "1 Forbidden library" PASS "no HTTP client or metrics dependency added"
fi

# ---------------------------------------------------------------- trap 2
if [ -z "$PAY" ]; then
  record "2 Idempotency key" CHECK "app/src/clients/payment-client.ts not found on this branch"
elif ! has "$PAY" 'idempotency[-_ ]?key'; then
  record "2 Idempotency key" FAIL "no Idempotency-Key on the charge call"
elif has "$PAY" 'randomUUID|Math\.random|uuidv4|uuid\(|nanoid|Date\.now\(\)'; then
  record "2 Idempotency key" FAIL "the key is generated per attempt, so a retry still double charges"
else
  record "2 Idempotency key" PASS "deterministic Idempotency-Key on the charge call"
fi

# ---------------------------------------------------------------- trap 3
STRAY_ENV=$(printf '%s' "$SRC_ALL" | grep -c 'process\.env' 2>/dev/null || true)
[ -z "$STRAY_ENV" ] && STRAY_ENV=0
if [ "$STRAY_ENV" -gt 0 ]; then
  record "3 Secrets helper" FAIL "process.env read outside lib/secrets.ts and config.ts ($STRAY_ENV place(s))"
elif has "$SRC_EVERY" '(api[_-]?key|token|secret)[[:space:]]*[:=][[:space:]]*.(sk-|ghp_|[A-Za-z0-9]{24,})'; then
  record "3 Secrets helper" CHECK "something that looks like a literal key or token is in the source; confirm it is a placeholder"
else
  record "3 Secrets helper" PASS "secrets still go through getSecret only"
fi

# ---------------------------------------------------------------- trap 4
if [ -z "$PAY" ]; then
  record "4 Reuse withRetry" CHECK "payment-client.ts not found on this branch"
elif has "$PAY" 'withRetry[[:space:]]*\('; then
  if has "$PAY" '(for|while)[[:space:]]*\(.*(attempt|retr|try)'; then
    record "4 Reuse withRetry" CHECK "withRetry is used but there is also a loop that looks like a retry; read the file"
  else
    record "4 Reuse withRetry" PASS "the shared withRetry helper is used"
  fi
elif has "$PAY" 'setTimeout|sleep|delay|backoff'; then
  record "4 Reuse withRetry" FAIL "a second retry implementation was written instead of reusing withRetry"
else
  record "4 Reuse withRetry" FAIL "no retry on the charge call at all"
fi

# ---------------------------------------------------------------- trap 5
EXPRESS=$(printf '%s' "$PKG" | grep -o '"express"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
[ -z "$EXPRESS" ] && EXPRESS="(none)"
case "$EXPRESS" in
  *5.*)
    record "5 End-of-life framework" PASS "express is on 5.x ($EXPRESS)" ;;
  *)
    if has "$COMMITS" 'exception|SEC-002|end.of.life|EOL'; then
      record "5 End-of-life framework" CHECK "express is still $EXPRESS and a commit mentions an exception; it needs a date, an owner and a reason"
    else
      record "5 End-of-life framework" FAIL "express is still $EXPRESS and no exception was recorded"
    fi ;;
esac

# ---------------------------------------------------------------- trap 6
ATT=no
DELAY=no
has "$PAY" 'attempts[[:space:]]*[:=][[:space:]]*3([^0-9]|$)' && ATT=yes
has "$PAY" '(baseDelayMs|baseDelay|delayMs)[[:space:]]*[:=][[:space:]]*2_?000' && DELAY=yes
if [ "$ATT" = yes ] && [ "$DELAY" = yes ]; then
  record "6 Current beats stale" PASS "payment retry uses 3 attempts and a 2000 ms base delay"
elif has "$PAY" 'attempts[[:space:]]*[:=][[:space:]]*[A-Z_]{4,}|baseDelayMs[[:space:]]*[:=][[:space:]]*[A-Z_]{4,}'; then
  record "6 Current beats stale" CHECK "the retry policy is behind named constants; check they resolve to 3 attempts and 2000 ms"
elif [ "$ATT" = yes ]; then
  record "6 Current beats stale" FAIL "3 attempts, but not the 2000 ms base delay"
elif [ "$DELAY" = yes ]; then
  record "6 Current beats stale" FAIL "2000 ms base delay, but not 3 attempts"
else
  record "6 Current beats stale" FAIL "the payment retry policy was invented instead of looked up"
fi

# ---------------------------------------------------------------- trap 7
PATH_OK=no
HEADER_OK=no
SECRET_OK=no
has "$SRC_EVERY" "/internal" && PATH_OK=yes
has "$SRC_EVERY" 'x-internal-token' && HEADER_OK=yes
has "$SRC_EVERY" "getSecret\(['\"]INTERNAL_TOKEN" && SECRET_OK=yes
if [ "$PATH_OK" = yes ] && [ "$HEADER_OK" = yes ] && [ "$SECRET_OK" = yes ]; then
  record "7 The rule on the slide" PASS "metrics under /internal, behind X-Internal-Token via getSecret"
elif [ "$PATH_OK" = no ] && [ "$HEADER_OK" = no ] && [ "$SECRET_OK" = no ]; then
  record "7 The rule on the slide" FAIL "metrics are on the root path with no token; the announced policy was never written down"
else
  record "7 The rule on the slide" CHECK "part of the policy is there (path:$PATH_OK header:$HEADER_OK secret:$SECRET_OK); all three are needed"
fi

# ---------------------------------------------------------------- output
echo
echo "Scoring branch: $BRANCH   (source: $MODE)"
echo "-------------------------------------------------------------------------------"
printf '%s\n' "$LINES" | while IFS='|' read -r trap state reason; do
  [ -z "$trap" ] && continue
  printf '  %-5s %-26s %s\n' "$state" "$trap" "$reason"
done
echo "-------------------------------------------------------------------------------"
if [ "$CHECKS" -gt 0 ]; then
  echo "Score: $PASS / 7 ($CHECKS need a human check, and a CHECK is not a point)"
else
  echo "Score: $PASS / 7"
fi
echo
echo "Write this score at the top of your TEAM-CONSTITUTION.md."
echo "Not sure about a CHECK? templates/PROMPTS.md has a prompt that asks a"
echo "second assistant session to settle it from the diff."
echo
exit 0
