#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

reference_genome="${1:-$LARGE_DEL_REFERENCE_FASTA}"
output_root="${2:-$LARGE_DEL_OUTPUT_DIR/alignment}"
if (( $# >= 2 )); then
    shift 2
else
    set --
fi

if [[ $# -eq 0 ]]; then
    set -- "$LARGE_DEL_QUERY_DIR"
fi

for input_dir in "$@"; do
    [[ -d "$input_dir" ]] || continue
    sample="$(basename "$input_dir")"
    sample_out="$output_root/$sample"
    ensure_dir "$sample_out"
    log "Running short-read alignment for $sample"
    "$SCRIPT_DIR/S1_run_bwa_short_read_alignment.sh" "$input_dir" "$sample_out" "$reference_genome"
done
