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
        local function hudGrain(parent, rotation)
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, HP.Bark),
                ColorSequenceKeypoint.new(0.35, HP.Wood),
                ColorSequenceKeypoint.new(0.7, HP.Bark),
                ColorSequenceKeypoint.new(1, HP.Wood),
            })
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.55),
                NumberSequenceKeypoint.new(0.35, 0.35),
                NumberSequenceKeypoint.new(0.7, 0.5),
                NumberSequenceKeypoint.new(1, 0.3),
            })
            gradient.Rotation = rotation or 8
            gradient.Parent = parent
            return gradient
        end
        local function helper120(name2, parent, argument, band, argument2)
            local panel = Instance.new("Frame")
            panel.Name, panel.BackgroundColor3, panel.BorderSizePixel, panel.Position, panel.Size =
                name2, HP.DeepForest, 0, UDim2.fromOffset(0, parent), UDim2.fromOffset(argument, band)
            panel.ZIndex = 3
            panel.Parent = hud
            uiLibrary.corner(panel, 8)
            uiLibrary.stroke(panel, HP.Bark, 3)
            local inner = Instance.new("UIStroke")
            inner.Color, inner.Thickness, inner.Transparency = HP.LeafLight, 1, 0.55
            inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            inner.Parent = panel
            hudGrain(panel, 8)
            local moss = Instance.new("Frame")
            moss.Name = "Moss"
            moss.BackgroundColor3, moss.BackgroundTransparency, moss.BorderSizePixel =
                HP.Fern, 0.25, 0
            moss.Position = UDim2.fromOffset(6, 3)
            moss.Size = UDim2.new(1, -12, 0, 3)
            moss.ZIndex = 5
            moss.Parent = panel
            uiLibrary.corner(moss, 2)
            return panel
        end
'''

HUD_122 = '''        local function helper122(argument, argument2, argument3)
            local plank = Instance.new("Frame")
            plank.Name, plank.BackgroundColor3, plank.BackgroundTransparency =
                "Plank", HP.Wood, 0.35
            plank.BorderSizePixel = 0
            plank.Position = UDim2.fromOffset(10, argument2 - 3)
            plank.Size = UDim2.fromOffset(540, 28)
            plank.ZIndex = 2
            plank.Parent = value132
            uiLibrary.corner(plank, 4)
            hudGrain(plank, 90)
            local edge = Instance.new("Frame")
            edge.BackgroundColor3, edge.BorderSizePixel = HP.Bark, 0
            edge.Position = UDim2.new(0, 0, 1, -2)
            edge.Size = UDim2.new(1, 0, 0, 2)
            edge.ZIndex = 3
            edge.Parent = plank
            helper121(value132, argument, "rowStat", 14, argument2, 120, 24)
            if argument3 then
                return helper121(value132, "--", "monoStat", 110, argument2, 436, 24, nil, true)
            end
            return helper121(value132, "--", "monoStat", 140, argument2, 406, 24, nil, true)
        end
'''

MINIMAP_THEME = '''        local sharedValue40, theme2 = config.minimapSize or 220, {}
        local MP = theme.palette
        theme2.Bg = MP.DeepForest
        theme2.Panel = MP.DeepForest
        theme2.Raised = MP.Wood
        theme2.Stroke = MP.Bark
        theme2.StrokeSoft = MP.Bark
        theme2.Text = MP.Parchment
        theme2.Muted = theme.TextSub
        theme2.Faint = theme.TextMuted
        theme2.Green = MP.LeafLight
        theme2.Red = theme.danger
        theme2.Purple = MP.Firefly
        theme2.Pink = MP.Fern
        theme2.Blue = MP.LeafLight
        theme2.White = MP.Parchment
        zone.theme = theme2
        theme2.Orb = MP.Firefly
        local sharedValue41 = {}
'''

GRADIENT = '''        local function helper162(argument, rotation)
            local new = NumberSequenceKeypoint.new
            return helper155("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, MP.Bark),
                    ColorSequenceKeypoint.new(0.35, MP.Wood),
                    ColorSequenceKeypoint.new(0.7, MP.Bark),
                    ColorSequenceKeypoint.new(1, MP.Wood),
                }),
                Rotation = rotation,
                Transparency = NumberSequence.new({ new(0, 0), new(0.55, 0.2), new(1, 1) }),
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
        '''        helper121(runsThisAccount, "Swangy", "windowChip", 12, 7, 138, 20)
        local hudLeaf = Instance.new("Frame")
        hudLeaf.Name, hudLeaf.BackgroundColor3, hudLeaf.BorderSizePixel = "Leaf", HP.LeafLight, 0
        hudLeaf.AnchorPoint, hudLeaf.Position = Vector2.new(1, 0.5), UDim2.new(1, -8, 0.5, 0)
        hudLeaf.Size, hudLeaf.Rotation, hudLeaf.ZIndex = UDim2.fromOffset(10, 10), 45, 5
        hudLeaf.Parent = runsThisAccount
        uiLibrary.corner(hudLeaf, 999)
''',
        1,
    )
    body = body.replace('"StatusChip", theme.SurfaceChip, 0,', '"StatusChip", HP.Wood, 0,', 1)
    body = body.replace('"ClockChip", theme.SurfaceChip, 0,', '"ClockChip", HP.Wood, 0,', 1)
    body = body.replace(
        "        uiLibrary.corner(statusChip, theme.RadiusMd)\n"
        "        uiLibrary.stroke(statusChip, theme.Hairline, 1)\n",
        "        uiLibrary.corner(statusChip, 4)\n"
        "        uiLibrary.stroke(statusChip, HP.Bark, 2)\n",
        1,
    )
    body = body.replace(
        "        uiLibrary.corner(clockChip, theme.RadiusMd)\n"
        "        uiLibrary.stroke(clockChip, theme.Hairline, 1)\n",
        "        uiLibrary.corner(clockChip, 4)\n"
        "        uiLibrary.stroke(clockChip, HP.Bark, 2)\n",
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
        mapMoss.Name = "Moss"
        mapMoss.BackgroundTransparency = 1
        mapMoss.BorderSizePixel = 0
        mapMoss.Size = UDim2.new(1, 0, 0, 4)
        mapMoss.ZIndex = 35
        mapMoss.Parent = view
        for index = 1, 3 do
            local segment = Instance.new("Frame")
            segment.Name = "MossSegment"
            segment.BackgroundColor3 = MP.Fern
            segment.BackgroundTransparency = 0.25
            segment.BorderSizePixel = 0
            segment.Position = UDim2.new((index - 1) / 3, 0, 0, 0)
            segment.Size = UDim2.new(1 / 3, -2, 0, 4)
            segment.ZIndex = 35
            segment.Parent = mapMoss
        end
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
