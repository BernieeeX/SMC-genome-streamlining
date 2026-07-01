#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$ASSEMBLY_GENOME_DIR}"
output_dir="${2:-$CHECKM_OUTPUT_DIR}"
extension="${3:-fa}"
threads="${4:-$THREADS_HIGH}"

require_dir "$input_dir"
ensure_dir "$output_dir"
export CHECKM_DATA_PATH="${CHECKM_DATA_PATH:-/path/to/checkm/data}"

activate_conda_env "$CONDA_SH" "$CHECKM_CONDA_ENV"

for genome in "$input_dir"/*."$extension"; do
    [[ -e "$genome" ]] || continue
    sample="$(basename "$genome" ".$extension")"
    sample_out="$output_dir/$sample"
    ensure_dir "$sample_out"
    log "Running CheckM for $sample"
    checkm lineage_wf -x "$extension" "$genome" "$sample_out" -t "$threads"
done
