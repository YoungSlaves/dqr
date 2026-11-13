#!/usr/bin/env python3
"""Headless checks for the two pure-logic seams: transport order and fonts.

The real module sources are embedded unchanged; the Luau CLI sandbox makes `_G`
read-only, so the transport is given its globals through a local `_G` binding
inside the wrapper (Roblox shares `_G` with the executor globals).
"""
from __future__ import annotations

import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
LUAU = ROOT / "tools" / "luau" / "luau.exe"
TMP = ROOT / "tools" / ".tmp-tests"
FAIL = 0


def run(name: str, script: str) -> None:
    global FAIL
    TMP.mkdir(exist_ok=True)
    path = TMP / f"{name}.luau"
    path.write_text(script, encoding="utf-8")
    result = subprocess.run([str(LUAU), str(path)], capture_output=True, text=True)
    out = (result.stdout + result.stderr).strip()
    print(f"--- {name} (exit {result.returncode})")
    print(out)
    if result.returncode != 0 or "FAIL" in out:
        FAIL += 1


NET = (ROOT / "src" / "core" / "net.lua").read_text(encoding="utf-8")
THEME = (ROOT / "src" / "ui" / "theme.lua").read_text(encoding="utf-8")

NET_TESTS = """
local function loadNet(globals)
    getgenv = function() return globals end
    local module = (function()
        local _G = globals
__MODULE__
    end)()
    local context = { HttpService = { JSONDecode = function() return {} end } }
    module(context)
    return context.net
end

local function ok(condition, label)
    print((condition and "PASS " or "FAIL ") .. label)
end

local function responder(response)
    return function(payload)
        return response
    end
end

local net = loadNet({ request = responder({ StatusCode = 200, Body = "hello" }) })
ok(net.available and net.name == "request", "request wins first")
ok(net.get("https://raw.githubusercontent.com/x/y/main/modules.json") == "hello", "GET normalises Body")
ok(net.postJson("https://example.invalid/hook", "{}") == true, "2xx POST succeeds")

net = loadNet({ httpget = function() return "only-get" end })
ok(net.kind == "httpget", "httpget chosen when request is absent")
ok(net.get("https://raw.githubusercontent.com/x") == "only-get", "httpget GET body")
local posted, _, why = net.postJson("https://example.invalid/hook", "{}")
ok(posted == false and tostring(why):find("GET only") ~= nil, "httpget never POSTs")

net = loadNet({ syn = { request = responder({ StatusCode = 200, Body = "syn" }) } })
ok(net.name == "syn.request", "syn.request is third")

net = loadNet({ fluxus = { request = responder({ StatusCode = 200, Body = "fluxus" }) } })
ok(net.name == "fluxus.request", "fluxus is fourth")

net = loadNet({ http_request = responder({ StatusCode = 200, Body = "bare" }) })
ok(net.name == "http_request", "bare http_request is last")

net = loadNet({ http = { request = responder({ StatusCode = 200, Body = "http" }) } })
ok(net.name == "http.request", "http.request alias")

net = loadNet({})
ok(net.available == false, "no transport -> unavailable")
ok(select(2, net.get("https://raw.githubusercontent.com/x")) == "unavailable (no request function)", "GET unavailable")
local posted2, _, why2 = net.postJson("https://example.invalid/hook", "{}")
ok(posted2 == false and tostring(why2):find("unavailable") ~= nil, "POST unavailable")

net = loadNet({ request = responder({ StatusCode = 404, Body = "nope" }) })
ok(net.get("https://raw.githubusercontent.com/x") == nil, "non-2xx is a failure")
net = loadNet({ request = responder({ StatusCode = 200, Body = "" }) })
ok(net.get("https://raw.githubusercontent.com/x") == nil, "empty body is a failure")
net = loadNet({ request = function() error("boom") end })
local value, err = net.get("https://raw.githubusercontent.com/x")
ok(value == nil and err ~= nil, "a throwing transport reads as network failure")
""".replace("__MODULE__", NET)

FONT_PRELUDE = """
local calls = 0
Font = { new = function() calls = calls + 1; error("no font asset") end }
Color3 = { fromHex = function()
    local c = {}
    function c:Lerp() return c end
    return c
end }
Instance = { new = function() return { Destroy = function() end } end }
__ENUMS__
local logs = {}
local context = { log = function(_, message) logs[#logs + 1] = message end }
local module = (function()
__MODULE__
end)()
module(context)
local theme = context.Theme
local function ok(condition, label)
    print((condition and "PASS " or "FAIL ") .. label)
end
"""

FONT_ENUM = (
    FONT_PRELUDE.replace(
        "__ENUMS__",
        'Enum = { Font = { GothamBlack = "GothamBlack", Gotham = "Gotham", '
        'Garamond = "Garamond", SourceSans = "SourceSans" } }',
    ).replace("__MODULE__", THEME)
    + """
ok(theme.fonts.title.path == "enum", "title falls back to enum")
ok(theme.fonts.body.path == "enum", "body falls back to enum")
ok(calls == 2, "Font.new called at most twice (" .. tostring(calls) .. ")")
ok(type(theme.fonts.title.Font) == "string" and theme.fonts.title.FontFace == nil, "enum path sets Font, not FontFace")
ok(logs[1] and logs[1]:find("title=enum") ~= nil, "one boot line reports the path")
"""
)

FONT_SUB = (
    FONT_PRELUDE.replace(
        "__ENUMS__",
        'Enum = { Font = { Garamond = "Garamond", SourceSans = "SourceSans" } }',
    ).replace("__MODULE__", THEME)
    + """
ok(theme.fonts.title.path == "substitute", "title uses substitute")
ok(theme.fonts.body.path == "substitute", "body uses substitute")
ok(calls == 2, "Font.new still called only twice")
ok(theme.fonts.title.Font == Enum.Font.Garamond, "title substitute is Garamond")
ok(theme.fonts.body.Font == Enum.Font.SourceSans, "body substitute is SourceSans")
"""
)

FONT_ASSET = (
    FONT_PRELUDE.replace(
        "__ENUMS__",
        'Enum = { Font = { GothamBlack = "GothamBlack", Gotham = "Gotham", '
        'Garamond = "Garamond", SourceSans = "SourceSans" } }',
    )
    .replace('Font = { new = function() calls = calls + 1; error("no font asset") end }', "")
    .replace(
        "local calls = 0",
        "local calls = 0\nFont = { new = function(family) calls = calls + 1; return { family = family } end }",
    )
    .replace("__MODULE__", THEME)
    + """
ok(theme.fonts.title.path == "asset", "title resolves the asset family")
ok(theme.fonts.body.path == "asset", "body resolves the asset family")
ok(calls == 2, "Font.new called once per role (" .. tostring(calls) .. ")")
ok(theme.fonts.title.FontFace ~= nil and theme.fonts.title.Font == nil, "asset path sets FontFace only")
"""
)


def main() -> int:
    if not LUAU.exists():
        print("luau CLI missing at", LUAU)
        return 2
    run("net-order", NET_TESTS)
    run("font-asset", FONT_ASSET)
    run("font-enum", FONT_ENUM)
    run("font-substitute", FONT_SUB)
    print("\nLOGIC", "OK" if FAIL == 0 else f"FAILED ({FAIL})")
    return 0 if FAIL == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
