#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

workdir="${1:-$MGEFINDER_WORKDIR}"
threads="${2:-$THREADS_DEFAULT}"
output_dir="${3:-$MGEFINDER_OUTPUT_DIR}"

ensure_dir "$workdir"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$MGEFINDER_CONDA_ENV"

log "Running mgefinder workflow"
mgefinder workflow denovo "$workdir" --cores "$threads"
