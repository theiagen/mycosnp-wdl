version 1.0

import "../tasks/task_mycosnp_variants.wdl" as mycosnp_nf
import "../tasks/task_versioning.wdl" as versioning

workflow mycosnp_variants {
  meta {
    description: "A WDL wrapper around the qc, processing and variant calling components of mycosnp-nf."
  }
  input {
    File read1
    File read2
    String samplename
    File? ref_tar #Optional user-defined reference tar file
  }
  call mycosnp_nf.mycosnp {
    input:
      read1 = read1,
      read2 = read2,
      samplename = samplename,
      ref_tar = ref_tar
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
    String reference_name = mycosnp.reference_name
    Int reads_before_trimming = mycosnp.reads_before_trimming
    Float gc_before_trimming = mycosnp.gc_before_trimming
    Float average_q_score_before_trimming = mycosnp.average_q_score_before_trimming
    Float reference_length_coverage_before_trimming = mycosnp.reference_length_coverage_before_trimming
    Int reads_after_trimming = mycosnp.reads_after_trimming
    String reads_after_trimming_percent = mycosnp.reads_after_trimming_percent
    Int paired_reads_after_trimming = mycosnp.paired_reads_after_trimming
    String paired_reads_after_trimming_percent = mycosnp.paired_reads_after_trimming_percent
    Int unpaired_reads_after_trimming = mycosnp.unpaired_reads_after_trimming
    String unpaired_reads_after_trimming_percent = mycosnp.unpaired_reads_after_trimming_percent
    Float gc_after_trimming = mycosnp.gc_after_trimming
    Float average_q_score_after_trimming = mycosnp.average_q_score_after_trimming
    Float reference_length_coverage_after_trimming = mycosnp.reference_length_coverage_after_trimming
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