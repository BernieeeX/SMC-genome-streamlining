#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: 04_plot_large_deletion_summary.R <input.tsv> <output.pdf>")
}

input_tsv <- args[[1]]
output_pdf <- args[[2]]

sv <- read.delim(input_tsv, stringsAsFactors = FALSE)
pdf(output_pdf, width = 8, height = 5)
if (nrow(sv) > 0 && "sample" %in% names(sv)) {
  bar <- sort(table(sv$sample), decreasing = TRUE)
  barplot(bar, las = 2, col = "#7570b3", main = "Large deletion summary", ylab = "Count")
} else {
  plot.new()
  title("Large deletion summary")
  text(0.5, 0.5, "Expected column: sample")
}
dev.off()
