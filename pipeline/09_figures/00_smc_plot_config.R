#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(ComplexHeatmap)
  library(circlize)
  library(ggrepel)
  library(grid)
})

department_colors <- c(
  "Other" = "#999999",
  "EICU" = "#F0E442",
  "ICU" = "#D55E00",
  "Neurosurgery Department" = "#0072B2",
  "Respiratory Medicine Department" = "#CC79A7"
)

species_colors <- c(
  "S. maltophilia" = "#8DD3C7",
  "S. pavanii" = "#FDB462",
  "S. maltophilia_AK" = "#BEBADA",
  "S. geniculata" = "#FB8072",
  "S. maltophilia_F" = "#80B1D3",
  "S. maltophilia_P" = "#B3DE69",
  "S. maltophilia_AM" = "#FCCDE5",
  "S. maltophilia_A" = "#BC80BD",
  "unclassified" = "#CCEBC5",
  "S. maltophilia_B" = "#FFED6F",
  "S. maltophilia_G" = "#A6CEE3",
  "S. maltophilia_AJ" = "#6A3D9A",
  "S. maltophilia_O" = "#1F78B4",
  "S. maltophilia_Q" = "#33A02C"
)

binary_colors <- c(
  "0" = "#2166AC",
  "1" = "#B2182B"
)

binary_colors_neutral <- c(
  "0" = "#D9D9D9",
  "1" = "#252525"
)

smc_theme <- function(base_size = 10) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid = element_blank(),
      axis.text = element_text(color = "black"),
      axis.title = element_text(color = "black"),
      plot.title = element_text(face = "bold", hjust = 0),
      legend.title = element_text(face = "bold")
    )
}

check_input_file <- function(path) {
  if (length(path) != 1L || !file.exists(path)) {
    stop("Input file does not exist: ", path, call. = FALSE)
  }
  invisible(path)
}

check_input_files <- function(paths) {
  lapply(paths, check_input_file)
  invisible(paths)
}

ensure_output_dir <- function(path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

source_repo_relative <- function(...) {
  source(file.path(...), local = FALSE)
}

read_tsv_safe <- function(path, ...) {
  check_input_file(path)
  readr::read_tsv(path, show_col_types = FALSE, ...)
}

read_table_safe <- function(path, ...) {
  check_input_file(path)
  readr::read_delim(path, show_col_types = FALSE, ...)
}

standardize_sample_order <- function(x, preferred_order = NULL) {
  x <- unique(as.character(x))
  if (!is.null(preferred_order)) {
    preferred_order <- unique(as.character(preferred_order))
    x <- c(intersect(preferred_order, x), setdiff(x, preferred_order))
  }
  x
}

save_smc_pdf <- function(plot, output_file, width = 8, height = 6) {
  ensure_output_dir(output_file)
  ggplot2::ggsave(
    filename = output_file,
    plot = plot,
    width = width,
    height = height,
    device = grDevices::cairo_pdf
  )
}

log_msg <- function(...) {
  message("[SMC-plot] ", paste(..., collapse = " "))
}

default_path <- function(...) {
  file.path("results", "09_figures", ...)
}

is_true_env <- function(name) {
  tolower(Sys.getenv(name, "false")) %in% c("true", "1", "yes", "y")
}

