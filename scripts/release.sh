#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT_DIR="$PWD"

VERSION="${1:-1.0.0}"
# Ensure tag format starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    TAG="v$VERSION"
else
    TAG="$VERSION"
fi

echo "=========================================================="
echo "  Cleany Automated Release Trigger"
echo "  Target Tag: $TAG"
echo "  Identity:   Woadlab <346284787+Woadlab@users.noreply.github.com>"
echo "  SSH Key:    ~/.ssh/woadlab_cleany_deploy"
echo "=========================================================="

# 1. Verify working directory is clean
if [[ -n "$(git status --porcelain)" ]]; then
    echo "==> Staging and committing changes as Woadlab..."
    git add -A
    git commit -m "chore(release): prepare $TAG" || true
fi

# 2. Run unit tests
echo "==> Running test suite..."
swift test

# 3. Create or update tag
echo "==> Tagging release $TAG..."
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "    Replacing existing local tag $TAG..."
    git tag -d "$TAG" >/dev/null 2>&1
fi

git tag -a "$TAG" -m "Cleany $TAG — Open Source Release"

# 4. Push branch and tag to origin using deploy key
echo "==> Pushing main to origin (git@github.com:Woadlab/cleany.git)..."
git push origin main

echo "==> Pushing tag $TAG to origin..."
git push origin "$TAG" --force

echo ""
echo "=========================================================="
echo " 🎉 Successfully pushed $TAG to GitHub!"
echo " The GitHub Actions bot is now building Cleany.dmg, Cleany.zip"
echo " and publishing the release automatically at:"
echo " https://github.com/Woadlab/cleany/releases/tag/$TAG"
echo "=========================================================="
