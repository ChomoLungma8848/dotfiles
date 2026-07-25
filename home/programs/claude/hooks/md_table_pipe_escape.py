#!/usr/bin/env python3
"""GFM テーブル行のコードスパン内にある未エスケープの | を \\| に変換する。

GFM ではテーブルの行分割がコードスパン解析より先に走るため、
バッククォート内でも未エスケープの | はセル区切りになる。
セル内にリテラルの | を書く正しい記法は \\| のみ(コードスパン内でも有効)。
このスクリプトは prettier の前処理として、書き手が無造作に書いた
`a|b` を `a\\|b` に直し、整形結果と GitHub レンダリングの両方を正しくする。

対象: テーブルと認識できるブロック(行頭 3 スペース以内で | 始まり、
直後に区切り行が続く)の行のみ。コードフェンス内・フロントマター・
本文中のコードスパンには触れない。冪等(既に \\| の箇所は変更しない)。

使い方: md_table_pipe_escape.py FILE [FILE...]  (in-place 書き換え、常に exit 0)
"""

import re
import sys

DELIM_RE = re.compile(r"^ {0,3}\|? *:?-+:? *(\| *:?-+:? *)*\|? *$")
FENCE_OPEN_RE = re.compile(r"^(`{3,}|~{3,})")
CODESPAN_RE = re.compile(r"(?<!`)(`+)(?!`)(.+?)(?<!`)\1(?!`)")


def escape_row(line: str) -> str:
    def repl(m: re.Match) -> str:
        inner = re.sub(r"(?<!\\)\|", r"\\|", m.group(2))
        return m.group(1) + inner + m.group(1)

    return CODESPAN_RE.sub(repl, line)


def is_table_row(line: str) -> bool:
    stripped = line.lstrip(" ")
    indent = len(line) - len(stripped)
    return indent <= 3 and stripped.startswith("|")


def process(text: str) -> str:
    lines = text.split("\n")
    out = list(lines)
    n = len(lines)
    i = 0

    # フロントマターをスキップ
    if lines and lines[0].strip() == "---":
        j = 1
        while j < n and lines[j].strip() not in ("---", "..."):
            j += 1
        i = j + 1 if j < n else n

    fence_close_re = None
    while i < n:
        stripped = lines[i].lstrip(" ")
        indent = len(lines[i]) - len(stripped)

        if fence_close_re is not None:
            if indent <= 3 and fence_close_re.match(stripped):
                fence_close_re = None
            i += 1
            continue

        m = FENCE_OPEN_RE.match(stripped)
        if indent <= 3 and m:
            marker = m.group(1)
            fence_close_re = re.compile(rf"^{marker[0]}{{{len(marker)},}}\s*$")
            i += 1
            continue

        if is_table_row(lines[i]) and i + 1 < n and DELIM_RE.match(lines[i + 1]):
            while i < n and is_table_row(lines[i]):
                out[i] = escape_row(lines[i])
                i += 1
            continue

        i += 1

    return "\n".join(out)


def main() -> int:
    for path in sys.argv[1:]:
        try:
            with open(path, encoding="utf-8") as f:
                original = f.read()
            fixed = process(original)
            if fixed != original:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(fixed)
        except OSError:
            continue  # fail-open: 読めない/書けないファイルは黙って飛ばす
    return 0


if __name__ == "__main__":
    sys.exit(main())
