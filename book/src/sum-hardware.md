# Hardware

This subsection shows how to synthesize the hardware design, flash the bitstream to the FPGA, and run your application using the accelerator.

## Synthesis

Start by running a new container.

```
cd fletcher-opae/examples/sum
docker run -it --rm --name ias --net=host -v `pwd`:/src:ro ias:1.2.1
```

Create the synthesis environment and generate the bitstream.

```
afu_synth_setup -s /src/hw/sources.txt /synth
cd /synth
${OPAE_PLATFORM_ROOT}/bin/run.sh
```

In order to flash the resulting bitstream we must run it through PACsign. In this case the bitstream is not signed, but this step is still required.

```
PACSign PR -y -t UPDATE -H openssl_manager -i sum.gbs -o sum_unsigned.gbs
```

Start a new shell and copy the resulting unsigned bitstream to your local machine.

```
cd fletcher-opae/examples/sum
docker cp ias:/synth/sum_unsigned.gbs .
```

## Flash the bistream

To flash the bistream start new [privileged](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) container to access the FPGA.

```
cd fletcher-opae/examples/sum
docker run -it --rm --privileged -v `pwd`:/src:ro ias:1.2.1
```

Flash the bitstream using `fpgaconf`.

```
fpgaconf sum_unsigned.gbs
```

## Run the host application

Start a new container with [access to the device](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).

```
cd fletcher-opae/examples/sum
docker run -it --rm --device /dev/intel-fpga-port.0 -v `pwd`:/src:ro ias:1.2.1
```

Build the host application. It's important to use a release build to disable simulation mode.

```
mkdir -p /build
cd /build
cmake3 -DCMAKE_BUILD_TYPE=release /src/sw
make
```

Run the host application, using the accelerator.

```
./sum /src/hw/example.rb
```

The result should be -6.
