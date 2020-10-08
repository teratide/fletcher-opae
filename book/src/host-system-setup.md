# Host system setup

This subsection describes the required setup steps for the host system.

## Docker

The development environment is based on a [Docker](https://www.docker.com/) image provided by this project. It includes all the required tools and components to:

- Generate Fletcher projects
  - fletchgen
  - vhdmmio
  - pyarrow
- Build Fletcher projects
  - C++11 compiler
  - Apache Arrow 1.0+
- Hardware/software co-simulation
  - Modelsim
  - OPAE ASE
- Generate bistreams
  - Quartus
  - Updated Platform Interface Manager
  - PACsign
- Update bitstream on FPPGA
  - fpgaconf
- Run on hardware
  - Fletcher runtime
  - Fletcher OPAE platform support
  - OPAE library

[Install](https://docs.docker.com/engine/install/centos/) the latest stable version of Docker.

## Driver

If you have access to a supported device and want to run on hardware start by installing the [Intel FPGA driver](https://github.com/OPAE/opae-sdk/releases/download/1.4.0-1/opae-intel-fpga-driver-2.0.4-2.x86_64.rpm).

```
sudo yum install -y https://github.com/OPAE/opae-sdk/releases/download/1.4.0-1/opae-intel-fpga-driver-2.0.4-2.x86_64.rpm
```

Validate that the driver installed successfully and is loaded.

```
$ lsmod | grep fpga
intel_fpga_pac_hssi    24389  0
intel_fpga_fme         87452  0
intel_fpga_afu         36165  0
ifpga_sec_mgr          13757  1 intel_fpga_fme
fpga_mgr_mod           14812  1 intel_fpga_fme
intel_fpga_pci         26500  2 intel_fpga_afu,intel_fpga_fme
```

## Updating the FIM and BMC firmware

> TODO
