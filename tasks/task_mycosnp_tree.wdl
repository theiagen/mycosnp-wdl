version 1.0

task mycosnptree {
  input {
    Array[File] vcf
    Array[File] vcf_index
    String docker = "quay.io/theiagen/mycosnp:1.4"
    String strain = "B11205" # this is not used by the NF pipeline as an input but internally is the reference strain
    String reference = "GCA_016772135" # Optional, defaults to accession reference 
    Int disk_size = 50
    Int cpu = 4
    Int memory = 32
    Int sample_ploidy
    Int min_depth = 10
    # Optional: User-provided reference tar file or fasta file
    File? ref_tar
    File? fasta
    # Phylogenetic tree options
    Boolean iqtree = true
    Boolean fasttree = true
    Boolean rapidnj = true
  }
  command <<<
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

   # Set reference FASTA
    if [[ -n "~{fasta}" && -f "~{fasta}" ]]; then 
        echo "Using user-provided FASTA: ~{fasta}" 
        cp ~{fasta} /reference/custom_ref.fa 
        ref_param="--fasta /reference/custom_ref.fa"
        ref_name="custom_ref.fa"
    else 
        echo "Using built-in reference: /reference/~{reference}.fa"
        ref_param="--fasta /reference/~{reference}.fa"
        ref_name="~{reference}.fa"
    fi 

    echo "$ref_name" | tee REFERENCE_NAME  # Save reference name for output
    echo "Final reference param: $ref_param"  # Log reference parameter

    # Debug
    export TMP_DIR=${TMPDIR:-/tmp}
    export TMP=${TMPDIR:-/tmp}
    env

    # Run MycoSNP
    mkdir mycosnptree
    cd mycosnptree
    if nextflow run /mycosnp-nf/main.nf \
        --add_vcf_file ../samples.csv \
        $ref_param \
        ~{if iqtree then '--iqtree' else ''} \
        ~{if fasttree then '--fasttree' else ''} \
        ~{if rapidnj then '--rapidnj' else ''} \
        --publish_dir_mode copy \
        --max_cpus ~{cpu} \
        --max_memory ~{memory}GB \
        --sample_ploidy ~{sample_ploidy} \
        --min_depth ~{min_depth} \
        --tmpdir ${TMPDIR:-/tmp}; then
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
    String reference_name = read_string("REFERENCE_NAME")
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
