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
    yum install -y glibc-devel.i686 libX11.i686 libXext.i686 libXft.i686 libgcc libgcc.i686 && \
    sed -ci 's/linux_rh60/linux/g' /opt/intelFPGA_pro/quartus_19.2.0b57/modelsim_ase/bin/vsim

ENV MTI_HOME /opt/intelFPGA_pro/quartus_19.2.0b57/modelsim_ase
ENV QUESTA_HOME "${MTI_HOME}"
ENV PATH "${MTI_HOME}/bin:${PATH}"

# Platform Interface Manager
ARG OFS_REF=349409852326f716ca196755357e45acd6407c78
RUN mkdir -p /ofs-platform-afu-bbb && \
    curl -L https://github.com/OPAE/ofs-platform-afu-bbb/archive/${OFS_REF}.tar.gz | tar xz -C /ofs-platform-afu-bbb --strip-components=1 && \
    cd /ofs-platform-afu-bbb/ && \
    ./plat_if_release/update_release.sh $OPAE_PLATFORM_ROOT

# Open Programmable Acceleration Engine
ARG OPAE_VERSION=2.0.1-2
RUN yum install -y git cmake3 make gcc gcc-c++ json-c-devel libuuid-devel hwloc-devel python-devel glibc-devel && \
    git clone --single-branch --branch release/${OPAE_VERSION} https://github.com/OPAE/opae-sdk.git /opae-sdk && \
    mkdir -p /opae-sdk/build && \
    cd /opae-sdk/build && \
    cmake3 \
    -DCMAKE_BUILD_TYPE=Release \
    -DOPAE_BUILD_SIM=On \
    -DOPAE_BUILD_LIBOPAE_PY=Off \
    -DOPAE_BUILD_LIBOPAEVFIO=Off \
    -DOPAE_BUILD_PLUGIN_VFIO=Off \
    -DOPAE_BUILD_LIBOPAEUIO=Off \
    -DOPAE_BUILD_EXTRA_TOOLS=Off \
    -DCMAKE_INSTALL_PREFIX=/usr /opae-sdk && \
    make -j && \
    make install && \
    rm -rf /opae-sdk

# Intel FPGA Basic Building Blocks
ARG BBB_REF=1909c504503f0602c86089cca1aa3aad3f7929d0
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
ARG FLETCHER_VERSION=0.0.19
ARG ARROW_VERSION=3.0.0
RUN mkdir -p /fletcher && \
    yum install -y https://apache.bintray.com/arrow/centos/$(cut -d: -f5 /etc/system-release-cpe)/apache-arrow-release-latest.rpm && \
    yum install -y arrow-devel-${ARROW_VERSION}-1.el7 && \
    curl -L https://github.com/abs-tudelft/fletcher/archive/${FLETCHER_VERSION}.tar.gz | tar xz -C /fletcher --strip-components=1 && \
    cd /fletcher && \
    cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr . && \
    make -j && \
    make install && \
    rm -rf /fletcher

# Fletcher hardware libs
RUN git clone --recursive --single-branch -b ${FLETCHER_VERSION} https://github.com/abs-tudelft/fletcher /fletcher
ENV FLETCHER_HARDWARE_DIR=/fletcher/hardware

# Fletcher plaform support for OPAE
ARG FLETCHER_OPAE_VERSION=0.2.1
RUN mkdir -p /fletcher-opae && \
    curl -L https://github.com/teratide/fletcher-opae/archive/${FLETCHER_OPAE_VERSION}.tar.gz | tar xz -C /fletcher-opae --strip-components=1 && \
    cd /fletcher-opae && \
    cmake3 -DCMAKE_BUILD_TYPE=Release -DBUILD_FLETCHER_OPAE-ASE=ON -DCMAKE_INSTALL_PREFIX=/usr . && \
    make -j && \
    make install && \
    rm -rf /fletcher-opae

# Install vhdmmio
RUN python3 -m pip install -U pip && \
    python3 -m pip install vhdmmio vhdeps pyfletchgen==${FLETCHER_VERSION} pyarrow==${ARROW_VERSION}

WORKDIR /src
