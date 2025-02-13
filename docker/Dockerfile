FROM debian:12
SHELL ["/bin/bash", "-c"]

# Yosys, nextpnr, iverilog and other HDL related tools
#
# Download the archive from
# https://github.com/YosysHQ/oss-cad-suite-build/releases, then set the
# oss_cad_suite_src variable to point to it. Note that due to a difference in
# the way ADD handles tar archives locally and remotely, this can not be set
# to the GitHub download URL of the release. It must be a local path.
ARG oss_cad_suite_src
RUN test -n "$oss_cad_suite_src"

ADD $oss_cad_suite_src /opt
ENV PATH /opt/oss-cad-suite/bin:$PATH

RUN apt-get update && apt-get install -y \
    bison \
    build-essential \
    cmake \
    curl \
    file \
    flex \
    git \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    ninja-build \
    pkg-config \
    python-is-python3 \
    python3-pip \
    python3-venv \
    texinfo \
    z3 \
    zlib1g-dev


# https://github.com/riscv/sail-riscv#building-the-model
RUN curl --location https://github.com/rems-project/sail/releases/download/0.18-linux-binary/sail.tar.gz | tar xvz --directory=/usr/local --strip-components=1

RUN cd /opt && \
    git clone --depth=1 https://github.com/riscv/sail-riscv.git && \
    cd sail-riscv && \
    cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DDEFAULT_ARCHITECTURES=rv32d && \
    cmake --build build && \
    cmake --build build --target install && \
    cd / && \
    rm -rf /opt/sail-riscv

RUN mkdir -p /opt/gcc && cd /opt/gcc && \
    git clone --depth 1 --branch releases/gcc-14.2.0 git://gcc.gnu.org/git/gcc.git gcc && \
    git clone --depth 1 --branch binutils-2_42 git://sourceware.org/git/binutils-gdb.git binutils

# Include binutils in the GCC build: https://stackoverflow.com/q/1726042/15158846
# We have minimised the included folders to just binutils, assembler, linker
# and their dependencies.
RUN ln -s /opt/gcc/binutils/{binutils,gas,ld,bfd,libsframe,opcodes,libctf} /opt/gcc/gcc

RUN mkdir /opt/gcc/build && cd /opt/gcc/build && \
    ../gcc/configure \
      --target=riscv64-unknown-elf \
      --with-gnu-as \
      --with-gnu-ld \
      --enable-languages=c,c++,lto \
      --disable-libada \
      --disable-libgm2 \
      --disable-libsanitizer \
      --disable-libssp \
      --disable-libquadmath \
      --disable-libquadmath-support \
      --disable-libgommp \
      --disable-libvtv \
      --disable-nls \
      --disable-hosted-libstdcxx \
      --without-headers && \
    make -j $(nproc) all && \
    make -j $(nproc) install && \
    rm -rf /opt/gcc


# Work around incorrect assumption that only risv32 gcc can build for 32-bit
# systems in riscof-plugins/sail_cSim. This 64-bit compiler will also build
# 32-bit binaries.
RUN ln -s /usr/local/bin/riscv64-unknown-elf-gcc /usr/local/bin/riscv32-unknown-elf-gcc && \
    ln -s /usr/local/bin/riscv64-unknown-elf-objdump /usr/local/bin/riscv32-unknown-elf-objdump && \
    ln -s /usr/local/bin/riscv64-unknown-elf-objcopy /usr/local/bin/riscv32-unknown-elf-objcopy

