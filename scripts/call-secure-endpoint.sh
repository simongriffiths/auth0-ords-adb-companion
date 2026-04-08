#!/usr/bin/env bash

set -eu

usage() {
  cat <<'EOF'
Usage: call-secure-endpoint.sh [ACCESS_TOKEN]

Calls the secured ORDS endpoint using a bearer token.

Required environment variables:
  ORDS_BASE_URL
  ORDS_SCHEMA
  ORDS_PATH

The access token may be provided as:
  1. the first positional argument
  2. ACCESS_TOKEN in the environment
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

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

require_command curl
require_env ORDS_BASE_URL
require_env ORDS_SCHEMA
require_env ORDS_PATH

access_token="${1:-${ACCESS_TOKEN:-}}"

if [ -z "$access_token" ]; then
  printf 'Provide an access token as the first argument or ACCESS_TOKEN\n' >&2
  exit 1
fi

base_url="${ORDS_BASE_URL%/}"
schema_path="${ORDS_SCHEMA#/}"
ords_path="${ORDS_PATH#/}"
url="${base_url}/${schema_path}/${ords_path}"

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

http_code="$(
  curl -sS \
    -o "$response_file" \
    -w '%{http_code}' \
    -H "Authorization: Bearer $access_token" \
    "$url"
)"

printf 'URL: %s\n' "$url"
printf 'HTTP: %s\n' "$http_code"
printf '\n'

if command -v jq >/dev/null 2>&1 && jq empty "$response_file" >/dev/null 2>&1; then
  jq '.' "$response_file"
else
  cat "$response_file"
  printf '\n'
fi

case "$http_code" in
  2??)
    exit 0
    ;;
  *)
    exit 1
    ;;
esac
