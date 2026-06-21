package infraweave.publish

import rego.v1

default allow := false

admin_jwt_usernames := {"IdentityCenter_someuser@acme-corp.com"}

actor_prefixes := {
	"module": "tf-module-",
	"stack": "tf-stack-",
	"provider": "tf-provider-",
	"policy": "tf-policy-",
}

trusted_context := "refs/heads/main"

trusted_tracks := {"stable", "rc", "beta", "alpha"}

untrusted_tracks := {"dev"}

track_exempt_types := {"provider"}

allow if {
	is_admin
}

allow if {
	input.identity.provider == "github_oidc"
	actor_matches_resource
	track_allowed
	workflow_allowed
}

workflow_allowed if {
	input.identity.workflow_ref == sprintf(
		"infraweave-io/%s/.github/workflows/publish.yml@%s",
		[input.identity.repository_name, trusted_context],
	)
}

is_admin if {
	admin_jwt_usernames[input.identity.claims["cognito:username"]]
}

actor_matches_resource if {
	actor := input.identity.repository_name
	prefix := actor_prefixes[input.request.resource_type]
	startswith(actor, prefix)

	resource_name := substring(actor, count(prefix), -1)
	resource_name != ""
	resource_name == input.request.resource_name
}

track_allowed if {
	track_exempt_types[input.request.resource_type]
}

track_allowed if {
	track := object.get(input.request, "track", "")
	track != ""
	allowed_tracks[track]
}

allowed_tracks := trusted_tracks if {
	object.get(input.identity, "ref", "") == trusted_context
}

allowed_tracks := untrusted_tracks if {
	object.get(input.identity, "ref", "") != trusted_context
}