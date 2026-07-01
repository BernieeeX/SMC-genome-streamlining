# Workflow

This repository implements the manuscript workflow as numbered stages under `pipeline/`.

```mermaid
flowchart TD
    A["01 Genome assembly"] --> B["02 Contig filtering and QC"]
    B --> C["03 Species assignment and typing"]
    C --> D["04 Genome annotation"]
    D --> E["05 Phylogeny and pangenome"]
    E --> F["06 AMR and virulence annotation"]
    F --> G["07 Plasmid and MGE analysis"]
    G --> H["08 Large deletion and structural variation"]
    H --> I["09 RNA-seq analysis"]
    I --> J["10 Figure generation and reproducibility"]
    E -. optional .-> K["dRep dereplication"]
    C -. optional external .-> L["KleTy Klebsiella typing"]
    H -. optional branch .-> M["Read-mapping SV validation"]
```

Default execution order in `pipeline/run_all.sh` is:

1. Genome assembly
2. Contig filtering and QC
3. Species assignment and typing
4. Genome annotation
5. Panaroo
6. MAFFT
7. AMR and virulence annotation
8. Plasmid and mobile genetic element analysis
9. Large deletion and structural variation analysis
10. RNA-seq analysis
11. Figure generation and reproducibility

Optional scripts are kept outside the default workflow unless explicitly enabled, such as `RUN_DREP=true`.
