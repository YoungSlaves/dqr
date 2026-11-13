#!/usr/bin/env python3
"""Presentation pass for the two legacy surfaces inside interfaceMainLoop.

The HUD (bottom-left) and HLMinimap (top-right) predate the Duskwood shell.
They are rebuilt here by exact-text seams so the same edits apply both to the
shipped file and to `tools/extract.py`'s parity copy.

Run directly to rewrite `src/features/interfaceMainLoop.lua`.
"""
from __future__ import annotations

import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
TARGET = ROOT / "src" / "features" / "interfaceMainLoop.lua"

BRAND = [
    ("Harvard Labs", "Swangy"),
    ("DUNGEON AUTOFARM", "SWANGY"),
]


def apply_brand(body: str) -> str:
    for old, new in BRAND:
        body = body.replace(old, new)
    return body


def _cut(body: str, start: str, end: str, replacement: str) -> str:
    first = body.index(start)
    last = body.index(end, first + len(start)) + len(end)
    return body[:first] + replacement + body[last:]


HUD_120 = '''        local HP = theme.palette
        local function helper120(name2, parent, argument, band)
            local panel = Instance.new("Frame")
            panel.Name, panel.BackgroundColor3, panel.BorderSizePixel, panel.Position, panel.Size =
                name2, HP.DeepForest, 0, UDim2.fromOffset(0, parent), UDim2.fromOffset(argument, band)
            panel.BackgroundTransparency = 0.04
            panel.ZIndex = 3
            panel.Parent = hud
            uiLibrary.corner(panel, 12)
            uiLibrary.stroke(panel, HP.Bark, 1)
            local inner = Instance.new("UIStroke")
            inner.Color, inner.Thickness, inner.Transparency = HP.Fern, 1, 0.78
            inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            inner.Parent = panel
            local signal = Instance.new("Frame")
            signal.Name = "Signal"
            signal.BackgroundColor3, signal.BorderSizePixel = HP.Fern, 0
            signal.Position, signal.Size = UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 2)
            signal.ZIndex = 5
            signal.Parent = panel
            uiLibrary.corner(signal, 999)
            local signalGradient = Instance.new("UIGradient")
            signalGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, HP.Fern),
                ColorSequenceKeypoint.new(0.55, HP.LeafLight),
                ColorSequenceKeypoint.new(1, HP.Hot),
            })
            signalGradient.Parent = signal
            return panel
        end
'''

HUD_122 = '''        local function helper122(argument, argument2, argument3)
            local index = ({ [11] = 1, [37] = 2, [63] = 3, [89] = 4 })[argument2] or 1
            local column = (index - 1) % 2
            local row = math.floor((index - 1) / 2)
            local cell = Instance.new("Frame")
            cell.Name = "Stat"
            cell.BackgroundColor3, cell.BackgroundTransparency, cell.BorderSizePixel =
                HP.Moss, 0.16, 0
            cell.Position = UDim2.fromOffset(10 + column * 294, 6 + row * 50)
            cell.Size = UDim2.fromOffset(280, 44)
            cell.ZIndex = 2
            cell.Parent = value132
            uiLibrary.corner(cell, 8)
            local accent = Instance.new("Frame")
            accent.Name = "Accent"
            accent.BackgroundColor3, accent.BorderSizePixel = index % 2 == 0 and HP.Hot or HP.Fern, 0
            accent.Position, accent.Size = UDim2.fromOffset(0, 10), UDim2.fromOffset(2, 24)
            accent.ZIndex = 3
            accent.Parent = cell
            uiLibrary.corner(accent, 999)
            local label = helper121(cell, argument, "captionKey", 10, 5, 260, 13)
            label.TextColor3 = theme.TextMuted
            return helper121(cell, "--", "rowStat", 10, 20, 260, 19, nil, argument3)
        end
'''

MINIMAP_THEME = '''        local sharedValue40, theme2 = config.minimapSize or 220, {}
        local MP = theme.palette
        theme2.Bg = MP.DeepForest
        theme2.Panel = MP.Moss
        theme2.Raised = MP.Wood
        theme2.Stroke = MP.Bark
        theme2.StrokeSoft = MP.Bark
        theme2.Text = MP.Parchment
        theme2.Muted = MP.Muted
        theme2.Faint = MP.Muted
        theme2.Green = MP.LeafLight
        theme2.Red = theme.danger
        theme2.Purple = MP.Hot
        theme2.Pink = MP.Fern
        theme2.Blue = MP.Fern
        theme2.White = MP.Parchment
        zone.theme = theme2
        theme2.Orb = MP.LeafLight
        local sharedValue41 = {}
'''

GRADIENT = '''        local function helper162(argument, rotation)
            local new = NumberSequenceKeypoint.new
            return helper155("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, MP.Wood),
                    ColorSequenceKeypoint.new(0.45, MP.Moss),
                    ColorSequenceKeypoint.new(0.7, MP.Bark),
                    ColorSequenceKeypoint.new(1, MP.Wood),
                }),
                Rotation = rotation,
                Transparency = NumberSequence.new({ new(0, 0.05), new(0.55, 0.28), new(1, 1) }),
            }, argument)
        end
'''


def apply_interface(body: str) -> str:
    body = _cut(
        body,
        "        local function helper120(name2, parent, argument, band, argument2)\n",
        "            return parent2\n        end\n",
        HUD_120,
    )
    body = _cut(
        body,
        "        local function helper122(argument, argument2, argument3)\n",
        '            return helper121(value132, "--", "monoStat", 140, argument2, 406, 24, nil, true)\n        end\n',
        HUD_122,
    )
    body = body.replace(
        '        helper121(runsThisAccount, "Harvard Labs", "windowChip", 12, 7, 138, 20)\n',
        '''        helper121(runsThisAccount, "SWANGY // OS", "windowChip", 16, 12, 190, 22)
        local hudLeaf = Instance.new("Frame")
        hudLeaf.Name, hudLeaf.BackgroundColor3, hudLeaf.BorderSizePixel = "Leaf", HP.LeafLight, 0
        hudLeaf.AnchorPoint, hudLeaf.Position = Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0)
        hudLeaf.Size, hudLeaf.Rotation, hudLeaf.ZIndex = UDim2.fromOffset(7, 7), 0, 5
        hudLeaf.Parent = runsThisAccount
        uiLibrary.corner(hudLeaf, 999)
''',
        1,
    )
    body = body.replace(
        'runsThisAccount = helper120("TitleChip", 0, 326, 34, theme.RadiusMd)',
        'runsThisAccount = helper120("TitleChip", 0, 600, 46, 12)',
        1,
    )
    body = body.replace(
        'local value132 = helper120("Stats", 42, 560, 121, theme.RadiusLg)',
        'local value132 = helper120("Stats", 54, 600, 112, 12)',
        1,
    )
    body = body.replace(
        'helper121(runsThisAccount, "|", "captionKey", 154, 7, 6, 20, theme.TextMuted)',
        'helper121(runsThisAccount, "|", "captionKey", 214, 12, 8, 20, theme.TextMuted)',
    )
    body = body.replace(
        'helper121(runsThisAccount, ver, "rowStat", 160, 7, 80, 20, theme.TextSub)',
        'helper121(runsThisAccount, ver, "rowStat", 228, 12, 100, 20, theme.TextSub)',
    )
    body = body.replace(
        'helper121(runsThisAccount, "|", "captionKey", 240, 7, 6, 20, theme.TextMuted)',
        'helper121(runsThisAccount, "|", "captionKey", 336, 12, 8, 20, theme.TextMuted)',
    )
    body = body.replace(
        'local textControl18 = helper121(runsThisAccount, "fps: --", "monoStat", 254, 7, 66, 20)',
        'local textControl18 = helper121(runsThisAccount, "fps: --", "monoStat", 468, 12, 118, 20, nil, true)',
        1,
    )
    body = body.replace(
        '"HUD", 1, Vector2.new(0, 1), UDim2.new(0, 20, 1, -20), UDim2.fromOffset(560, 199)',
        '"HUD", 1, Vector2.new(0, 1), UDim2.new(0, 24, 1, -24), UDim2.fromOffset(600, 214)',
        1,
    )
    body = body.replace('"StatusChip", theme.SurfaceChip, 0,', '"StatusChip", HP.DeepForest, 0,', 1)
    body = body.replace('"ClockChip", theme.SurfaceChip, 0,', '"ClockChip", HP.DeepForest, 0,', 1)
    body = body.replace(
        "        uiLibrary.corner(statusChip, theme.RadiusMd)\n"
        "        uiLibrary.stroke(statusChip, theme.Hairline, 1)\n",
        "        uiLibrary.corner(statusChip, 8)\n"
        "        uiLibrary.stroke(statusChip, HP.Bark, 1)\n",
        1,
    )
    body = body.replace(
        "        uiLibrary.corner(clockChip, theme.RadiusMd)\n"
        "        uiLibrary.stroke(clockChip, theme.Hairline, 1)\n",
        "        uiLibrary.corner(clockChip, 8)\n"
        "        uiLibrary.stroke(clockChip, HP.Bark, 1)\n",
        1,
    )
    body = body.replace(
        'UDim2.fromOffset(0, 173), UDim2.fromOffset(200, 24), theme.TextSub',
        'UDim2.fromOffset(10, 178), UDim2.fromOffset(260, 20), theme.TextSub',
        1,
    )
    body = body.replace(
        '"StatusChip", HP.DeepForest, 0, UDim2.fromOffset(410, 173), UDim2.fromOffset(150, 24)',
        '"StatusChip", HP.Moss, 0, UDim2.fromOffset(350, 176), UDim2.fromOffset(240, 30)',
        1,
    )
    body = body.replace(
        '"ClockChip", HP.DeepForest, 0, UDim2.fromOffset(318, 173), UDim2.fromOffset(84, 24)',
        '"ClockChip", HP.Moss, 0, UDim2.fromOffset(528, 176), UDim2.fromOffset(62, 30)',
        1,
    )

    body = _cut(
        body,
        "        local sharedValue40, theme2 = config.minimapSize or 220, {}\n",
        "        local sharedValue41 = {}\n",
        MINIMAP_THEME,
    )
    body = _cut(
        body,
        "        local function helper162(argument, rotation)\n",
        "        end\n",
        GRADIENT,
    )
    body = body.replace(
        "        stroke2.Parent = view\n",
        '''        stroke2.Parent = view
        stroke2.Color = MP.Bark
        stroke2.Thickness = 3
        local strokeInner = Instance.new("UIStroke")
        strokeInner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        strokeInner.Color = MP.LeafLight
        strokeInner.Thickness = 1
        strokeInner.Transparency = 0.55
        strokeInner.Parent = view
        local mapMoss = Instance.new("Frame")
        mapMoss.Name = "Signal"
        mapMoss.BackgroundColor3 = MP.Fern
        mapMoss.BackgroundTransparency = 0.1
        mapMoss.BorderSizePixel = 0
        mapMoss.Size = UDim2.new(1, 0, 0, 2)
        mapMoss.ZIndex = 35
        mapMoss.Parent = view
        local mapSignal = Instance.new("UIGradient")
        mapSignal.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, MP.Fern),
            ColorSequenceKeypoint.new(0.55, MP.LeafLight),
            ColorSequenceKeypoint.new(1, MP.Purple),
        })
        mapSignal.Parent = mapMoss
''',
        1,
    )
    body = body.replace(
        "corner.CornerRadius, view.BackgroundColor3 = UDim.new(0, 14), theme2.Panel",
        "corner.CornerRadius, view.BackgroundColor3 = UDim.new(0, 10), theme2.Panel",
    )
    body = body.replace("stroke2.Thickness = 1", "stroke2.Thickness = 3")
    body = body.replace("                view.BackgroundTransparency = 0.1\n", "                view.BackgroundTransparency = 0\n", 1)
    body = body.replace('            { Text = "Map view",', '            { Text = "Swangy map",', 1)
    body = body.replace(
        '                mapBtn.Text = "MINIMAP [" .. tostring(config.mapKey or "M") .. "]"',
        '                mapBtn.Text = "SWANGY MAP [" .. tostring(config.mapKey or "M") .. "]"',
        1,
    )
    body = body.replace(
        "                mapBtn.TextSize, mapBtn.TextColor3, mapBtn.BackgroundColor3 = 13, theme2.Text, theme2.Raised\n"
        "                mapBtn.BackgroundTransparency = 0\n"
        "                mapBtnStroke.Color = theme2.Stroke\n"
        "                mapBtnStroke.Thickness = 1\n",
        "                mapBtn.TextSize, mapBtn.TextColor3, mapBtn.BackgroundColor3 = 13, MP.Parchment, MP.Wood\n"
        "                mapBtn.BackgroundTransparency = 0.15\n"
        "                mapBtnStroke.Color = MP.Bark\n"
        "                mapBtnStroke.Thickness = 2\n",
        1,
    )
    body = body.replace("zone.mapBtnCorner.CornerRadius = UDim.new(0, 8)", "zone.mapBtnCorner.CornerRadius = UDim.new(0, 4)", 1)
    return apply_brand(body)


def apply_all() -> None:
    body = TARGET.read_text(encoding="utf-8", errors="surrogateescape")
    body = apply_interface(body)
    TARGET.write_text(body, encoding="utf-8", errors="surrogateescape", newline="")
    for path in sorted((ROOT / "src" / "features").glob("*.lua")):
        if path == TARGET:
            continue
        text = path.read_text(encoding="utf-8", errors="surrogateescape")
        path.write_text(apply_brand(text), encoding="utf-8", errors="surrogateescape", newline="")


if __name__ == "__main__":
    apply_all()
    print("reskinned HUD + minimap and renamed visible brand")
