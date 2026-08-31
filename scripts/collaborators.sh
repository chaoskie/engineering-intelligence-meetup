#!/usr/bin/env bash
# Manage push access for meetup participants (outside collaborators, permission: push).
# Usage:
#   scripts/collaborators.sh add <github-user> [<github-user> ...]
#   scripts/collaborators.sh add-file usernames.txt      # one username per line, # comments ok
#   scripts/collaborators.sh list
#   scripts/collaborators.sh remove-all                   # revoke every outside collaborator (run the day after)
# Requires: gh (logged in as someone with admin on the repo).
set -euo pipefail
REPO="${REPO:-the-experts/engineering-intelligence-meetup}"

add() { for u in "$@"; do
  gh api -X PUT "repos/$REPO/collaborators/$u" -f permission=push >/dev/null && echo "invited: $u" || echo "FAILED: $u" >&2
done; }

case "${1:-}" in
  add) shift; add "$@" ;;
  add-file) shift; mapfile -t users < <(grep -vE '^\s*(#|$)' "$1" | tr -d ' @'); add "${users[@]}" ;;
  list) gh api "repos/$REPO/collaborators?affiliation=outside" --jq '.[].login'
        echo "-- pending invitations:"; gh api "repos/$REPO/invitations" --jq '.[].invitee.login' ;;
  remove-all)
    for u in $(gh api "repos/$REPO/collaborators?affiliation=outside" --jq '.[].login'); do
      gh api -X DELETE "repos/$REPO/collaborators/$u" && echo "removed: $u"; done
    for id in $(gh api "repos/$REPO/invitations" --jq '.[].id'); do
      gh api -X DELETE "repos/$REPO/invitations/$id" && echo "cancelled invitation: $id"; done ;;
  *) sed -n 2,8p "$0"; exit 1 ;;
esac
