# policies/sc28_encryption.rego
# METADATA
# title: SC-28 - Encryption at Rest (GCS)
# description: "Every google_storage_bucket must encrypt at rest with a customer-managed encryption key (CMEK)."
# custom:
#   control_id: SC-28
#   framework: nist-800-53
#   severity: high
#   remediation: "Add an encryption { default_kms_key_name = ... } block referencing a google_kms_crypto_key you control."

# opa eval --input plan.json --data policies/sc28_encryption.rego "data.compliance.sc28.deny"
# opa eval "data.<package path>.<rule name>"

# namespace
package compliance.sc28

import rego.v1

# return empty = compliant
# return msg = not compliant
deny contains msg if {
	# look through the resources in the Terraform plan
	# input is the JSON data being given to OPA
	# for each resource in the list, call it resource
	some resource in input.planned_values.root_module.resources
	# only look at GCS buckets
	resource.type == "google_storage_bucket"
	# compliance test: deny the resource if does not have CMEK
	not has_cmek(resource)
	msg := sprintf(
		"[SC-28] %s: missing customer-managed encryption key. Remediation: add encryption { default_kms_key_name = ... }.",
		[resource.address],
	)
}

# The same logic for module-wrapped buckets (recurse into child_modules).
# Don't let someone bypass the policy simply by putting the bucket inside a module
deny contains msg if {
	some child in input.planned_values.root_module.child_modules
	some resource in child.resources
	resource.type == "google_storage_bucket"
	not has_cmek(resource)
	msg := sprintf(
		"[SC-28] %s: missing customer-managed encryption key. Remediation: add encryption { default_kms_key_name = ... }.",
		[resource.address],
	)
}

has_cmek(resource) if {
	count(resource.values.encryption) > 0
	not empty_kms_key(resource.values.encryption[0])
}

# rules to define what empty means
empty_kms_key(enc) if enc.default_kms_key_name == ""
empty_kms_key(enc) if enc.default_kms_key_name == null
