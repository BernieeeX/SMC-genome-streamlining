#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

reference_genome="${1:?Usage: $0 <reference_genome> <bamfile> <out_dir>}"
bamfile="${2:?Usage: $0 <reference_genome> <bamfile> <out_dir>}"
out_dir="${3:?Usage: $0 <reference_genome> <bamfile> <out_dir>}"

require_file "$reference_genome"
require_file "$bamfile"
ensure_dir "$out_dir"

file_name="$(basename "$bamfile" _sort_mkd.bam)"
log "Running GATK HaplotypeCaller for $file_name"
samtools index "$bamfile"
gatk HaplotypeCaller \
    -ploidy 2 \
    -mbq 20 \
    -A MappingQualityRankSumTest \
    -A ReadPosRankSumTest \
    -R "$reference_genome" \
    -I "$bamfile" \
    -O "$out_dir/${file_name}.g.vcf.gz" \
    -ERC GVCF
