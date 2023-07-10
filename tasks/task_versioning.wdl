version 1.0

task version_capture {
  input {
    String? timezone
  }
  meta {
    volatile: true
  }
  command <<<
    mycosnpwdl_version="mycosnp-wdl v1.5"
    ~{default='' 'export TZ=' + timezone}
    date +"%Y-%m-%d" > TODAY
    echo "${mycosnpwdl_version}" > MYCOSNPWDL_VERSION
  >>>
  output {
    String date = read_string("TODAY")
    String mycosnpwdl_version = read_string("MYCOSNPWDL_VERSION")
  }
  runtime {
    memory: "1 GB"
    cpu: 1
    docker: "quay.io/theiagen/utility:1.1"
    disks: "local-disk 10 HDD"
    dx_instance_type: "mem1_ssd1_v2_x2" 
  }
}
