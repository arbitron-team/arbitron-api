#!/usr/bin/env bash
# Every list endpoint takes the same filter vocabulary: comma-separated lists, min/max bounds, sort, fields, limit and cursor.
set -euo pipefail
: "${ARBITRON_KEY:?set ARBITRON_KEY to a key from https://arbitron.app/settings/api}"
B=https://arbitron.app/api/v1
H="Authorization: Bearer $ARBITRON_KEY"

echo "# BTC funding across venues, best short and long venue"
curl -fsS "$B/funding/BTC" -H "$H" | python3 -c 'import json,sys; d=json.load(sys.stdin)["data"]; print(d["best_short_exchange"], d["highest"]["rate_pct"], "|", d["best_long_exchange"], d["lowest"]["rate_pct"])'

echo "# Contracts settling in the next 30 minutes with a large rate"
curl -fsS "$B/funding?settles_within_minutes=30&min_abs_rate_pct=0.05&sort=next_funding_asc&fields=exchange,symbol,rate_pct,next_funding_at&limit=10" -H "$H"

echo "# ETH daily APR for the last 14 days on Binance and Bybit"
curl -fsS "$B/funding/history?coin=ETH&exchange=Binance,Bybit&days=14" -H "$H"

echo "# The last 10 settlement prints of SOL on Bybit"
curl -fsS "$B/funding/history?coin=SOL&exchange=Bybit&resolution=settlement&days=7&order=desc&limit=10" -H "$H"

echo "# Spreads among three venues right now, both legs liquid"
curl -fsS "$B/spreads?exchange=Binance,Bybit,Okx&exchange_match=all&min_volume_usdt=500000&max_spread_pct=3&limit=10" -H "$H"

echo "# Backtested spreads that cycled at least 10 times in the window and were active in the last day"
curl -fsS "$B/spreads/backtest?size_usd=100&min_cycles=10&min_confidence=50&active_within_hours=24&sort=cycles_desc&limit=10" -H "$H"

echo "# What is new on the listings calendar since a timestamp (poll with the previous meta.as_of)"
curl -fsS "$B/listings?detected_after=2026-09-21T00:00:00Z&sort=detected_asc" -H "$H"

echo "# Conditional request: a 304 costs nothing"
ETAG=$(curl -fsSI "$B/exchanges" -H "$H" | awk 'tolower($1)=="etag:"{print $2}' | tr -d '\r')
curl -s -o /dev/null -w "%{http_code}\n" "$B/exchanges" -H "$H" -H "If-None-Match: $ETAG"
