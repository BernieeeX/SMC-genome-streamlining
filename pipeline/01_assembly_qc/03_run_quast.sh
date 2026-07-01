#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$FILTERED_CONTIGS_DIR}"
output_dir="${2:-$QUAST_OUTPUT_DIR}"
threads="${3:-$THREADS_DEFAULT}"

require_dir "$input_dir"
ensure_dir "$output_dir"

assemblies=("$input_dir"/*.fa "$input_dir"/*.fasta)
if (( ${#assemblies[@]} == 0 )); then
    die "No FASTA assemblies found in $input_dir"
fi

log "Running QUAST on filtered assemblies"
quast.py -t "$threads" -o "$output_dir" "${assemblies[@]}"
