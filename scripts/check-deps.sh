#!/usr/bin/env bash
# check-deps.sh — Verify required tools for HacktifyTests lab scripts
# Usage: ./scripts/check-deps.sh

set -euo pipefail

REQUIRED=(curl nmap)
OPTIONAL=(nikto sqlmap)

miss=()
for t in "${REQUIRED[@]}"; do
  if ! command -v "$t" >/dev/null 2>&1; then
    miss+=("$t")
  fi
done

if [ ${#miss[@]} -ne 0 ]; then
  echo "Missing required tools: ${miss[*]}" >&2
  echo "Please install them before running the scan scripts. Example (Debian/Ubuntu):"
  echo "  sudo apt update && sudo apt install -y curl nmap"
  exit 2
fi

echo "Required tools found: ${REQUIRED[*]}"

found_optional=()
for t in "${OPTIONAL[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    found_optional+=("$t")
  fi
done

if [ ${#found_optional[@]} -gt 0 ]; then
  echo "Optional tools available: ${found_optional[*]}"
else
  echo "Optional tools not found: ${OPTIONAL[*]} (these are recommended but not required)"
fi

echo "All checks complete."
exit 0
