#!/usr/bin/env bash
set -euo pipefail

token="$(curl -fsS -H Metadata:true \
  'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')"
curl -fsS -H "Authorization: Bearer ${token}" \
  'https://__KV_NAME__.vault.azure.net/secrets/app-marker?api-version=7.4' \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["id"])'
