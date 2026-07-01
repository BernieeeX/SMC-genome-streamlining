#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

input_dir="${1:?Usage: $0 <input_dir> <output_dir>}"
output_dir="${2:?Usage: $0 <input_dir> <output_dir>}"

require_dir "$input_dir"
ensure_dir "$output_dir"

for file in "$input_dir"/*_sorted.bam; do
    [[ -e "$file" ]] || continue
    sample_name="$(basename "$file" _sorted.bam)"
    log "Marking duplicates for $sample_name"
    gatk MarkDuplicates -I "$file" -O "$output_dir/${sample_name}_sort_mkd.bam" -M "$output_dir/${sample_name}_sort_mkd.txt"
done
