#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$PLATON_INPUT_DIR}"
output_dir="${2:-$PLATON_OUTPUT_DIR}"
extension="${3:-fasta}"
threads="${4:-$THREADS_DEFAULT}"

require_dir "$input_dir"
ensure_dir "$output_dir"
export PLATON_DB="${PLATON_DB:?Set PLATON_DB in config/config.sh}"

activate_conda_env "$CONDA_SH" "$PLATON_CONDA_ENV"

for file in "$input_dir"/*."$extension"; do
    [[ -e "$file" ]] || continue
    sample="$(basename "$file" ".$extension")"
    log "Running Platon for $sample"
    platon --output "$output_dir/$sample" --verbose --threads "$threads" "$file"
done
