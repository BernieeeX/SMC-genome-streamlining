#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

input_fasta="${1:-${ASSEMBLY_GENOME_DIR:?Set ASSEMBLY_GENOME_DIR in config/config.sh}}"
output_fasta="${2:-$FILTERED_CONTIGS_DIR/filtered_contigs_1kb.fasta}"
min_len="${3:-$MIN_CONTIG_LENGTH}"

if [[ -d "$input_fasta" ]]; then
    die "Expected a FASTA file, but received a directory: $input_fasta"
fi
require_file "$input_fasta"
ensure_dir "$(dirname "$output_fasta")"

log "Filtering contigs shorter than ${min_len} bp"
awk -v min_len="$min_len" '
function emit() {
    if (header != "" && length(seq) >= min_len) {
        print header
        print seq
    }
}
/^>/ {
    emit()
    header = $0
    seq = ""
    next
}
{
    seq = seq $0
}
END {
    emit()
}
' "$input_fasta" > "$output_fasta"

log "Wrote filtered contigs to $output_fasta"
