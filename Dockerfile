# modeled after StaPH-B/docker-builds template
# Software installation, no database files
FROM mambaorg/micromamba:1.4.9

# build and run as root users since micromamba image has 'mambauser' set as the $USER
USER root
# set workdir to default for building; set to /data at the end
WORKDIR /

# Version arguments
# ARG variables only persist during build time
ARG MYCOSNP_SOFTWARE_VERSION="1.6.3"
ARG MYCOSNP_SRC_URL=https://github.com/CDCgov/mycosnp-nf/archive/refs/tags/v${MYCOSNP_SOFTWARE_VERSION}.tar.gz

# metadata labels
LABEL base.image="mambaorg/micromamba:1.4.9"
LABEL dockerfile.version="1"
LABEL software="mycosnp-wdl"
LABEL software.version=${MYCOSNP_SOFTWARE_VERSION}
LABEL description="A WDL wrapper of CDCGov/mycosnp-nf for Terra.bio"
LABEL website="https://github.com/CDCgov/mycosnp-nf"
LABEL license="https://github.com/CDCgov/mycosnp-nf/blob/master/LICENSE"
LABEL maintainer1="Zachary Konkel"
LABEL maintainer.email1="zachary.konkel@theiagen.com"
LABEL maintainer2="Andrew Lang"
LABEL maintainer.email2="andrew.lang@theiagen.com"

# Install references
COPY data/reference/ /reference

# install dependencies; cleanup apt garbage
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  ca-certificates \
  git \
  procps \
  libtiff5 \
  bsdmainutils && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/*

# create environment
COPY env.yaml /tmp/env.yaml
RUN micromamba install -y --name base -f /tmp/env.yaml && \
  micromamba clean -a -y && \
  rm /tmp/env.yaml

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
