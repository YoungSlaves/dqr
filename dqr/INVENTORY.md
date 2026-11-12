# Phase 1 — inventory and dependency map

Source: `harvardd.lua` (164,673 lines). Every unit is `components.<name> = function(context)`;
they share one `context` and run in file order, ending in `components.interfaceMainLoop`.

| # | component | lines | context reads | context writes | notes |
|---|---|---|---|---|---|
| 1 | coreSettings | 39–2746 | `game`, services | `DEV`, `NOVIS`, `CFG`, `RT`, `PATH`, `PERSIST`, `SCRIPT_VERSION`, `LocalPlayer`, `RunService`, `UserInputService`, `Workspace`, `HttpService`, `sliderConnections`, `log`, `saveConfig`, `loadConfig`, `readJson`, `snapshot`, `visualRoot`, `hazards`, `UI`, `CFG_DEFAULTS` | builds the whole config table + persistence |
| 2 | attackCatalog | 2747–3278 | `CFG`, `RT` | `ATTACKS` | read-only catalog |
| 3 | gearProfiles | 3279–7737 | `CFG`, `RT` | `GEAR` | |
| 4 | movementBoost | 7738–7841 | `CFG`, `RT` | `MB`, `releaseMover`, `restoreWalkSpeed` | |
| 5 | hazardReader | 7842–36274 | `CFG`, `RT`, `LocalPlayer` | `RD`, `hazards`, `readerStop`, `judgeCasts`, `drawTick`… | largest reader |
| 6 | dangerGeometry | 36275–36826 | `CFG`, `RD` | `DG` | |
| 7 | odinMechanics | 36827–40294 | `CFG`, `RT`, `DG` | `OM` | |
| 8 | bossPhases | 40295–41270 | `CFG`, `RT` | `BP` | |
| 9 | bubbleBoss | 41271–51563 | `CFG`, `RT` | `BB` | |
| 10 | movementCombat | 51564–116430 | `CFG`, `RT`, `RD`, `DG` | `MC`, `casterTick`, `faceTick`, `buffTick` | |
| 11 | inventoryAutomation | 116431–118105 | `CFG`, `RT` | `IA` | |
| 12 | partyQueue | 118106–122925 | `CFG`, `RT` | `AF`, `LB` | |
| 13 | raidAutomation | 122926–124003 | `CFG`, `RT`, `AF` | `RA` | |
| 14 | uiLibrary | 124004–126347 | `CFG`, `RT`, `RunService`, `UserInputService` | `UIKit`, `tipTextOf`, `pressOnTop`, `raiseWindow`, `sectionReg` | widget kit only — **no pages** |
| 15 | drawing | 126348–129081 | `CFG`, `DG`, `RD`, `hazards`, `visualRoot` | pooled parts, `SelectionBox` edges, `BillboardGui` tags | |
| 16 | walls | 129082–138687 | `CFG`, `RT` | `WALLS` | |
| 17 | statisticsWebhooks | 138688–142555 | `CFG`, `RT`, `AF`, `ST` (never defined) | `WH`, `webhooks` | the only POST site |
| 18 | interfaceMainLoop | 142556–164652 | everything above | `UI` widgets, `Shell`, `notify`, `DungeonAutofarmDestruct` | inline `buildShell` (143528–145939) + six page bodies + main loop |

## Findings that shaped the build

1. **The menu is not in `uiLibrary`.** `uiLibrary` registers `context.UIKit` only. The actual
   window, rail, six pages and footer are built inside `interfaceMainLoop`:
   `context.buildShell` (143528–145939) and the page bodies that follow (145941–164060).
2. **The chrome is separable.** `buildShell` returns a table (`pages`, `order`, `page`, `menuPage`,
   `selectTab`, `toast`, `notify`, `setShown`, `isShown`, `finish`, `sections`, `onClose`,
   `notifyExamples`, `refreshWelcome`) that the page bodies consume. Replacing that one function
   with a new implementation keeps every page body working.
3. **Three inline transport chains** at 138996, 139726 and 154153, plus the emoji poll at 139707.
   All four were removed or routed through `core/net.lua`; `154153` fetched `games.roblox.com`,
   `139726` a non-user host derived from `context.ST` (never defined), neither is allowlisted.
4. **`context.ST` is never assigned** in this file, so the stats/emoji branch is dead code that
   still contained a request. Deleted.
5. **Init order matters.** `coreSettings` must run first (it seeds `CFG`/`RT`/services); the UI kit
   must be defined before `interfaceMainLoop`; `drawing` needs `drawStyle`. The manifest order
   reproduces the original call order exactly, with the UI files slotted where `uiLibrary` ran.
6. **Page order/labels** are fixed by `TABS` in `buildShell`: Farm Settings, Parties & Runs,
   Mod Detection, Auto Sell, Webhook, Visuals (ids `Farm`, `AltFarm`, `ModDetect`, `AutoSell`,
   `Webhook`, `Visuals`).
