# Simulate

This subsection shows how to run hardware/software co-simulation using [OPAE ASE](https://github.com/OPAE/opae-sim).

Start by starting a new container for simulation:

```
cd fletcher-opae/examples/sum
docker run -it --rm --name ias -e DISPLAY -v `pwd`:/src:ro ias:1.2.1
```

## Start simulation

```
afu_sim_setup -s /src/hw/sources.txt /sim
cd /sim
make
```

Start the simulation.

```
make sim
```

## Start host application

Start another shell in the running container.

```
docker exec -it ias bash
```

Build the host application.

```
mkdir -p /build
cd /build
cmake3 /src/sw
make
```

Check if the simulator is ready and run your host application.

```
export ASE_WORKDIR=/sim/work
./sum /src/hw/example.rb
```

The host application should output `-6`.
