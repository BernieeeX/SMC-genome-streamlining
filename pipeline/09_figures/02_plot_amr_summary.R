#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: 02_plot_amr_summary.R <input.tsv> <output.pdf>")
}

input_tsv <- args[[1]]
output_pdf <- args[[2]]

amr <- read.delim(input_tsv, stringsAsFactors = FALSE)
pdf(output_pdf, width = 8, height = 8)
if (nrow(amr) > 0 && all(c("Sample", "Gene") %in% names(amr))) {
  tab <- table(amr$Sample, amr$Gene)
  heatmap(as.matrix(tab), scale = "none", Colv = NA, Rowv = NA, margins = c(8, 8), main = "AMR / virulence gene presence")
} else {
  plot.new()
  title("AMR / virulence gene presence")
  text(0.5, 0.5, "Expected columns: Sample, Gene")
}
dev.off()
