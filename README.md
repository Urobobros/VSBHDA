# VSBHDA
Sound blaster emulation for HDA (and AC97/SBLive); a fork of crazii's SBEMU: https://github.com/crazii/SBEMU

Works with unmodified HDPMI binaries, making it compatible with HX.

Supported Sound cards:
 * HDA ( Intel High Definition Audio )
 * Intel ICH / nForce
 * VIA VT82C686, VT8233/35/37
 * SB Live/SB Audigy

Emulated modes/cards:
8-bit, 16-bit, mono, stereo, high-speed;
Sound blaster 1.0, 2.0, Pro, Pro2, 16.

Requirements:
 * HDPMI32i - DPMI host with port trapping; 32-bit protected-mode
 * HDPMI16i - DPMI host with port trapping; 16-bit protected-mode
 * JEMMEX 5.84 - V86 monitor with port trapping; v86-mode
 
VSBHDA uses some source codes from:
 * MPXPlay: https://mpxplay.sourceforge.net/, for sound card access
 * DOSBox: https://www.dosbox.com/, for OPL3 FM emulation

To create the binaries, Open Watcom v2.0 is recommended. DJGPP v2.05
may also be used, but cannot create the 16-bit variant of VSBHDA.

In all cases the JWasm assembler (v2.17 or better) is also needed.
For Open Watcom, a few things from the HX development package (HXDEV)
are required - see Makefile for details. If you don't already have
JWasm installed, it can be built from source using GCC:

```bash
git clone https://github.com/JWasm/JWasm.git
cd JWasm && make -f GccUnix.mak
sudo cp GccUnixR/jwasm /usr/local/bin/jwasm
```

## Building

VSBHDA is intended to be built with Open Watcom v2.0 and the JWasm assembler.
Ensure both tools and the utilities from the HX development package (`loadpero.bin`,
`cstrtdhx.obj` and `patchpe.exe`) are available in your `PATH`.

To build the 32‑bit variant run:

```
wmake
```

For the 16‑bit variant execute:

```
wmake -f OW16.mak
```

A DJGPP makefile is provided as well:

```
make -f djgpp.mak
```

A helper script `build.sh` can be used to call these commands. Use one
of `./build.sh ow`, `./build.sh ow16` or `./build.sh djgpp` depending on
the desired target.

If you obtained the optional Open Watcom distribution provided with
SBEMU, run `./open-watcom-v2` once to initialize the toolchain. The
`build.sh` script attempts to source this file automatically if `wmake`
is not available in your `PATH`.
You can get the package from the [Open Watcom v2 releases](https://github.com/open-watcom/open-watcom-v2/releases).

The source tree uses uppercase file names as found in the original
project. The makefiles reference these names and will now build
correctly on case‑sensitive systems such as Linux.

### Cross‑compiling with DJGPP

If you prefer building with a DJGPP cross compiler, obtain a toolchain
via the [build-djgpp](https://github.com/andrewwutw/build-djgpp)
project or one of its prebuilt releases. The tools require `libfl2`
on your system which can be installed with

```
sudo apt-get install libfl2
```

Invoke

```
make -f djgpp.mak CROSS=i586-pc-msdosdjgpp-
```

The helper script will automatically download a prebuilt cross toolchain
from the [build-djgpp](https://github.com/andrewwutw/build-djgpp) project
if `i586-pc-msdosdjgpp-gcc` is not present in your `PATH`. The toolchain is
extracted under `djgpp-cross` and added to the environment for the build.
If JWasm isn’t installed, the script downloads version 2.19 and builds it
automatically.

or simply run

```
./build.sh cross
```

to compile VSBHDA using the cross toolchain.
