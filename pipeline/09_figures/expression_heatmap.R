#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
expression_file <- if (length(args) >= 1) args[[1]] else default_path("input", "expression_vst_matrix.tsv")
metadata_file <- if (length(args) >= 2) args[[2]] else default_path("input", "metadata_public_safe.tsv")
output_file <- if (length(args) >= 3) args[[3]] else default_path("output", "expression_heatmap.pdf")
order_file <- if (length(args) >= 4) args[[4]] else default_path("input", "core_tree_isolate_order.tsv")

check_input_files(c(expression_file, metadata_file))
expr <- read_tsv_safe(expression_file)
metadata <- read_tsv_safe(metadata_file)

sample_col <- intersect(names(metadata), c("sample_id", "Sample", "isolate", "Isolate"))[1]
if (is.na(sample_col)) stop("metadata file needs a sample identifier column", call. = FALSE)

expr_sample_col <- intersect(names(expr), c("gene", "Gene", "feature", "Feature"))[1]
if (is.na(expr_sample_col)) {
  expr_sample_col <- names(expr)[1]
}

matrix_data <- as.data.frame(expr)
rownames(matrix_data) <- matrix_data[[expr_sample_col]]
matrix_data[[expr_sample_col]] <- NULL
mat <- as.matrix(matrix_data)
storage.mode(mat) <- "numeric"

sample_order <- colnames(mat)
if (file.exists(order_file)) {
  order_tbl <- read_tsv_safe(order_file)
  order_col <- intersect(names(order_tbl), c("sample_id", "Sample", "isolate", "Isolate"))[1]
  if (!is.na(order_col)) {
    sample_order <- standardize_sample_order(order_tbl[[order_col]], sample_order)
  }
}
sample_order <- intersect(sample_order, colnames(mat))
mat <- mat[, sample_order, drop = FALSE]

meta_sub <- data.frame(
  sample_id = metadata[[sample_col]],
  department = if ("Department_group" %in% names(metadata)) metadata$Department_group else "Other",
  stringsAsFactors = FALSE
)

annotation <- HeatmapAnnotation(
  Department = meta_sub$department[match(colnames(mat), meta_sub$sample_id)],
  col = list(Department = department_colors)
)

pdf(output_file, width = 11, height = 8)
Heatmap(
  mat,
  name = "Expression",
  top_annotation = annotation,
  col = colorRamp2(c(min(mat, na.rm = TRUE), median(mat, na.rm = TRUE), max(mat, na.rm = TRUE)), c("#4575B4", "#F7F7F7", "#D73027")),
  show_row_names = TRUE,
  show_column_names = FALSE,
  cluster_columns = FALSE,
  cluster_rows = TRUE,
  row_names_gp = grid::gpar(fontsize = 7)
)
dev.off()
log_msg("Saved expression heatmap to", output_file)
