#!/usr/bin/env bash
set -euo pipefail

# Generic project scaffold: create the project dir, init git, wire the base
# skeleton, create the GitHub repo, and apply the canonical labels.
#
# Usage: scaffold.sh <name> [base-skeleton]
#   name          - project / repo name (e.g. laravel-module-todo)
#   base-skeleton - base skeleton repo, without the 99linesofcode/ prefix
#                   (default: git-skeleton)
#
# This is the language-agnostic part of new-project (Steps 1, 2, 4). The
# language-specific wiring (devshell, workflows, install) lives in
# scaffold-<lang>.sh.

NAME="${1:?usage: scaffold.sh <name> [base-skeleton]}"
BASE="${2:-git-skeleton}"
DIR="$HOME/Development/$NAME"

# Step 1: create the project directory + init git
mkdir -p "$DIR"
cd "$DIR"
git init -b main

# Step 2: add the base skeleton as a remote and reset onto it
git remote add origin "git@github.com:99linesofcode/$NAME.git"
git remote add skeleton "git@github.com:99linesofcode/$BASE.git"
git fetch skeleton
git reset --hard skeleton/main

# Step 4: create the GitHub repo
gh repo create "99linesofcode/$NAME" --public --description ""

# Step 4: apply the canonical Shape Up labels in a single swipe
for l in accessibility bug documentation duplicate enhancement "good first issue" \
         "help wanted" invalid question wontfix; do
  gh label delete "$l" --repo "$NAME" --yes 2>/dev/null || true
done

while IFS='|' read -r label color desc; do
  gh label create "$label" --repo "$NAME" --color "$color" --description "$desc" --force
done <<'EOF'
type: slice|c3b1e1|The big picture, sliced
type: pitch|f2d5b3|Shaped and ready to bet
type: task|b9e0c4|The doing
type: bug|f0b6b6|Something broken
type: chore|b8d0e8|The little stuff
EOF

# Step 4: set Actions workflow permissions (read/write + allow approving PRs)
# so the automatic-updates workflow can approve and merge Dependabot PRs.
gh api -X PUT "repos/99linesofcode/$NAME/actions/permissions" \
  -f enabled=true \
  -f default_workflow_permissions=write \
  -f can_approve_pull_request_reviews=true

echo "Scaffolded $NAME from $BASE in $DIR"
echo "Next: run scaffold-<lang>.sh $NAME for the language-specific wiring."
