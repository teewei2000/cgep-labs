#!/usr/bin/env bash
# scripts/policy-gate.sh
# Usage: policy-gate.sh --workspace <path> [--policy <dir>]
# Requires a saved tfplan inside the workspace (from terraform plan -out=tfplan).
set -euo pipefail

# set default variables
POLICY_DIR="policies"
WORKSPACE=""
EVIDENCE_DIR="evidence/lab-3-4"

# example: ./scripts/policy-gate.sh --workspace terraform/primitives/compliant-s3
# $1 = --workspace, $2= terraform/primitives/compliant-s3
while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --policy)    POLICY_DIR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$WORKSPACE" ]] && { echo "Usage: $0 --workspace <path>" >&2; exit 2; }
mkdir -p "$EVIDENCE_DIR"

# Write plan.json next to tfplan. Use -chdir so a relative WORKSPACE path
# doesn't get doubled after a cd (a common bash footgun).
# so if: WORKSPACE = terraform/primitive/compliant-s3
# Terraform looks for terraform/primitive/compliant-s3/tfplan 
# and creates terraform/primitive/compliant-s3/plan.json
terraform -chdir="$WORKSPACE" show -json tfplan > "$WORKSPACE/plan.json"

# initialize Gate status
EXIT=0
{
  echo "["
  FIRST=1
  # AWS namespaces only. Including a GCP namespace here would "pass" with zero
  # coverage on an AWS plan — the exact empty-pass lesson from Step 3.
  for ns in compliance.sc28_aws compliance.ac3_aws compliance.cm6_aws ; do
    [[ $FIRST -eq 1 ]] && FIRST=0 || printf ","
    # Capture JSON even when conftest exits non-zero; use that exit code for the gate.
    set +e
    # Load policies from policies/, evaluate the SC-28 AWS namespace against this Terraform plan, and return the result as JSON.
    OUT=$(conftest test --policy "$POLICY_DIR" --namespace "$ns" --output=json "$WORKSPACE/plan.json")
    # capture Exit cpse from Conftest
    STATUS=$?
    set -e
    # if there is a "0" return in $STATUS, EXIT = 1, overall gate goes fails
    [[ $STATUS -eq 0 ]] || EXIT=1
    printf '%s' "$OUT"
  done
  echo
  echo "]"
} > "$EVIDENCE_DIR/conftest-results.json"

if [[ $EXIT -eq 0 ]]; then echo "policy-gate: PASS"
else echo "policy-gate: FAIL"; echo "See $EVIDENCE_DIR/conftest-results.json"
fi
exit $EXIT
