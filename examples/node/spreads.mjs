// Arbitron API from Node 18+: fetch, the filter vocabulary, and the rate-limit headers.
//   ARBITRON_KEY=arb_live_... node spreads.mjs
const BASE = "https://arbitron.app/api/v1";
const headers = { Authorization: `Bearer ${process.env.ARBITRON_KEY}` };

async function get(path, params = {}) {
  const url = new URL(BASE + path);
  for (const [k, v] of Object.entries(params)) if (v != null) url.searchParams.set(k, String(v));
  const res = await fetch(url, { headers });
  if (!res.ok) {
    const problem = await res.json(); // RFC 9457: detail says what to change
    throw new Error(`${res.status} ${problem.code}: ${problem.detail}`);
  }
  console.error("rate limit:", res.headers.get("ratelimit"));
  return res.json();
}

// The spread between venues right now, restricted to pairs a real order could take.
const { data, meta } = await get("/spreads", {
  min_volume_usdt: 500_000, max_spread_pct: 3, min_strength: 2, sort: "spread_desc", limit: 10,
  fields: "symbol,exchange_a,exchange_b,spread_pct,direction,strength",
});
console.log(`${meta.total} tradeable pairs as of ${meta.as_of}; cite ${meta.url}`);
for (const r of data) console.log(`${r.symbol.padEnd(14)} ${r.exchange_a} / ${r.exchange_b}  ${r.spread_pct.toFixed(3)}%  ${r.direction}  strength ${r.strength}`);
