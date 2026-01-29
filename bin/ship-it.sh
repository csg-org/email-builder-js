#!/usr/bin/env bash
set -x

for package in $(find packages -name 'block-*' -type d -d 1); do
  (
    echo "Deploying $package"
    cd "$package"
    npm install
    npm run build
  )
done

for package in $(find packages -name 'block-*' -type d -d 1); do
  (
    echo "Deploying $package"
    cd "$package"
    npm publish --access public --tag latest
  )
done

(
  cd packages/document-core
  npm install
  npm run build
)

(
  cd packages/document-core
  npm publish --access public --tag latest
)

(
  cd packages/email-builder
  npm install
  npm run build
)

(
  cd packages/email-builder
  npm publish --access public --tag latest
)

