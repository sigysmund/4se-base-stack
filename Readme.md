# Embedded Linux Base Stack

This repository aims to provide a reference implementation for updateable, secure embedded Linux systems
that are built with the Yocto build system.

**Current features**:

- Basic stack structure
- Dual boot (recovery/system update schema)
- Bootcounter support
- Creation of update bundles
- Authentication of updates via certificates
- Some common configurations (like root password, ssh config, etc)
- Lightweight factory reset (through overlay clearance)
- Updates over various sources
  - from media device (USB)
  - via network download (ssh)
  - over-the-air (using `hawkbit` as remote backend, see [backend](./backend/Readme.md))

**Planned features**:

- Application watchdog to determine system health
- Differential updates (using `casync`)
- Support for update bundle encryption
- Support for sub-device updates via custom hook scripts


## Getting started

To have something ready to install on one of the supported boards, you need to

**(1)** Install the minimal host system requirements (see below).

**(2)** Pull the repository

```bash
git clone https://github.com/sigysmund/4se-base-stack
```

**(3)** Optional: Provide custom configure for some features (e.g. by setting up a `.env` file, see below).

**(4)** Start the build by running

```bash
./run-kas build conf/<machine>.yml <image [default: full-image]>
```

Example: \
```bash
./run-kas build conf/kas.qemux86-64.yml
```

**(5)** Locate the `*.wic` image file under `build/tmp/deploy/<machine>/` and flash it
on the device/ memory card using a tool like `Etcher`. 


### Host system requirements

The host system requirements are reduced as much as possible, yet there are
some:

- `git` _(well, who doesn't need it...)_
- `bash`
- `Docker`

For development, it is recommended to also install (and use!)

- `shellcheck`

If you want to run the `hawkbit` Update Backend Server, you'll also need

- `docker-compose`


## Branching and version control strategy

The branches in this repo are aligned with the Yocto project releases.

Currently supported releases:
- _scarthgap_

No longer maintained releases (no further feature development):
- _kirkstone_
- _dunfell_ 

To control how upstream changes enter builds in this repo, `kas` provides `lockfiles` that specify
the specific revisions to be checked out. They were created using

```bash
./run-kas dump --lock --inplace conf/kas.<machine>.yml
```

If you want to update the revisions, you can do so using the same command again with the added option `--update`.
In case you want to work with latest greatest, simply remove the respective `lockfile` next to the configuration
you want to build.


## Supported machines and images

The approach is to gradually expand the support on different platforms, starting with some of the widely
used development boards, such as the Raspberry Pi and Intel.

Currently supported boards:

- Intel _[MACHINE=intel-multiboot]_
- QEMU x86_64 _[MACHINE=qemux86-64-multiboot]_

For these, the following images can be built:

  - full-image              - Builds the full image (including recovery & system) with the configured sub-images.
  - system-update-bundle    - Builds a system update bundle with the configured sub-image.
  - recovery-update-bundle  - Builds a recovery update bundle with the configured sub-image.

  - custom-recovery-image   - Builds the recovery image only, with custom applications included.
  - custom-system-image     - Builds the system image only, with custom applications included.


## Configuring the project

The overall configuration is managed via the [kas](https://github.com/siemens/kas) tool.
It's main configuration can be found under [`./conf`](./conf).

Besides, the customizable features can be configured using an `.env` file. See `.env.example` for a reference of the syntax.

The board specifc integrations can be selected using the appropriate `MACHINE` name in the `run` commands (see above).


## Building the project

Like the configuration, the build environment is provided by [kas](https://github.com/siemens/kas).
The `./run-kas` script provided in this repo is only a shallow wrapper around the scripts copied from upstream kas, 
currently at version 4.6, like recommended by the respective documentation.

If you want to stay in the bitbake environment (and not only execute a single build command), you can use
```bash
./run-kas shell <machine>
```


## Deploying build artifacts

There are two types of build artifacts: _full system images_ and _update bundles_.

**Full system images** contain a fully partitioned representation of the system to be installed
on the main memory (e.g. the eMMC).
Depending on the hardware, this might require specific tools provided by the board manufacturer.
In the case of popular single-board-computers like the RaspberryPi, the external SD card needs
to be flashed with the image - which is most easily done with a tool like
[Etcher](https://www.balena.io/etcher/).

... or simplu use ```dd```.

As soon as the device is initially flashed with the expected partitioning and software,
**update bundles** can be installed by bringing them on the device and simply running

```bash
sw-mode-control update /path/to/update-bundle.raucb
```

Of course, this will only work for bundles to update the currently inactive software mode
(i.e. the `system` mode needs to be running to update the `recovery` software and vice versa).
To switch modes, you can use

```bash
sw-mode-control start-system|start-recovery
```


## Automated update flow

There is an `update-observer` service that watches for update packages under `/media`. Currently,
it does not account for running uploads, though, so be sure to first upload to a different location
(for example `/tmp`) and then atomically `mv` the bundle into the watched folder.

The service will attempt to detect whether a reboot into the other mode is required, perform this reboot,
then install the update and eventually reboot to the `system` mode.

It uses _file names_ to do that, so be sure to prefix your bundles with `system-update`
or `recovery-update` respectively.


## Emulation with QEMU

As mentioned above, there is a `qemuarm` based configuration that now supports the full multiboot setup.
For using it, simply build the `full-image` and run the emulator with

```bash
scripts/run-qemuarm-multiboot
```

The emulator is configured to expose SSH on port `2222`. For running the above script on host,
network isolation of the spawned container is turned off, so you should see the listening port when running `ss -tlp`.
When externally starting a container before calling the script, be sure to configure it appropriately.

Logging into the virtual device should then be as easy as
```bash
ssh -p 2222 root@localhost
```

Note that `ssh` uses lower case `-p` while `scp` upper case `-P` to set the port.

With this, you can inspect the build result, test new applications or install updates.

## Running N100

Flashed WIC image on M.2 SSD: 

```
Disk /dev/sdc: 500118192 sectors, 238.5 GiB
Model: TS-CM10G        
Sector size (logical/physical): 512/512 bytes
Disk identifier (GUID): 00000000-0000-0000-0000-00004D9B9EF0
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 34, last usable sector is 11288576
Partitions will be aligned on 2048-sector boundaries
Total free space is 139231 sectors (68.0 MiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048          133119   64.0 MiB    0700  boot
   2          270336          278527   4.0 MiB     0700  grubenv
   3          278528          540671   128.0 MiB   0700  boot_recov
   4          540672         2113535   768.0 MiB   8300  primary
   5         2113536         2375679   128.0 MiB   0700  boot_sys
   6         2375680         6569983   2.0 GiB     8300  rootfs
   7         6569984         6832127   128.0 MiB   0700  boot_b
   8         6832128        11026431   2.0 GiB     8300  rootfs_b
   9        11026432        11288575   128.0 MiB   8300  appfs
   
```


## Contribution

Feel free to contact me in case you have feature proposals or want to contribute.