FROM debian:12

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
    python-is-python3 \
    python3-pip \
    gcc-riscv64-unknown-elf \
    opam \
    build-essential \
    libgmp-dev \
    z3 \
    pkg-config \
    zlib1g-dev

# https://github.com/riscv/sail-riscv#building-the-model
RUN opam init -y --disable-sandboxing && \
    opam switch create ocaml-base-compiler.4.08.0 && \
    opam install sail -y && \
    eval $(opam config env) && \
    cd /opt && \
    git clone --depth=1 https://github.com/riscv/sail-riscv.git && \
    cd sail-riscv && \
    ARCH=RV32 make csim && \
    mv c_emulator/riscv_sim_RV32 /usr/local/bin && \
    cd / && \
    rm -rf /opt/sail-riscv

# Work around incorrect assumption that only risv32 gcc can build for 32-bit
# systems in riscof-plugins/sail_cSim. This 64-bit compiler will also build
# 32-bit binaries.
RUN ln -s /usr/bin/riscv64-unknown-elf-gcc /usr/local/bin/riscv32-unknown-elf-gcc && \
    ln -s /usr/bin/riscv64-unknown-elf-objdump /usr/local/bin/riscv32-unknown-elf-objdump && \
    ln -s /usr/bin/riscv64-unknown-elf-objcopy /usr/local/bin/riscv32-unknown-elf-objcopy

# Duplicated so that cache from eariler versions can be reused
RUN apt-get install -y cmake ninja-build
