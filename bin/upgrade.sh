#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# All package.json files: every package under packages/
PACKAGE_JSON_FILES=(
  "$ROOT"/packages/*/package.json
)

# --- audit: ensure every package.json has the same version ---
audit() {
  local versions=()
  for f in "${PACKAGE_JSON_FILES[@]}"; do
    [[ -f "$f" ]] || continue
    local v
    v=$(sed -n 's/^[[:space:]]*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$f")
    versions+=("$v")
  done
  local first="${versions[0]}"
  for v in "${versions[@]}"; do
    if [[ "$v" != "$first" ]]; then
      echo "Version mismatch: found '$first' and '$v' across package.json files."
      exit 1
    fi
  done
  return 0
}

# --- get: print current version (from root package.json) ---
get() {
  sed -n 's/^[[:space:]]*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$ROOT/package.json"
}

# --- upgrade: set version in every package.json to the given string ---
upgrade() {
  local new_version="$1"
  if [[ -z "$new_version" ]]; then
    echo "Usage: $0 upgrade <new-version>"
    exit 1
  fi
  for f in "${PACKAGE_JSON_FILES[@]}"; do
    [[ -f "$f" ]] || continue
    if sed -i.bak "s#^\([[:space:]]*\"version\":[[:space:]]*\)\"[^\"]*\"#\1\"$new_version\"#" "$f"; then
      rm -f "${f}.bak"
      echo "Updated $f -> $new_version"
    fi
  done
  # Update all @csg-org/* dependency versions in email-builder/package.json
  local email_builder_json="$ROOT/packages/email-builder/package.json"
  if [[ -f "$email_builder_json" ]]; then
    if sed -i.bak "s#\(\"@csg-org/[^\"]*\":[[:space:]]*\)\"[^\"]*\"#\1\"^$new_version\"#" "$email_builder_json"; then
      rm -f "${email_builder_json}.bak"
      echo "Updated $email_builder_json dependencies -> ^$new_version"
    fi
  fi
}


case "${1:-}" in
  get)
    audit
    get
    ;;
  upgrade)
    upgrade "${2:-}"
    ;;
  audit)
    audit
    echo "Audit passed: all package.json versions match."
    ;;
  *)
    echo "Usage: $0 { get | audit | upgrade <new-version> }"
    exit 1
    ;;
esac
