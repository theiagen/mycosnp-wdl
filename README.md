# MycoSNP-WDL Workflow Series

## Quick Facts

| **Workflow Type** | **Applicable Kingdom** | **Last Known Changes** | **Command-line Compatibility** | **Workflow Level** |
|---|---|---|---|---|
| MycoSNP-WDL | Fungi | mycosnp-wdl v1.5 | Yes | Sample-level, Set-level |

## MycoSNP-WDL
WDL wrappers of [CDCGov/mycosnp-nf](https://github.com/CDCgov/mycosnp-nf) for *Candiozyma (Candida) auris* variant calling and single nucleotide polymorphism (SNP) phylogenetic tree reconstruction.

### wf_mycosnp_variants.wdl

#### Inputs

<div class="searchable-table" markdown="1">

| **Terra Task Name** | **Variable** | **Type** | **Description** | **Default Value** | **Terra Status** |
|---|---|---|---|---|---|
| wf_mycosnp_variants | **read1** | File | Illumina forward read file in FASTQ format (compression optional)  |  | Required |
| wf_mycosnp_variants | **read2** | File | Illumina reverse read file in FASTQ format (compression optional)  |  | Required |
| wf_mycosnp_variants | **samplename** | String | Name of sample to be analyzed |  | Required |
| wf_mycosnp_variants | **strain** | String | Name of reference strain | "B11205" | Optional |
| wf_mycosnp_variants | **accession** | String | Accession number of reference strain | "GCA_016772135" | Optional |

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

</div>

### wf_mycosnp_tree.wdl

#### Inputs

<div class="searchable-table" markdown="1">

| **Terra Task Name** | **Variable** | **Type** | **Description** | **Default Value** | **Terra Status** |
|---|---|---|---|---|---|
| wf_mycosnp_tree | **vcf** | Array[File] | VCF files for analysis |  | Required |
| wf_mycosnp_tree | **vcf_index** | Array[File] | Index files for the VCF files |  | Required |
| wf_mycosnp_tree | **strain** | String | Name of reference strain | "B11205" | Optional |
| wf_mycosnp_tree | **accession** | String | Accession number of reference strain | "GCA_016772135" | Optional |

</div>

#### Outputs

<div class="searchable-table" markdown="1">

| **Variable** | **Type** | **Description** |
|---|---|---|
| mycosnp_tree_version | String | Version of the MycoSNP-WDL workflow |
| mycosnp_tree_analysis_date | String | Date of the analysis |
| mycosnp_version | String | Version of [MycoSNP-nf](https://github.com/CDCgov/mycosnp-nf/tree/master) used |
| mycosnp_docker | String | Docker image used for MycoSNP |
| analysis_date | String | Date of the analysis |
| reference_strain | String | Reference strain used |
| reference_accession | String | Accession number of the reference strain |
| mycosnp_rapidnj_tree | File | RapidNJ tree file |
| mycosnp_fastree_tree | File | FastTree tree file |
| mycosnp_iqtree_tree | File | IQ-TREE tree file |
| mycosnp_alignment | File | Alignment file |
| mycosnptree_snpdists | File | SNP distances file |
| mycosnp_tree_full_results | File | Full results file |
| mycosnp_tree_vcf_csv | File | VCF to CSV file |

</div>