#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$SPADES_PLASMID_INPUT_DIR}"
output_dir="${2:-$SPADES_PLASMID_OUTPUT_DIR}"
threads="${3:-$THREADS_DEFAULT}"

require_dir "$input_dir"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$SPADES_CONDA_ENV"

for subdir in "$input_dir"/*/; do
    [[ -d "$subdir" ]] || continue
    sample="$(basename "$subdir")"
    r1_candidates=("$subdir"/*_1.fastq "$subdir"/*_1.fastq.gz)
    r2_candidates=("$subdir"/*_2.fastq "$subdir"/*_2.fastq.gz)
    r1="${r1_candidates[0]:-}"
    r2="${r2_candidates[0]:-}"
    if [[ -z "$r1" || -z "$r2" ]]; then
        log "Skipping $sample because paired reads were not found"
        continue
    fi
    sample_out="$output_dir/$sample"
    ensure_dir "$sample_out"
    log "Running SPAdes plasmid assembly for $sample"
    spades.py --plasmid -1 "$r1" -2 "$r2" -o "$sample_out" -t "$threads"
done
