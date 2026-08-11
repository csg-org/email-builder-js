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

build_and_publish() {
  local package="$1"
  (
    set -e
    echo "Deploying $package"
    cd "$package"
    # --include=dev: install devDependencies even when NODE_ENV=production or npm config would omit them.
    # The packages don't declare tsup/typescript, so install them here without saving to package.json;
    # a local tsup also keeps `npx tsup` from resolving to a global npx cache that may lack tsup's
    # typescript peer dependency. typescript is pinned to 5.x because tsup's dts step
    # (rollup-plugin-dts) requires the TypeScript 5.x compiler API and fails on newer major versions.
    npm install --include=dev --no-save 'typescript@5' tsup
    npm run build
    npm publish --access public --tag latest $DRY_RUN_FLAG
  )
}

for package in $(find packages -name 'block-*' -type d -maxdepth 1); do
  build_and_publish "$package"
done

build_and_publish "packages/document-core"

echo ""
echo "All subpackages published. It may take several minutes for version $VERSION to appear in the registry."
echo "Verify all @csg-org packages show $VERSION at: https://www.npmjs.com/org/csg-org"
read -p "Press enter to publish @csg-org/email-builder once all subpackages show $VERSION"

build_and_publish "packages/email-builder"
