# MycoSNP-WDL Workflow Series

## Quick Facts

| **Workflow Type** | **Applicable Kingdom** | **Last Known Changes** | **Command-line Compatibility** | **Workflow Level** |
|---|---|---|---|---|
| MycoSNP-WDL | Fungi | mycosnp-wdl v1.5 | Yes | Sample-level, Set-level |


## MycoSNP-WDL
WDL wrappers of and Terra.bio support for [CDCGov/mycosnp-nf](https://github.com/CDCgov/mycosnp-nf). These workflows conduct *Candiozyma (Candida) auris* [variant calling](#wf_mycosnp_variants.wdl) and subsequent single nucleotide polymorphism (SNP) [phylogenetic tree reconstruction](#wf_mycosnp_treewdl).

<br/>

### wf_mycosnp_variants.wdl
`mycosnp_variants` is a Terra sample-level workflow that calls variants for inputted reads referencing the *C. auris* B11204 assembly accession [GCA_016772135](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_016772135/) by default. Users can optionally reference a separate *C. auris* clade as labeled in the [reference data directory](https://github.com/theiagen/mycosnp-wdl/tree/main/data/reference), supply a reference FASTA (must use suffix `.fa`) that will be indexed via BWA, or provide a gzipped tarchive (`.tar.gz`) with the same directory structure as the provided reference clades:

```
data/reference
├── B11221
├── Clade1
│   ├── bwa
|   |   ├── bwa 
|   |   |   ├── reference.am
|   |   |   ├── reference.ann
|   |   |   ├── reference.bwt
|   |   |   ├── reference.pac
|   |   |   └── reference.sa
│   ├── dict
|   |   └── reference.dict
│   ├── fai
|   |   └── reference.fa.fai
│   ├── masked
|   |   └── reference.fa
│   └── Clade1.fasta
├── Clade2
├── Clade3
├── Clade4
├── Clade5
└── GCA_016772135
```


#### Inputs

<div class="searchable-table" markdown="1">

| **Terra Task Name** | **Variable** | **Type** | **Description** | **Default Value** | **Terra Status** |
|---|---|---|---|---|---|
| mycosnp_variants | **read1** | File | Illumina forward read file in FASTQ format (compression optional) | | Required |
| mycosnp_variants | **read2** | File | Illumina reverse read file in FASTQ format (compression optional) | | Required |
| mycosnp_variants | **samplename** | String | Name of sample to be analyzed | | Required |
| mycosnp_variants | **ref_tar** | File | Reference tar file | | Optional |
| mycosnp_variants | **fasta** | File | Reference FASTA file | | Optional |
| mycosnp | **coverage** | Int | {…} | | Optional |
| mycosnp | **cpu** | Int | {…} | | Optional |
| mycosnp | **debug** | Boolean | {…} | | Optional |
| mycosnp | **disk_size** | Int | {…} | | Optional |
| mycosnp | **docker** | String | {…} | | Optional |
| mycosnp | **memory** | Int | {…} | | Optional |
| mycosnp | **min_depth** | Int | {…} | | Optional |
| mycosnp | **reference** | String | {…} | | Optional |
| mycosnp | **sample_ploidy** | Int | {…} | | Optional |
| mycosnp | **strain** | String | {…} | | Optional |
| version_capture | **timezone** | String | {…} | | Optional |

</div>

#### Outputs

<div class="searchable-table" markdown="1">

| **Variable** | **Type** | **Description** |
|---|---|---|
| analysis_date | String | Date of the analysis |
| assembly_size | Int | Size of the assembly |
| average_q_score_after_trimming | Float | Average quality score after trimming |
| average_q_score_before_trimming | Float | Average quality score before trimming |
| consensus_n_variant_min_depth | Int | Minimum depth for consensus N variant |
| full_results | File | Full results file |
| gc_after_trimming | Float | GC content after trimming |
| gc_before_trimming | Float | GC content before trimming |
| mean_coverage_depth | Float | Mean coverage depth |
| multiqc | File | MultiQC report |
| myco_bam | File | BAM file |
| myco_bam_bai | File | BAM index file |
| mycosnp_docker | String | Docker image used for MycoSNP |
| mycosnp_variants_analysis_date | String | Date of the MycoSNP variants analysis |
| mycosnp_variants_version | String | Version of the MycoSNP variants |
| mycosnp_version | String | Version of MycoSNP |
| number_n | Int | Number of N bases |
| paired_reads_after_trimming | Int | Number of paired reads after trimming |
| paired_reads_after_trimming_percent | String | Percentage of paired reads after trimming |
| percent_reference_coverage | Float | Percentage of reference coverage |
| reads_after_trimming | Int | Number of reads after trimming |
| reads_after_trimming_percent | String | Percentage of reads after trimming |
| reads_before_trimming | Int | Number of reads before trimming |
| reads_mapped | Int | Number of reads mapped |
| reference_length_coverage_after_trimming | Float | Reference length coverage after trimming |
| reference_length_coverage_before_trimming | Float | Reference length coverage before trimming |
| reference_name | String | Name of the reference |
| reference_strain | String | Reference strain used |
| unpaired_reads_after_trimming | Int | Number of unpaired reads after trimming |
| unpaired_reads_after_trimming_percent | String | Percentage of unpaired reads after trimming |
| vcf | File | VCF file |
| vcf_index | File | Index file for the VCF |

</div>

<br/>

### wf_mycosnp_tree.wdl
`mycosnp_tree` is a Terra set-level workflow reconstructs an IQ-TREE SNP phylogenetic tree that incorporates representative genomes of Clade1-Clade5 *C. auris*. VCF data generated from [wf_mycosnp_variants.wdl](#wf_mycosnp_variantswdl) are used as inputs.

#### Inputs

- **ref_fasta** will generate a new reference directory

- **strain** is passed to output but does not change workflow function

<div class="searchable-table" markdown="1">

| **Terra Task Name** | **Variable** | **Type** | **Description** | **Default Value** | **Terra Status** |
|---|---|---|---|---|---|
| mycosnp_tree | **vcf** | Array[File] | VCF files for analysis |  | Required |
| mycosnp_tree | **vcf_index** | Array[File] | Index files for the VCF files |  | Required |
| mycosnp_tree | **ref_fasta** | File | Reference FASTA input | | Optional |
| mycosnptree | **cpu** | Int | CPU cores | 4 | Optional |
| mycosnptree | **disk_size** | Int | Disk size (GB) | 50 | Optional |
| mycosnptree | **docker** | String | "us-docker.pkg.dev/general-theiagen/theiagen/mycosnp:1.5" | | Optional |
| mycosnptree | **memory** | Int | RAM (GB) | 32 | Optional |
| mycosnptree | **reference** | String | Preexisting [reference directory](https://github.com/theiagen/mycosnp-wdl/tree/main/data/reference) | "GCA_016772135" | Optional |
| mycosnptree | **strain** | String | mycosnp-nf reference strain name | "B11205" | Optional |
| version_capture | **docker** | String | "us-docker.pkg.dev/general-theiagen/theiagen/mycosnp:1.5" | | Optional |

</div>

#### Outputs

<div class="searchable-table" markdown="1">

| **Variable** | **Type** | **Description** |
|---|---|---|
| mycosnp_alignment | File | Alignment file |
| mycosnp_docker | String | Docker image used for MycoSNP |
| mycosnp_fastree_tree | File | FastTree tree file |
| mycosnp_iqtree_tree | File | IQ-TREE tree file |
| mycosnp_rapidnj_tree | File | RapidNJ tree file |
| mycosnp_tree_analysis_date | String | Date of the analysis |
| mycosnp_tree_full_results | File | Full results file |
| mycosnp_tree_vcf_csv | File | VCF to CSV file |
| mycosnp_tree_version | String | Version of the MycoSNP-WDL workflow |
| mycosnp_version | String | Version of MycoSNP |
| mycosnptree_snpdists | File | SNP distances file |
| reference_name | String | Name of the reference |
| reference_strain | String | Reference strain used |

</div>