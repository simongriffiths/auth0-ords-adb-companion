#!/usr/bin/env bash

set -eu

usage() {
  cat <<'EOF'
Usage: get-token.sh [--token-only]

Requests a client credentials access token from Auth0.

Required environment variables:
  AUTH0_DOMAIN
  AUTH0_CLIENT_ID
  AUTH0_CLIENT_SECRET
  AUTH0_AUDIENCE

Optional environment variables:
  TOKEN_ONLY=true
EOF
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

require_env() {
  var_name="$1"
  eval "var_value=\${$var_name:-}"
  if [ -z "$var_value" ]; then
    printf 'Missing required environment variable: %s\n' "$var_name" >&2
    exit 1
  fi
}

token_only="${TOKEN_ONLY:-false}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --token-only)
      token_only="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_command curl
require_command jq
require_env AUTH0_DOMAIN
require_env AUTH0_CLIENT_ID
require_env AUTH0_CLIENT_SECRET
require_env AUTH0_AUDIENCE

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

payload="$(jq -n \
  --arg client_id "$AUTH0_CLIENT_ID" \
  --arg client_secret "$AUTH0_CLIENT_SECRET" \
  --arg audience "$AUTH0_AUDIENCE" \
  '{
    client_id: $client_id,
    client_secret: $client_secret,
    audience: $audience,
    grant_type: "client_credentials"
  }'
)"

http_code="$(
  curl -sS \
    -o "$response_file" \
    -w '%{http_code}' \
    -H 'Content-Type: application/json' \
    --data "$payload" \
    "https://$AUTH0_DOMAIN/oauth/token"
)"

case "$http_code" in
  2??)
    ;;
  *)
    printf 'Auth0 token request failed with HTTP %s\n' "$http_code" >&2
    cat "$response_file" >&2
    printf '\n' >&2
    exit 1
    ;;
esac

access_token="$(jq -r '.access_token // empty' "$response_file")"

if [ -z "$access_token" ]; then
  printf 'Token response did not include access_token\n' >&2
  cat "$response_file" >&2
  printf '\n' >&2
  exit 1
fi

if [ "$token_only" = "true" ]; then
  printf '%s\n' "$access_token"
else
  jq '.' "$response_file"
fi
