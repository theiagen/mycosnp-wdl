# MycoSNP-WDL Workflow Series

## Quick Facts

| **Workflow Type** | **Applicable Kingdom** | **Last Known Changes** | **Command-line Compatibility** | **Workflow Level** |
|---|---|---|---|---|
| MycoSNP-WDL | Fungi | mycosnp-wdl v1.5 | Yes | Sample-level, Set-level |


## MycoSNP-WDL
WDL wrappers of and Terra.bio support for [CDCGov/mycosnp-nf](https://github.com/CDCgov/mycosnp-nf). These workflows conduct *Candiozyma (Candida) auris* [variant calling](#wf_mycosnp_variants.wdl) and subsequent single nucleotide polymorphism (SNP) [phylogenetic tree reconstruction](#wf_mycosnp_treewdl).

<br/>

### wf_mycosnp_variants.wdl
This is a sample-level workflow that calls variants for inputted reads referencing the *C. auris* B11204 assembly accession [GCA_016772135](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_016772135/) by default. Users can optionally reference a separate *C. auris* clade as labeled in the [reference data directory](https://github.com/theiagen/mycosnp-wdl/tree/main/data/reference), supply a reference FASTA (must use suffix `.fa`) that will be indexed via BWA, or provide a gzipped tarchive (`.tar.gz`) with the same directory structure as the provided reference clades:

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
| wf_mycosnp_variants | **read1** | File | Illumina forward read file in FASTQ format (compression optional)  |  | Required |
| wf_mycosnp_variants | **read2** | File | Illumina reverse read file in FASTQ format (compression optional)  |  | Required |
| wf_mycosnp_variants | **samplename** | String | Name of sample to be analyzed |  | Required |
| wf_mycosnp_variants | **ref_tar** | File | Reference tar file | | Optional |
| wf_mycosnp_variants | **fasta** | File | Reference FASTA file | | Optional |

</div>

#### Outputs

<div class="searchable-table" markdown="1">

| **Variable** | **Type** | **Description** |
|---|---|---|
| mycosnp_variants_vcf | File | VCF file with called variants |
| mycosnp_variants_vcf_index | File | Index file for the VCF |
| mycosnp_variants_bam | File | BAM file with aligned reads |
| mycosnp_variants_bam_index | File | Index file for the BAM |
| mycosnp_variants_stats | File | Statistics file for the variant calling |
| mycosnp_variants_version | String | Version of the MycoSNP variants |
| mycosnp_variants_analysis_date | String | Date of the MycoSNP variants analysis |
| mycosnp_version | String | Version of MycoSNP |
| mycosnp_docker | String | Docker image used for MycoSNP |
| analysis_date | String | Date of the analysis |
| reference_strain | String | Reference strain used |
| reference_name | String | Name of the reference |
| reads_before_trimming | Int | Number of reads before trimming |
| gc_before_trimming | Float | GC content before trimming |
| average_q_score_before_trimming | Float | Average quality score before trimming |
| reference_length_coverage_before_trimming | Float | Reference length coverage before trimming |
| reads_after_trimming | Int | Number of reads after trimming |
| reads_after_trimming_percent | String | Percentage of reads after trimming |
| paired_reads_after_trimming | Int | Number of paired reads after trimming |
| paired_reads_after_trimming_percent | String | Percentage of paired reads after trimming |
| unpaired_reads_after_trimming | Int | Number of unpaired reads after trimming |
| unpaired_reads_after_trimming_percent | String | Percentage of unpaired reads after trimming |
| gc_after_trimming | Float | GC content after trimming |
| average_q_score_after_trimming | Float | Average quality score after trimming |
| reference_length_coverage_after_trimming | Float | Reference length coverage after trimming |
| mean_coverage_depth | Float | Mean coverage depth |
| reads_mapped | Int | Number of reads mapped |
| number_n | Int | Number of N bases |
| percent_reference_coverage | Float | Percentage of reference coverage |
| assembly_size | Int | Size of the assembly |
| consensus_n_variant_min_depth | Int | Minimum depth for consensus N variant |
| vcf | File | VCF file |
| vcf_index | File | Index file for the VCF |
| multiqc | File | MultiQC report |
| myco_bam | File | BAM file |
| myco_bam_bai | File | BAM index file |
| full_results | File | Full results file |

</div>

<br/>

### wf_mycosnp_tree.wdl
This workflow reconstructs an IQ-TREE SNP phylogenetic tree that incorporates representative genomes of Clade1-Clade5 *C. auris*. VCF data generated from [wf_mycosnp_variants.wdl](#wf_mycosnp_variantswdl) are used as inputs.

#### Inputs

<div class="searchable-table" markdown="1">

| **Terra Task Name** | **Variable** | **Type** | **Description** | **Default Value** | **Terra Status** |
|---|---|---|---|---|---|
| wf_mycosnp_tree | **vcf** | Array[File] | VCF files for analysis |  | Required |
| wf_mycosnp_tree | **vcf_index** | Array[File] | Index files for the VCF files |  | Required |
| wf_mycosnp_tree | **fasta** | File | Reference FASTA input | | Optional |

</div>

#### Outputs

<div class="searchable-table" markdown="1">

| **Variable** | **Type** | **Description** |
|---|---|---|
| mycosnp_tree_version | String | Version of the MycoSNP-WDL workflow |
| mycosnp_tree_analysis_date | String | Date of the analysis |
| mycosnp_version | String | Version of [MycoSNP-nf](https://github.com/CDCgov/mycosnp-nf/tree/master) used |
| mycosnp_docker | String | Docker image used for MycoSNP |
| reference_strain | String | Reference strain used |
| reference_name | String | Accession number of the reference strain |
| mycosnp_rapidnj_tree | File | RapidNJ tree file |
| mycosnp_fastree_tree | File | FastTree tree file |
| mycosnp_iqtree_tree | File | IQ-TREE tree file |
| mycosnp_alignment | File | Alignment file |
| mycosnptree_snpdists | File | SNP distances file |
| mycosnp_tree_full_results | File | Full results file |
| mycosnp_tree_vcf_csv | File | VCF to CSV file |

</div>