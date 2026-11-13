#!/usr/bin/env python3
"""Static audit for the headless build: network policy and load-graph hygiene."""
from __future__ import annotations

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
FAIL = 0


def check(ok: bool, label: str, detail: str = "") -> None:
    global FAIL
    if not ok:
        FAIL += 1
    print(f"{'PASS' if ok else 'FAIL'} {label}{(' — ' + detail) if detail else ''}")


manifest = json.loads((ROOT / "modules.json").read_text(encoding="utf-8"))
modules = manifest.get("modules", [])
paths = [m.get("path", "") for m in modules]
names = [m.get("name", "") for m in modules]

missing = [p for p in paths if not (ROOT / p).is_file()]
check(not missing, "manifest files exist", str(missing[:5]))
check(len(names) == len(set(names)), "manifest module names are unique")
check(len(paths) == len(set(paths)), "manifest module paths are unique")
check(manifest.get("version") == "2.0.2", "manifest version is current")

source_files = {p.relative_to(ROOT).as_posix() for p in (ROOT / "src").rglob("*.lua")}
listed = set(paths)
dead = sorted(source_files - listed)
check(not dead, "no unlisted source files", str(dead[:10]))
check(not (listed - source_files), "manifest contains no missing sources")

files = [ROOT / "dqr.lua"] + [ROOT / p for p in paths if (ROOT / p).is_file()]
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
allowed_transport = {"dqr.lua", "src/core/net.lua"}
extra = [h for h in trans_hits if h[0] not in allowed_transport]
check(not extra, "transport resolved only in loader + core/net", str(extra))

urls = sorted(set(re.findall(r"https?://[^\s\"')]+", joined)))
print("\nURL classification")
for url in urls:
    if "raw.githubusercontent.com" in url:
        kind = "(a) GitHub module fetch"
    elif "static.wikia.nocookie.net" in url or "media.discordapp.net" in url:
        kind = "(c) payload asset URL (embedded in a webhook body, never fetched here)"
    else:
        kind = "(d) VIOLATION"
        check(False, "no non-allowlisted host", url)
    print(f"  {kind:70} {url[:90]}")

print(f"\nmanifest: {len(modules)} modules, version {manifest.get('version')}")
print("\nAUDIT", "OK" if FAIL == 0 else f"FAILED ({FAIL})")
sys.exit(0 if FAIL == 0 else 1)
