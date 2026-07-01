#!/usr/bin/env python3
"""Merge per-sample ABRicate TSV files into one provenance-aware table."""

import argparse
import glob
import os
import pandas as pd


def infer_source_label(dir_path: str) -> str:
    base = os.path.basename(os.path.normpath(dir_path)).lower()
    if "card" in base:
        return "card"
    if "ncbi" in base:
        return "ncbi"
    return base


def sample_from_filename(fp: str) -> str:
    name = os.path.basename(fp)
    if name.endswith("_abricate.tsv"):
        return name[: -len("_abricate.tsv")]
    return os.path.splitext(name)[0]


def collect(dir_path: str):
    rows = []
    source = infer_source_label(dir_path)
    for fp in sorted(glob.glob(os.path.join(dir_path, "*_abricate.tsv"))):
        sample = sample_from_filename(fp)
        try:
            df = pd.read_csv(fp, sep="\t", dtype=str)
        except Exception:
            continue
        if df.empty:
            continue
        gene_col = next((c for c in df.columns if str(c).strip().lower() == "gene"), None)
        if gene_col is None:
            continue
        genes = df[gene_col].dropna().astype(str).str.strip()
        for gene in genes[genes != ""].unique():
            rows.append((sample, gene, source))
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--card_dir", required=True)
    ap.add_argument("--ncbi_dir", required=True)
    ap.add_argument("-o", "--out", required=True)
    args = ap.parse_args()

    rows = collect(args.card_dir) + collect(args.ncbi_dir)
    out_df = pd.DataFrame(rows, columns=["Sample", "Gene", "SourceDB"]).drop_duplicates()
    out_df.to_csv(args.out, sep="\t", index=False)


if __name__ == "__main__":
    main()
