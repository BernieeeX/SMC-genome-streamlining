#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$ABRICATE_NCBI_INPUT_DIR}"
output_dir="${2:-$ABRICATE_NCBI_OUTPUT_DIR}"
database="${3:-$ABRICATE_DB_NCBI}"
extension="${4:-fa}"

require_dir "$input_dir"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$ABRICATE_CONDA_ENV"

for fa_file in "$input_dir"/*."$extension"; do
    [[ -e "$fa_file" ]] || continue
    sample="$(basename "$fa_file" ".$extension")"
    log "Running ABRicate ($database) for $sample"
    abricate --db "$database" "$fa_file" > "$output_dir/${sample}_abricate.tsv"
done
