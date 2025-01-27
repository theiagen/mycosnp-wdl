version 1.0

task mycosnp {
  input {
    File read1
    File read2
    String samplename
    String docker = "us-docker.pkg.dev/general-theiagen/theiagen/mycosnp:1.5"
    String strain = "B11205"
    String accession = "GCA_016772135" # Optional, defaults to clade-specific reference
    Int memory = 64
    Int cpu = 8
    Int disk_size = 100
    Int? coverage
    Int? sample_ploidy
    Int min_depth = 10
    Boolean debug = false
  }
  command <<<
    date | tee DATE
    # mycosnp-nf does not have a version output
    echo "mycosnp-nf 1.5" | tee MYCOSNP_VERSION

    # Make sample FOFN
    echo "sample,fastq_1,fastq_2" > sample.csv
    echo "~{samplename},~{read1},~{read2}" >> sample.csv

    # Debug
    export TMP_DIR=${TMPDIR:-/tmp}
    export TMP=${TMPDIR:-/tmp}
    env

    # Run MycoSNP
    mkdir ~{samplename}
    cd ~{samplename}
    if nextflow run /mycosnp-nf/main.nf \
        --input ../sample.csv \
        --ref_dir /reference/~{accession} \
        --publish_dir_mode copy \
        ~{if defined(sample_ploidy) then '--sample_ploidy ' + sample_ploidy else ''} \
        --min_depth ~{min_depth} \
        --skip_phylogeny \
        --tmpdir "${TMPDIR:-/tmp}" \
        --max_cpus ~{cpu} \
        --max_memory "~{memory}.GB" ~{'--coverage ' + coverage}; then
        
      # Everything finished, pack up the results
      if [[ "~{debug}" == "false" ]]; then
        # not in debug mode, clean up
        rm -rf .nextflow/ work/
      fi
      
      cd ..
      genomeCoverageBed -ibam ~{samplename}/results/samples/~{samplename}/finalbam/~{samplename}.bam -d > ~{samplename}/results/samples/~{samplename}/finalbam/~{samplename}.coverage.txt
      tar -cf - ~{samplename}/ | gzip -n --best > ~{samplename}.tar.gz
    else
      # Run failed
      exit 1
    fi

    # QC Metrics
    csvtk transpose -t ~{samplename}/results/stats/qc_report/qc_report.txt > tqc_report.txt
    grep "^Reads Before Trimming" tqc_report.txt | cut -f2 | tee MYCOSNP_READS_BEFORE_TRIMMING
    grep "^GC Before Trimming" tqc_report.txt | cut -f2 | sed 's/%//' | tee MYCOSNP_GC_BEFORE_TRIMMING
    grep "^Average Q Score Before Trimming" tqc_report.txt | cut -f2 | tee MYCOSNP_AVERAGE_Q_SCORE_BEFORE_TRIMMING
    grep "^Reference Length Coverage Before Trimming" tqc_report.txt | cut -f2 | tee MYCOSNP_REFERENCE_LENGTH_COVERAGE_BEFORE_TRIMMING
    grep "^Reads After Trimming" tqc_report.txt | cut -f2 | cut -f1 -d " " | tee MYCOSNP_READS_AFTER_TRIMMING
    grep "^Reads After Trimming" tqc_report.txt | cut -f2 | cut -f2 -d " " | tee MYCOSNP_READS_AFTER_TRIMMING_PERCENT
    grep "^Paired Reads After Trimming" tqc_report.txt | cut -f2 | cut -f1 -d " " | tee MYCOSNP_PAIRED_READS_AFTER_TRIMMING
    grep "^Paired Reads After Trimming" tqc_report.txt | cut -f2 | cut -f2 -d " " | sed -e "s/(//" | tee MYCOSNP_PAIRED_READS_AFTER_TRIMMING_PERCENT
    grep "^Unpaired Reads After Trimming" tqc_report.txt | cut -f2 | cut -f1 -d " " | tee MYCOSNP_UNPAIRED_READS_AFTER_TRIMMING
    grep "^Unpaired Reads After Trimming" tqc_report.txt | cut -f2 | cut -f2 -d " " | sed -e "s/(//" | tee MYCOSNP_UNPAIRED_READS_AFTER_TRIMMING_PERCENT
    grep "^GC After Trimming" tqc_report.txt | cut -f2 | sed 's/%//' | tee MYCOSNP_GC_AFTER_TRIMMING
    grep "^Average Q Score After Trimming" tqc_report.txt | cut -f2 | tee MYCOSNP_AVERAGE_Q_SCORE_AFTER_TRIMMING
    grep "^Reference Length Coverage After Trimming" tqc_report.txt | cut -f2 | tee MYCOSNP_REFERENCE_LENGTH_COVERAGE_AFTER_TRIMMING
    grep "^Mean Coverage Depth" tqc_report.txt | cut -f2 | tee MYCOSNP_MEAN_COVERAGE_DEPTH
    grep "^Reads Mapped" tqc_report.txt | cut -f2 | cut -f1 -d " " | tee MYCOSNP_READS_MAPPED

    # Assembly Metrics
    awk '{if ($3 < ~{min_depth}) {print $0}}' ~{samplename}/results/samples/~{samplename}/finalbam/~{samplename}.coverage.txt | wc -l | tee NUMBER_NS
    wc -l ~{samplename}/results/samples/~{samplename}/finalbam/~{samplename}.coverage.txt | cut -f 1 -d " " | tee ASSEMBLY_SIZE
    echo "($(cat ASSEMBLY_SIZE) - $(cat NUMBER_NS)) / $(cat ASSEMBLY_SIZE) * 100" | xargs -I {} awk 'BEGIN {printf("%.2f\n", {})}' | tee PERCENT_REFERENCE_COVERAGE
  >>>
  output {
    String mycosnp_version = read_string("MYCOSNP_VERSION")
    String mycosnp_docker = docker
    String analysis_date = read_string("DATE")
    String reference_strain = strain
    String reference_accession = accession
    Int reads_before_trimming = read_int("MYCOSNP_READS_BEFORE_TRIMMING")
    Float gc_before_trimming = read_float("MYCOSNP_GC_BEFORE_TRIMMING")
    Float average_q_score_before_trimming = read_float("MYCOSNP_AVERAGE_Q_SCORE_BEFORE_TRIMMING")
    Float reference_length_coverage_before_trimming = read_float("MYCOSNP_REFERENCE_LENGTH_COVERAGE_BEFORE_TRIMMING")
    Int reads_after_trimming = read_int("MYCOSNP_READS_AFTER_TRIMMING")
    String reads_after_trimming_percent = read_string("MYCOSNP_READS_AFTER_TRIMMING_PERCENT")
    Int paired_reads_after_trimming = read_int("MYCOSNP_PAIRED_READS_AFTER_TRIMMING")
    String paired_reads_after_trimming_percent = read_string("MYCOSNP_PAIRED_READS_AFTER_TRIMMING_PERCENT")
    Int unpaired_reads_after_trimming = read_int("MYCOSNP_UNPAIRED_READS_AFTER_TRIMMING")
    String unpaired_reads_after_trimming_percent = read_string("MYCOSNP_UNPAIRED_READS_AFTER_TRIMMING_PERCENT")
    Float gc_after_trimming = read_float("MYCOSNP_GC_AFTER_TRIMMING")
    Float average_q_score_after_trimming = read_float("MYCOSNP_AVERAGE_Q_SCORE_AFTER_TRIMMING")
    Float reference_length_coverage_after_trimming = read_float("MYCOSNP_REFERENCE_LENGTH_COVERAGE_AFTER_TRIMMING")
    Float mean_coverage_depth = read_float("MYCOSNP_MEAN_COVERAGE_DEPTH")
    Int reads_mapped = read_int("MYCOSNP_READS_MAPPED")
    Int number_n = read_int("NUMBER_NS")
    Float percent_reference_coverage = read_float("PERCENT_REFERENCE_COVERAGE")
    Int assembly_size = read_int("ASSEMBLY_SIZE")
    Int consensus_n_variant_min_depth = min_depth
    File vcf = "~{samplename}/results/samples/~{samplename}/variant_calling/haplotypecaller/~{samplename}.g.vcf.gz"
    File vcf_index = "~{samplename}/results/samples/~{samplename}/variant_calling/haplotypecaller/~{samplename}.g.vcf.gz.tbi"
    File multiqc = "~{samplename}/results/multiqc/multiqc_report.html"
    File bam_file = "~{samplename}/results/samples/~{samplename}/finalbam/~{samplename}.bam"
    File bam_bai_file = "~{samplename}/results/samples/~{samplename}/finalbam/~{samplename}.bam.bai"
    File full_results = "~{samplename}.tar.gz"
  }
  runtime {
    docker: "~{docker}"
    memory: "~{memory} GB"
    cpu: cpu
    disks:  "local-disk ~{disk_size} SSD"
    maxRetries: 3
    preemptible: 0
  }
}