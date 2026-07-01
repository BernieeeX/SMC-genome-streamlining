#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$ASSEMBLY_GENOME_DIR}"
output_dir="${2:-$DREP_OUTPUT_DIR}"
threads="${3:-$THREADS_HIGH}"
extension="${4:-fa}"

require_dir "$input_dir"
ensure_dir "$output_dir"

genomes=("$input_dir"/*."$extension")
(( ${#genomes[@]} > 0 )) || die "No .$extension genomes found in $input_dir"

activate_conda_env "$CONDA_SH" "$DREP_CONDA_ENV"

log "Running dRep dereplication"
dRep dereplicate "$output_dir" -g "$input_dir"/*."$extension" -p "$threads" --debug --completeness 50 --contamination 10 --S_algorithm gANI
