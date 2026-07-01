#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$ABRICATE_VFDB_INPUT_DIR}"
output_dir="${2:-$ABRICATE_VFDB_OUTPUT_DIR}"
database="${3:-$ABRICATE_DB_VFDB}"
extension="${4:-fa}"

require_dir "$input_dir"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$ABRICATE_CONDA_ENV"

for fasta_file in "$input_dir"/*."$extension"; do
    [[ -e "$fasta_file" ]] || continue
    sample="$(basename "$fasta_file" ".$extension")"
    sample_output_dir="$output_dir/$sample"
    ensure_dir "$sample_output_dir"
    log "Running ABRicate ($database) for $sample"
    abricate --db "$database" "$fasta_file" > "$sample_output_dir/${sample}_vfdb_results.txt"
done
