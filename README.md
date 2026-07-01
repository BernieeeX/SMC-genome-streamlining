# SMC Project Pipeline

This repository packages the bioinformatics workflow used for the SMC manuscript project into a clean, reproducible structure. It is a manuscript-associated reproducible workflow: the original scripts are preserved under `raw_scripts/` as a provenance archive, and the cleaned active workflow lives under `pipeline/`.

## Purpose

The repository provides a manuscript-aligned analysis pipeline for genome assembly, quality control, species typing, annotation, pangenome analysis, AMR/virulence annotation, plasmid and mobile genetic element analysis, large-deletion analysis, RNA-seq analysis, and figure generation.

## Pipeline Overview

1. Genome assembly
2. Contig filtering and assembly quality control
3. Species assignment and typing
4. Genome annotation
5. Phylogeny and pangenome analysis
6. AMR and virulence gene annotation
7. Plasmid and mobile genetic element analysis
8. Large deletion and structural variation analysis
9. RNA-seq mapping and differential expression analysis
10. Figure generation and reproducibility

## Repository Structure

- `pipeline/` - cleaned active workflow and `run_all.sh`
- `config/` - example configuration and sample sheets
- `docs/` - workflow, input, output, and manuscript-mapping notes
- `raw_scripts/` - provenance archive, kept unchanged

## Required Software

The pipeline assumes a Unix-like shell environment with:

- `bash`
- `python 3`
- `perl`
- `awk`
- `pandas`
- `samtools`
- `bwa`
- `fastp`
- `hisat2`
- `featureCounts`
- `quast.py`
- `checkm`
- `gtdbtk`
- `mlst`
- `prokka`
- `mafft`
- `panaroo`
- `abricate`
- `sourmash`
- `platon`
- `mgefinder`
- `spades.py`
- `nucmer`, `show-snps`, `show-tiling`
- `gatk`
- `whamg`
- `R` with `DESeq2`

If you use Conda, edit `config/config.example.sh` to point to your local `CONDA_SH` and environment names.

Optional scripts such as dRep dereplication and KleTy Klebsiella typing are not part of the default manuscript workflow.

## Input File Format

Use the example tables in `config/` as templates:

- `config/samples.example.tsv` for genome-level inputs
- `config/rnaseq_samples.example.tsv` for RNA-seq inputs

The tables contain placeholder paths only. Replace them with your local file locations and keep sensitive or patient-level metadata out of the repository.

## How To Run

1. Copy `config/config.example.sh` to `config/config.sh`.
2. Edit the paths, environment names, and database locations.
3. Populate your own `samples.tsv` and `rnaseq_samples.tsv` files from the examples.
4. Run the workflow from the repository root:

```bash
bash pipeline/run_all.sh
```

You can also run individual modules, for example:

```bash
bash pipeline/03_annotation/01_run_prokka.sh
bash pipeline/05_amr_virulence/01_run_abricate.sh
Rscript pipeline/08_rnaseq/04_run_deseq2.R results/08_rnaseq/counts/featureCounts.tsv config/rnaseq_samples.tsv results/08_rnaseq/deseq2
```

## Expected Outputs

Outputs are written under `results/` by module:

- assembly and QC summaries
- taxonomy and typing tables
- Prokka annotations
- Panaroo pangenomes and MAFFT alignments
- ABRicate and VFDB/CARD summary tables
- Platon, MGEFinder, and SPAdes plasmid outputs
- large-deletion and WHAM intermediate files
- RNA-seq BAM files, count tables, and DESeq2 results
- figure PDFs for manuscript-ready reporting

## Citation and Manuscript Association

This repository corresponds to the SMC manuscript analysis workflow. Cite the manuscript and the relevant third-party tools used in each module when publishing results derived from this pipeline.

## Data Availability Note

No raw sequencing data, patient-level clinical metadata, unpublished sensitive tables, or other restricted materials are stored in this repository. Only placeholder paths and reproducible pipeline code are included.
