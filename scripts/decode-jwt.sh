#!/usr/bin/env bash

set -eu

usage() {
  cat <<'EOF'
Usage: decode-jwt.sh [ACCESS_TOKEN]

Decodes the JWT header and payload locally.
This helper does not validate the signature.
EOF
}

base64_decode() {
  if command -v base64 >/dev/null 2>&1; then
    if printf '' | base64 --decode >/dev/null 2>&1; then
      base64 --decode
      return
    fi
    if printf '' | base64 -d >/dev/null 2>&1; then
      base64 -d
      return
    fi
    if printf '' | base64 -D >/dev/null 2>&1; then
      base64 -D
      return
    fi
  fi

  if command -v openssl >/dev/null 2>&1; then
    openssl base64 -d -A
    return
  fi

  printf 'No usable base64 decoder found\n' >&2
  exit 1
}

decode_segment() {
  segment="$1"
  padded="$segment"

  case $((${#segment} % 4)) in
    2) padded="${segment}==" ;;
    3) padded="${segment}=" ;;
    0) padded="${segment}" ;;
    *)
      printf 'Invalid base64url segment length\n' >&2
      exit 1
      ;;
  esac

  printf '%s' "$padded" | tr '_-' '/+' | base64_decode
}

pretty_print_json() {
  if command -v jq >/dev/null 2>&1; then
    jq '.'
  else
    cat
  fi
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

token="${1:-${ACCESS_TOKEN:-}}"

if [ -z "$token" ]; then
  printf 'Provide a JWT as the first argument or ACCESS_TOKEN\n' >&2
  exit 1
fi

IFS='.' read -r header payload signature extra <<EOF
$token
EOF

if [ -z "${header:-}" ] || [ -z "${payload:-}" ] || [ -z "${signature:-}" ] || [ -n "${extra:-}" ]; then
  printf 'Input does not look like a three-part JWT\n' >&2
  exit 1
fi

printf 'This helper decodes JWT content only. It does not verify signatures.\n' >&2
printf '\nHeader:\n'
decode_segment "$header" | pretty_print_json
printf '\nPayload:\n'
decode_segment "$payload" | pretty_print_json
printf '\n'
