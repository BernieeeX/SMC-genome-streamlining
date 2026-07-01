#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

vcf_file="${1:?Usage: $0 <vcf_file> <output_dir>}"
output_dir="${2:?Usage: $0 <vcf_file> <output_dir>}"

ensure_dir "$output_dir"
output_name="$(basename "$vcf_file" .vcf)"

gatk VariantFiltration \
    -V "$vcf_file" \
    -O "$output_dir/${output_name}_variantfiltration.vcf" \
    --filter-expression "QD < 2.00" --filter-name "QD2" \
    --filter-expression "DP < 10.00" --filter-name "DP10" \
    --filter-expression "FS > 200.00" --filter-name "FS200" \
    --filter-expression "MQ < 20.00" --filter-name "MQ20" \
    --filter-expression "ReadPosRankSum < -20.00" --filter-name "ReadPosRankSum-20" \
    --filter-expression "ExcessHet > 5.68" --filter-name "ExcessHet5.68"
