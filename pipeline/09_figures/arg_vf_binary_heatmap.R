#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
arg_file <- if (length(args) >= 1) args[[1]] else default_path("input", "arg_presence_absence.tsv")
vf_file <- if (length(args) >= 2) args[[2]] else default_path("input", "vf_presence_absence.tsv")
metadata_file <- if (length(args) >= 3) args[[3]] else default_path("input", "metadata_public_safe.tsv")
resistance_file <- if (length(args) >= 4) args[[4]] else default_path("input", "resistance_phenotypes_binary.tsv")
species_file <- if (length(args) >= 5) args[[5]] else default_path("input", "species_assignment.tsv")
output_file <- if (length(args) >= 6) args[[6]] else default_path("output", "arg_vf_binary_heatmap.pdf")

check_input_files(c(arg_file, vf_file, metadata_file, resistance_file, species_file))
arg_tbl <- read_tsv_safe(arg_file)
vf_tbl <- read_tsv_safe(vf_file)
metadata <- read_tsv_safe(metadata_file)
resistance <- read_tsv_safe(resistance_file)
species <- read_tsv_safe(species_file)

sample_col_md <- intersect(names(metadata), c("sample_id", "Sample", "isolate", "Isolate"))[1]
sample_col_rs <- intersect(names(resistance), c("sample_id", "Sample", "isolate", "Isolate"))[1]
sample_col_sp <- intersect(names(species), c("sample_id", "Sample", "isolate", "Isolate"))[1]
if (any(is.na(c(sample_col_md, sample_col_rs, sample_col_sp)))) stop("Metadata, resistance, and species tables need sample identifier columns", call. = FALSE)

sample_order_file <- default_path("input", "core_tree_isolate_order.tsv")
sample_order <- NULL
if (file.exists(sample_order_file)) {
  order_tbl <- read_tsv_safe(sample_order_file)
  order_col <- intersect(names(order_tbl), c("sample_id", "Sample", "isolate", "Isolate"))[1]
  if (!is.na(order_col)) sample_order <- order_tbl[[order_col]]
}

arg_sample_col <- intersect(names(arg_tbl), c("sample_id", "Sample", "isolate", "Isolate"))[1]
vf_sample_col <- intersect(names(vf_tbl), c("sample_id", "Sample", "isolate", "Isolate"))[1]
if (any(is.na(c(arg_sample_col, vf_sample_col)))) stop("ARG/VF tables need sample identifier columns", call. = FALSE)

arg_tbl <- as.data.frame(arg_tbl)
vf_tbl <- as.data.frame(vf_tbl)
rownames(arg_tbl) <- arg_tbl[[arg_sample_col]]
rownames(vf_tbl) <- vf_tbl[[vf_sample_col]]
arg_mat <- as.matrix(arg_tbl[, setdiff(names(arg_tbl), arg_sample_col), drop = FALSE])
vf_mat <- as.matrix(vf_tbl[, setdiff(names(vf_tbl), vf_sample_col), drop = FALSE])

all_samples <- standardize_sample_order(rownames(arg_mat), sample_order)
all_samples <- intersect(all_samples, rownames(vf_mat))
arg_mat <- arg_mat[all_samples, , drop = FALSE]
vf_mat <- vf_mat[all_samples, , drop = FALSE]

species_col <- intersect(names(species), c("species", "Species", "gtdb_species", "taxonomy"))[1]
department_col <- intersect(names(metadata), c("Department_group", "department", "Department"))[1]
resistance_cols <- setdiff(names(resistance), sample_col_rs)
species_map <- species |>
  transmute(sample_id = .data[[sample_col_sp]], species = .data[[species_col]])
dept_map <- if (!is.na(department_col)) metadata |>
  transmute(sample_id = .data[[sample_col_md]], department = .data[[department_col]]) else tibble::tibble(sample_id = all_samples, department = "Other")

row_annotation <- rowAnnotation(
  Species = species_map$species[match(all_samples, species_map$sample_id)],
  Department = dept_map$department[match(all_samples, dept_map$sample_id)],
  col = list(Species = species_colors, Department = department_colors)
)

pdf(output_file, width = 12, height = 9)
ht <- Heatmap(
  arg_mat,
  name = "ARG",
  col = binary_colors,
  left_annotation = row_annotation,
  cluster_rows = FALSE,
  cluster_columns = FALSE,
  row_order = all_samples,
  show_row_names = TRUE,
  row_names_gp = grid::gpar(fontsize = 7)
) +
  Heatmap(
    vf_mat,
    name = "VF",
    col = binary_colors_neutral,
    left_annotation = row_annotation,
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_order = all_samples,
    show_row_names = TRUE,
    row_names_gp = grid::gpar(fontsize = 7)
  )
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right")
dev.off()
