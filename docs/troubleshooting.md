# Troubleshooting

Use this guide when the demo flow does not behave as expected.

## 401 Unauthorized

Likely cause:

- Missing bearer token
- Expired token
- Wrong issuer
- Wrong audience
- Invalid signature
- ORDS cannot fetch the JWKS document
- Using an ID token instead of an access token

Fix:

- Confirm the request includes `Authorization: Bearer <token>`
- Decode the token and inspect `iss`, `aud`, `exp`, and `scope`
- Confirm the ORDS issuer matches the token issuer exactly
- Confirm the ORDS audience matches the Auth0 API Identifier exactly
- Confirm the JWKS URL is reachable from the ORDS environment
- Request a fresh access token with the client credentials flow

## 403 Forbidden

Likely cause:

- The token is valid, but the protected path is not authorized by the ORDS privilege model
- Scope or role expectations do not line up with the example assumptions

Fix:

- Review the privilege definition in `sql/03_define_security.sql`
- Confirm the protected path pattern matches the endpoint you are calling
- Confirm your environment-specific authorization mapping matches the assumptions documented in the SQL comments

## Issuer Mismatch

Likely cause:

- Tenant domain copied incorrectly
- Missing or extra trailing slash

Fix:

- Compare the token `iss` value with the ORDS configured issuer character for character
- Use the issuer value derived from the Auth0 tenant domain, typically `https://your-tenant.auth0.com/`

## Audience Mismatch

Likely cause:

- Auth0 API Identifier and ORDS audience do not match
- The ORDS endpoint URL was used as the audience by mistake

Fix:

- Confirm the Auth0 API Identifier is the value used for `AUTH0_AUDIENCE`
- Confirm ORDS is configured with that same audience string
- Do not assume the audience should equal the ORDS request URL

## Wrong Token Type

Likely cause:

- ID token used instead of an access token

Fix:

- Use the client credentials grant for this machine-to-machine example
- Confirm the token contains the expected `aud` and scope claims for the API

## Invalid Signature

Likely cause:

- Token signed with the wrong algorithm
- ORDS cannot retrieve the correct key
- JWT tampering or truncation during copy and paste

Fix:

- Confirm the Auth0 API uses `RS256`
- Confirm the JWKS URL is correct
- Request a fresh token and avoid editing it manually

## Unreachable JWKS

Likely cause:

- ORDS environment cannot access the JWKS URL
- Incorrect domain or path in the JWKS configuration

Fix:

- Confirm the configured URL is `https://<tenant>/.well-known/jwks.json`
- Check network egress and DNS resolution from the ORDS environment
- Retry once the ORDS host can reach the JWKS endpoint

## Missing Scope

Likely cause:

- The machine-to-machine application was not granted the expected scope

Fix:

- Grant the scope in Auth0
- Request a fresh access token after changing permissions
- Inspect the decoded token payload to verify the scope claim

## Trailing Slash Mismatch in Issuer

Likely cause:

- ORDS is configured with `https://your-tenant.auth0.com`
- The token uses `https://your-tenant.auth0.com/`

Fix:

- Configure ORDS to use the same issuer formatting as the token claim
- Treat the trailing slash as significant unless you have confirmed otherwise in your environment
