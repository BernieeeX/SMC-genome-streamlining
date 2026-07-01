#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
de_file <- if (length(args) >= 1) args[[1]] else default_path("input", "deseq2_results_resistant_vs_sensitive.tsv")
deletion_gene_file <- if (length(args) >= 2) args[[2]] else default_path("input", "deletion_region_gene_list.tsv")
annotation_file <- if (length(args) >= 3) args[[3]] else default_path("input", "gene_annotation.tsv")
output_file <- if (length(args) >= 4) args[[4]] else default_path("output", "volcano_deletion_region.pdf")

check_input_files(c(de_file, deletion_gene_file))
de <- read_tsv_safe(de_file)
deletion_genes <- read_tsv_safe(deletion_gene_file)
annotation <- if (file.exists(annotation_file)) read_tsv_safe(annotation_file) else tibble::tibble()

gene_col <- intersect(names(de), c("gene", "Gene", "gene_id", "id"))[1]
lfc_col <- intersect(names(de), c("log2FoldChange", "log2FC", "LFC"))[1]
padj_col <- intersect(names(de), c("padj", "adj.P.Val", "qvalue"))[1]
if (any(is.na(c(gene_col, lfc_col, padj_col)))) stop("deseq2 results must contain gene, log2FC, and padj columns", call. = FALSE)

deletion_gene_col <- intersect(names(deletion_genes), c("gene", "Gene", "gene_id", "id"))[1]
if (is.na(deletion_gene_col)) deletion_gene_col <- names(deletion_genes)[1]

plot_df <- de |>
  transmute(
    gene = .data[[gene_col]],
    log2FC = as.numeric(.data[[lfc_col]]),
    padj = as.numeric(.data[[padj_col]]),
    status = case_when(
      .data[[gene_col]] %in% deletion_genes[[deletion_gene_col]] ~ "Deletion-region",
      !is.na(padj) & padj < 0.05 & abs(log2FC) >= 1 ~ "Significant",
      TRUE ~ "Other"
    )
  ) |>
  mutate(minus_log10_padj = -log10(padj))

label_genes <- plot_df |> filter(status == "Deletion-region" | (status == "Significant" & abs(log2FC) >= 2))

p <- ggplot(plot_df, aes(x = log2FC, y = minus_log10_padj)) +
  geom_point(aes(color = status), alpha = 0.8, size = 1.8) +
  scale_color_manual(values = c("Deletion-region" = "#D73027", "Significant" = "#4575B4", "Other" = "grey70")) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "grey55") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey55") +
  ggrepel::geom_text_repel(data = label_genes, aes(label = gene), size = 3, max.overlaps = 30) +
  labs(
    x = "log2 fold change",
    y = expression(-log[10](adjusted~p)),
    color = NULL,
    title = "Differential expression volcano with deletion-region highlight"
  ) +
  smc_theme()

save_smc_pdf(p, output_file, width = 8.5, height = 6.5)

