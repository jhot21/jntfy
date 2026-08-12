#!/usr/bin/env bash
# Fetches binwiederhier/ntfy-android and merges its main branch into a new
# sync branch off of origin/main. Exits 0 on a clean merge (branch is ready
# to open a normal PR from), exits 1 if there were conflicts (branch is left
# with conflict markers, staged for manual resolution).
set -euo pipefail

UPSTREAM_URL="https://github.com/binwiederhier/ntfy-android.git"
UPSTREAM_BRANCH="main"
BASE_BRANCH="main"
DATE_TAG="$(date +%Y-%m-%d)"
SYNC_BRANCH="sync-upstream-${DATE_TAG}"

git fetch origin "${BASE_BRANCH}"
git fetch "${UPSTREAM_URL}" "${UPSTREAM_BRANCH}"

git checkout -B "${SYNC_BRANCH}" "origin/${BASE_BRANCH}"

set +e
git merge --no-ff FETCH_HEAD -m "Sync with upstream binwiederhier/ntfy-android@${UPSTREAM_BRANCH} (${DATE_TAG})"
MERGE_STATUS=$?
set -e

git push origin "${SYNC_BRANCH}" --force-with-lease

echo "sync_branch=${SYNC_BRANCH}" >> "${GITHUB_OUTPUT:-/dev/stdout}"

if [ "${MERGE_STATUS}" -ne 0 ]; then
  echo "merge_conflict=true" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  exit 1
else
  echo "merge_conflict=false" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  exit 0
fi
