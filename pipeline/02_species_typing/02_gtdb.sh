#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

genome_dir="${1:-$GTDB_INPUT_DIR}"
output_dir="${2:-$GTDB_OUTPUT_DIR}"
extension="${3:-fa}"
threads="${4:-$THREADS_HIGH}"

require_dir "$genome_dir"
ensure_dir "$output_dir"
export GTDBTK_DATA_PATH="${GTDBTK_DATA_PATH:-/path/to/gtdbtk/data}"

activate_conda_env "$CONDA_SH" "$GTDB_CONDA_ENV"

log "Running GTDB-Tk classification"
gtdbtk classify_wf --genome_dir "$genome_dir" --extension "$extension" --out_dir "$output_dir" --cpus "$threads"
