# modeled after StaPH-B/docker-builds template
# Software installation, no database files
FROM mambaorg/micromamba:0.27.0

# build and run as root users since micromamba image has 'mambauser' set as the $USER
USER root
# set workdir to default for building; set to /data at the end
WORKDIR /

# Version arguments
# ARG variables only persist during build time
ARG MYCOSNP_SOFTWARE_VERSION="1.4"
ARG MYCOSNP_SRC_URL=https://github.com/CDCgov/mycosnp-nf/archive/refs/tags/v${MYCOSNP_SOFTWARE_VERSION}.tar.gz

# metadata labels
LABEL base.image="nfcore/base:2.1"
LABEL dockerfile.version="1"
LABEL software="mycosnp-wdl"
LABEL software.version=${MYCOSNP_SOFTWARE_VERSION}
LABEL description="A WDL wrapper of CDCGov/mycosnp-nf for Terra.bio"
LABEL website="https://github.com/CDCgov/mycosnp-nf"
LABEL license="https://github.com/CDCgov/mycosnp-nf/blob/master/LICENSE"
LABEL maintainer1="Robert A. Petit III"
LABEL maintainer.email1="robert.petit@theiagen.com"
LABEL maintainer2="Kevin Libuit"
LABEL maintainer.email2="kevin.libuit@theiagen.com"

# Install references
COPY data/reference/ /reference

# install dependencies; cleanup apt garbage
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  ca-certificates \
  git \
  procps \
  bsdmainutils && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/*

RUN micromamba install -y --name base -c conda-forge -c bioconda -c defaults \
    'bioconda::bcftools==1.14' \
    'bioconda::bedtools==2.30.0' \
    'bioconda::bwa==0.7.17' \
    'bioconda::csvtk==0.23.0' \
    'bioconda::faqcs==2.10' \
    'bioconda::fastqc==0.11.9' \
    'bioconda::fasttree==2.1.10' \
    'bioconda::gatk4==4.2.5.0' \
    'bioconda::iqtree==2.1.4_beta' \
    'bioconda::multiqc==1.11' \
    'bioconda::mummer==3.23' \
    'bioconda::nextflow==22.04.0' \
    'bioconda::picard==2.26.10' \
    'bioconda::qualimap==2.2.2d' \
    'bioconda::rapidnj==2.3.2' \
    'bioconda::raxml-ng==1.0.3' \
    'bioconda::samtools==1.15' \
    'bioconda::seqkit==2.1.0' \
    'bioconda::seqtk==1.3' \
    'bioconda::snp-dists==0.8.2' \
    'bioconda::sra-tools==2.11.0' \
    'conda-forge::biopython==1.78' \
    'conda-forge::coreutils==9.0' \
    'conda-forge::openjdk==11.0.8' \
    'conda-forge::pandas==1.1.5' \
    'conda-forge::pigz==2.6' \
    'conda-forge::scipy==1.8.0' \
    'conda-forge::sed==4.7' && \
    micromamba clean -a -y

# get the mycosnp-nf latest release
RUN wget --quiet "${MYCOSNP_SRC_URL}" && \
 tar -xf v${MYCOSNP_SOFTWARE_VERSION}.tar.gz && \
 rm v${MYCOSNP_SOFTWARE_VERSION}.tar.gz && \
 mv -v mycosnp-nf-${MYCOSNP_SOFTWARE_VERSION} mycosnp-nf

# set the environment, add base conda/micromamba bin directory into path
# set locale settings to UTF-8
# set the environment, put new conda env in PATH by default
ENV PATH="/opt/conda/bin:${PATH}" \
  LC_ALL=C.UTF-8

# set final working directory to /data
WORKDIR /data
