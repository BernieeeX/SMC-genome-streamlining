#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

bamfile="${1:?Usage: $0 <bamfile> <output_dir> <reference_genome>}"
output_dir="${2:?Usage: $0 <bamfile> <output_dir> <reference_genome>}"
ref="${3:?Usage: $0 <bamfile> <output_dir> <reference_genome>}"
threads="${4:-6}"
filter_script="${WHAM_FILTER_SCRIPT:?Set WHAM_FILTER_SCRIPT in config/config.sh}"

require_file "$bamfile"
require_file "$ref"
require_file "$filter_script"
ensure_dir "$output_dir"

file_name="$(basename "$bamfile" .bam)"

whamg -a "$ref" -f "$bamfile" -x "$threads" | perl "$filter_script" > "$output_dir/${file_name}.vcf"
