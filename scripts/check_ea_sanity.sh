#!/usr/bin/env bash
# check_ea_sanity.sh — Lightweight sanity checks for UNIFIED_SUPREME_FUSION.mq5
# Usage: bash scripts/check_ea_sanity.sh [path/to/file.mq5]
#
# Exits 0 on success, non-zero on any failure.
set -euo pipefail

FILE="${1:-UNIFIED_SUPREME_FUSION.mq5}"
PASS=0
FAIL=0

pass() { echo "  PASS: $*"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $*"; FAIL=$((FAIL + 1)); }

echo "=== EA Sanity Check: $FILE ==="

# 1. File exists and is not empty
if [[ ! -f "$FILE" ]]; then
  fail "$FILE not found"
  exit 1
fi
if [[ ! -s "$FILE" ]]; then
  fail "$FILE is empty"
  exit 1
fi
pass "File exists and is non-empty"

# 2. No placeholder / stub markers
PLACEHOLDER_PATTERNS=(
  '/\*\.\.\. existing code \.\.\.\*/'
  '/\*\.\.\. additional EA logic \.\.\.\*/'
  'Other existing contents remain unchanged'
  'Full EA content'
)
for pat in "${PLACEHOLDER_PATTERNS[@]}"; do
  if grep -nqE "$pat" "$FILE"; then
    MATCH="$(grep -nE "$pat" "$FILE" | head -n3)"
    fail "Placeholder/stub marker found matching '$pat':\n$MATCH"
  fi
done
if [[ $FAIL -eq 0 ]]; then
  pass "No placeholder/stub markers found"
fi

# 3. #property strict must exist
if grep -qE '^[[:space:]]*#property[[:space:]]+strict\b' "$FILE"; then
  pass "#property strict found"
else
  fail "#property strict not found — add '#property strict' near the top of the file"
fi

# 4. #property version must exist and match semantic version pattern
VER_LINE="$(grep -E '^[[:space:]]*#property[[:space:]]+version\b' "$FILE" | head -n1 || true)"
if [[ -z "$VER_LINE" ]]; then
  fail "#property version not found"
else
  VER="$(echo "$VER_LINE" | sed -E 's/.*version[^"]*"?([0-9]+\.[0-9]+(\.[0-9]+)?)"?.*/\1/')"
  if [[ "$VER" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    pass "#property version found: $VER"
    # 4a. Optionally compare against a VERSION file if present
    if [[ -f "VERSION" ]]; then
      EXPECTED_VER="$(tr -d '[:space:]' < VERSION)"
      if [[ "$VER" == "$EXPECTED_VER" ]]; then
        pass "#property version matches VERSION file ($VER)"
      else
        fail "#property version '$VER' does not match VERSION file '$EXPECTED_VER'"
      fi
    fi
  else
    fail "Could not parse a valid semantic version from: $VER_LINE"
  fi
fi

# 5. Banned tokens
BANNED_TOKENS=(
  'TRADE_RETCODE_NO_QUOTES'
)
for token in "${BANNED_TOKENS[@]}"; do
  if grep -qnE "$token" "$FILE"; then
    MATCH="$(grep -nE "$token" "$FILE" | head -n3)"
    fail "Banned token '$token' found:\n$MATCH"
  else
    pass "Banned token '$token' not present"
  fi
done

# Summary
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
echo "All checks passed."
