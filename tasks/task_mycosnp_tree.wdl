version 1.0

task mycosnptree {
  input {
    Array[File] vcf
    Array[File] vcf_index
    String docker="quay.io/theiagen/mycosnp:1.4" # this doesnt match the 1.5 version in the command
    String strain="B11205" # Optional, defaults to clade-specific reference 
    String accession="GCA_016772135" # Optional, defaults to clade-specific reference 
    Int disk_size = 50
    Int cpu = 4
    Int memory = 32
    Int? sample_ploidy
  }
  command <<<
    set -euo pipefail

    date | tee DATE
    # mycosnp-nf does not have a version output
    echo "mycosnp-nf 1.5" | tee MYCOSNPTREE_VERSION

    vcf_array=(~{sep=' ' vcf})
    vcf_array_len=$(echo "${#vcf[@]}")
    vcf_index_array=(~{sep=' ' vcf_index})
    vcf_index_array_len=$(echo "${#vcf_index[@]}")

    # Ensure vcf, vcf_index, and samplename arrays are of equal length
    if [ "$vcf_array_len" -ne "$vcf_index_array_len" ]; then
      echo "VCF array (length: $vcf_array_len) and VCF index array (length: $vcf_index_array_len) are of unequal length." >&2
      exit 1
    fi

    # Make sample FOFN
    touch samples.csv
    for index in ${!vcf_array[@]}; do
      vcf=${vcf_array[$index]}
      echo -e "${vcf}" >> samples.csv
    done

    # Debug
    export TMP_DIR=${TMPDIR:-/tmp}
    export TMP=${TMPDIR:-/tmp}
    env

    # Run MycoSNP
    mkdir mycosnptree
    cd mycosnptree
    if nextflow run /mycosnp-nf/main.nf \
        --add_vcf_file ../samples.csv \
        --ref_dir /reference/~{accession} \
        --strain ~{strain} \
        ~{if defined(sample_ploidy) then '--sample_ploidy ' + sample_ploidy else ''} \
        --iqtree \
        --publish_dir_mode copy \
        --max_cpus ~{cpu} \
        --tmpdir ${TMPDIR:-/tmp}; then
      # Everything finished, pack up the results and clean up
      rm -rf .nextflow/ work/
      cd ..
      tar -cf - mycosnptree/ | gzip -n --best  > mycosnptree.tar.gz
    else
      # Run failed
      exit 1
    fi
  >>>
  output {
    String mycosnptree_version = read_string("MYCOSNPTREE_VERSION")
    String mycosnptree_docker = docker
    String analysis_date = read_string("DATE")
    String reference_strain = strain
    String reference_accession = accession
    File mycosnptree_rapidnj_tree = "mycosnptree/results/combined/phylogeny/rapidnj/rapidnj_phylogeny.nh"
    File mycosnptree_fasttree_tree = "mycosnptree/results/combined/phylogeny/fasttree/fasttree_phylogeny.nh"
    File mycosnptree_iqtree_tree = "mycosnptree/results/combined/phylogeny/iqtree/iqtree_phylogeny.nh"
    File mycosnptree_alignment = "mycosnptree/results/combined/vcf-to-fasta/vcf-to-fasta.fasta"
    File mycosnptree_snpdists = "mycosnptree/results/combined/snpdists/combined.tsv"
    File mycosnptree_full_results = "mycosnptree.tar.gz"
    File mycosnptree_vcf_csv = "samples.csv"
  }
  runtime {
    docker: "~{docker}"
    memory: "~{memory} GB"
    cpu: cpu
    disks: "local-disk " + disk_size + " SSD"
    maxRetries: 3
    preemptible: 0
  }
}
