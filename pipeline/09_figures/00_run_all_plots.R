#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
})

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

run_script <- function(script_name, args = character()) {
  script_path <- file.path("pipeline", "09_figures", script_name)
  check_input_file(script_path)
  log_msg("Running", script_name)
  system2("Rscript", c(script_path, args))
}

run_script(
  "itol_annotation_tracks.R",
  c(
    default_path("input", "tree_core_genome.nwk"),
    default_path("input", "metadata_public_safe.tsv"),
    default_path("input", "resistance_phenotypes_binary.tsv"),
    default_path("input", "species_assignment.tsv"),
    default_path("output", "itol_tracks")
  )
)
run_script(
  "expression_heatmap.R",
  c(
    default_path("input", "expression_vst_matrix.tsv"),
    default_path("input", "metadata_public_safe.tsv"),
    default_path("output", "expression_heatmap.pdf")
  )
)
run_script(
  "volcano_deletion_region.R",
  c(
    default_path("input", "deseq2_results_resistant_vs_sensitive.tsv"),
    default_path("input", "deletion_region_gene_list.tsv"),
    default_path("input", "gene_annotation.tsv"),
    default_path("output", "volcano_deletion_region.pdf")
  )
)
run_script(
  "ko_term_heatmap.R",
  c(
    default_path("input", "ko_term_results.tsv"),
    default_path("output", "ko_term_heatmap.pdf")
  )
)
run_script(
  "isolate_pair_integrated_heatmap.R",
  c(
    default_path("input", "isolate_pair_gene_table.tsv"),
    default_path("input", "copy_number_change.tsv"),
    default_path("input", "tpm_table.tsv"),
    default_path("input", "deseq2_pair_results.tsv"),
    default_path("output", "isolate_pair_integrated_heatmap.pdf")
  )
)
run_script(
  "ko_barplot_all_significant.R",
  c(
    default_path("input", "ko_annotation.tsv"),
    default_path("input", "deseq2_pair_results.tsv"),
    default_path("output", "ko_barplot_all_significant.pdf")
  )
)
run_script(
  "plasmid_similarity_summary.R",
  c(
    default_path("input", "plasmid_blast_summary.tsv"),
    default_path("input", "plasmid_mash_summary.tsv"),
    default_path("input", "plasmid_feature_table.tsv"),
    default_path("output", "plasmid_similarity_summary.pdf")
  )
)
run_script(
  "resistance_metadata_heatmap.R",
  c(
    default_path("input", "metadata_public_safe.tsv"),
    default_path("input", "resistance_phenotypes_binary.tsv"),
    default_path("output", "resistance_metadata_heatmap.pdf")
  )
)
run_script(
  "arg_vf_binary_heatmap.R",
  c(
    default_path("input", "arg_presence_absence.tsv"),
    default_path("input", "vf_presence_absence.tsv"),
    default_path("input", "metadata_public_safe.tsv"),
    default_path("input", "resistance_phenotypes_binary.tsv"),
    default_path("input", "species_assignment.tsv"),
    default_path("output", "arg_vf_binary_heatmap.pdf")
  )
)

if (is_true_env("RUN_OPTIONAL")) {
  run_script(
    "brite_barplot_optional.R",
    c(
      default_path("input", "brite_annotation.tsv"),
      default_path("input", "deseq2_pair_results.tsv"),
      default_path("output", "brite_barplot_optional.pdf")
    )
  )
}

