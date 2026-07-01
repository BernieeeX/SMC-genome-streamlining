#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

input_dirs=("$@")
if (( ${#input_dirs[@]} == 0 )); then
    input_dirs=("$LARGE_DEL_MARKDUP_DIR")
fi

for input_dir in "${input_dirs[@]}"; do
    [[ -d "$input_dir" ]] || continue
    log "Marking duplicates in $input_dir"
    "$SCRIPT_DIR/s2.1_mark_dup_general_ref.sh" "$input_dir" "$input_dir"
done
