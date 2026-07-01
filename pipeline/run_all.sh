#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/00_setup/common.sh"
load_config

run_step() {
    local label="$1"
    local script_path="$2"
    shift 2
    log "=== $label ==="
    case "$script_path" in
        *.R) Rscript "$script_path" "$@" ;;
        *.py) python "$script_path" "$@" ;;
        *) bash "$script_path" "$@" ;;
    esac
}

run_step "Genome assembly" "$ROOT_DIR/pipeline/01_assembly_qc/01_metawrap_assembly.sh"
run_step "Contig filtering" "$ROOT_DIR/pipeline/01_assembly_qc/02_filter_contigs_1kb.sh"
run_step "Assembly QC" "$ROOT_DIR/pipeline/01_assembly_qc/03_run_quast.sh"
run_step "Assembly completeness" "$ROOT_DIR/pipeline/01_assembly_qc/04_run_checkm.sh"

run_step "Mash / sourmash comparison" "$ROOT_DIR/pipeline/02_species_typing/01_run_mash.sh"
run_step "Species assignment" "$ROOT_DIR/pipeline/02_species_typing/02_gtdb.sh"
run_step "MLST typing" "$ROOT_DIR/pipeline/02_species_typing/03_run_mlst.sh"

run_step "Genome annotation" "$ROOT_DIR/pipeline/03_annotation/01_run_prokka.sh"

run_step "Pangenome analysis" "$ROOT_DIR/pipeline/04_phylogeny_pangenome/01_run_panaroo.sh"
run_step "Core-gene alignment" "$ROOT_DIR/pipeline/04_phylogeny_pangenome/02_run_mafft.sh"
if [[ "${RUN_DREP:-false}" == "true" ]]; then
    run_step "Genome dereplication" "$ROOT_DIR/pipeline/04_phylogeny_pangenome/03_run_drep_optional.sh"
fi

run_step "AMR annotation" "$ROOT_DIR/pipeline/05_amr_virulence/01_run_abricate.sh"
run_step "Virulence annotation" "$ROOT_DIR/pipeline/05_amr_virulence/02_run_vfdb.sh"
run_step "AMR merge" "$ROOT_DIR/pipeline/05_amr_virulence/03_merge_abricate_long.py" \
    --card_dir "$ABRICATE_CARD_OUTPUT_DIR" \
    --ncbi_dir "$ABRICATE_NCBI_OUTPUT_DIR" \
    -o "$ABRICATE_MERGED_OUTPUT"
run_step "Virulence merge" "$ROOT_DIR/pipeline/05_amr_virulence/04_merge_vfdb_long.py" \
    --vfdb_root "$ABRICATE_VFDB_OUTPUT_DIR" \
    -o "$VFDB_MERGED_OUTPUT"

run_step "Platon plasmid annotation" "$ROOT_DIR/pipeline/06_plasmid_mge/01_run_platon.sh"
run_step "MGEFinder workflow" "$ROOT_DIR/pipeline/06_plasmid_mge/02_run_mgefinder.sh"
run_step "SPAdes plasmid assembly" "$ROOT_DIR/pipeline/06_plasmid_mge/03_run_spades_plasmid.sh"

run_step "Structural variation discovery" "$ROOT_DIR/pipeline/07_large_deletion/01_assembly_based_mummer/01_run_mummer.sh"
run_step "Large deletion summarise" "$ROOT_DIR/pipeline/07_large_deletion/01_assembly_based_mummer/02_summarise_large_deletions.py" \
    --source-dir "$MUMMER_OUTPUT_DIR" \
    --output-dir "$MUMMER_OUTPUT_DIR/summary" \
    -o "$LARGE_DEL_SUMMARY_TSV"

run_step "RNA-seq trimming" "$ROOT_DIR/pipeline/08_rnaseq/01_run_fastp.sh"
run_step "RNA-seq alignment" "$ROOT_DIR/pipeline/08_rnaseq/02_run_hisat2.sh"
run_step "RNA-seq counting" "$ROOT_DIR/pipeline/08_rnaseq/03_run_featurecounts.sh"

if [[ -f "$RNASEQ_COUNTS_DIR/featureCounts.tsv" && -f "$RNASEQ_SAMPLES_TSV" ]]; then
    run_step "RNA-seq differential expression" "$ROOT_DIR/pipeline/08_rnaseq/04_run_deseq2.R" \
        "$RNASEQ_COUNTS_DIR/featureCounts.tsv" "$RNASEQ_SAMPLES_TSV" "$RNASEQ_DESEQ2_DIR"
fi

if [[ -f "$QC_SUMMARY_TSV" ]]; then
    run_step "QC figure generation" "$ROOT_DIR/pipeline/09_figures/01_plot_qc_summary.R" \
        "$QC_SUMMARY_TSV" "$FIGURE_OUTPUT_DIR/qc_summary.pdf"
fi

if [[ -f "$AMR_SUMMARY_TSV" ]]; then
    run_step "AMR figure generation" "$ROOT_DIR/pipeline/09_figures/02_plot_amr_summary.R" \
        "$AMR_SUMMARY_TSV" "$FIGURE_OUTPUT_DIR/amr_summary.pdf"
fi

if [[ -f "$RNASEQ_RESULTS_TSV" ]]; then
    run_step "RNA-seq figure generation" "$ROOT_DIR/pipeline/09_figures/03_plot_rnaseq_volcano.R" \
        "$RNASEQ_RESULTS_TSV" "$FIGURE_OUTPUT_DIR/rnaseq_volcano.pdf"
fi

if [[ -f "$LARGE_DEL_SUMMARY_TSV" ]]; then
    run_step "Large deletion figure generation" "$ROOT_DIR/pipeline/09_figures/04_plot_large_deletion_summary.R" \
        "$LARGE_DEL_SUMMARY_TSV" "$FIGURE_OUTPUT_DIR/large_deletion_summary.pdf"
fi
