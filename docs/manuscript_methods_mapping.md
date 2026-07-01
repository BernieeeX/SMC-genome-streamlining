# Manuscript Methods Mapping

## Default workflow

| Manuscript method | Raw source | Pipeline script(s) |
|---|---|---|
| Genome assembly | `raw_scripts/metawrap_assembly.sh` | `pipeline/01_assembly_qc/01_metawrap_assembly.sh` |
| Contig filtering and QC | `raw_scripts/run_checkm.sh` | `pipeline/01_assembly_qc/02_filter_contigs_1kb.sh`, `pipeline/01_assembly_qc/03_run_quast.sh`, `pipeline/01_assembly_qc/04_run_checkm.sh` |
| Species assignment and typing | `raw_scripts/run_mash.sh`, `raw_scripts/gtdb.sh` | `pipeline/02_species_typing/01_run_mash.sh`, `pipeline/02_species_typing/02_gtdb.sh`, `pipeline/02_species_typing/03_run_mlst.sh` |
| Genome annotation | `raw_scripts/run_prokka.sh` | `pipeline/03_annotation/01_run_prokka.sh` |
| Phylogeny and pangenome analysis | `raw_scripts/run_panaroo.sh`, `raw_scripts/run_mafft.sh` | `pipeline/04_phylogeny_pangenome/01_run_panaroo.sh`, `pipeline/04_phylogeny_pangenome/02_run_mafft.sh` |
| AMR and virulence gene annotation | `raw_scripts/run_abricate.sh`, `raw_scripts/vfbd_run.sh`, `raw_scripts/merge_abricate_long.py`, `raw_scripts/merge_vfdb_long.py` | `pipeline/05_amr_virulence/01_run_abricate.sh`, `pipeline/05_amr_virulence/02_run_vfdb.sh`, `pipeline/05_amr_virulence/03_merge_abricate_long.py`, `pipeline/05_amr_virulence/04_merge_vfdb_long.py` |
| Plasmid and mobile genetic element analysis | `raw_scripts/run_platon.sh`, `raw_scripts/run_mgefinder.sh`, `raw_scripts/run_spades_plasmid.sh` | `pipeline/06_plasmid_mge/01_run_platon.sh`, `pipeline/06_plasmid_mge/02_run_mgefinder.sh`, `pipeline/06_plasmid_mge/03_run_spades_plasmid.sh` |
| Large deletion and structural variation analysis | `raw_scripts/run_mummer.sh`, `raw_scripts/large_del/*` | `pipeline/07_large_deletion/01_assembly_based_mummer/01_run_mummer.sh`, `pipeline/07_large_deletion/01_assembly_based_mummer/02_summarise_large_deletions.py`, `pipeline/07_large_deletion/01_assembly_based_mummer/03_copy_txt_files.py`, `pipeline/07_large_deletion/02_read_mapping_sv_validation/*` |
| RNA-seq mapping and differential expression analysis | Newly generated wrappers | `pipeline/08_rnaseq/01_run_fastp.sh`, `pipeline/08_rnaseq/02_run_hisat2.sh`, `pipeline/08_rnaseq/03_run_featurecounts.sh`, `pipeline/08_rnaseq/04_run_deseq2.R` |
| Figure generation and reproducibility | Newly generated templates | `pipeline/09_figures/01_plot_qc_summary.R`, `pipeline/09_figures/02_plot_amr_summary.R`, `pipeline/09_figures/03_plot_rnaseq_volcano.R`, `pipeline/09_figures/04_plot_large_deletion_summary.R` |

## Optional or excluded scripts

| Status | Raw source | Pipeline script | Note |
|---|---|---|---|
| Optional | `raw_scripts/run_drep.sh` | `pipeline/04_phylogeny_pangenome/03_run_drep_optional.sh` | Runs only when `RUN_DREP=true` |
| Optional external | `raw_scripts/run_klety.sh` | `pipeline/99_optional_external/run_klety_klebsiella_only.sh` | Klebsiella-specific; not part of the default SMC workflow |
| Optional, module-internal | `raw_scripts/large_del/*` | `pipeline/07_large_deletion/02_read_mapping_sv_validation/*` | Read-mapping validation branch separated from the assembly-based MUMmer branch |
