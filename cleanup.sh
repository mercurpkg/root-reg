#!/usr/bin/env bash
git checkout --orphan cleanup-stage
git add -A
git commit -m "Cleanup"
git branch -D main
git branch -m main
git push --force origin main