#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

align_dir="${1:-$RNASEQ_ALIGN_DIR}"
gtf_file="${2:-$RNASEQ_GTF}"
output_dir="${3:-$RNASEQ_COUNTS_DIR}"
threads="${4:-$RNASEQ_THREADS}"

require_file "$gtf_file"
require_dir "$align_dir"
ensure_dir "$output_dir"

bams=("$align_dir"/*/*.sorted.bam "$align_dir"/*.sorted.bam)
(( ${#bams[@]} > 0 )) || die "No sorted BAM files found in $align_dir"

log "Running featureCounts"
featureCounts -T "$threads" -a "$gtf_file" -o "$output_dir/featureCounts.tsv" "${bams[@]}"
