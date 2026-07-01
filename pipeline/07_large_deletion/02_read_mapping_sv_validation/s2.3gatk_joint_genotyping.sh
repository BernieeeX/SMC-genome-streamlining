#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

input_dir="${1:?Usage: $0 <input_dir> <out_dir> <reference_genome>}"
output_dir="${2:?Usage: $0 <input_dir> <out_dir> <reference_genome>}"
reference_genome="${3:?Usage: $0 <input_dir> <out_dir> <reference_genome>}"
regions_list="${LARGE_DEL_REGIONS_LIST:?Set LARGE_DEL_REGIONS_LIST in config/config.sh}"

require_dir "$input_dir"
ensure_dir "$output_dir"
require_file "$reference_genome"

sample_map="$output_dir/samples.map"
: > "$sample_map"

for file in "$input_dir"/*.g.vcf.gz; do
    [[ -e "$file" ]] || continue
    sample_name="$(basename "$file" .g.vcf.gz)"
    printf '%s\t%s\n' "$sample_name" "$file" >> "$sample_map"
done

log "Running GenomicsDBImport and GenotypeGVCFs"
gatk GenomicsDBImport --genomicsdb-workspace-path "$output_dir/my_database_genomicsDBImport" --batch-size 25 -L "$regions_list" -sample-name-map "$sample_map"
gatk GenotypeGVCFs -R "$reference_genome" -V "gendb://$output_dir/my_database_genomicsDBImport" -O "$output_dir/mtb_genotypeGVCF.vcf.gz"
