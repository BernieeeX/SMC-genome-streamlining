#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
blast_file <- if (length(args) >= 1) args[[1]] else default_path("input", "plasmid_blast_summary.tsv")
mash_file <- if (length(args) >= 2) args[[2]] else default_path("input", "plasmid_mash_summary.tsv")
feature_file <- if (length(args) >= 3) args[[3]] else default_path("input", "plasmid_feature_table.tsv")
output_file <- if (length(args) >= 4) args[[4]] else default_path("output", "plasmid_similarity_summary.pdf")

check_input_files(c(blast_file, mash_file, feature_file))
blast <- read_tsv_safe(blast_file)
mash <- read_tsv_safe(mash_file)
feature <- read_tsv_safe(feature_file)

sample_col <- intersect(names(blast), c("sample_id", "Sample", "isolate"))[1]
identity_col <- intersect(names(blast), c("identity", "pct_identity", "similarity"))[1]
coverage_col <- intersect(names(blast), c("coverage", "pct_coverage"))[1]
feature_sample_col <- intersect(names(feature), c("sample_id", "Sample", "isolate"))[1]
feature_count_col <- intersect(names(feature), c("feature_count", "n_features", "features"))[1]
mash_sample_col <- intersect(names(mash), c("sample_id", "Sample", "isolate"))[1]
mash_dist_col <- intersect(names(mash), c("distance", "mash_distance", "dist"))[1]
if (any(is.na(c(sample_col, identity_col, coverage_col, feature_sample_col, feature_count_col, mash_sample_col, mash_dist_col)))) {
  stop("Plasmid summary tables need sample, similarity/coverage, feature, and Mash distance columns", call. = FALSE)
}

plot_df <- blast |>
  transmute(
    sample_id = .data[[sample_col]],
    identity = as.numeric(.data[[identity_col]]),
    coverage = as.numeric(.data[[coverage_col]])
  ) |>
  left_join(
    mash |>
      transmute(sample_id = .data[[mash_sample_col]], mash_distance = as.numeric(.data[[mash_dist_col]])),
    by = "sample_id"
  ) |>
  left_join(
    feature |>
      transmute(sample_id = .data[[feature_sample_col]], feature_count = as.numeric(.data[[feature_count_col]])),
    by = "sample_id"
  )

p <- ggplot(plot_df, aes(x = mash_distance, y = identity, size = feature_count, color = coverage)) +
  geom_point(alpha = 0.85) +
  scale_color_gradient(low = "#4575B4", high = "#D73027") +
  labs(
    x = "Mash distance",
    y = "Plasmid identity",
    color = "Coverage",
    size = "Feature count",
    title = "Plasmid similarity and support summary"
  ) +
  smc_theme()

save_smc_pdf(p, output_file, width = 8, height = 6)

