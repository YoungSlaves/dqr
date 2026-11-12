# Swangy — Duskwood build

Dungeon Quest automation, rebuilt as an **enchanted-forest artifact** under the **Swangy** name
(the hosting repo remains `YoungSlaves/dqr`): a branch with a hanging
title sign, six hanging-sign tabs on a rope rail, a bark-framed stone window, plank rows, leaf
buttons, knot toggles, vine sliders and drifting fireflies. Same features, same defaults, same
saved settings as the monolith it came from — only the presentation layer changed.

## Load it

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YoungSlaves/dqr/main/dqr.lua"))()
```

One call. The loader shows a themed loading card, downloads the manifest and every module,
compile-checks all of them, then opens the menu. Nothing else is fetched at runtime except your
own webhook posts.

Reload without rejoining: `_G.DQR_RELOAD()`. Stop it: `_G.DungeonAutofarmDestruct()`.

## Executor requirements

| Need | Why |
|---|---|
| `loadstring` | every module is compiled before it runs (the build gate) |
| a file API (`writefile`, `readfile`, `listfiles`, `isfile`/`makefolder`, `delfile`) | the version-keyed cache; without it the build still runs live |
| `request`, `httpget`, `syn.request`, `fluxus.request` or `http.request` | module download and webhooks |
| `setfenv` (falls back to installed globals) | the unchanged component bodies expect `getService`/`argumentHelpers` |

Transport order is fixed: `request` → `httpget`/`HttpGet` → `syn.request` → `fluxus.request` →
bare `http_request` → `http.request`.

**`httpget`-only executors can read the repo but cannot POST webhooks.** `httpget` returns a body
and no status, is GET-only, and is treated as GET-only here; the webhook panel still saves and
gates exactly as before, but posts report `GET only (httpget) - cannot post` in the log.

`HttpService` is used for `JSONEncode`/`JSONDecode` only. It never makes a request — it cannot
reach `raw.githubusercontent.com` from an executor.

## Network policy

Exactly two channels are allowed:

| Channel | Target | Trigger |
|---|---|---|
| Module loading | `raw.githubusercontent.com/<owner>/dqr/<branch>/...` | startup, `_G.DQR_RELOAD` |
| User webhooks | the exact `webhookUrl` you typed | existing webhook events, when non-empty |

Everything else was removed from the presentation rewrite: no analytics, stats, telemetry,
version beacon, emoji/icon fetch, server-list probe, shortener or proxy. A fresh install with an
empty webhook URL makes zero requests after the module fetch.

Forking: edit `OWNER`, `REPO`, `BRANCH` and `basePath` (in `dqr.lua` and `modules.json`). The repo
must be public — a private repo needs a token for raw reads and embedding one is forbidden. Pin a
branch or tag in `basePath`; `main` moves.

## Layout

```
dqr.lua                    loader + loading card + gate + cache (~350 lines)
modules.json               version, minLoader, basePath, ordered modules
src/core/services.lua      getService / argumentHelpers shared by every module
src/core/net.lua           the only transport resolver in the build
src/ui/theme.lua           palette, metrics, one-shot font resolver, VINE/LEAF ids
src/ui/shapes.lua          every shape + the three ScreenGuis + fireflies
src/ui/primitives.lua      text roles, layout, tooltips, hover
src/ui/kit.lua             widget kit the six pages call (UIKit-compatible)
src/ui/window.lua          Duskwood shell: branch, sign, hanging tabs, footer, notifications
src/draw/style.lua         world-space palette and label plate
src/features/*.lua         17 components extracted verbatim (one per existing component)
```

`src/features/interfaceMainLoop.lua` keeps the six page bodies verbatim; only its inline window
chrome (lines 143528–145939 of the original) was cut and replaced by
`context.UI.buildShell` from `src/ui/window.lua`. Every other component is byte-identical —
`tools/verify_parity.py` re-slices the original and proves it.

## Three GUI layers

| ScreenGui | DisplayOrder | Contents | Interactive |
|---|---|---|---|
| `DQRAmbient` | 40 | fireflies only | no |
| `DQRRoot` | 50 | window, rail, rows, controls, tooltips, notifications | yes |
| `DQRLoading` | 50 | startup card only | no |

All three: `ZIndexBehavior = Sibling`, `IgnoreGuiInset = true`, `ResetOnSpawn = false`. Ordering
*between* GUIs is `DisplayOrder` only; `ZIndex` never crosses a ScreenGui boundary. Loading and
menu share 50 because the card is destroyed before the menu exists.

The bug-report overlay is an existing feature with its own ScreenGui; removing it would break
parity, so it is the one documented exception to "exactly three".

## Cache and failure behaviour

`dqr/cache/<version>/` holds that version's `modules.json` plus every module source, written
(temp → rename where the executor exposes `os.rename`, otherwise write-then-verify) only after a
full fetch + parse + compile pass. The newest two versions are kept.

* network or 404 failure + a complete cache → run the cached version whole, with the offline chip
  (warning dot, `offline · cached v<version>` in the footer and on the card, one persistent notice);
* no usable cache → destroy the card, leave zero GUI instances, run no modules, keep the previous
  `_G.DungeonAutofarmDestruct`, print exactly one console error naming the stage, path and last
  valid cached version.

A cached manifest is never mixed with fresh modules, and fresh code never runs when only part of
the version downloaded.

## Design notes / deviations

* `UICorner` has one radius per object; every leaf, diamond, knot and vein is a rotated square with
  `UDim.new(0.5, 0)` inside a **non-rotated ≥44×44** click target. Text never sits inside a rotated
  frame.
* Wood grain is a `UIGradient` per face (`Bark → Wood → Bark → Wood`, rotations 90 / 8) — never a
  shared instance. Accent gradients are gone; the only gradients left are wood grain and moss
  shading.
* Fonts resolve once at boot (Fondamento for titles, Merriweather for body) with `asset → enum →
  substitute` fallback, logged as one `UI` line. No font is ever fetched.
* `VINE_IMAGE_ID` / `LEAF_IMAGE_ID` are `nil` in `src/ui/theme.lua`; while nil no `ImageLabel` is
  created at all. Set a verified id to opt in.
* The loading card's palette constants live in the loader: it must exist before `ui/theme.lua` can
  be downloaded, so it is the one bootstrap exception to "theme owns every colour". `ui/shapes.lua`
  owns the other two ScreenGuis; the loader owns `DQRLoading` for the same reason.
* Save-state chip: shows `saved`, and `unsaved` if `shell.setSaveState("unsaved")` is called; the
  original build had no such state to observe, so none was invented.

## Verification actually run

```
$ luau-compile --binary <each of the 26 shipped .lua files>
compile_failures=0                       (Luau CLI 0.69x, exit 0 per file)

$ python tools/verify_parity.py
OK   coreSettings / attackCatalog / ... / interfaceMainLoop   (17/17 SHA-256 match)
CFG keys: original=2543 build=2543 missing=0 extra=0
PARITY OK

$ python tools/audit.py
PASS HttpService makes no request
PASS transport resolved only in loader + core/net
PASS menu layer creates Ambient/Menu/Loading only in shapes + loader bootstrap
PASS DQRAmbient / DQRRoot / DQRLoading, orders 40/50/50, Sibling everywhere
counts: rotated-45 frames=3  UIGradient creations=12  menu ScreenGuis=2
PASS VINE_IMAGE_ID nil / LEAF_IMAGE_ID nil / vine+leaf behind the nil guard
PASS Font.new only in theme resolver, loader card, pre-existing bug report
PASS fireflies spawn in the ambient layer
PASS row rotation formula lives in shapes.plankRow
AUDIT OK

$ python tools/test_logic.py
PASS request wins first / GET normalises Body / 2xx POST succeeds
PASS httpget chosen when request is absent / httpget never POSTs
PASS syn.request is third / fluxus is fourth / bare http_request is last
PASS no transport -> unavailable / non-2xx fails / empty body fails
PASS a throwing transport reads as network failure
PASS font asset -> asset (FontFace only, Font.new twice)
PASS font asset missing -> enum (Font only, Font.new twice, one boot line)
PASS both missing -> substitute (Garamond / SourceSans)
LOGIC OK
```

Not run here, because Roblox cannot be launched in this environment: the GUI
layering runtime test (firefly click-through), font stub matrix, loading-gate
instance tracing, the failure-rule matrix, webhook payload diff, teardown
counts, and frame-cost measurements. `tools/audit.py` covers their static
counterparts (declared orders, click-through `Active = false`, nil asset ids,
single gradient owner, resolver confinement). Please run the runtime checklist
in Roblox before trusting the visual result.

## Deviations and limits

* **Page bodies stay in `interfaceMainLoop`.** They are interleaved with loop
  state and closure helpers; slicing them into `ui/sections.lua` would change
  capture. They are byte-identical and every control they build now renders
  through the Duskwood kit.
* **Exactly three GUIs applies to the menu layer.** Four pre-existing feature
  screens remain (bug report, party lobby �2, cast timer). Deleting them would
  break features, so they stay.
* **`buildShell` was replaced wholesale.** It is one contiguous block; its
  page table contract is reimplemented in `src/ui/window.lua`. The welcome
  card, search, notifications, toast and flash are rebuilt there.
* **Save-state chip is passive.** The original had no dirty flag to observe;
  `shell.setSaveState("unsaved")` is the hook, default is `saved`.
* **Frame cost was not measured.** Without Roblox there is no honest number;
  the build adds static frames per row/tab and at most 8 fireflies with two
  tweens each, all paused while the window is hidden.
* The world layer keeps config-driven colours (user's Visuals choices) and
  only remaps hard-coded literals; defaults are untouched for parity.
* The colour picker's hue strip keeps a full RGB spectrum (`Color3.fromRGB` in
  `src/ui/kit.lua`). A two-colour forest gradient would make the picker unable
  to select colours � the one place a literal spectrum is required.
* Feature bodies still contain the colour defaults and gameplay colours they
  shipped with; those are user-facing settings, not menu chrome.
