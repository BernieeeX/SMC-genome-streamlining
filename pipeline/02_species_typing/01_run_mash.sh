#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

query_sig_dir="${1:-$MASH_QUERY_SIG_DIR}"
reference_sig="${2:-$MASH_REFERENCE_SIG}"
output_dir="${3:-$MASH_OUTPUT_DIR}"

require_dir "$query_sig_dir"
require_file "$reference_sig"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$MASH_CONDA_ENV"

for sig_file in "$query_sig_dir"/*.sig; do
    [[ -e "$sig_file" ]] || continue
    sample="$(basename "$sig_file" .sig)"
    out_csv="$output_dir/${sample}_vs_ref.csv"
    log "Running sourmash compare for $sample"
    sourmash compare -o "$out_csv" "$sig_file" "$reference_sig" --distance-matrix
done
