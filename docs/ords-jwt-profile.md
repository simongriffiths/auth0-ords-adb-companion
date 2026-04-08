# ORDS JWT Profile

This repository uses a simple JWT trust profile where ORDS validates Auth0-issued access tokens before allowing access to the protected module.

Current ORDS guidance favors `ORDS_SECURITY` and `ORDS_SECURITY_ADMIN` for JWT profile management. The older `OAUTH` and `OAUTH_ADMIN` packages are deprecated for new work.

## Core Values

The ORDS configuration example centers on three values:

- issuer
- audience
- JWKS URL

These values must align with Auth0 exactly.

## Issuer

The issuer is the `iss` claim that Auth0 puts into the token.

Example:

- `https://your-tenant.auth0.com/`

This value comes from your Auth0 tenant domain, including the trailing slash shown above.

## Audience

The audience is the `aud` claim that Auth0 puts into the token.

Example:

- `https://api.example.com/ords-api`

This is the Auth0 API Identifier. It is a logical identifier, not the ORDS endpoint URL, and it does not need to resolve on the network.

## JWKS URL

ORDS uses the JWKS URL to obtain the public keys required for signature validation.

Example:

- `https://your-tenant.auth0.com/.well-known/jwks.json`

If ORDS cannot reach this URL, signature validation will fail even when the token itself looks correct.

## Exact-Match Requirement

ORDS JWT validation is only reliable when the configured values match the token claims exactly.

Check for:

- the full issuer string
- the exact audience string
- the correct JWKS endpoint path
- accidental whitespace or copy and paste errors

## Trailing Slash Pitfall

One of the most common causes of confusion is issuer formatting.

Example mismatch:

- token `iss`: `https://your-tenant.auth0.com/`
- ORDS configured issuer: `https://your-tenant.auth0.com`

Those values look similar to a human, but they may not compare as equal during validation.

## Mapping Back to Auth0

Use this mapping when moving between the two systems:

- Auth0 tenant domain -> ORDS issuer and JWKS host
- Auth0 API Identifier -> ORDS allowed audience
- Auth0-issued access token -> bearer token sent to the ORDS endpoint

## Scope-Based JWT Profile

This demo is intended to use a schema-level scope-based JWT profile.

That means:

- ORDS trusts the external issuer, audience, and JWKS definition
- the JWT `scope` or `scp` claim must contain the ORDS privilege names protecting the resource
- the demo Auth0 scope and the demo ORDS privilege name should therefore match

For this repository, the intended privilege and scope value is:

- `read:demo`

If you prefer a role-based JWT profile instead, use a role claim such as `/roles` and map that claim to ORDS role names.

## Configuration Modes

Depending on the ORDS deployment, JWT trust may be configured in one of two places:

- schema-level JWT profile through `ORDS_SECURITY.CREATE_JWT_PROFILE` or `ORDS_SECURITY_ADMIN.CREATE_JWT_PROFILE`
- pool-level configuration through `security.jwt.profile.*` in the ORDS pool config

If the pool is configured for pool-level JWT profiles, schema-level profiles are ignored.

## Reference Template

See [../ords/jwt-profile.example.properties](../ords/jwt-profile.example.properties) for a placeholder-driven example you can adapt to your environment.
