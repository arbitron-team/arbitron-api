# Arbitron API and MCP server

Read-only market data for crypto perpetual futures across the venues [Arbitron](https://arbitron.app) tracks: current funding rates, funding history, the spread between two venues right now, the scanner's backtested spreads, and the listings calendar. Two doors to the same data: a REST API for programs and an MCP server for AI assistants.

This repository holds the public artefacts of that product so they can be pinned, diffed and cited. The service itself is closed source.

| What | Where |
|---|---|
| Developer guide | https://arbitron.app/developers (Markdown twin: https://arbitron.app/developers/index.md) |
| API reference (Scalar) | https://arbitron.app/developers/reference |
| OpenAPI 3.1 document | https://arbitron.app/api/v1/openapi.json (a copy: [`openapi/openapi.json`](openapi/openapi.json)) |
| MCP server | `https://arbitron.app/mcp` (Streamable HTTP; registry entry `app.arbitron/mcp`: [`mcp/server.json`](mcp/server.json)) |
| Server card | https://arbitron.app/.well-known/mcp/server-card.json |
| Plans and keys | https://arbitron.app/developers#plans, keys at https://arbitron.app/settings/api |
| llms.txt | https://arbitron.app/llms.txt |

## REST in one minute

```bash
export ARBITRON_KEY=arb_live_...   # https://arbitron.app/settings/api

# The most negative funding on liquid contracts
curl -s "https://arbitron.app/api/v1/funding?max_rate_pct=-0.01&min_volume_usdt=1000000&sort=rate_asc&limit=5" \
  -H "Authorization: Bearer $ARBITRON_KEY"

# The spread between venues right now, tradeable pairs only
curl -s "https://arbitron.app/api/v1/spreads?min_volume_usdt=500000&max_spread_pct=3&min_strength=2&fields=symbol,exchange_a,exchange_b,spread_pct,direction" \
  -H "Authorization: Bearer $ARBITRON_KEY"
```

Every response is `{ "data": ..., "meta": { "as_of", "delayed_seconds", "source", "url", "count", "total", "next_cursor" } }`. Errors are RFC 9457 problem details. Rates are percent per settlement. More in [`examples/`](examples/).

## MCP in one minute

Claude Desktop, Cursor and ChatGPT connect with OAuth 2.1 (sign in with your Arbitron account); a program connects with the same API key as a bearer token. Client configurations are in [`mcp/clients/`](mcp/clients/). Nine read-only tools: `arbitron_search_coins`, `arbitron_get_funding_rates`, `arbitron_get_coin_funding`, `arbitron_get_funding_history`, `arbitron_get_spreads`, `arbitron_get_spread_backtest`, `arbitron_get_listings`, `arbitron_get_exchanges`, `arbitron_get_usage`.

## Plans

The Demo plan is free: 15-minute delayed data, 50 rows per page, no history. Paid plans (Developer, Pro, Business) are live, reach further back, and include commercial use. Details at https://arbitron.app/developers#plans.

## Citing

Attribute republished figures as "Data: Arbitron" with a link to `meta.url`, and keep `meta.as_of` with the number. Name the exchange and the settlement interval beside any funding rate.

## Contents of this repository

- `openapi/openapi.json`: the OpenAPI document as served, refreshed by [`scripts/refresh.sh`](scripts/refresh.sh).
- `mcp/server.json`: the manifest published to the official MCP registry.
- `mcp/clients/`: configuration snippets for Claude Desktop, Cursor and ChatGPT.
- `examples/`: curl, Python and Node examples.
- `.cursor-plugin/`: the plugin manifest for the Cursor marketplace.

Files here are licensed under the [MIT License](LICENSE). The data the API returns is subject to the [terms](https://arbitron.app/terms).
