#!/usr/bin/env python3
"""Parity proof for the modular build.

1. Re-slice harvardd.lua, apply the same two presentation seams, and compare
   SHA-256 of every shipped feature body with the source.
2. Dump every `config.<key>` / `CFG.<key>` referenced in the original and in
   the build, and diff the sets.  Any missing or extra key fails.
"""
from __future__ import annotations

import collections
import hashlib
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "harvardd.lua"
BUILD = ROOT / "src" / "features"

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from extract import COMPONENTS, build_body  # noqa: E402


def sha(blob: bytes) -> str:
    return hashlib.sha256(blob).hexdigest()


def main() -> int:
    lines = SRC.read_text(encoding="utf-8", errors="surrogateescape").splitlines(keepends=True)
    failures = 0
    for name, a, b in COMPONENTS:
        want = sha(build_body(lines, name, a, b).encode("utf-8", "surrogateescape"))
        path = BUILD / f"{name}.lua"
        if not path.exists():
            print(f"MISSING {path}")
            failures += 1
            continue
        text = path.read_text(encoding="utf-8", errors="surrogateescape")
        inner = text.split("\nreturn function(context)\n", 1)[0]
        inner = inner.split("\n", 1)[1]
        got = sha(inner.encode("utf-8", "surrogateescape"))
        ok = got == want
        failures += 0 if ok else 1
        print(f"{'OK  ' if ok else 'FAIL'} {name:22} {got[:16]}")

    key_re = re.compile(r"\b(?:config|CFG)\.([A-Za-z_][A-Za-z0-9_]*)")
    label_re = re.compile(r'"([A-Z][^"\n]{1,120})"')

    def scan(paths):
        keys, labels = collections.Counter(), collections.Counter()
        for p in paths:
            t = p.read_text(encoding="utf-8", errors="surrogateescape")
            keys.update(key_re.findall(t))
            labels.update(label_re.findall(t))
        return keys, labels

    src_keys, src_labels = scan([SRC])
    out_files = sorted(BUILD.glob("*.lua")) + sorted((ROOT / "src" / "ui").glob("*.lua"))
    out_keys, out_labels = scan(out_files)

    only_src = sorted(set(src_keys) - set(out_keys))
    only_out = sorted(set(out_keys) - set(src_keys))
    print(f"\nCFG keys: original={len(src_keys)} build={len(out_keys)} missing={len(only_src)} extra={len(only_out)}")
    if only_src:
        print("  missing:", only_src[:60])
    if only_out:
        print("  extra:", only_out[:60])
    failures += len(only_src) + len(only_out)

    lost = sorted(k for k in src_labels if k not in out_labels)
    print(f"quoted labels: original={len(src_labels)} build={len(out_labels)} not-in-build={len(lost)}")
    for k in lost[:20]:
        print(f"  - {k!r}")

    print("\nPARITY", "OK" if failures == 0 else f"FAILED ({failures})")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
