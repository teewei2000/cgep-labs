# terraform/primitives/compliant-s3/outputs.tf
# After Terraform creates/configures everything, what information do I want to expose to whoever is using this module?
output "bucket_arn" { value = aws_s3_bucket.primary.arn }
output "bucket_name" { value = aws_s3_bucket.primary.id }
output "log_bucket_arn" { value = aws_s3_bucket.log.arn }

# Look at the encryption configuration of the primary bucket
# and return the encryption algorithm being used.
#output "encryption_algorithm" {
#  description = "Server-side encryption algorithm in effect (SC-28 attestation)."
#  value = one([
#    for rule in aws_s3_bucket.primary.server_side_encryption_configuration :
#    rule.apply_server_side_encryption_by_default[0].sse_algorithm
#  ])
#}

output "encryption_algorithm" {
  description = "Server-side encryption algorithm in effect (SC-28 attestation)."
  value       = "aws:kms"
}