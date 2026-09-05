# Compliance Policies

This directory contains OPA/Rego policies used to evaluate Terraform plans against NIST 800-53 controls.

## SC-28 - Encryption at Rest

### GCP

Policy: sc28_encryption.rego

Control ID: SC-28

Severity: High

Remediation:

Add an encryption { default_kms_key_name = ... } block referencing a google_kms_crypto_key you control.

### AWS

Policy: sc28_encryption_aws.rego

Control ID: SC-28

Severity: High

Remediation:

Add aws_s3_bucket_server_side_encryption_configuration { bucket = aws_s3_bucket.<name>.id ... } for the bucket.

## AC-3 - Access Enforcement

### GCP

Policy: ac3_no_public.rego

Control ID: AC-3

Severity: Critical

Remediation:

Set uniform_bucket_level_access = true and public_access_prevention = enforced. For firewalls, narrow source_ranges or remove the rule.

### AWS

Policy: ac3_no_public_aws.rego

Control ID: AC-3

Severity: Critical

Remediation:

Add an aws_s3_bucket_public_access_block resource referencing the S3 bucket, with all four public access block flags set to true.

## CM-6 - Configuration Settings

### GCP

Policy: cm6_required_tags.rego

Control ID: CM-6

Severity: Medium

Remediation:

Add the four required labels (project, environment, managed_by, compliance_scope) to the resource.

### AWS

Policy: cm6_required_tags_aws.rego

Control ID: CM-6

Severity: Medium

Remediation:

Add the four required tags (Project, Environment, ManagedBy, ComplianceScope) to the resource or use provider default_tags.
