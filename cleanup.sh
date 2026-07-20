#!/usr/bin/env bash
restore(){
    echo "Restoring old branch..."

    git checkout main
    git branch -D clean-stage

    echo "Restored."
    exit 1
}
set -euo pipefail
if [ "${1:-}" == "restore" ]; then
    restore
fi
if [ "${1:-}" != "confirm" ]; then
    echo "Usage: $0 confirm | restore"
    echo "This will rewrite git history and force-push main."
    exit 1
fi

echo "Creating orphan branch..."

git checkout --orphan clean-stage

git add -A
git commit -m "Clean up"

echo
echo "New history created:"
git log --oneline -1

echo "Checking differences..."
git diff --stat main clean-stage

echo
read -r -p "Replace main and force push? (type YES): " answer

if [ "$answer" != "YES" ]; then
    echo "Aborted."
    restore
fi
echo
read -r -p "Are you really sure? (type YES): " answer

if [ "$answer" != "YES" ]; then
    echo "Aborted."
    restore
fi



git branch -D main
git branch -m main

git push --force origin main

echo "Cleanup complete."