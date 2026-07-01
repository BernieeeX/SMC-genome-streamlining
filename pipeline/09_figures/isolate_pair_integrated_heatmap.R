#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
gene_table_file <- if (length(args) >= 1) args[[1]] else default_path("input", "isolate_pair_gene_table.tsv")
copy_number_file <- if (length(args) >= 2) args[[2]] else default_path("input", "copy_number_change.tsv")
tpm_file <- if (length(args) >= 3) args[[3]] else default_path("input", "tpm_table.tsv")
deseq_file <- if (length(args) >= 4) args[[4]] else default_path("input", "deseq2_pair_results.tsv")
output_file <- if (length(args) >= 5) args[[5]] else default_path("output", "isolate_pair_integrated_heatmap.pdf")

check_input_files(c(gene_table_file, copy_number_file, tpm_file, deseq_file))

gene_tbl <- read_tsv_safe(gene_table_file)
copy_tbl <- read_tsv_safe(copy_number_file)
tpm_tbl <- read_tsv_safe(tpm_file)
deseq_tbl <- read_tsv_safe(deseq_file)

gene_col <- intersect(names(gene_tbl), c("gene", "Gene", "gene_id"))[1]
copy_gene_col <- intersect(names(copy_tbl), c("gene", "Gene", "gene_id"))[1]
tpm_gene_col <- intersect(names(tpm_tbl), c("gene", "Gene", "gene_id"))[1]
deseq_gene_col <- intersect(names(deseq_tbl), c("gene", "Gene", "gene_id"))[1]
lfc_col <- intersect(names(deseq_tbl), c("log2FC", "log2FoldChange", "lfc"))[1]
if (any(is.na(c(gene_col, copy_gene_col, tpm_gene_col, deseq_gene_col, lfc_col)))) {
  stop("Integrated heatmap inputs need a gene column and DESeq2 log2FC values", call. = FALSE)
}

rename_gene <- function(df, col_name) {
  df <- as.data.frame(df)
  names(df)[names(df) == col_name] <- "gene"
  df
}

gene_join <- rename_gene(gene_tbl, gene_col)
copy_join <- rename_gene(copy_tbl, copy_gene_col)
tpm_join <- rename_gene(tpm_tbl, tpm_gene_col)
deseq_join <- rename_gene(deseq_tbl, deseq_gene_col)

integrated <- Reduce(function(x, y) merge(x, y, by = "gene", all = TRUE), list(gene_join, copy_join, tpm_join, deseq_join))

presence_col <- intersect(names(gene_join), c("presence", "status", "gene_state"))[1]
copy_value_col <- setdiff(names(copy_join), "gene")[1]
tpm_value_col <- setdiff(names(tpm_join), "gene")[1]
if (is.na(presence_col)) presence_col <- setdiff(names(gene_join), "gene")[1]
if (is.na(copy_value_col)) copy_value_col <- setdiff(names(copy_join), "gene")[1]
if (is.na(tpm_value_col)) tpm_value_col <- setdiff(names(tpm_join), "gene")[1]

presence_mat <- matrix(integrated[[presence_col]], ncol = 1)
rownames(presence_mat) <- integrated$gene
copy_mat <- matrix(as.numeric(integrated[[copy_value_col]]), ncol = 1)
rownames(copy_mat) <- integrated$gene
tpm_mat <- matrix(as.numeric(integrated[[tpm_value_col]]), ncol = 1)
rownames(tpm_mat) <- integrated$gene
lfc_mat <- matrix(as.numeric(integrated[[lfc_col]]), ncol = 1)
rownames(lfc_mat) <- integrated$gene

pdf(output_file, width = 10, height = max(6, 0.2 * nrow(integrated) + 2))
ht_list <- Heatmap(
  presence_mat,
  name = "Gene state",
  col = c("0" = "#D9D9D9", "1" = "#252525", "lost" = "#D73027", "gained" = "#4575B4"),
  cluster_rows = FALSE,
  cluster_columns = FALSE,
  row_names_gp = grid::gpar(fontsize = 8)
) +
  Heatmap(
    copy_mat,
    name = "Copy number",
    col = colorRamp2(c(min(copy_mat, na.rm = TRUE), max(copy_mat, na.rm = TRUE)), c("#F7F7F7", "#2166AC")),
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_names_gp = grid::gpar(fontsize = 8)
  ) +
  Heatmap(
    tpm_mat,
    name = "TPM",
    col = colorRamp2(c(min(tpm_mat, na.rm = TRUE), max(tpm_mat, na.rm = TRUE)), c("#F7F7F7", "#B2182B")),
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_names_gp = grid::gpar(fontsize = 8)
  ) +
  Heatmap(
    lfc_mat,
    name = "log2FC",
    col = colorRamp2(c(min(lfc_mat, na.rm = TRUE), 0, max(lfc_mat, na.rm = TRUE)), c("#4575B4", "#F7F7F7", "#D73027")),
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_names_gp = grid::gpar(fontsize = 8)
  )
draw(ht_list, heatmap_legend_side = "right", annotation_legend_side = "right")
dev.off()
