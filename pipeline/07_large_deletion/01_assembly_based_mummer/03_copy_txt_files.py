#!/usr/bin/env python3
"""Copy text outputs from a large-deletion run into a flat directory."""

import argparse
import os
import shutil


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source-dir", required=True)
    ap.add_argument("--output-dir", required=True)
    args = ap.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)
    for root, _, files in os.walk(args.source_dir):
        for file in files:
            if not file.endswith(".txt"):
                continue
            source_file = os.path.join(root, file)
            dest_file = os.path.join(args.output_dir, file)
            if os.path.exists(dest_file):
                base, ext = os.path.splitext(file)
                count = 1
                while os.path.exists(dest_file):
                    dest_file = os.path.join(args.output_dir, f"{base}_{count}{ext}")
                    count += 1
            shutil.copy2(source_file, dest_file)
            print(f"Copied: {source_file} -> {dest_file}")

    print("done.txt")


if __name__ == "__main__":
    main()
