#!/usr/bin/env python3
"""Audit the replaced buildShell block (143528-145939) against the new shell.

Not a visual diff: it inventories every literal and every local function in the
old block, then shows which ones the build no longer contains and what the
surrounding code did.
"""
from __future__ import annotations

import collections
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "harvardd.lua"
START, END = 143528, 145939  # 1-indexed inclusive

BEHAVIOUR = re.compile(
    r"task\.(?:spawn|delay|wait)|RunService|Heartbeat|RenderStepped|UserInputService|"
    r"GetPropertyChangedSignal|MouseButton1Click|MouseEnter|MouseLeave|InputBegan|"
    r"InputChanged|InputEnded|readfile|writefile|makefolder|isfolder|GetAsync|RequestAsync|"
    r"context\.WH|leaderstats|UserId|GetUserThumbnailAsync|config\.|http|request|"
    r"connect|Connect|pcall|tostring|selectTab|setShown|close|minimize|maximize|resize"
)


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


def blocks(block: list[str]):
    """Top-level items at 8-space indentation: functions and assignments."""
    items = []
    for i, line in enumerate(block):
        m = re.match(r"^        (local function|function|local )?", line)
        if not m:
            continue
        if re.match(r"^        local function ([A-Za-z0-9_]+)", line):
            name = re.match(r"^        local function ([A-Za-z0-9_]+)", line).group(1)
            j = i + 1
            while j < len(block) and block[j] != "        end":
                j += 1
            items.append((name, i + 1, min(j + 1, len(block))))
        elif re.match(r"^        value3\.([A-Za-z0-9_]+) = function", line):
            name = "page." + re.match(r"^        value3\.([A-Za-z0-9_]+)", line).group(1)
            j = i + 1
            while j < len(block) and block[j] != "        end":
                j += 1
            items.append((name, i + 1, min(j + 1, len(block))))
        elif re.match(r"^        function context\.([A-Za-z0-9_]+)", line):
            name = "context." + re.match(r"^        function context\.([A-Za-z0-9_]+)", line).group(1)
            j = i + 1
            while j < len(block) and block[j] != "        end":
                j += 1
            items.append((name, i + 1, min(j + 1, len(block))))
    return items


def main() -> None:
    lines = SRC.read_text(encoding="utf-8", errors="surrogateescape").splitlines()
    block = lines[START - 1 : END]
    old_text = "\n".join(block)
    new_text = ""
    for p in [ROOT / "dqr.lua"] + sorted((ROOT / "src").rglob("*.lua")):
        new_text += p.read_text(encoding="utf-8", errors="surrogateescape") + "\n"

    old_lits = literals(old_text)
    new_set = set(literals(new_text))
    missing = list(dict.fromkeys(s for s in old_lits if s not in new_set))
    print(f"old literals {len(set(old_lits))}, missing {len(missing)}")

    report = ["MISSING LITERALS: owner and verdict", ""]
    for s in missing:
        needle = '"' + s + '"'
        hit = next((i for i, ln in enumerate(block) if needle in ln), None)
        report.append(f"=== {s!r} at file line {START + hit}")
        if hit is not None:
            report.extend(block[max(0, hit - 8) : hit + 9])
        report.append("")
    (ROOT / "tools" / ".missing-context.txt").write_text("\n".join(report), encoding="utf-8")

    items = blocks(block)
    print(f"top-level functions: {len(items)}")
    inv = ["FUNCTION INVENTORY (old block)", ""]
    for name, a, b in items:
        span = "\n".join(block[a - 1 : b])
        lits = literals(span)
        flags = sorted(set(BEHAVIOUR.findall(span)))
        inv.append(f"## {name}  lines {START + a - 1}-{START + b - 1} ({b - a + 1} lines)")
        inv.append("   calls: " + ", ".join(sorted(set(re.findall(r"\b(helper\d+)\(", span)))))
        inv.append("   flags: " + ", ".join(flags))
        inv.append("   literals: " + " | ".join(lits[:12]))
        inv.append("")
    (ROOT / "tools" / ".shell-inventory.txt").write_text("\n".join(inv), encoding="utf-8")

    # exported keys from the old page/shell object
    exports = collections.Counter(re.findall(r"value3\.([A-Za-z0-9_]+) =", old_text))
    print("page exports:", ", ".join(sorted(exports)))
    print("context exports:", ", ".join(sorted(set(re.findall(r"context\.([A-Za-z0-9_]+) =", old_text)))))


if __name__ == "__main__":
    main()
