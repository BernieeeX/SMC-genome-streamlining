#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_fasta="${1:-$MAFFT_INPUT_FASTA}"
output_fasta="${2:-$MAFFT_OUTPUT_FILE}"
threads="${3:-$THREADS_HIGH}"

require_file "$input_fasta"
ensure_dir "$(dirname "$output_fasta")"

activate_conda_env "$CONDA_SH" "${MAFFT_CONDA_ENV:-tree}"

log "Running MAFFT alignment"
mafft --thread "$threads" --globalpair --maxiterate 500 --auto "$input_fasta" > "$output_fasta"
