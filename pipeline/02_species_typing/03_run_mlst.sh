#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

genome_dir="${1:-$GTDB_INPUT_DIR}"
output_tsv="${2:-$MLST_OUTPUT_DIR/mlst_results.tsv}"
extension="${3:-fa}"

require_dir "$genome_dir"
ensure_dir "$(dirname "$output_tsv")"

activate_conda_env "$CONDA_SH" "$MLST_CONDA_ENV"

{
    printf "sample\tmlst_result\n"
    for genome in "$genome_dir"/*."$extension"; do
        [[ -e "$genome" ]] || continue
        sample="$(basename "$genome" ".$extension")"
        log "Running MLST for $sample"
        mlst "$genome" | awk -v s="$sample" 'BEGIN{OFS="\t"} {print s, $0}'
    done
} > "$output_tsv"
