# TrellisDev
Trellis and Litex Development Environment

In order to build the docker image run the following command.
Attention the build may take several hours and require 30GB!
```sh
sudo docker build -t plex1/trellisdev .
```

Start the docker container:
```sh
sudo docker run -it --rm plex1/trellisdev:latest
```

or with docker volumes:

```sh
sudo docker volume create --driver local --opt type=none --opt device=/home/felix_arnold/trellis/trellisvol --opt o=bind trellisvol
sudo docker volume inspect trellisvol
sudo docker run -it --rm -v trellisvol:/home/trellisdev plex1/trellisdev:latest
```

Inside th container, first copy the linux image and rootfs:

```sh
cp /home/trellisdev/tools/litex/buildroot/output/images/* /home/trellisdev/tools/litex/linux-on-litex-vexriscv/buildroot/

```
See https://github.com/litex-hub/linux-on-litex-vexriscv for instructions.


## Simulation

Start the simulation:
```sh
cd /home/trellisdev/tools/litex/linux-on-litex-vexriscv
./sim.py
```

## Building

For the non-5G verision of the Lattice Versa evaluation board use this commands:
```sh
cd /home/trellisdev/tools/litex/litex
git apply /home/trellisdev/non5Gversion.diff
```

```sh
./make.py --board=versa_ecp5 --build
```

FPGA programming file can be found in:
/home/trellisdev/tools/litex/linux-on-litex-vexriscv/build/versa_ecp5/gateware

For programming use this command:
sudo openocd -f ecp5-versa5g2.cfg -c "transport select jtag; init; svf top.svf; exit"