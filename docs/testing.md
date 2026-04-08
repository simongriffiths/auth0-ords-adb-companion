# Testing

This document gives a linear path from configuration to a working secured endpoint call.

## 1. Configure Auth0

- Create the API.
- Use a stable API Identifier such as `https://api.example.com/ords-api`.
- Set the signing algorithm to `RS256`.
- Create a machine-to-machine application.
- Grant the application access to the API and the example scope.

## 2. Configure ORDS

- Review `ords/jwt-profile.example.properties`.
- Adapt the issuer, audience, and JWKS values to your environment.
- Apply the equivalent settings to your ORDS deployment.

## 3. Populate Local `.env`

Create a local `.env` from `.env.example` and provide values for:

- `AUTH0_DOMAIN`
- `AUTH0_CLIENT_ID`
- `AUTH0_CLIENT_SECRET`
- `AUTH0_AUDIENCE`
- `ORDS_BASE_URL`
- `ORDS_SCHEMA`
- `ORDS_PATH`

If your schema is already ORDS-enabled, set `ORDS_SCHEMA` to the existing base path pattern exposed by `USER_ORDS_SCHEMAS`. Do not assume the SQL script will remap an already-enabled schema.

## 4. Apply SQL

Run the scripts in order:

1. `sql/01_create_sample_objects.sql`
2. `sql/02_define_module.sql`
3. `sql/03_define_security.sql`

If you need to remove the demo later, use `sql/99_cleanup.sql`.

## 5. Request a Token

Example:

```sh
set -a
. ./.env
set +a
./scripts/get-token.sh --token-only
```

Expected result:

- A bearer access token is returned
- The token `aud` matches `AUTH0_AUDIENCE`

## 6. Call the Secured ORDS Endpoint

Example:

```sh
set -a
. ./.env
set +a
ACCESS_TOKEN="$(./scripts/get-token.sh --token-only)"
./scripts/call-secure-endpoint.sh "$ACCESS_TOKEN"
```

Expected result:

- The script prints the response body
- The script prints the HTTP status code

## 7. Inspect or Verify the Result

Successful outcome:

- `200 OK`

Expected failure modes:

- `401 Unauthorized`
  The token is missing, invalid, expired, signed incorrectly, or does not match issuer or audience expectations.
- `403 Forbidden`
  The token is valid, but ORDS authorization or privilege mapping still blocks the request.

## Debugging Helper

To inspect the token locally:

```sh
./scripts/decode-jwt.sh "$ACCESS_TOKEN"
```

This does not verify the signature. It is only a debugging aid.
