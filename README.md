# MycoSNP-WDL Workflow Series

## Quick Facts

| **Workflow Type** | **Applicable Kingdom** | **Last Known Changes** | **Command-line Compatibility** | **Workflow Level** |
|---|---|---|---|---|
| mycosnp_variants | Fungi | v1.5 | Yes | Sample-level |
| mycosnp_tree | Fungi | v1.5 | Yes | Set-level |


## MycoSNP-WDL
WDL wrappers of [CDCGov/mycosnp-nf](https://github.com/CDCgov/mycosnp-nf) designed for [Terra.bio](https://terra.bio) integration. These workflows conduct *Candiozyma (Candida) auris* [variant calling](#wf_mycosnp_variants.wdl) and subsequent single nucleotide polymorphism (SNP) [phylogenetic tree reconstruction](#wf_mycosnp_treewdl).

<br/>

### wf_mycosnp_variants.wdl
`mycosnp_variants` calls variants for inputted reads referencing the *C. auris* B11204 assembly accession [GCA_016772135](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_016772135/) by default. Users can optionally reference a separate *C. auris* clade [data directory](https://github.com/theiagen/mycosnp-wdl/tree/main/data/reference), FASTA, or directory as described below.

Note that `mycosnp_tree` requires at least 4 genomes that reference the same reference in `mycosnp_variants`.

#### Inputs 

- **reference** optionally takes a presupplied reference clade directory delineated [here](https://github.com/theiagen/mycosnp-wdl/tree/main/data/reference). Currently, this option will fail the workflow with "GCA_016772135" set as the reference - use "B11205" instead.
- **ref_fasta** optionally takes a reference FASTA (requires suffix `.fa`) that will be indexed via BWA and generate a reference directory.
- **ref_tar** optionally takes a gzipped tarchive (`.tar.gz`) with the same directory structure as the provided reference clades:

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

- **strain** optionally delineates the strain name for VCF gene name annotation. MycoSNP currently only annotates with respect to the default strain, "B11205", so changing this option will simply bypass VCF annotation.


<div class="searchable-table" markdown="1">

| **Terra Task Name** | **Variable** | **Type** | **Description** | **Default Value** | **Terra Status** |
|---|---|---|---|---|---|
| mycosnp_variants | **read1** | File | Illumina forward read file in FASTQ format (compression optional) | | Required |
| mycosnp_variants | **read2** | File | Illumina reverse read file in FASTQ format (compression optional) | | Required |
| mycosnp_variants | **samplename** | String | Name of sample to be analyzed | | Required |
| mycosnp | **coverage** | Int | Coverage is used to calculate a down-sampling rate that results in the specified coverage. For example, if coverage is 70, then FASTQ files are down-sampled such that, when aligned to the reference, the result is approximately 70x coverage | 0 | Optional |
| mycosnp | **cpu** | Int | Number of CPUs to allocate to the task | 8 | Optional |
| mycosnp | **debug** | Boolean | Keeps `.nextflow/` and `work/` directories | false | Optional |
| mycosnp | **disk_size** | Int | Amount of storage (in GB) to allocate to the task | 100 | Optional |
| mycosnp | **docker** | String | The Docker container to use for the task | "us-docker.pkg.dev/general-theiagen/theiagen/mycosnp:1.5" | Optional |
| mycosnp | **memory** | Int | Amount of memory/RAM (in GB) to allocate to the task | 64 | Optional |
| mycosnp | **min_depth** | Int | Min depth for a base to be called as the consensus sequence, otherwise it will be called as an N; set to 0 to disable | 10 | Optional |
| mycosnp | **reference** | String | Reference clade | "GCA_016772135" | Optional |
| mycosnp | **sample_ploidy** | Int | 1 | Ploidy of sample (GATK) | Optional |
| mycosnp | **strain** | String | Reference strain | "B11205" | Optional |
| mycosnp_variants | **ref_fasta** | File | Reference FASTA file | | Optional |
| mycosnp_variants | **ref_tar** | File | Reference gzipped compressed tarchive | | Optional |
| version_capture | **timezone** | String | Alternative timezone | | Optional |

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
`mycosnp_tree` reconstructs an IQ-TREE SNP phylogenetic tree that incorporates representative genomes of Clade1-Clade5 *C. auris*. VCF data generated from [wf_mycosnp_variants.wdl](#wf_mycosnp_variantswdl) are used as inputs.

#### Inputs

- **reference** optionally takes a presupplied reference clade directory delineated [here](https://github.com/theiagen/mycosnp-wdl/tree/main/data/reference).
- **ref_fasta** optionally takes a reference FASTA (requires suffix `.fa`) that will be indexed via BWA and generate a reference directory.
- **strain** is passed to output but does not change workflow function.

<div class="searchable-table" markdown="1">

| **Terra Task Name** | **Variable** | **Type** | **Description** | **Default Value** | **Terra Status** |
|---|---|---|---|---|---|
| mycosnp_tree | **vcf** | Array[File] | VCF files for analysis |  | Required |
| mycosnp_tree | **vcf_index** | Array[File] | Index files for the VCF files |  | Required |
| mycosnp_tree | **ref_fasta** | File | Reference FASTA input | | Optional |
| mycosnptree | **cpu** | Int | Number of CPUs to allocate to the task | 8 | Optional |
| mycosnptree | **disk_size** | Int | Amount of storage (in GB) to allocate to the task | 100 | Optional |
| mycosnptree | **docker** | String | The Docker container to use for the task | "us-docker.pkg.dev/general-theiagen/theiagen/mycosnp:1.5" | Optional |
| mycosnptree | **memory** | Int | Amount of memory/RAM (in GB) to allocate to the task | 64 | Optional |
| mycosnptree | **reference** | String | Preexisting [reference directory](https://github.com/theiagen/mycosnp-wdl/tree/main/data/reference) | "GCA_016772135" | Optional |
| mycosnptree | **strain** | String | mycosnp-nf reference strain name | "B11205" | Optional |
| version_capture | **timezone** | String | Alternative timezone | | Optional |

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
| mycosnp_tree_version | String | Version of the    `mycosnp_tree` WDL workflow |
| mycosnp_version | String | Version of MycoSNP |
| mycosnptree_snpdists | File | SNP distances file |
| reference_name | String | Name of the reference |
| reference_strain | String | Reference strain used |

</div>