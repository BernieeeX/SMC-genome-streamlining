# Input Requirements

## Genome-level inputs

- A FASTA file or a directory of FASTA files for each assembled genome.
- Paired-end reads for assembly and RNA-seq, using the file names described in the example TSV files.
- A reference genome FASTA for the large-deletion and structural-variation branch.
- A GTF file for RNA-seq counting.
- A sample sheet for genome-level inputs and a separate sample sheet for RNA-seq inputs.

## Example tables

- `config/samples.example.tsv`
- `config/rnaseq_samples.example.tsv`

## External databases and indexes

- GTDB-Tk reference data
- CheckM reference data
- Platon database
- BWA and HISAT2 indexes
- ABRicate databases
- WHAM filter script path

## Notes

- Keep all placeholder paths in `config/config.example.sh`.
- Do not store raw sequencing data or private clinical metadata in the repository.
- KleTy and dRep are optional and excluded from the default manuscript workflow.
