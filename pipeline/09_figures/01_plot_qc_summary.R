#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: 01_plot_qc_summary.R <input.tsv> <output.pdf>")
}

input_tsv <- args[[1]]
output_pdf <- args[[2]]

qc <- read.delim(input_tsv, stringsAsFactors = FALSE)
pdf(output_pdf, width = 8, height = 5)
par(mfrow = c(1, 2), mar = c(5, 5, 2, 1))

if (all(c("completeness", "contamination") %in% names(qc))) {
  plot(qc$completeness, qc$contamination,
       xlab = "Completeness (%)", ylab = "Contamination (%)",
       pch = 19, col = "#1b9e77", main = "Assembly QC")
} else {
  plot.new()
  title("Assembly QC")
  text(0.5, 0.5, "Expected columns: completeness, contamination")
}

if (all(c("N50", "size") %in% names(qc))) {
  plot(qc$size, qc$N50, xlab = "Genome size", ylab = "N50", pch = 19, col = "#d95f02")
} else {
  plot.new()
  title("Genome size vs N50")
  text(0.5, 0.5, "Expected columns: size, N50")
}

dev.off()
