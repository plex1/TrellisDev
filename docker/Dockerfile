#
# trellisDev Dockerfile
#

# Pull base image
FROM ubuntu:18.04

# Set the maintainer
MAINTAINER Felix Arnold (plex1) <felix.arnold@gmail.com>

# Global arguments
ARG USER=trellisdev
ARG USERPWD=trellisdev 
ARG WORKDIR=/home/trellisdev
ARG ROOTPWD=trellisdev

# Set frontend required for docker
ENV DEBIAN_FRONTEND noninteractive

####### Packages #######################################
# Install some base tools
RUN apt-get update && apt-get install -y \
  apt-utils \
  sudo \
  unzip \
  wget \  
  nano \
  git 

 

####### Linux ##########################################

# Change root password
RUN echo "root:${ROOTPWD}" | chpasswd

# Create the default user
RUN useradd -m -s /bin/bash -d ${WORKDIR} ${USER}
RUN echo "${USER}:${USERPWD}" | chpasswd
RUN adduser ${USER} sudo

# Customize terminal
RUN echo 'RESET="\[$(tput sgr0)\]"' >> $WORKDIR/.bashrc
RUN echo 'GREEN="\[$(tput setaf 2)\]"' >> $WORKDIR/.bashrc 
RUN echo 'export PS1="${GREEN}\u:\W${RESET} $ "' >> $WORKDIR/.bashrc


# Install verilator
# Verilator
RUN apt-get update && apt-get install -y \
  verilator \
  libevent-dev\
  libjson-c-dev 

####### RICSV #############################################
# 64 bit version

USER root

# Make a working folder and set the necessary environment variables.
ENV RISCV /opt/riscv
ENV NUMJOBS 1


# Add the GNU utils bin folder to the path.
ENV PATH $RISCV/bin:$PATH
RUN echo 'export PATH=/opt/riscv/bin:$PATH' >> $WORKDIR/.bashrc

# Set the version variables
ARG RISCV_GCC_VER=riscv64-unknown-elf-gcc-8.1.0-2019.01.0-x86_64-linux-ubuntu14

WORKDIR /opt

# Download pre-built gcc compiler
RUN wget https://static.dev.sifive.com/dev-tools/$RISCV_GCC_VER.tar.gz -q && \
    tar -xzvf $RISCV_GCC_VER.tar.gz && \
    mv $RISCV_GCC_VER /opt/riscv && \
    rm $RISCV_GCC_VER.tar.gz

# Run a simple test to make sure compile is setup corretly
RUN mkdir -p $RISCV/test
WORKDIR $RISCV/test
RUN echo '#include <stdio.h>\n int main(void) { printf("Hello \
  world!\\n"); return 0; }' > hello.c 
RUN riscv64-unknown-elf-gcc -o hello hello.c

####### RICSV #############################################
# 32 bit version, used for trellis examples
# installation guide, see https://github.com/cliffordwolf/picorv32

WORKDIR /opt
# Ubuntu packages needed:
RUN apt-get update && apt-get install -y \
    autoconf automake autotools-dev curl libmpc-dev \
    libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
    gperf libtool patchutils bc zlib1g-dev git libexpat1-dev && \
    sudo mkdir /opt/riscv32i && \
    sudo chown $USER /opt/riscv32i && \
    git clone https://github.com/riscv/riscv-gnu-toolchain riscv-gnu-toolchain-rv32i && \
    cd riscv-gnu-toolchain-rv32i && \
    git checkout 411d134 && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    ../configure --with-arch=rv32i --prefix=/opt/riscv32i && \
    make -j$(nproc)

# Add the GNU utils bin folder to the path.
ENV PATH $RISCV/bin:$PATH
RUN echo 'export PATH=/opt/riscv32i/bin:$PATH' >> $WORKDIR/.bashrc

####### FPGA FLOW ####################################

WORKDIR /opt

#yosys dependencies  
RUN apt-get install -y \ 
  tcl-dev \
  clang\
  gawk \
  libreadline-dev \
  mercurial 

RUN apt-get install -y \ 
  python3 \
  pkg-config

# yosys  
RUN git clone https://github.com/YosysHQ/yosys.git yosys && \
    cd yosys && \
    make -j$(nproc) && \
    make install


# next-pnr , projtrellis dependencies
RUN apt-get install -y \
  cmake \
  python3-dev\
  libboost-dev \
  libboost-filesystem-dev \
  libboost-thread-dev \
  libboost-program-options-dev \
  libboost-python-dev \
  libboost-iostreams-dev\
  libboost-dev \
  libeigen3-dev

RUN apt-get install -y \
  qt5-default
  
# projtrellis
RUN git clone --recursive https://github.com/SymbiFlow/prjtrellis && \
    cd prjtrellis && \
    cd libtrellis && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr . && \
    make && \
    sudo make install


# next-pnr
RUN git clone https://github.com/YosysHQ/nextpnr nextpnr && \
    cd nextpnr && \
    cmake -DARCH=ecp5 -DTRELLIS_INSTALL_PREFIX=/usr .  && \
    make -j$(nproc)  && \
    make install


####### linux-on-litex-vexriscv ####################################



RUN apt-get install -y \
    build-essential device-tree-compiler wget git python3-setuptools

USER $USER


RUN mkdir -p $WORKDIR/tools/litex 
WORKDIR $WORKDIR/tools/litex

RUN git clone https://github.com/enjoy-digital/linux-on-litex-vexriscv

# litex, required python 3.6+
RUN wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py && \
    chmod +x litex_setup.py && \
    ./litex_setup.py init
    
USER root
RUN sudo ./litex_setup.py install

# buildroot
RUN sudo apt-get install -y \
    cpio rsync

USER $USER

RUN git clone http://github.com/buildroot/buildroot buildroot && \
    cd buildroot && \
    make BR2_EXTERNAL=../linux-on-litex-vexriscv/buildroot/ litex_vexriscv_defconfig  &&\
    make
    
# or use prebuilt version
# RUN  git clone https://github.com/enjoy-digital/linux-on-litex-vexriscv-prebuilt &&\
#      cp -r linux-on-litex-vexriscv-prebuilt/* linux-on-litex-vexriscv

####### copy files ####################################

USER root
COPY ./files/non5Gversion.diff $WORKDIR
RUN chown -R $USER $WORKDIR/non5Gversion.diff

####### Startup Script ####################################

USER root
WORKDIR /
# run the startup script each time the container is created
COPY ./startup.sh /opt
RUN chmod +x /opt/startup.sh
ENTRYPOINT ["/opt/startup.sh"]


