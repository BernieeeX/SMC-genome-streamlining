#!/usr/bin/env python3
"""Filter heterozygous and low-depth genotype calls from a VCF."""

import sys


filename = str(sys.argv[1])

with open(filename) as variant_file:
    for line in variant_file:
        line = line.rstrip("\n")
        line_l = line.split("\t")
        if line_l[0].startswith("#"):
            print("\t".join(line_l))
            continue

        after_correction = line_l[0:9]
        for i in line_l[9:]:
            indv_format = i.split(":")
            gt = "./."
            if indv_format[0] not in {"0/1", "./.", ".|.", "0|1"}:
                if int(indv_format[2]) >= 10:
                    if indv_format[0] in {"0/0", "0|0"}:
                        ad = indv_format[1].split(",")
                        if round(int(ad[1]) / int(indv_format[2]), 4) < 0.1:
                            gt = "0/0"
                    elif indv_format[0] in {"1/1", "1|1"}:
                        ad = indv_format[1].split(",")
                        if round(int(ad[0]) / int(indv_format[2]), 4) < 0.1:
                            gt = "1/1"
            indv_format[0] = gt
            after_correction.append(":".join(indv_format))
        print("\t".join(after_correction))
