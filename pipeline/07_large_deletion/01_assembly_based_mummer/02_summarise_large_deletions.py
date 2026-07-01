#!/usr/bin/env python3
"""Collect large-deletion result files into a flat summary table."""

import argparse
import shutil
from pathlib import Path

import pandas as pd


def unique_dest(output_dir: Path, path: Path) -> Path:
    candidate = output_dir / path.name
    if not candidate.exists():
        return candidate
    suffix = "".join(path.suffixes)
    base = path.name[: -len(suffix)] if suffix else path.name
    count = 1
    while True:
        candidate = output_dir / f"{base}_{count}{suffix}"
        if not candidate.exists():
            return candidate
        count += 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source-dir", required=True)
    ap.add_argument("--output-dir", required=True)
    ap.add_argument(
        "--extensions",
        nargs="*",
        default=[".txt", ".snps", ".tiling", ".vcf", ".vcf.gz"],
        help="File extensions to include in the summary",
    )
    ap.add_argument("-o", "--out", required=True)
    args = ap.parse_args()

    source_dir = Path(args.source_dir)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    rows = []
    for path in source_dir.rglob("*"):
        if not path.is_file():
            continue
        if not any(str(path).endswith(ext) for ext in args.extensions):
            continue
        dest = unique_dest(output_dir, path)
        shutil.copy2(path, dest)
        rows.append({"source": str(path), "copied_to": str(dest), "sample": path.stem})

    pd.DataFrame(rows).to_csv(args.out, sep="\t", index=False)


if __name__ == "__main__":
    main()
