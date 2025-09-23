#!/usr/bin/env bash
set -x

for package in $(find packages -name 'block-*' -type d -d 1); do
  (
    echo "Deploying $package"
    cd "$package"
    npm publish --access public
)
done

cd packages/email-builder
npm publish --access public
