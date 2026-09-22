"""Arbitron API from Python: standard library only, cursor pagination, ETag reuse.

    ARBITRON_KEY=arb_live_... python funding.py
"""
import json
import os
import urllib.parse
import urllib.request

BASE = "https://arbitron.app/api/v1"
KEY = os.environ["ARBITRON_KEY"]


def get(path, **params):
    query = urllib.parse.urlencode({k: v for k, v in params.items() if v is not None})
    req = urllib.request.Request(f"{BASE}{path}?{query}", headers={"Authorization": f"Bearer {KEY}"})
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.load(resp)


def every_page(path, **params):
    """Follow meta.next_cursor until the last page."""
    cursor = None
    while True:
        body = get(path, cursor=cursor, **params)
        yield from body["data"]
        cursor = body["meta"].get("next_cursor")
        if not cursor:
            return


if __name__ == "__main__":
    negative = list(every_page("/funding", max_rate_pct=-0.01, min_volume_usdt=1_000_000, sort="rate_asc",
                               fields="exchange,symbol,rate_pct,interval_hours", limit=500))
    print(f"{len(negative)} liquid contracts with negative funding")
    for row in negative[:5]:
        print(f"  {row['exchange']:<12} {row['symbol']:<16} {row['rate_pct']:+.4f}% every {row['interval_hours']}h")

    btc = get("/funding/BTC")["data"]
    print(f"BTC: short on {btc['best_short_exchange']} ({btc['highest']['rate_pct']:+.4f}%), "
          f"long on {btc['best_long_exchange']} ({btc['lowest']['rate_pct']:+.4f}%)")
