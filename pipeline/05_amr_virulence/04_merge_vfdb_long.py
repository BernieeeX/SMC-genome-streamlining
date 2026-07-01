#!/usr/bin/env python3
"""Summarise ABRicate CARD outputs into a gene-level presence table."""

import argparse
import glob
import os
import re

import pandas as pd


_paren_re = re.compile(r"\(([^()]+)\)")


def extract_gene_from_product(prod):
    if prod is None:
        return None
    items = [x.strip() for x in _paren_re.findall(str(prod))]
    for item in items:
        if "|" in item or " " in item:
            continue
        if item.startswith("WP_") or item.startswith("gb") or item.startswith("ref"):
            continue
        return item
    return None


def extract_gene_from_gene_col(gene_col):
    if gene_col is None:
        return None
    for item in [x.strip() for x in _paren_re.findall(str(gene_col))]:
        if "|" not in item and " " not in item:
            return item
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--vfdb_root", required=True)
    ap.add_argument("-o", "--out", required=True)
    args = ap.parse_args()

    rows = []
    for sample_dir in sorted(glob.glob(os.path.join(args.vfdb_root, "*"))):
        if not os.path.isdir(sample_dir):
            continue
        sample = os.path.basename(sample_dir)
        for fp in sorted(glob.glob(os.path.join(sample_dir, "*_vfdb_results.txt"))):
            try:
                df = pd.read_csv(fp, sep="\t", dtype=str)
            except Exception:
                continue
            if df.empty:
                continue
            for _, row in df.iterrows():
                gene = None
                if "PRODUCT" in df.columns:
                    gene = extract_gene_from_product(row.get("PRODUCT"))
                if not gene and "GENE" in df.columns:
                    gene = extract_gene_from_gene_col(row.get("GENE"))
                if gene:
                    rows.append((sample, gene, "vfdb"))

    out_df = pd.DataFrame(rows, columns=["Sample", "VF_Gene", "SourceDB"]).drop_duplicates()
    out_df.to_csv(args.out, sep="\t", index=False)


if __name__ == "__main__":
    main()
