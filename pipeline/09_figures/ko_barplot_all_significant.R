#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
ko_file <- if (length(args) >= 1) args[[1]] else default_path("input", "ko_annotation.tsv")
deseq_file <- if (length(args) >= 2) args[[2]] else default_path("input", "deseq2_pair_results.tsv")
output_file <- if (length(args) >= 3) args[[3]] else default_path("output", "ko_barplot_all_significant.pdf")
top_n <- if (length(args) >= 4) as.integer(args[[4]]) else NA_integer_

check_input_files(c(ko_file, deseq_file))
ko <- read_tsv_safe(ko_file)
deseq <- read_tsv_safe(deseq_file)

ko_col <- intersect(names(ko), c("KO", "ko", "ko_term", "term"))[1]
gene_col_ko <- intersect(names(ko), c("gene", "Gene", "gene_id", "id"))[1]
deseq_gene_col <- intersect(names(deseq), c("gene", "Gene", "gene_id"))[1]
lfc_col <- intersect(names(deseq), c("log2FC", "log2FoldChange", "lfc"))[1]
padj_col <- intersect(names(deseq), c("padj", "adj.P.Val", "qvalue"))[1]
if (any(is.na(c(ko_col, gene_col_ko, deseq_gene_col, lfc_col, padj_col)))) stop("KO and DESeq2 tables need KO and gene identifier columns plus log2FC and padj", call. = FALSE)

ko <- as.data.frame(ko)
names(ko)[names(ko) == gene_col_ko] <- "gene"
deseq_sub <- data.frame(
  gene = deseq[[deseq_gene_col]],
  log2FC = as.numeric(deseq[[lfc_col]]),
  padj = as.numeric(deseq[[padj_col]]),
  stringsAsFactors = FALSE
)

plot_df <- merge(ko, deseq_sub, by = "gene", all.x = TRUE)
plot_df$significant <- !is.na(plot_df$padj) & plot_df$padj < 0.05

if (is.na(top_n)) {
  top_n <- nrow(plot_df)
}

plot_df <- plot_df |>
  filter(significant) |>
  mutate(abs_lfc = abs(log2FC)) |>
  arrange(desc(abs_lfc)) |>
  slice_head(n = top_n)

p <- ggplot(plot_df, aes(x = reorder(.data[[ko_col]], log2FC), y = log2FC, fill = log2FC > 0)) +
  geom_col(width = 0.8) +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#D73027", "FALSE" = "#4575B4"), guide = "none") +
  labs(x = "KO term", y = "log2 fold change", title = "Significant KO terms ranked by effect size") +
  smc_theme()

save_smc_pdf(p, output_file, width = 9, height = max(5, 0.22 * nrow(plot_df) + 2))
