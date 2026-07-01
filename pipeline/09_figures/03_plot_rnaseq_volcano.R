#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: 03_plot_rnaseq_volcano.R <deseq2_results.tsv> <output.pdf>")
}

input_tsv <- args[[1]]
output_pdf <- args[[2]]

res <- read.delim(input_tsv, stringsAsFactors = FALSE)
pdf(output_pdf, width = 7, height = 6)
if (nrow(res) > 0 && all(c("log2FoldChange", "padj") %in% names(res))) {
  x <- res$log2FoldChange
  y <- -log10(res$padj)
  plot(x, y, pch = 19, cex = 0.5,
       xlab = "log2 fold change", ylab = "-log10 adjusted p-value",
       main = "DESeq2 volcano plot")
  abline(v = c(-1, 1), col = "grey60", lty = 2)
  abline(h = -log10(0.05), col = "grey60", lty = 2)
} else {
  plot.new()
  title("DESeq2 volcano plot")
  text(0.5, 0.5, "Expected columns: log2FoldChange, padj")
}
dev.off()
