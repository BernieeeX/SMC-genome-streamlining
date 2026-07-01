#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

samples_tsv="${1:-$RNASEQ_SAMPLES_TSV}"
output_dir="${2:-$RNASEQ_TRIM_DIR}"
threads="${3:-$RNASEQ_THREADS}"

require_file "$samples_tsv"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$RNASEQ_CONDA_ENV"

tail -n +2 "$samples_tsv" | while IFS=$'\t' read -r sample_id condition read1 read2; do
    [[ -n "${sample_id:-}" ]] || continue
    require_file "$read1"
    require_file "$read2"
    log "Running fastp for $sample_id"
    fastp \
        -i "$read1" \
        -I "$read2" \
        -o "$output_dir/${sample_id}_R1.trim.fastq.gz" \
        -O "$output_dir/${sample_id}_R2.trim.fastq.gz" \
        --detect_adapter_for_pe \
        --thread "$threads" \
        --html "$output_dir/${sample_id}.fastp.html" \
        --json "$output_dir/${sample_id}.fastp.json"
done
