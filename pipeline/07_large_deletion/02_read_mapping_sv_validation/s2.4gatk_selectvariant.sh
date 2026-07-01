#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

input_file="${1:?Usage: $0 <input_file> <output_dir> <reference_genome> <var_type>}"
output_dir="${2:?Usage: $0 <input_file> <output_dir> <reference_genome> <var_type>}"
reference_genome="${3:?Usage: $0 <input_file> <output_dir> <reference_genome> <var_type>}"
var_type="${4:?Usage: $0 <input_file> <output_dir> <reference_genome> <var_type>}"

ensure_dir "$output_dir"
outfile_name1="$(basename "$input_file" .vcf.gz)"

gunzip -c "$input_file" > "$output_dir/${outfile_name1}.vcf"
gatk SelectVariants -R "$reference_genome" -V "$output_dir/${outfile_name1}.vcf" --select-type-to-include "$var_type" -O "$output_dir/${outfile_name1}_${var_type}.vcf"
rm -f "$output_dir/${outfile_name1}.vcf"
