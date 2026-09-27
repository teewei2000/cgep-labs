## Lab 4.4 — Evidence Chain of Custody

The evidence chain of custody is demonstrated through four properties:

### 1. Integrity

The SHA-256 digest stored in the `.sha256` artifact provides a fingerprint
of the evidence bundle. The verification script recalculates the SHA-256
digest of the downloaded bundle and compares it with the recorded digest.

Evidence:
- `evidence-<RUN_ID>-<SHA>.tar.gz`
- `evidence-<RUN_ID>-<SHA>.tar.gz.sha256`
- `evidence/lab-4-4/receipt.json`

Tampering with the local bundle changes its SHA-256 digest and causes the
integrity verification to fail.

### 2. Authenticity

The evidence bundle is signed using Cosign with GitHub Actions OIDC-based
keyless signing. The resulting `.sig.bundle` provides the signature and
certificate information used by `verify-evidence.sh` to verify the bundle.

Evidence:
- `evidence-<RUN_ID>-<SHA>.tar.gz.sig.bundle`
- `grc-gate.yml`
- `scripts/verify-evidence.sh`

### 3. Provenance

The receipt links the evidence to the GitHub Actions run, repository commit,
S3 vault location, bundle and SHA-256 digest. This provides traceability
between the generated evidence and the CI/CD execution that produced it.

Evidence:
- `evidence/lab-4-4/receipt.json`
- GitHub Actions run ID
- Git commit SHA

### 4. Preservation

The signed evidence bundle is stored in the AWS S3 evidence vault with
Object Lock retention. The verification script checks that the retention
period has not expired.

Evidence:
- S3 Object Lock vault
- `evidence-<RUN_ID>-<SHA>.tar.gz`
- S3 object retention metadata
- `scripts/verify-evidence.sh`


