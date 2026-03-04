#!/usr/bin/env bash
# =============================================================================
# transfer-repos.sh
# Automates transferring multiple GitHub repositories from one user to another.
#
# PREREQUISITES:
#   1. GitHub CLI installed: https://cli.github.com/
#   2. Authenticated:  gh auth login  (needs repo admin / owner scope)
#   3. Destination user (NEW_OWNER) must accept the transfer invitation on
#      GitHub within 24 hours for the transfer to complete.
#   4. Both accounts must not have a repository with the same name — rename
#      any collisions before running this script.
#
# LIMITATIONS:
#   - Forked repositories may have restrictions on transfers depending on
#     the upstream repository's visibility and organisation policies.
#   - Transfers into or out of GitHub organisations follow org-level
#     permission rules and may require an additional admin approval step.
#   - Name collisions on the destination account will cause the API call to
#     fail; resolve them manually before running the script.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SOURCE_OWNER="Yourfiyan"
NEW_OWNER="kohlerfelicita"

REPOS=(
  "spider-man-tm"
  "system-prompts-and-models-of-ai-tools"
  "VRINDA"
  "my-environment-site-Ambrin-s-creation"
  "automatic-invention"
  "psychic-engine"
  "SEO-CHECKER"
)

# Set DRY_RUN=true (or pass --dry-run) to preview actions without executing.
DRY_RUN=false

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# Parse --dry-run flag from arguments
for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
if ! command -v gh &>/dev/null; then
  error "GitHub CLI (gh) is not installed. Install it from https://cli.github.com/"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  error "Not authenticated with GitHub CLI. Run: gh auth login"
  exit 1
fi

AUTHED_USER="$(gh api user --jq '.login' 2>/dev/null || true)"
info "Authenticated as: ${AUTHED_USER:-unknown}"

if [[ "$DRY_RUN" == "true" ]]; then
  warn "DRY-RUN mode enabled — no transfers will be executed."
fi

echo ""
echo "================================================================"
echo "  Source  : ${SOURCE_OWNER}"
echo "  Target  : ${NEW_OWNER}"
echo "  Repos   : ${#REPOS[@]}"
echo "================================================================"
echo ""

# ---------------------------------------------------------------------------
# Per-repository checks and transfer
# ---------------------------------------------------------------------------
TRANSFERRED=()
SKIPPED=()
FAILED=()

for repo in "${REPOS[@]}"; do
  echo "------------------------------------------------------------"
  info "Processing: ${SOURCE_OWNER}/${repo}"

  # 1. Confirm the repository exists and the current owner matches
  OWNER_CHECK="$(gh api "repos/${SOURCE_OWNER}/${repo}" --jq '.owner.login' 2>/dev/null || echo "NOT_FOUND")"

  if [[ "$OWNER_CHECK" == "NOT_FOUND" ]]; then
    warn "Repository '${SOURCE_OWNER}/${repo}' not found or not accessible — skipping."
    SKIPPED+=("$repo")
    continue
  fi

  if [[ "$OWNER_CHECK" != "$SOURCE_OWNER" ]]; then
    warn "Repository owner is '${OWNER_CHECK}', expected '${SOURCE_OWNER}' — skipping."
    SKIPPED+=("$repo")
    continue
  fi

  success "Repository confirmed: ${SOURCE_OWNER}/${repo}"

  # 2. Prompt for confirmation (unless in DRY_RUN mode which shows intent only)
  if [[ "$DRY_RUN" == "true" ]]; then
    info "DRY-RUN: would transfer '${repo}' → ${NEW_OWNER}"
    TRANSFERRED+=("${repo} (dry-run)")
    continue
  fi

  read -r -p "  Transfer '${repo}' from '${SOURCE_OWNER}' to '${NEW_OWNER}'? [y/N] " confirm
  confirm="$(echo "$confirm" | tr '[:upper:]' '[:lower:]')"
  if [[ "$confirm" != "y" && "$confirm" != "yes" ]]; then
    warn "Skipped by user: ${repo}"
    SKIPPED+=("$repo")
    continue
  fi

  # 3. Execute transfer via GitHub API
  if gh api \
      --method POST \
      "repos/${SOURCE_OWNER}/${repo}/transfer" \
      --field "new_owner=${NEW_OWNER}" \
      --silent; then
    success "Transfer initiated: ${SOURCE_OWNER}/${repo} → ${NEW_OWNER}"
    TRANSFERRED+=("$repo")
  else
    error "Transfer FAILED for: ${repo}"
    FAILED+=("$repo")
  fi

  echo ""
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "================================================================"
echo "  SUMMARY"
echo "================================================================"
echo -e "  ${GREEN}Transferred / queued${RESET} : ${#TRANSFERRED[@]}"
for r in "${TRANSFERRED[@]}"; do echo "    ✓ $r"; done

echo -e "  ${YELLOW}Skipped${RESET}              : ${#SKIPPED[@]}"
for r in "${SKIPPED[@]}"; do echo "    - $r"; done

echo -e "  ${RED}Failed${RESET}               : ${#FAILED[@]}"
for r in "${FAILED[@]}"; do echo "    ✗ $r"; done
echo "================================================================"

if [[ ${#FAILED[@]} -gt 0 ]]; then
  exit 1
fi
