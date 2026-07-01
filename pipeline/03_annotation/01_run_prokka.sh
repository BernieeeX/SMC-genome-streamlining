#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_dir="${1:-$ANNOTATION_INPUT_DIR}"
output_dir="${2:-$PROKKA_OUTPUT_DIR}"
extension="${3:-fa}"

require_dir "$input_dir"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$PROKKA_CONDA_ENV"

for fa_file in "$input_dir"/*."$extension"; do
    [[ -e "$fa_file" ]] || continue
    sample="$(basename "$fa_file" ".$extension")"
    sample_out="$output_dir/${sample}_annotation"
    ensure_dir "$sample_out"
    log "Annotating $sample with Prokka"
    prokka --force --outdir "$sample_out" --prefix "${sample}_annotation" "$fa_file"
done
