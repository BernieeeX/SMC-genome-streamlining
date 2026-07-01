#!/usr/bin/env Rscript

source(file.path("pipeline", "09_figures", "00_smc_plot_config.R"))

args <- commandArgs(trailingOnly = TRUE)
metadata_file <- if (length(args) >= 1) args[[1]] else default_path("input", "metadata_public_safe.tsv")
resistance_file <- if (length(args) >= 2) args[[2]] else default_path("input", "resistance_phenotypes_binary.tsv")
output_file <- if (length(args) >= 3) args[[3]] else default_path("output", "resistance_metadata_heatmap.pdf")

check_input_files(c(metadata_file, resistance_file))
metadata <- read_tsv_safe(metadata_file)
resistance <- read_tsv_safe(resistance_file)

sample_col_md <- intersect(names(metadata), c("sample_id", "Sample", "isolate", "Isolate"))[1]
sample_col_rs <- intersect(names(resistance), c("sample_id", "Sample", "isolate", "Isolate"))[1]
if (any(is.na(c(sample_col_md, sample_col_rs)))) stop("Metadata and resistance tables need sample identifier columns", call. = FALSE)

meta_vars <- intersect(names(metadata), c("Department_group", "Sample_Source", "Sex", "Age_group", "Year"))
res_cols <- setdiff(names(resistance), sample_col_rs)
if (length(meta_vars) == 0 || length(res_cols) == 0) stop("Need at least one metadata column and one resistance column", call. = FALSE)

meta_long <- metadata |>
  select(sample_id = all_of(sample_col_md), all_of(meta_vars)) |>
  pivot_longer(-sample_id, names_to = "metadata_field", values_to = "group")

res_long <- resistance |>
  select(sample_id = all_of(sample_col_rs), all_of(res_cols)) |>
  pivot_longer(-sample_id, names_to = "antibiotic", values_to = "resistant")

summary_tbl <- meta_long |>
  left_join(res_long, by = "sample_id") |>
  group_by(metadata_field, group, antibiotic) |>
  summarise(
    n_resistant = sum(as.numeric(resistant) %in% c(1, 1L), na.rm = TRUE),
    n_total = sum(!is.na(resistant)),
    rate = ifelse(n_total > 0, n_resistant / n_total, NA_real_),
    label = paste0(n_resistant, "/", n_total),
    .groups = "drop"
  )

summary_tbl$group <- factor(summary_tbl$group, levels = unique(summary_tbl$group))

p <- ggplot(summary_tbl, aes(x = antibiotic, y = group, fill = rate)) +
  geom_tile(color = "white", width = 0.95, height = 0.95) +
  geom_text(aes(label = label), size = 3) +
  facet_wrap(~ metadata_field, scales = "free_y") +
  scale_fill_gradient(low = "#F7FBFF", high = "#08519C", na.value = "#F0F0F0") +
  labs(x = NULL, y = NULL, fill = "Rate", title = "Resistance rate by metadata group") +
  smc_theme() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_smc_pdf(p, output_file, width = 11, height = 8)

