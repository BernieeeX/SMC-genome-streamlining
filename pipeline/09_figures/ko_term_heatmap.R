#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
input_file <- if (length(args) >= 1) args[[1]] else default_path("input", "ko_term_results.tsv")
output_file <- if (length(args) >= 2) args[[2]] else default_path("output", "ko_term_heatmap.pdf")

check_input_file(input_file)
ko <- read_tsv_safe(input_file)

ko_col <- intersect(names(ko), c("KO", "ko", "ko_term", "term"))[1]
lfc_col <- intersect(names(ko), c("log2FC", "log2FoldChange", "lfc"))[1]
padj_col <- intersect(names(ko), c("padj", "adj.P.Val", "qvalue"))[1]
metal_col <- intersect(names(ko), c("metal_ion_related", "metal", "metal_flag"))[1]
if (any(is.na(c(ko_col, lfc_col, padj_col)))) stop("KO table needs KO, log2FC, and padj columns", call. = FALSE)

plot_df <- ko |>
  transmute(
    KO = .data[[ko_col]],
    log2FC = as.numeric(.data[[lfc_col]]),
    padj = as.numeric(.data[[padj_col]]),
    metal_ion = if (!is.na(metal_col)) as.character(.data[[metal_col]]) else "no"
  ) |>
  mutate(
    significance = case_when(
      !is.na(padj) & padj < 0.05 ~ "significant",
      TRUE ~ "n.s."
    ),
    label = if_else(significance == "significant", "*", "")
  )

mat <- as.matrix(plot_df["log2FC"])
rownames(mat) <- plot_df$KO

left_annotation <- rowAnnotation(
  Sig = plot_df$significance,
  Metal = plot_df$metal_ion,
  col = list(
    Sig = c("significant" = "#D73027", "n.s." = "#BBBBBB"),
    Metal = c("yes" = "#B2182B", "no" = "#D9D9D9", "1" = "#B2182B", "0" = "#D9D9D9")
  )
)

pdf(output_file, width = 8, height = max(5, 0.22 * nrow(plot_df) + 2))
draw(
  Heatmap(
    mat,
    name = "log2FC",
    col = colorRamp2(c(min(mat, na.rm = TRUE), 0, max(mat, na.rm = TRUE)), c("#4575B4", "#F7F7F7", "#D73027")),
    left_annotation = left_annotation,
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_names_gp = grid::gpar(fontsize = 8)
  ),
  heatmap_legend_side = "right",
  annotation_legend_side = "right"
)
dev.off()

