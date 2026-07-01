#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

query_list="${1:-$KLETY_QUERY_LIST}"
output_dir="${2:-$KLETY_OUTPUT_DIR}"
klety_script="${3:-$KLETY_SCRIPT}"

require_file "$query_list"
require_file "$klety_script"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$KLETY_CONDA_ENV"

log "Running KleTy (Klebsiella-specific optional helper)"
python "$klety_script" --ql "$query_list" -o "$output_dir" -g
