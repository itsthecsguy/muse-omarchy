# A native-feeling Muse on Omarchy: plan

Status: planning only, nothing implemented. Researched 2026-11-10. Nick confirmed the same day: Muse is Meta's agent (the same product as the Mac, Android and iOS apps), he is on a paid subscription, and he is in the US.

## Recommendation in brief

1. **Today (5 minutes):** install muse.ai as an Omarchy web app (its own Chromium `--app` window, launcher entry, icon, keybind). No terms-of-service risk, and sign-in is the normal Meta login.
2. **Next (about half a day, optional):** a Walker quick-prompt and/or small TUI built on the official **Meta Model API**. This talks to the Muse Spark models, not to Nick's Muse agent account, so it complements the web app and does not replace it.
3. **Do not build:** anything that drives the consumer muse.ai backend directly (reverse-engineered endpoints, copied cookies or session tokens, hosted "Muse API" resellers).
4. **Watch:** an official native Windows app is announced; no Linux app is planned. Revisit if that changes.

## 1. What "Muse" is

**Confirmed by Nick: Meta's Muse, the personal AI agent at <https://muse.ai>.** It is the same product as the Mac, Android and iOS apps; Linux is the gap.

| Aspect | Finding | How sure |
|---|---|---|
| Product | "Muse — Your Personal AI Agent from Meta", launched 2026-09-08 | Page title checked directly; date from press |
| Access points | iOS, Android, muse.ai, WhatsApp, native Mac app (2026-09-17) | Press coverage |
| Windows | Native app announced by Microsoft on 2026-10-07, no date | Press coverage |
| Linux | No app and none planned; the browser is the only route | One source states it, none contradict |
| PWA | Yes. `https://muse.ai/manifest.json` declares `display: standalone`, name "Muse", icons to 512 px, `start_url: /?__pwa=1` | Checked directly |
| Agent API | None. There is no public API for the Muse agent itself (tasks, memory, history) | Secondary sources, consistent |
| Model API | Yes. **Meta Model API** (`dev.meta.ai`) serves the Muse Spark models with OpenAI- and Anthropic-compatible endpoints. Public preview, reported US-only, about $1.25 / $4.25 per million input / output tokens | Meta blog plus third-party guides; exact endpoint paths conflict between guides |
| CLI | **Muse Code**, Meta's official terminal coding agent. Installs on Linux (x86_64, arm64), binary `muse`, signs in with a Meta account or API key | Meta docs plus guides; billing details conflict |
| MCP | Muse is an MCP *client*: connectors under Settings > Connectors, plus private custom connectors. Meta ships no MCP *server* for talking to Muse | Third-party write-ups |
| Plans | Free (capped), Power $20/mo, Maximum $100/mo; same features, different usage | Press; Meta's help page may not list prices |
| Automation stance | `muse.ai/robots.txt` says automated data collection is prohibited without express written permission and points to Meta's Automated Data Collection Terms | Checked directly |

For comparison, Grok Bot on this machine is a real packaged app (`grok-bot 0.79.3-1`, Electron-style dependencies, its own URL scheme). Muse has no equivalent package for Linux.

### Other things called Muse (not the one meant)

- **Muse** the thinking canvas (museapp.com): iPad/Mac only, not a chat product.
- **Sudowrite Muse**: a fiction-writing model inside Sudowrite.
- **Unity Muse**, **Microsoft Muse** (game model), **MuseScore**, the Arch `muse` package (a DAW), the Muse EEG headband.


## 2. Options, lightest to heaviest

| # | Option | Effort | Gain over a browser tab | Risks | Verdict |
|---|---|---|---|---|---|
| A | **Omarchy web app**: `omarchy-webapp-install` creating a `.desktop` entry that runs `omarchy-launch-webapp https://muse.ai/` | 5 min | Own window with no tabs or URL bar, own icon, shows in the app launcher, own window class for Hyprland rules | Shares the default Chromium profile (fine: that is where Nick is already signed in). Site redesigns cannot break it | **Quick win** |
| B | **A plus Hyprland integration**: keybind in `~/.config/hypr/bindings.lua`, optional window rule (fixed workspace, or a floating "scratchpad" that toggles like a desktop assistant) | 15-30 min | One keystroke summons Muse; focus-or-launch so there is only ever one window | Need a free key combo; window class must match the rule | **Recommended, part of the quick win** |
| C | **Chromium "Install app" (true PWA)** from the manifest | 5 min | Same as A, plus Chromium manages icon and updates | Duplicates A; Omarchy's launcher convention is A. Notifications work in either | Skip, A covers it |
| D | **Muse Code CLI** (official) | 10 min plus sign-in | Muse models in the terminal, good for coding tasks; official and supported on Linux | It is a coding agent, not the personal agent; separate billing may apply; one guide reports shell-command failures on Linux | **Optional add-on** if Nick wants terminal use |
| E | **Quick prompt / TUI on the Meta Model API** (Walker or a small terminal UI, API key in the keyring) | 0.5-1 day | Instant "ask a question" popup with no page load, streams into a small window, scriptable | Not the Muse agent: no shared history, memory, connectors, or cloud VM. Pay-per-token on top of any subscription. Preview is reported US-only. Endpoint details need checking against `dev.meta.ai` | **Recommended phase 2**, if the caveats are acceptable |
| F | **Native Qt/QML client on the Meta Model API** (Omarchy app style) | 3-7 days | Themed, fully native chat app | Same limits as E for far more work; history and settings must be built from scratch | Only if E proves useful daily |
| G | **Electron or Tauri wrapper around muse.ai** | 0.5-2 days | Tray icon, custom global shortcut, separate cookie jar | Meta login flows often reject embedded webviews (Tauri uses WebKitGTK); must ship and update a browser engine; gains almost nothing over A+B | **Not worth it** |
| H | **Unofficial client on muse.ai's private endpoints**, session-cookie reuse, or hosted wrappers such as useapi.net's "Muse API" | n/a | Would give the real agent in a CLI or native UI | Against the robots.txt notice and Meta's automated-collection terms; account ban risk; breaks whenever the site changes; hands Meta session credentials to code or a third party | **Not recommended. Ruled out.** |

### Why H is ruled out

There is no documented API for the consumer agent. Every route to it outside the official clients means either calling undocumented endpoints or replaying Nick's logged-in session from another program. Meta states its position on automated access in `robots.txt`, and the hosted third-party services ask for account credentials or cookies. The cost of being wrong is Nick's Meta account, so this stays off the table unless Meta publishes an agent API.

Option A/B is different in kind: it is Chromium itself, signed in the normal way, showing the real site. Nothing is automated or intercepted.

## 3. Recommended path

**Phase 1, today: A + B.**

- Create the web app with `omarchy-webapp-install` (name "Muse", URL `https://muse.ai/`, icon from the site's 512 px PWA icon).
- Add a keybind using Omarchy's own helper, of the form `o.bind("SUPER + SHIFT + <key>", "Muse", { webapp = "https://muse.ai/" })`. Pick the key after checking `omarchy menu keybindings --print` for conflicts.
- Optionally add a window rule keyed on the web app's window class (pattern `chrome-muse.ai__-Default`, to be confirmed with `hyprctl clients`): either pin it to a workspace or make it a floating, centered toggle window.
- Sign in once in that window. Chromium's shared profile keeps the session.

**Phase 2, optional: E.** A small script bound to a key: prompt in Walker, send to the Meta Model API, stream the answer into a floating terminal or notification. Store the key with `secret-tool` (libsecret), never in a dotfile. Check the real endpoint, model IDs, and regional availability in Meta's docs before writing code.

**Phase 3, only if warranted:** grow E into a TUI with local history, or into a Qt app (F).

**Alongside:** install Muse Code (D) if terminal coding with Muse models is wanted.

## 4. Open questions for Nick

Answered: Muse is Meta's agent; Nick has a paid subscription; he is in the US, so the Meta Model API preview is available to him.

Since Nick wants the Muse app itself (the agent, with his account and history), the web app in phase 1 is the real answer on Linux. Phase 2 is a side tool at most, because the API is billed per token separately from the subscription and does not reach his agent account.

Decided by Nick:

- **Keybind:** set per user, with no default shipped.
- **Window:** a toggle window (shown and hidden with one action), not a fixed workspace.
- **Profile:** shares the main Chromium profile by default, with an option to use an isolated profile.

Still open:

1. Is a one-shot quick prompt (phase 2) wanted at all, given it costs extra per token and is not the agent?
2. Is Muse Code of interest, given it may be billed separately?

## 5. To verify before implementing

- Exact window class of the web app, for the Hyprland rule.
- Whether Meta sign-in and notifications behave in `--app` mode on Wayland.
- Meta Model API endpoint, model names, pricing, and terms, from `dev.meta.ai` rather than third-party guides.
- Muse Code's current pricing and the reported Linux shell issue.

## Sources

Checked directly: `https://muse.ai` (title, meta tags), `https://muse.ai/manifest.json`, `https://muse.ai/robots.txt`, local `grok-bot` package, Omarchy's `omarchy-webapp-install` and `omarchy-launch-webapp`.

- Launch and Mac app: <https://www.therundown.ai/news/meta-muse-personal-ai-agent>, <https://hypebeast.com/2026/9/meta-muse-ai-mac-app-turns-desktop-into-smart-agent>, <https://betanews.com/article/meta-launches-a-muse-app-for-macos/>
- Windows and Linux status: <https://windowsreport.com/meta-muse-is-coming-to-windows-microsoft-confirms/>, <https://www.iphoneincanada.ca/2026/10/07/meta-muse-windows-app/>, <https://imasters.com/news/meta-muse-gets-native-windows-app-and-the-announcement-came-from-microsoft>
- Meta Model API: <https://ai.meta.com/blog/introducing-muse-spark-meta-model-api/>, <https://dev.meta.ai/docs/overview>, <https://www.layer3labs.io/guides/meta-model-api-guide>
- Muse Code: <https://research.meta.ai/blog/introducing-muse-code-and-muse-spark-1-2>, <https://codersera.com/blog/how-to-install-muse-code-cli-2026/>, <https://www.codeagentswarm.com/en/guides/muse-code-on-linux>
- Connectors and MCP: <https://www.aiagentslibrary.com/blog/meta-muse-mcp/>, <https://parallel.ai/articles/meta-muse-custom-integrations>, <https://useapi.net/docs/api-muse-v1/mcp> (third-party wrapper, listed as an example of what to avoid)
- Pricing: <https://www.facebook.com/fb-answers/meta-muse-pricing/>, <https://www.layer3labs.io/guides/meta-muse-pricing>
