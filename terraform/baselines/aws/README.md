# AWS Security Services Baseline

## CloudTrail

CloudTrail records AWS management activity across regions and stores
validated logs in an encrypted S3 bucket.

Controls:
- AU-2 — Audit Events
- AU-12 — Audit Record Generation
- AU-10 — Non-repudiation / audit information integrity

Evidence:
- CloudTrail trail configuration
- S3 CloudTrail log bucket
- CloudTrail log-file validation

## Security Hub

Security Hub aggregates AWS security findings and evaluates the account
against NIST 800-53 Rev. 5 and AWS Foundational Security Best Practices.

Controls:
- RA-5 — Vulnerability Monitoring and Scanning
- SI-4 — System Monitoring

Evidence:
- evidence/lab-5-2/security-hub-findings.json

## AWS Config

AWS Config provides resource configuration history and compliance
monitoring.

Controls:
- CM-2 — Baseline Configuration
- CM-6 — Configuration Settings
- CM-8 — System Component Inventory

If AWS Config is unavailable because of an organization-level SCP,
Security Hub findings documenting the missing Config capability are
retained as evidence of the control gap.