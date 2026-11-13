# Swangy — headless Duskwood build

Dungeon Quest automation with a compact, movable HUD and a client-side local display spoofer.

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YoungSlaves/dqr/main/dqr.lua"))()
```

Reload without rejoining:

```lua
_G.DQR_RELOAD()
```

Stop:

```lua
_G.DungeonAutofarmDestruct()
```

## Runtime layout

| Path | Purpose |
|---|---|
| `dqr.lua` | loader, cache, module download and compile gate |
| `modules.json` | ordered module manifest |
| `src/core` | shared services and the only transport resolver |
| `src/features` | automation, combat, webhook, drawing, and wall modules |
| `src/ui/theme.lua` | palette and fonts used by the world drawing layer |
| `src/headless/config.lua` | config defaults, merge, and save |
| `src/headless/main.lua` | HUD, controls, spoofers, reset, and GPU mode |

Only files listed in `modules.json` are part of the runtime. The old menu stack and extraction/parity tooling were removed; there is no dead UI source in the repository.

## Configuration

The runtime config is `swangy/config/config.json`. The local spoofer is configured under:

```json
"Universal": {
  "Spoofer": {
    "Enabled": false,
    "Name": "",
    "PFP": "bunnyoutofhole.jpg",
    "Level": "",
    "Gold": "",
    "Gems": "",
    "EXP": "",
    "Health": ""
  }
}
```

`PFP` is a filename resolved from `swangy/images`. Text values use `*` to display a blank field. Turning `Enabled` off removes the fake labels and restores the local `playerStatus` and character `playerNameplate`.

## Checks

```sh
tools/luau/luau-compile.exe src/headless/main.lua
tools/luau/luau-compile.exe src/headless/config.lua
tools/luau/luau.exe tools/.tmp-tests/headless-main.luau
tools/luau/luau.exe tools/.tmp-tests/headless-config.luau
python tools/audit.py
python tools/test_logic.py
```
