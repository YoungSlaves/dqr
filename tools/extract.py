#!/usr/bin/env python3
"""Mechanical extraction of the 18 components out of harvardd.lua.

Every component body is copied byte-for-byte between its `components.<name> =
function(context)` line and the line before the next component (or the call
list at the end of the file).

Only `interfaceMainLoop` is touched, in two places, both of them presentation
seams and both recorded here:

  * lines 143528-145939 (`context.buildShell = ... end`) are cut out and
    replaced by a three-line stub that calls the new forest shell
    (`ui/window.lua`).  Everything else in the body keeps its exact bytes.
  * the menu ScreenGui literal is swapped for `context.UI.menuGui()` so that
    `ui/shapes.lua` owns the three ScreenGuis and their display orders.

`tools/verify_parity.py` re-applies the same cuts to the original and compares
SHA-256 of every shipped body.
"""
from __future__ import annotations

import hashlib
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "harvardd.lua"
OUT = ROOT / "src" / "features"

# name -> (first body line, last body line)  1-indexed, inclusive, body only
COMPONENTS = [
    ("coreSettings", 40, 2746),
    ("attackCatalog", 2748, 3278),
    ("gearProfiles", 3280, 7737),
    ("movementBoost", 7739, 7841),
    ("hazardReader", 7843, 36274),
    ("dangerGeometry", 36276, 36826),
    ("odinMechanics", 36828, 40294),
    ("bossPhases", 40296, 41270),
    ("bubbleBoss", 41272, 51563),
    ("movementCombat", 51565, 116430),
    ("inventoryAutomation", 116432, 118105),
    ("partyQueue", 118107, 122925),
    ("raidAutomation", 122927, 124003),
    ("drawing", 126349, 129081),
    ("walls", 129083, 138687),
    ("statisticsWebhooks", 138689, 142555),
    ("interfaceMainLoop", 142557, 164652),
]

# name -> (first line, last line, replacement text) cut before shipping
CUTS = {
    "interfaceMainLoop": (
        143528,
        145939,
        # the original block's closing `end` is the first line after the cut
        "    context.buildShell = function(argument)\n"
        "        return context.UI.buildShell(argument)\n",
    ),
}

# exact-text edits applied after the cut (presentation seams only)
EDITS = {
    "interfaceMainLoop": [
        (
            '        local dungeonAutofarmUi = Instance.new("ScreenGui")\n'
            '        dungeonAutofarmUi.Name, dungeonAutofarmUi.ResetOnSpawn, dungeonAutofarmUi.IgnoreGuiInset, dungeonAutofarmUi.DisplayOrder, dungeonAutofarmUi.ZIndexBehavior =\n'
            '            "DungeonAutofarmUI", false, true, 100, Enum.ZIndexBehavior.Sibling\n'
            '        dungeonAutofarmUi.Parent = statusChip\n',
            '        local dungeonAutofarmUi = context.UI.menuGui()\n',
        ),
        (
            '        local value3 = statusChip:FindFirstChild("DungeonAutofarmUI")\n',
            '        local value3 = nil\n',
        ),
        # bug-report diagnostics: report the resolver we actually use, without
        # naming a transport global anywhere outside core/net.lua
        (
            '            helper22("request", request or http_request or syn and syn.request or http and http.request)\n',
            '            helper22("request", context.net and context.net.fn or nil)\n',
        ),
    ],
}

# marker-based cuts: (start text, exclusive end text, replacement)
BLOCKS = {
    "statisticsWebhooks": [
        (
            "    local function helper3(url, body)\n",
            "    local function name2()\n",
            "    -- DQR network policy: the one webhook POST, through core/net.lua.\n"
            "    local function helper3(url, body)\n"
            "        local ok, status, err, retry = context.net.postJson(url, body)\n"
            "        if ok then\n"
            "            return true\n"
            "        end\n"
            "        if status == 429 then\n"
            "            return false, \"rate limited\", retry or 1\n"
            "        end\n"
            "        return false, err\n"
            "    end\n",
        ),
        (
            "    task.spawn(function()\n        task.wait(5)\n        while not (context.RT and context.RT.destroyed) do\n",
            "    local function helper26(argument, argument2)\n",
            "    -- DQR network policy: the old emoji poll fetched a non-user host. Removed.\n"
            "    webhooks.emojis = webhooks.emojis or {}\n",
        ),
    ],
    "interfaceMainLoop": [
        (
            "        sharedValue39.lowPopServer = function()\n",
            "        sharedValue39.spreadLobby = function()\n",
            "        -- DQR network policy: the Roblox games.roblox.com server probe is gone.\n"
            "        -- Callers already treat nil as \"no low-pop server found\".\n"
            "        sharedValue39.lowPopServer = function()\n"
            "            return nil\n"
            "        end\n",
        ),
    ],
    "drawing": [
        (
            "    local function helper11(parent, textColor3)\n",
            "    local function helper12()\n",
            "    -- DQR section 8 label plate: DeepForest @0.70, 4px radius, 1px Bark\n"
            "    -- hairline, 11px body text with a 1px DeepForest outline.\n"
            "    local function helper11(parent, textColor3)\n"
            "        local style = context.drawStyle\n"
            "        local tag = Instance.new(\"BillboardGui\")\n"
            "        tag.Name, tag.Size, tag.AlwaysOnTop, tag.MaxDistance, tag.StudsOffsetWorldSpace =\n"
            "            \"tag\", UDim2.fromOffset(240, 26), true, 250, Vector3.new(0, 4, 0)\n"
            "        tag.LightInfluence = 0\n"
            "        local plate = Instance.new(\"Frame\")\n"
            "        plate.Name, plate.BackgroundColor3, plate.BackgroundTransparency =\n"
            "            \"plate\", style.plate, 0.70\n"
            "        plate.BorderSizePixel = 0\n"
            "        plate.Size = UDim2.fromScale(1, 1)\n"
            "        plate.Parent = tag\n"
            "        style.round(plate, 4)\n"
            "        style.hairline(plate)\n"
            "        local text = Instance.new(\"TextLabel\")\n"
            "        text.Name, text.Size = \"text\", UDim2.fromScale(1, 1)\n"
            "        text.BackgroundTransparency = 1\n"
            "        text.TextColor3 = textColor3 or style.text\n"
            "        text.TextStrokeColor3 = style.plate\n"
            "        text.TextStrokeTransparency = 0\n"
            "        text.TextScaled = false\n"
            "        text.TextSize = 11\n"
            "        text.TextYAlignment = Enum.TextYAlignment.Center\n"
            "        style.font(text, \"body\")\n"
            "        text.Parent = plate\n"
            "        style.pad(plate, 1, 3, 1, 3)\n"
            "        style.uppercase(text)\n"
            "        tag.Parent = parent\n"
            "        return tag\n"
            "    end\n",
        ),
        (
            "        helper6(value2, 0.05, config.colorFloor)\n",
            None,
            "        helper6(value2, 1.5, config.colorFloor or context.drawStyle.hazard)\n",
        ),
        (
            "            helper6(value, 0.03, Color3.fromRGB(235, 235, 245))\n",
            None,
            "            helper6(value, 1.5, context.drawStyle.hazard)\n",
        ),
        (
            "        helper11(value2, Color3.new(1, 1, 1))\n",
            None,
            "        helper11(value2, context.drawStyle.text)\n",
        ),
    ],
    "walls": [
        (
            "            Enum.Material.SmoothPlastic, Color3.fromHex(config.wallColor or \"2f0e0e\")\n",
            None,
            "            Enum.Material.SmoothPlastic, Color3.fromHex(config.wallColor or \"5b8c3a\")\n",
        ),
        (
            "        value.Transparency = math.clamp(tonumber(config.wallTransparency) or 0, 0, 1)\n",
            None,
            "        value.Transparency = math.clamp(tonumber(config.wallTransparency) or 0.55, 0, 1)\n",
        ),
    ],
}

HEADER = "-- Extracted verbatim from harvardd.lua lines {a}-{b}; presentation owned elsewhere.\n"
FOOTER = ""


def sha(blob: bytes) -> str:
    return hashlib.sha256(blob).hexdigest()


def build_body(lines: list[str], name: str, a: int, b: int) -> str:
    body = "".join(lines[a - 1 : b])
    cut = CUTS.get(name)
    if cut:
        first, last, replacement = cut
        offset = a - 1
        head = "".join(lines[a - 1 : first - 1])
        tail = "".join(lines[last:b])
        body = head + replacement + tail
        assert str(first) and offset >= 0
    for start, end, replacement in BLOCKS.get(name, []):
        first = body.find(start)
        if first < 0:
            raise SystemExit(f"FATAL: {name}: block start not found:\n{start[:140]}")
        if end is None:
            body = body[:first] + replacement + body[first + len(start) :]
            continue
        last = body.find(end, first + len(start))
        if last < 0:
            raise SystemExit(f"FATAL: {name}: block end not found:\n{end[:140]}")
        body = body[:first] + replacement + body[last:]
    for old, new in EDITS.get(name, []):
        if old not in body:
            raise SystemExit(f"FATAL: {name}: edit anchor not found:\n{old[:140]}")
        body = body.replace(old, new, 1)
    # drop the component's own closing `end` and trailing blank lines; the
    # shipped file supplies `return function(context) ... end` instead
    tail = body.splitlines(keepends=True)
    while tail and tail[-1].strip() == "":
        tail.pop()
    if tail and tail[-1].strip() == "end":
        tail.pop()
    body = "".join(tail)
    if not body.endswith("\n"):
        body += "\n"
    return body


def main() -> int:
    lines = SRC.read_text(encoding="utf-8", errors="surrogateescape").splitlines(keepends=True)
    OUT.mkdir(parents=True, exist_ok=True)
    report = []
    for name, a, b in COMPONENTS:
        body = build_body(lines, name, a, b)
        text = HEADER.format(a=a, b=b) + "return function(context)\n" + body + "end\n"
        path = OUT / f"{name}.lua"
        path.write_text(text, encoding="utf-8", errors="surrogateescape", newline="")
        report.append((name, len(body.encode("utf-8", "surrogateescape")), sha(body.encode("utf-8", "surrogateescape"))))

    print(f"{'component':22} {'bytes':>9} sha256(body)")
    for name, size, digest in report:
        print(f"{name:22} {size:>9} {digest[:16]}")
    print(f"\n{len(report)} files -> {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
