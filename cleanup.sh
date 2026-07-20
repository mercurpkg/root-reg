#!/usr/bin/env bash
restore(){
    echo "Restoring old branch..."

    git checkout main

    if git show-ref --verify --quiet refs/heads/clean-stage; then
        git branch -D clean-stage
    fi

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


current_branch=$(git branch --show-current)

if [ "$current_branch" != "main" ]; then
    echo "Error: You must run this on main branch."
    exit 1
fi
if git show-ref --verify --quiet refs/heads/clean-stage; then
    echo "clean-stage already exists"
    exit 1
fi

echo "Creating backup tag..."

TAG_NAME="cleanup-backup-$(date +%Y-%m-%d-%H%M%S)"

git tag -a "$TAG_NAME" -m "Backup before cleanup"

git push origin "$TAG_NAME"

echo "Created backup tag: $TAG_NAME"


echo "Creating orphan branch..."
git checkout --orphan clean-stage

git add -A
git commit -F cleanup-message.txt

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


git fetch origin

if ! git diff --quiet origin/main main; then
    echo "Warning: Remote main differs from local main."
fi

git branch -D main
git branch -m main


git push --force-with-lease origin main

echo "Cleanup complete."