Lab 3.3:

for GCP:

policies/sc28_encryption.rego
METADATA
title: SC-28 - Encryption at Rest (GCS)
description: "Every google_storage_bucket must encrypt at rest with a customer-managed encryption key (CMEK)."
custom:
  control_id: SC-28
  framework: nist-800-53
  severity: high
  remediation: "Add an encryption { default_kms_key_name = ... } block referencing a google_kms_crypto_key you control."


policies/ac3_no_public.rego
METADATA
title: AC-3 - Access Enforcement (no public GCS or open firewall)
description: "GCS buckets must enforce uniform_bucket_level_access AND public_access_prevention=enforced. Firewall rules must not allow 0.0.0.0/0 on management ports (22, 3389)."
custom:
  control_id: AC-3
  framework: nist-800-53
  severity: critical
  remediation: "Set uniform_bucket_level_access = true, public_access_prevention = enforced. For firewalls, narrow source_ranges or remove the rule."

policies/cm6_required_tags.rego
METADATA
title: CM-6 - Configuration Settings (required compliance labels)
description: "Every taggable resource must carry the four required labels: project, environment, managed_by, compliance_scope."
custom:
  control_id: CM-6
  framework: nist-800-53
  severity: medium
  remediation: "Add the four required labels (project, environment, managed_by, compliance_scope) to the resource."

Lab 3.4

For AWS:

 policies/sc28_encryption_aws.rego
 METADATA
 title: SC-28 - Encryption at Rest (AWS S3)
 description: "Every aws_s3_bucket must have an aws_s3_bucket_server_side_encryption_configuration that references it."
 custom:
   control_id: SC-28
   framework: nist-800-53
   severity: high
   remediation: "Add aws_s3_bucket_server_side_encryption_configuration { bucket = aws_s3_bucket.<name>.id ... } for the bucket."

 policies/ac3_no_public_aws.rego
 METADATA
 title: AC-3 - Access Enforcement (AWS S3 public access block)
 description: "Every aws_s3_bucket must have an aws_s3_bucket_public_access_block referencing it, with all four flags true."
 custom:
   control_id: AC-3
   framework: nist-800-53
   severity: critical

 policies/cm6_required_tags_aws.rego
 METADATA
 title: CM-6 - Configuration Settings (AWS required tags)
 custom:
   control_id: CM-6
   framework: nist-800-53
   severity: medium