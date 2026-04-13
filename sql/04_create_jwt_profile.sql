prompt Creating the ORDS JWT profile for the Auth0 + ORDS + ADB demo

-- This script creates a schema-level scope-based JWT profile for the current
-- schema by using ORDS_SECURITY.CREATE_JWT_PROFILE.
--
-- Replace the placeholder values before running:
--   p_issuer   -> your Auth0 issuer, including the trailing slash
--   p_audience -> your Auth0 API Identifier
--   p_jwk_url  -> your Auth0 JWKS URL
--
-- If you need to create or replace the JWT profile for another schema, use
-- ORDS_SECURITY_ADMIN.CREATE_JWT_PROFILE from an account with the necessary
-- privileges instead.

begin
  begin
    ords_security.delete_jwt_profile;
  exception
    when others then
      null;
  end;

  ords_security.create_jwt_profile(
    p_issuer          => 'https://your-tenant.auth0.com/',
    p_audience        => 'https://api.example.com/ords-api',
    p_jwk_url         => 'https://your-tenant.auth0.com/.well-known/jwks.json',
    p_description     => 'Auth0 JWT trust profile for the ORDS demo',
    p_allowed_skew    => 30,
    p_allowed_age     => 3600,
    p_role_claim_name => null
  );

  commit;
end;
/
