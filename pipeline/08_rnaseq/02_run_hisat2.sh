#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../00_setup/common.sh"
load_config

samples_tsv="${1:-$RNASEQ_SAMPLES_TSV}"
trim_dir="${2:-$RNASEQ_TRIM_DIR}"
output_dir="${3:-$RNASEQ_ALIGN_DIR}"
index_prefix="${4:-$HISAT2_INDEX_PREFIX}"
threads="${5:-$RNASEQ_THREADS}"

require_file "$samples_tsv"
require_dir "$trim_dir"
ensure_dir "$output_dir"

activate_conda_env "$CONDA_SH" "$RNASEQ_CONDA_ENV"

tail -n +2 "$samples_tsv" | while IFS=$'\t' read -r sample_id condition read1 read2; do
    [[ -n "${sample_id:-}" ]] || continue
    r1="$trim_dir/${sample_id}_R1.trim.fastq.gz"
    r2="$trim_dir/${sample_id}_R2.trim.fastq.gz"
    require_file "$r1"
    require_file "$r2"
    sample_out="$output_dir/$sample_id"
    ensure_dir "$sample_out"
    log "Aligning RNA-seq reads for $sample_id with HISAT2"
    hisat2 -x "$index_prefix" -1 "$r1" -2 "$r2" -p "$threads" | samtools sort -@ "$threads" -o "$sample_out/${sample_id}.sorted.bam"
    samtools index "$sample_out/${sample_id}.sorted.bam"
done
