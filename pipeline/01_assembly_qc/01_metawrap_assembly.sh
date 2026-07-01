#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

read1="${1:-${ASSEMBLY_INPUT_R1:?Set ASSEMBLY_INPUT_R1 in config/config.sh}}"
read2="${2:-${ASSEMBLY_INPUT_R2:?Set ASSEMBLY_INPUT_R2 in config/config.sh}}"
out_dir="${3:-$ASSEMBLY_OUTPUT_DIR}"
threads="${4:-$THREADS_DEFAULT}"

require_file "$read1"
require_file "$read2"
ensure_dir "$out_dir"

activate_conda_env "$CONDA_SH" "$METAWRAP_CONDA_ENV"

log "Running metaWRAP assembly"
metawrap assembly -1 "$read1" -2 "$read2" -t "$threads" -o "$out_dir"
