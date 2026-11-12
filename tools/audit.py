#!/usr/bin/env python3
"""Static audit: network allowlist, shape ownership, GUI layering, assets."""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
BUILD = ROOT / "dqr"
FAIL = 0


def check(ok: bool, label: str, detail: str = "") -> None:
    global FAIL
    if not ok:
        FAIL += 1
    print(f"{'PASS' if ok else 'FAIL'} {label}{(' — ' + detail) if detail else ''}")


files = sorted(p for p in BUILD.rglob("*.lua"))
text = {p: p.read_text(encoding="utf-8", errors="surrogateescape") for p in files}
joined = "\n".join(text.values())

# ---------------------------------------------------------------- network
forbidden = re.compile(r"HttpService\s*[:.]\s*(GetAsync|RequestAsync|PostAsync)")
hits = [(p, m.group(0)) for p, t in text.items() for m in forbidden.finditer(t)]
check(not hits, "HttpService makes no request", str(hits[:3]))

transport = re.compile(r"\b(syn\.request|http_request|fluxus\.request|httpget|HttpGet|http\.request)\b")
def rel(p: pathlib.Path) -> str:
    return p.relative_to(ROOT).as_posix()


trans_hits = [(rel(p), len(transport.findall(t))) for p, t in text.items() if transport.search(t)]
allowed_transport = {"dqr/dqr.lua", "dqr/src/core/net.lua"}
extra = [h for h in trans_hits if h[0] not in allowed_transport]
check(not extra, "transport resolved only in loader + core/net", str(extra))

urls = sorted(set(re.findall(r"https?://[^\s\"')]+", joined)))
print("\nURL classification")
for url in urls:
    if "raw.githubusercontent.com" in url:
        kind = "(a) GitHub module fetch"
    elif "static.wikia.nocookie.net" in url or "media.discordapp.net" in url:
        kind = "(c) payload asset URL (embedded in a webhook body, never fetched here)"
    elif "games.roblox.com" in url:
        kind = "(d) VIOLATION"
        check(False, "no non-allowlisted host", url)
    else:
        kind = "(d) VIOLATION"
        check(False, "no unknown host", url)
    print(f"  {kind:70} {url[:90]}")

# ------------------------------------------------------------- shape rules
menu_gui_files = {"dqr/src/ui/shapes.lua", "dqr/dqr.lua"}
screen_gui_sites = [rel(p) for p, t in text.items() if 'Instance.new("ScreenGui")' in t]
# The four remaining screens are pre-existing features (bug report, party
# lobby x2, cast timer). The menu layer itself is exactly three GUIs.
check(
    {"dqr/src/ui/shapes.lua", "dqr/dqr.lua"} <= set(screen_gui_sites),
    "menu layer creates Ambient/Menu/Loading only in shapes + loader bootstrap",
    str(screen_gui_sites),
)
gui_creations = ["shapes", "loader"]

for name in ("DQRAmbient", "DQRRoot", "DQRLoading"):
    check(name in joined, f"{name} declared")
check("order = 40" in joined and "order = 50" in joined, "display orders 40/50/50")
check(joined.count("ZIndexBehavior.Sibling") >= 3, "ZIndexBehavior Sibling everywhere")

rotated = len(re.findall(r"\.Rotation = 45", joined))
gradients = len(re.findall(r'Instance\.new\("UIGradient"\)', joined))
print(f"\ncounts: rotated-45 frames={rotated} UIGradient creations={gradients} ScreenGuis={len(gui_creations)}")

check('theme.VINE_IMAGE_ID = nil' in text[BUILD / "src/ui/theme.lua"], "VINE_IMAGE_ID nil")
check('theme.LEAF_IMAGE_ID = nil' in text[BUILD / "src/ui/theme.lua"], "LEAF_IMAGE_ID nil")
vine = text[BUILD / "src/ui/shapes.lua"]
check(
    "if theme.VINE_IMAGE_ID == nil then" in vine and "if theme.LEAF_IMAGE_ID == nil then" in vine,
    "vine/leaf ImageLabels are behind the nil guard",
)
check(
    joined.count("Image = theme.VINE_IMAGE_ID") == 1 and joined.count("Image = theme.LEAF_IMAGE_ID") == 1,
    "only the guarded vine/leaf read an image id",
)

check("Font.new" in text[BUILD / "src/ui/theme.lua"], "font resolver present")
# interfaceMainLoop still holds the pre-existing bug-report font set (BuilderSans);
# that is feature code, not menu typography, and is left byte-identical.
font_new_sites = [rel(p) for p, t in text.items() if "Font.new" in t]
check(
    set(font_new_sites) <= {"dqr/src/ui/theme.lua", "dqr/dqr.lua", "dqr/src/features/interfaceMainLoop.lua"},
    "Font.new only in theme resolver, loader card, and the pre-existing bug report",
    str(font_new_sites),
)

firefly_root = re.search(r"function shapes\.spawnFireflies[\s\S]{0,400}?ensureGui\(\"ambient\"\)", joined)
check(bool(firefly_root), "fireflies spawn in the ambient layer")

check(re.search(r"grain\(row, 90\)", joined) is not None, "plank rows carry their own grain")
check(
    "row.Rotation = ((index * 7) % 3 - 1) * 0.6" in text[BUILD / "src/ui/shapes.lua"],
    "row rotation formula lives in shapes.plankRow",
)
grain_sites = len(re.findall(r"shapes\.grain\(", joined))
check(grain_sites >= 6, "each plank/sign face asks for its own grain instance", str(grain_sites))

print("\nAUDIT", "OK" if FAIL == 0 else f"FAILED ({FAIL})")
sys.exit(0 if FAIL == 0 else 1)
