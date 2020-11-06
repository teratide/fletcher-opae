FROM centos:7.7.1908

# Intel Acceleration Stack for Development for Intel Programmable Acceleration Card with Intel Arria 10 GX FPGA
RUN yum install -y curl epel-release sudo && \
    mkdir -p /installer && \
    curl -L http://download.altera.com/akdlm/software/ias/1.2.1/a10_gx_pac_ias_1_2_1_pv_dev.tar.gz | tar xz -C /installer --strip-components=1 && \
    sed -i 's/install_opae=1/install_opae=0/g' /installer/setup.sh && \
    /installer/setup.sh --installdir /opt --yes && \
    rm -rf /installer && \
    yum install -y libpng12 freetype fontconfig libX11 libSM libXrender libXext libXtst

ENV OPAE_PLATFORM_ROOT /opt/inteldevstack/a10_gx_pac_ias_1_2_1_pv/
ENV QUARTUS_HOME /opt/intelFPGA_pro/quartus_19.2.0b57/quartus/
ENV PATH "${QUARTUS_HOME}/bin:${PATH}"

# Modelsim
RUN mkdir -p /installer && \
    cd /installer && \
    curl -L -O http://download.altera.com/akdlm/software/acdsinst/19.2/57/ib_installers/ModelSimProSetup-19.2.0.57-linux.run && \
    curl -L -O http://download.altera.com/akdlm/software/acdsinst/19.2/57/ib_installers/modelsim-part2-19.2.0.57-linux.qdz && \
    chmod +x ModelSimProSetup-19.2.0.57-linux.run && \
    ./ModelSimProSetup-19.2.0.57-linux.run --mode unattended --installdir /opt/intelFPGA_pro/quartus_19.2.0b57/ --accept_eula 1 && \
    rm -rf /installer && \
    yum install -y glibc-devel.i686 libX11.i686 libXext.i686 libXft.i686 libgcc.i686 && \
    sed -ci 's/linux_rh60/linux/g' /opt/intelFPGA_pro/quartus_19.2.0b57/modelsim_ase/bin/vsim

ENV MTI_HOME /opt/intelFPGA_pro/quartus_19.2.0b57/modelsim_ase
ENV QUESTA_HOME "${MTI_HOME}"
ENV PATH "${MTI_HOME}/bin:${PATH}"

# Platform Interface Manager
ARG OFS_REF=d2249059be0f10791662e6244dcd8feed00bd50e
RUN mkdir -p /ofs-platform-afu-bbb && \
    curl -L https://github.com/OPAE/ofs-platform-afu-bbb/archive/${OFS_REF}.tar.gz | tar xz -C /ofs-platform-afu-bbb --strip-components=1 && \
    cd /ofs-platform-afu-bbb/ && \
    ./plat_if_release/update_release.sh $OPAE_PLATFORM_ROOT

# Open Programmable Acceleration Engine
ARG OPAE_REF=release/2.0.0
RUN mkdir -p /opae-sdk/build && \
    yum install -y git cmake3 make gcc gcc-c++ json-c-devel libuuid-devel hwloc-devel python-devel glibc-devel && \
    curl -L https://github.com/OPAE/opae-sdk/archive/${OPAE_REF}.tar.gz | tar xz -C /opae-sdk --strip-components=1 && \
    cd /opae-sdk/build && \
    cmake3 -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_ASE=On -DOPAE_BUILD_SIM=On -DOPAE_SIM_TAG=c5b24f7b31a656d9e85541ca9ba9e1841ac4ede1 \
    -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make -j && \
    make install && \
    rm -rf /opae-sdk/build

# Intel FPGA Basic Building Blocks
ARG BBB_REF=579ce26b433c3b81de4fa1a5e3e9985f48bc5dde
RUN mkdir -p /intel-fpga-bbb/build && \
    curl -L https://github.com/OPAE/intel-fpga-bbb/archive/${BBB_REF}.tar.gz | tar xz -C /intel-fpga-bbb --strip-components=1 && \
    cd /intel-fpga-bbb/build && \
    cmake3 -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make -j && \
    make install

ENV FPGA_BBB_CCI_SRC /intel-fpga-bbb

# Intel TBB
RUN curl -L https://github.com/oneapi-src/oneTBB/releases/download/v2020.3/tbb-2020.3-lin.tgz | tar xz -C /usr --strip-components=1

# Fletcher runtime
ARG FLETCHER_REF=0.0.12
ARG ARROW_VERSION=1.0.1
RUN mkdir -p /fletcher && \
    yum install -y https://apache.bintray.com/arrow/centos/$(cut -d: -f5 /etc/system-release-cpe)/apache-arrow-release-latest.rpm && \
    yum install -y arrow-devel-${ARROW_VERSION}-1.el7 && \
    curl -L https://github.com/abs-tudelft/fletcher/archive/${FLETCHER_REF}.tar.gz | tar xz -C /fletcher --strip-components=1 && \
    cd /fletcher && \
    cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr . && \
    make -j && \
    make install && \
    rm -rf /fletcher

# Fletcher hardware libs
RUN git clone --recursive --single-branch -b ${FLETCHER_REF} https://github.com/abs-tudelft/fletcher /fletcher
ENV FLETCHER_HARDWARE_DIR=/fletcher/hardware

# Fletcher plaform support for OPAE
ARG FLETCHER_OPAE_REF=bbb936545bddc9d8c7f446db6b542647a2265219
RUN mkdir -p /fletcher-opae && \
    curl -L https://github.com/abs-tudelft/fletcher-opae/archive/${FLETCHER_OPAE_REF}.tar.gz | tar xz -C /fletcher-opae --strip-components=1 && \
    cd /fletcher-opae && \
    cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr . && \
    make -j && \
    make install && \
    rm -rf /fletcher-opae

# Install vhdmmio
RUN python3 -m pip install -U pip && \
    python3 -m pip install vhdmmio pyfletchgen pyarrow==${ARROW_VERSION}

WORKDIR /src
