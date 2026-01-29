#!/usr/bin/env bash
set -euo pipefail

CUSTOMER=$1
CORE_REPO=$2

LOCK_FILE="customers/$CUSTOMER/lock.yaml"

# 1) read lock.yaml
TAG=$(yq '.core.git.tag' "$LOCK_FILE")
COMMIT=$(yq '.core.git.commit' "$LOCK_FILE")

echo "Deploying customer: $CUSTOMER"
echo "Pinned core version: tag=$TAG commit=$COMMIT"

# 2) checkout core repo

cd "$CORE_REPO"
git fetch --all --tags

if [[ "$COMMIT" != "" ]]; then
    git checkout "$COMMIT"
else
    git checkout "$TAG"
fi

echo "Checked out core repo to version $TAG"

# 3) return to customer-config repo and deploy
cd "$ROOT"

helmfile --environment "$CUSTOMER" apply