#!/usr/bin/env bash
# scripts/capture-evidence.sh
# Usage:
#   capture-evidence.sh --workspace <path> --run-id <id> --vault <bucket> [--profile <p>]
# Example:
#   bash scripts/capture-evidence.sh \
#  --workspace terraform/primitives/compliant-s3 \
#  --run-id    test-001 \
#  --vault     "$VAULT" \
#  --profile   default
# Output:
# {"run_id":"test-001","vault":"cgep-lab-grc-evidence-vault-f301512f","key":"runs/test-001/bundle.tar.gz","version_id":".sb1xG9FXiXxgTdg3h6CLZQfzcxs5D9D","captured_at_utc":"2026-09-23T22:45:45Z"}
#   The version_id is the durable handle to this exact evidence. Save it. Anything that points at this evidence later, like your OSCAL component's evidence link in Chapter 6, references s3://VAULT/KEY?versionId=.... Write the whole receipt to your evidence folder:



# You don't need to understand every line, but the shape is worth knowing. 
# It collects the plan, the state, the git commit, and the Terraform version; it computes a SHA-256 of each so any later change is detectable; 
# it tars them into one bundle; it uploads that bundle to the vault; 
# and it prints a single-line JSON receipt with the version_id that uniquely identifies what it just stored. 
# The set -euo pipefail and the trap at the top mean a partial failure cleans up after itself rather than leaving junk behind.

set -euo pipefail

PROFILE_ARG=""
WORKSPACE=""
RUN_ID=""
VAULT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --run-id)    RUN_ID="$2";    shift 2 ;;
    --vault)     VAULT="$2";     shift 2 ;;
    --profile)   PROFILE_ARG="--profile $2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$WORKSPACE" || -z "$RUN_ID" || -z "$VAULT" ]] && {
  echo "Usage: $0 --workspace <path> --run-id <id> --vault <bucket> [--profile <p>]" >&2
  exit 2
}

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

if command -v sha256sum >/dev/null 2>&1; then SHASUM="sha256sum"
elif command -v shasum    >/dev/null 2>&1; then SHASUM="shasum -a 256"
else echo "Need sha256sum or shasum" >&2; exit 2; fi

CAPTURED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
BUNDLE_DIR="$WORK/bundle-$RUN_ID"
mkdir -p "$BUNDLE_DIR"

( cd "$WORKSPACE" && [[ -f tfplan ]] && \
    terraform show -json tfplan > "$BUNDLE_DIR/plan.json" 2>/dev/null || true )
( cd "$WORKSPACE" && terraform state pull > "$BUNDLE_DIR/state.json" 2>/dev/null || true )
( cd "$WORKSPACE" && git log -1 --pretty=full > "$BUNDLE_DIR/commit.txt" 2>/dev/null \
    || echo "no git commit available" > "$BUNDLE_DIR/commit.txt" )
terraform version > "$BUNDLE_DIR/version.txt"

# manifest.json: filename, sha256, size, captured_at_utc per file
{
  echo "["
  FIRST=1
  for f in "$BUNDLE_DIR"/*; do
    base=$(basename "$f")
    [[ "$base" == "manifest.json" ]] && continue
    HASH=$($SHASUM "$f" | awk '{print $1}')
    SIZE=$(wc -c < "$f" | tr -d ' ')
    [[ $FIRST -eq 1 ]] && FIRST=0 || printf ","
    printf '\n  {"filename":"%s","sha256":"%s","size":%s,"captured_at_utc":"%s"}' \
      "$base" "$HASH" "$SIZE" "$CAPTURED_AT"
  done
  echo
  echo "]"
} > "$BUNDLE_DIR/manifest.json"

BUNDLE_TGZ="/tmp/bundle-$RUN_ID.tar.gz"
( cd "$WORK" && tar czf "$BUNDLE_TGZ" "bundle-$RUN_ID" )

KEY="runs/$RUN_ID/bundle.tar.gz"
UPLOAD_OUT=$(aws $PROFILE_ARG s3api put-object \
  --bucket "$VAULT" --key "$KEY" --body "$BUNDLE_TGZ" --output json)
VERSION_ID=$(echo "$UPLOAD_OUT" | awk -F'"' '/"VersionId"/{print $4}')

printf '{"run_id":"%s","vault":"%s","key":"%s","version_id":"%s","captured_at_utc":"%s"}\n' \
  "$RUN_ID" "$VAULT" "$KEY" "$VERSION_ID" "$CAPTURED_AT"