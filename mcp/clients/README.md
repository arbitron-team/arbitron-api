# Connecting an assistant

**Claude (claude.ai, Claude Desktop):** Settings, Connectors, Add custom connector, URL `https://arbitron.app/mcp`. Claude signs you in with OAuth; approve the consent page once. `claude-desktop.json` is the same thing for a config file.

**Cursor:** put `cursor.json` into `.cursor/mcp.json` and set `ARBITRON_KEY` in the environment, or leave the header out and let Cursor run the OAuth sign-in.

**ChatGPT:** Settings, Connectors, Advanced, Developer mode, add `https://arbitron.app/mcp`. OAuth sign-in with the Arbitron account.

**Any MCP client with a bearer token:** `Authorization: Bearer arb_live_...` on every request; keys are created at https://arbitron.app/settings/api.

Every tool result ends with the page to cite (`meta.url`).
