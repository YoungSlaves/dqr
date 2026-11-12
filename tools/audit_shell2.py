#!/usr/bin/env python3
"""Map every missing literal to its owning function body in the old block."""
from __future__ import annotations

import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
START, END = 143528, 145939


def literals(text: str) -> list[str]:
    out, i, n = [], 0, len(text)
    while i < n:
        if text[i] != '"':
            i += 1
            continue
        i += 1
        buf = []
        while i < n:
            ch = text[i]
            if ch == "\\" and i + 1 < n:
                buf.append(text[i : i + 2])
                i += 2
                continue
            if ch == '"':
                i += 1
                break
            buf.append(ch)
            i += 1
        value = "".join(buf)
        if "\n" not in value:
            out.append(value)
    return out


def fn_headers(block: list[str]):
    """(line index, indent, name) for every function assignment at any depth."""
    heads = []
    for i, line in enumerate(block):
        m = re.match(r"^(\s*)(?:local function|function) ([A-Za-z0-9_.]+)\s*\(", line)
        if m:
            heads.append((i, len(m.group(1)), m.group(2)))
            continue
        m = re.match(r"^(\s*)(?:local )?([A-Za-z0-9_]+) = function\s*\(", line)
        if m:
            heads.append((i, len(m.group(1)), m.group(2)))
            continue
        m = re.match(r"^(\s*)value3\.([A-Za-z0-9_]+) = function\s*\(", line)
        if m:
            heads.append((i, len(m.group(1)), "page." + m.group(2)))
        m = re.match(r"^(\s*)function context\.([A-Za-z0-9_]+)", line)
        if m:
            heads.append((i, len(m.group(1)), "context." + m.group(2)))
    return heads


def main() -> None:
    lines = (ROOT / "harvardd.lua").read_text(encoding="utf-8", errors="surrogateescape").splitlines()
    block = lines[START - 1 : END]
    old_text = "\n".join(block)
    new_text = ""
    for p in [ROOT / "dqr.lua"] + sorted((ROOT / "src").rglob("*.lua")):
        new_text += p.read_text(encoding="utf-8", errors="surrogateescape") + "\n"
    new_set = set(literals(new_text))
    missing = list(dict.fromkeys(s for s in literals(old_text) if s not in new_set))
    heads = fn_headers(block)

    report = [f"{len(missing)} literals from the old shell absent from the build", ""]
    for s in missing:
        needle = '"' + s + '"'
        hits = [i for i, ln in enumerate(block) if needle in ln]
        owner = "?"
        for h in heads:
            if hits and h[0] <= hits[0]:
                owner = h[2]
        report.append(f"### {s!r}  owner={owner}  file line {START + hits[0] if hits else '?'}")
        if hits:
            i = hits[0]
            report.extend("  " + x for x in block[max(0, i - 3) : i + 4])
        report.append("")
    (ROOT / "tools" / ".missing-report.txt").write_text("\n".join(report), encoding="utf-8")
    print("\n".join(r for r in report if r.startswith("###")))


if __name__ == "__main__":
    main()
