#!/usr/bin/env bash
set -ex

for package in $(find packages -name 'block-*' -type d -d 1); do
  (
    set -e
    echo "Deploying $package"
    cd "$package"
    npm install
    npm run build
    npm publish --access public --tag latest
  )
done

(
  set -e
  echo "Deploying document-core"
  cd packages/document-core
  npm install
  npm run build
  npm publish --access public --tag latest
)

echo "It may take several minutes for the subpackages to appear in the registry."
read -p "Press enter to continue"

(
  set -e
  echo "Deploying email-builder"
  cd packages/email-builder
  npm install
  npm run build
  npm publish --access public --tag latest
)
