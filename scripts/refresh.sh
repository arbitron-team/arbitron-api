#!/usr/bin/env bash
# Refresh the served artefacts into this repository. No key needed: both documents are public.
set -euo pipefail
cd "$(dirname "$0")/.."
curl -fsS https://arbitron.app/api/v1/openapi.json | python3 -m json.tool > openapi/openapi.json
curl -fsS https://arbitron.app/.well-known/mcp/server-card.json | python3 -m json.tool > mcp/server-card.json
echo "refreshed: openapi/openapi.json, mcp/server-card.json"
