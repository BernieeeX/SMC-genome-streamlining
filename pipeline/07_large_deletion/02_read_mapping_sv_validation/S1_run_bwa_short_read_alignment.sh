#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../00_setup/common.sh"
load_config

input_dir="${1:?Usage: $0 <input_dir> <output_dir> <reference_genome>}"
output_dir="${2:?Usage: $0 <input_dir> <output_dir> <reference_genome>}"
reference_genome="${3:?Usage: $0 <input_dir> <output_dir> <reference_genome>}"
threads="${4:-$THREADS_HIGH}"

require_dir "$input_dir"
ensure_dir "$output_dir"
require_file "$reference_genome"

reference_dir="$(dirname "$reference_genome")"
reference_filename="$(basename "$reference_genome")"

if [[ ! -f "${reference_dir}/${reference_filename}.bwt" ]]; then
    log "Creating BWA index for $reference_genome"
    bwa index "$reference_genome"
fi

for file in "$input_dir"/*_raw_1.fastq "$input_dir"/*_raw_1.fastq.gz; do
    [[ -e "$file" ]] || continue
    sample_id="$(basename "$file")"
    sample_id="${sample_id%_raw_1.fastq.gz}"
    sample_id="${sample_id%_raw_1.fastq}"
    fastq1="$file"
    fastq2="$input_dir/${sample_id}_raw_2.fastq"
    [[ -f "$fastq2" ]] || fastq2="$input_dir/${sample_id}_raw_2.fastq.gz"

    if [[ ! -f "$fastq1" || ! -f "$fastq2" ]]; then
        log "Skipping $sample_id because paired FASTQs are missing"
        continue
    fi

    ensure_dir "$output_dir/$sample_id"
    log "Aligning $sample_id to the reference genome"
    bwa mem "$reference_genome" "$fastq1" "$fastq2" -t "$threads" -R "@RG\tID:${sample_id}\tSM:${sample_id}\tSQ:bwa" > "$output_dir/${sample_id}.sam"
    samtools view -S -b -@ "$threads" "$output_dir/${sample_id}.sam" > "$output_dir/${sample_id}.bam"
    samtools sort -@ "$threads" -o "$output_dir/${sample_id}_sorted.bam" "$output_dir/${sample_id}.bam"
    samtools index -@ "$threads" "$output_dir/${sample_id}_sorted.bam"
    rm -f "$output_dir/${sample_id}.sam" "$output_dir/${sample_id}.bam"
done
