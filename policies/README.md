# Compliance Policies

This directory contains OPA/Rego policies used to evaluate Terraform plans against NIST 800-53 controls.

## SC-28 - Encryption at Rest

Policy: sc28_encryption.rego
Control ID: SC-28
Severity: High

Remediation:
Add an encryption { default_kms_key_name = ... } block referencing a google_kms_crypto_key you control.


## AC-3 - Access Enforcement

Policy: ac3_no_public.rego
Control ID: AC-3
Severity: Critical

Remediation:
Set uniform_bucket_level_access = true and public_access_prevention = enforced. For firewalls, narrow source_ranges or remove the rule.


## CM-6 - Configuration Settings

Policy: cm6_required_tags.rego
Control ID: CM-6
Severity: Medium

Remediation:
Add the four required labels (project, environment, managed_by, compliance_scope) to the resource.
