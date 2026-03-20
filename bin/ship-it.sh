#!/usr/bin/env bash
set -exo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN_FLAG=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN_FLAG="--dry-run"
  echo "=== DRY RUN ==="
fi

VERSION=$("$SCRIPT_DIR/version.sh" get)
echo "Publishing version: $VERSION"

for package in $(find packages -name 'block-*' -type d -maxdepth 1); do
  (
    set -e
    echo "Deploying $package"
    cd "$package"
    npm install
    npm run build
    npm publish --access public --tag latest $DRY_RUN_FLAG
  )
done

(
  set -e
  echo "Deploying document-core"
  cd packages/document-core
  npm install
  npm run build
  npm publish --access public --tag latest $DRY_RUN_FLAG
)

echo ""
echo "All subpackages published. It may take several minutes for version $VERSION to appear in the registry."
echo "Verify all @csg-org packages show $VERSION at: https://www.npmjs.com/org/csg-org"
read -p "Press enter to publish @csg-org/email-builder once all subpackages show $VERSION"

(
  set -e
  echo "Deploying email-builder"
  cd packages/email-builder
  npm install
  npm run build
  npm publish --access public --tag latest $DRY_RUN_FLAG
)
