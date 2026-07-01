#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
tree_file <- if (length(args) >= 1) args[[1]] else default_path("input", "tree_core_genome.nwk")
metadata_file <- if (length(args) >= 2) args[[2]] else default_path("input", "metadata_public_safe.tsv")
resistance_file <- if (length(args) >= 3) args[[3]] else default_path("input", "resistance_phenotypes_binary.tsv")
species_file <- if (length(args) >= 4) args[[4]] else default_path("input", "species_assignment.tsv")
output_dir <- if (length(args) >= 5) args[[5]] else default_path("output", "itol_tracks")

check_input_files(c(tree_file, metadata_file, resistance_file, species_file))
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

metadata <- read_tsv_safe(metadata_file)
resistance <- read_tsv_safe(resistance_file)
species <- read_tsv_safe(species_file)

sample_col <- intersect(names(metadata), c("sample_id", "Sample", "isolate", "Isolate"))[1]
if (is.na(sample_col)) stop("metadata file needs a sample identifier column", call. = FALSE)
species_sample_col <- intersect(names(species), c("sample_id", "Sample", "isolate", "Isolate"))[1]
res_sample_col <- intersect(names(resistance), c("sample_id", "Sample", "isolate", "Isolate"))[1]
if (is.na(species_sample_col) || is.na(res_sample_col)) stop("species and resistance tables need sample identifier columns", call. = FALSE)

species_name_col <- intersect(names(species), c("species", "Species", "gtdb_species", "taxonomy"))[1]
if (is.na(species_name_col)) stop("species assignment table needs a species column", call. = FALSE)

department_col <- intersect(names(metadata), c("department", "Department", "Department_group", "dept"))[1]

species_map <- species |>
  transmute(sample_id = .data[[species_sample_col]], species = .data[[species_name_col]]) |>
  distinct()

species_out <- file.path(output_dir, "itol_species_dataset.txt")
department_out <- file.path(output_dir, "itol_department_dataset.txt")
resistance_out <- file.path(output_dir, "itol_resistance_binary_datasets.txt")

species_dataset <- data.frame(sample_id = metadata[[sample_col]], stringsAsFactors = FALSE) |>
  left_join(species_map, by = "sample_id") |>
  mutate(species = ifelse(is.na(species), "unclassified", species))

writeLines(c(
  "DATASET_COLORSTRIP",
  "SEPARATOR TAB",
  "DATASET_LABEL\tSpecies",
  "COLOR\t#000000",
  "LEGEND_TITLE\tSpecies"
), species_out)
write.table(species_dataset, species_out, sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE, append = TRUE)

if (!is.na(department_col)) {
  department_dataset <- data.frame(
    sample_id = metadata[[sample_col]],
    department = metadata[[department_col]],
    stringsAsFactors = FALSE
  )
  writeLines(c(
    "DATASET_COLORSTRIP",
    "SEPARATOR TAB",
    "DATASET_LABEL\tDepartment",
    "COLOR\t#000000",
    "LEGEND_TITLE\tDepartment"
  ), department_out)
  write.table(department_dataset, department_out, sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE, append = TRUE)
}

resistance_cols <- setdiff(names(resistance), c(res_sample_col, sample_col))
resistance_subset <- data.frame(sample_id = resistance[[res_sample_col]], resistance[, resistance_cols, drop = FALSE], stringsAsFactors = FALSE)

writeLines(c(
  "DATASET_BINARY",
  "SEPARATOR TAB",
  "DATASET_LABEL\tResistance",
  "COLOR\t#000000",
  "FIELD_COLORS\t#2166AC,#B2182B"
), resistance_out)
write.table(resistance_subset, resistance_out, sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE, append = TRUE)

log_msg("Wrote iTOL annotation datasets to", output_dir)
