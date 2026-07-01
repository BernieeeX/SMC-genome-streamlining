#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
brite_file <- if (length(args) >= 1) args[[1]] else default_path("input", "brite_annotation.tsv")
deseq_file <- if (length(args) >= 2) args[[2]] else default_path("input", "deseq2_pair_results.tsv")
output_file <- if (length(args) >= 3) args[[3]] else default_path("output", "brite_barplot_optional.pdf")

check_input_files(c(brite_file, deseq_file))
brite <- read_tsv_safe(brite_file)
deseq <- read_tsv_safe(deseq_file)

brite_col <- intersect(names(brite), c("BRITE", "brite", "category"))[1]
gene_col <- intersect(names(brite), c("gene", "Gene", "gene_id"))[1]
deseq_gene_col <- intersect(names(deseq), c("gene", "Gene", "gene_id"))[1]
lfc_col <- intersect(names(deseq), c("log2FC", "log2FoldChange", "lfc"))[1]
padj_col <- intersect(names(deseq), c("padj", "adj.P.Val", "qvalue"))[1]
if (any(is.na(c(brite_col, gene_col, deseq_gene_col, lfc_col, padj_col)))) stop("BRITE and DESeq2 tables need category, gene, log2FC, and padj columns", call. = FALSE)

plot_df <- brite |>
  transmute(gene = .data[[gene_col]], brite = .data[[brite_col]]) |>
  left_join(
    deseq |>
      transmute(gene = .data[[deseq_gene_col]], log2FC = as.numeric(.data[[lfc_col]]), padj = as.numeric(.data[[padj_col]])),
    by = "gene"
  ) |>
  filter(!is.na(padj) & padj < 0.05) |>
  group_by(brite) |>
  summarise(mean_log2FC = mean(log2FC, na.rm = TRUE), n = n(), .groups = "drop") |>
  arrange(desc(abs(mean_log2FC)))

p <- ggplot(plot_df, aes(x = reorder(brite, mean_log2FC), y = mean_log2FC, fill = mean_log2FC > 0)) +
  geom_col(width = 0.8) +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#D73027", "FALSE" = "#4575B4"), guide = "none") +
  labs(x = "BRITE category", y = "Mean log2 fold change", title = "Optional BRITE summary") +
  smc_theme()

save_smc_pdf(p, output_file, width = 9, height = max(5, 0.22 * nrow(plot_df) + 2))

