#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
  stop("Usage: run_deseq2.R <featureCounts.tsv> <samples.tsv> <output_dir>")
}

counts_file <- args[[1]]
samples_file <- args[[2]]
output_dir <- args[[3]]
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

suppressPackageStartupMessages({
  library(DESeq2)
})

count_lines <- read.delim(counts_file, comment.char = "#", check.names = FALSE)
count_matrix <- as.matrix(count_lines[, 7:ncol(count_lines), drop = FALSE])
rownames(count_matrix) <- count_lines$Geneid
sample_names <- sub("\\.sorted\\.bam$", "", basename(colnames(count_matrix)))
sample_names <- sub("\\.bam$", "", sample_names)

samples <- read.delim(samples_file, stringsAsFactors = FALSE)
if (!all(c("sample_id", "condition") %in% colnames(samples))) {
  stop("samples.tsv must contain sample_id and condition columns")
}
samples <- samples[match(sample_names, samples$sample_id), , drop = FALSE]
if (any(is.na(samples$sample_id))) {
  stop("Sample table does not match the count matrix column order")
}

dds <- DESeqDataSetFromMatrix(countData = round(count_matrix), colData = samples, design = ~ condition)
dds <- DESeq(dds)

res <- results(dds)
res_df <- as.data.frame(res)
res_df$gene <- rownames(res_df)
write.table(res_df, file = file.path(output_dir, "deseq2_results.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

saveRDS(dds, file = file.path(output_dir, "deseq2_object.rds"))
