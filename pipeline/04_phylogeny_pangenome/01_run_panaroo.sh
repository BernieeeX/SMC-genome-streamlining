#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

gff_dir="${1:-$PANAROO_GFF_DIR}"
output_dir="${2:-$PANAROO_OUTPUT_DIR}"
threads="${3:-$THREADS_DEFAULT}"

require_dir "$gff_dir"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$PANAROO_CONDA_ENV"

gffs=("$gff_dir"/*.gff)
(( ${#gffs[@]} > 0 )) || die "No GFF files found in $gff_dir"

log "Running Panaroo"
panaroo -i "$gff_dir"/*.gff -o "$output_dir" --clean-mode strict --threads "$threads" --core_entropy_filter 0.5 --core_threshold 0.95
