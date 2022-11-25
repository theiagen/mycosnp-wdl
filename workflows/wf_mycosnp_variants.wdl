version 1.0

import "../tasks/task_mycosnp_variants.wdl" as mycosnp_nf
import "../tasks/task_versioning.wdl" as versioning

workflow mycosnp_variants {
  meta {
    description: "A WDL wrapper around the qc, processing and variant calling components of mycosnp-nf."
  }
  input {
    File    read1
    File    read2
    String  samplename
  }
  call mycosnp_nf.mycosnp {
    input:
      read1 = read1,
      read2 = read2,
      samplename = samplename
  }
  call versioning.version_capture{
    input:
  }
  output {
    #Version Captures
    String mycosnp_variants_version = version_capture.mycosnpwdl_version
    String mycosnp_variants_analysis_date = version_capture.date
    #MycoSNP QC and Assembly
    String mycosnp_version = mycosnp.mycosnp_version
    String mycosnp_docker = mycosnp.mycosnp_docker
    String analysis_date = mycosnp.analysis_date
    String reference_strain = mycosnp.reference_strain
    String reference_accession = mycosnp.reference_accession
    Int read_raw = mycosnp.read_raw
    Float gc_raw = mycosnp.gc_raw
    Float phred_raw = mycosnp.phred_raw
    Float coverage_raw = mycosnp.coverage_raw
    Int read_clean = mycosnp.read_clean
    Int read_pairs_clean = mycosnp.read_pairs_clean
    Int read_unpaired_clean = mycosnp.read_unpaired_clean
    Float gc_clean = mycosnp.gc_clean
    Float phred_clean = mycosnp.phred_clean
    Float coverage_clean = mycosnp.coverage_clean
    Float mean_coverage_depth = mycosnp.mean_coverage_depth
    Int reads_mapped = mycosnp.reads_mapped
    Int number_n = mycosnp.number_n
    Float percent_reference_coverage = mycosnp.percent_reference_coverage
    Int assembly_size = mycosnp.assembly_size
    Int consensus_n_variant_min_depth = mycosnp.consensus_n_variant_min_depth
    File vcf = mycosnp.vcf
    File vcf_index = mycosnp.vcf_index
    File multiqc = mycosnp.multiqc
    File myco_bam = mycosnp.bam_file
    File myco_bam_bai = mycosnp.bam_bai_file
    File full_results = mycosnp.full_results
  }
}
