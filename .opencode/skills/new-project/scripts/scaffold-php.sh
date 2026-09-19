#!/usr/bin/env bash
set -euo pipefail

# PHP/Laravel scaffold: wire the devshell and GitHub workflows, then load the
# devshell and install dependencies.
#
# Usage: scaffold-php.sh <name> [module|app]
#   name - project / repo name (must already be scaffolded by scaffold.sh)
#   type - "module" (default) or "app"
#
# This is the PHP-specific part of new-project (Steps 3, 6). Run it after
# scaffold.sh.

NAME="${1:?usage: scaffold-php.sh <name> [module|app]}"
TYPE="${2:-module}"
DIR="$HOME/Development/$NAME"
cd "$DIR"

# Step 3: wire the devshell submodule (init if the skeleton already declares it)
if grep -q 'path = devshell' .gitmodules 2>/dev/null; then
  git submodule update --init --recursive
else
  git submodule add git@github.com:99linesofcode/devshell-php.git devshell
fi

# Step 3: copy the thin-wrapper workflows, but only if the skeleton didn't
# already ship them (laravel-skeleton / laravel-package-skeleton do).
if [ ! -f .github/workflows/automatic-updates.yaml ]; then
  # Ensure the PHP wrapper repo is present locally (clone if missing, pull if present)
  GITHUB_PHP="$HOME/Development/.github-php"
  if [ ! -d "$GITHUB_PHP/.git" ]; then
    git clone git@github.com:99linesofcode/.github-php.git "$GITHUB_PHP"
  else
    git -C "$GITHUB_PHP" pull --ff-only
  fi

  mkdir -p .github/workflows
  if [ "$TYPE" = "app" ]; then
    cp "$GITHUB_PHP"/workflows/*.yaml .github/workflows/
  else
    cp "$GITHUB_PHP"/workflows/automatic-updates.yaml \
       "$GITHUB_PHP"/workflows/changelog.yaml .github/workflows/
  fi
fi

# Step 6: load the devshell + install
direnv allow
composer install

echo "PHP scaffold complete for $NAME ($TYPE)."
