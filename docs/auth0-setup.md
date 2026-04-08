# Auth0 Setup

Use this document to create the minimum Auth0 configuration needed for the ORDS trust example in this repository.

## 1. Create an API

In Auth0, create an API that represents the protected ORDS-backed resource server.

Recommended values:

- Name: `ORDS Demo API`
- Identifier: `https://api.example.com/ords-api`
- Signing Algorithm: `RS256`

The signing algorithm matters. This trust model assumes ORDS validates RS256-signed JWTs by fetching keys from the Auth0 JWKS endpoint.

## 2. Choose the API Identifier Carefully

The API Identifier becomes the JWT `aud` claim.

Important rules:

- It does not have to be the ORDS endpoint URL.
- It does not have to resolve on the network.
- It should be stable and unique for the protected API.
- It must exactly match the audience value configured in ORDS.

Good example:

- `https://api.example.com/ords-api`

Not recommended:

- copying the full ORDS endpoint URL just because it is easy to see in a browser
- changing the identifier casually after clients and ORDS have already been configured

## 3. Confirm the Auth0 Issuer Values

Your issuer and JWKS values derive from the Auth0 tenant domain.

Example tenant domain:

- `your-tenant.auth0.com`

Derived values:

- Issuer: `https://your-tenant.auth0.com/`
- JWKS URL: `https://your-tenant.auth0.com/.well-known/jwks.json`

Note the trailing slash in the issuer example. That exact value is often significant when ORDS performs issuer matching.

## 4. Create a Machine-to-Machine Application

Create an Auth0 machine-to-machine application that will request tokens using the client credentials grant.

You will need:

- Client ID
- Client Secret

Those values belong in your local `.env` file only. Do not commit them.

## 5. Grant API Permissions

Authorize the machine-to-machine application to call the API you created.

At minimum:

- enable the application for the API
- grant the scope or scopes used by your example

For this repository, a simple scope such as `read:demo` is enough.

## 6. Define Scopes

Create at least one scope for the example.

Recommended example scope:

- `read:demo`

This repository keeps the example small. The important point is to make the scope naming and the ORDS-side authorization explanation internally consistent.

## 7. Populate Local Environment Variables

Copy `.env.example` to `.env` locally and set:

- `AUTH0_DOMAIN`
- `AUTH0_CLIENT_ID`
- `AUTH0_CLIENT_SECRET`
- `AUTH0_AUDIENCE`

Keep `AUTH0_AUDIENCE` identical to the API Identifier you created in Auth0.

## Common Mistakes

- Using `HS256` instead of `RS256`
- Forgetting the issuer trailing slash when ORDS expects one
- Using the ORDS URL as the audience without meaning to
- Granting no scopes to the machine-to-machine application
- Testing with an ID token instead of an access token
