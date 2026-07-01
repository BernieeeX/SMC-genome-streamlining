#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

reference="${1:-$MUMMER_REFERENCE}"
query_folder="${2:-$MUMMER_QUERY_DIR}"
output_folder="${3:-$MUMMER_OUTPUT_DIR/raw}"
snp_output_folder="${4:-$MUMMER_OUTPUT_DIR/snp}"
tiling_output_folder="${5:-$MUMMER_OUTPUT_DIR/tiling}"

require_file "$reference"
require_dir "$query_folder"
ensure_dir "$output_folder"
ensure_dir "$snp_output_folder"
ensure_dir "$tiling_output_folder"

for query_file in "$query_folder"/*.fa "$query_folder"/*.fna "$query_folder"/*.fasta; do
    [[ -e "$query_file" ]] || continue
    filename="$(basename "$query_file")"
    filename="${filename%.*}"
    delta_file="$output_folder/$filename.delta"

    log "Running nucmer for $filename"
    nucmer --maxmatch -c 100 -p "$output_folder/$filename" "$reference" "$query_file"

    if [[ -f "$delta_file" ]]; then
        show-snps -Clr "$delta_file" > "$snp_output_folder/$filename.snps"
        show-tiling -a "$delta_file" > "$tiling_output_folder/$filename.tiling"
    else
        log "Skipping downstream parsing because delta file was not created: $delta_file"
    fi
done
