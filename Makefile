
# create vsbhda.exe with Open Watcom v2.0 and JWasm.
# to create the binary, enter
#   wmake
# optionally, for a debug version, enter
#   wmake debug=1

# the HX DOS extender is used; that means, a few
# things from the HXDEV package are required:
#
# - loadpero.bin     pe loader stub attached to binary
# - cstrtdhx.obj     startup module linked into binary
# - patchpe.exe      patches PE signature to PX
#
# patchpe is a Win32 application; to run it in DOS, the
# HXRT package will be needed; cstrtdx.obj should be copied
# to the Open Watcom lib386\dos directory; and loadpero.bin
# will be searched by the linker in the current directory
# or in any directory contained in the PATH environment var.

!ifndef DEBUG
DEBUG=0
!endif

WATCOM=\ow20
# activate next line if FM synth should be deactivated
#NOFM=1

# use jwlink (1) or wlink (0)
USEJWL=1

CC=$(WATCOM)\binnt\wcc386.exe
CPP=$(WATCOM)\binnt\wpp386.exe
!if $(USEJWL)
LINK=jwlink.exe
!else
LINK=$(WATCOM)\binnt\wlink.exe
!endif
LIB=$(WATCOM)\binnt\wlib.exe
ASM=jwasm.exe

NAME=vsbhda

!if $(DEBUG)
OUTD=owd
OUTD16=ow16d
C_DEBUG_FLAGS=-D_DEBUG
A_DEBUG_FLAGS=-D_DEBUG -Fl$* -Sg
!else
OUTD=ow
OUTD16=ow16
C_DEBUG_FLAGS=
A_DEBUG_FLAGS=
!endif

OBJFILES = &
	$(OUTD)/main.obj		$(OUTD)/sndisr.obj		$(OUTD)/ptrap.obj		$(OUTD)/linear.obj		$(OUTD)/pic.obj &
	$(OUTD)/vsb.obj			$(OUTD)/vdma.obj		$(OUTD)/virq.obj		$(OUTD)/vmpu.obj		$(OUTD)/tsf.obj &
!ifndef NOFM
	$(OUTD)/dbopl.obj		$(OUTD)/vopl3.obj &
!endif
	$(OUTD)/ac97mix.obj		$(OUTD)/au_cards.obj &
	$(OUTD)/dmairq.obj		$(OUTD)/pcibios.obj		$(OUTD)/memory.obj		$(OUTD)/physmem.obj		$(OUTD)/timer.obj &
	$(OUTD)/sc_e1371.obj	$(OUTD)/sc_ich.obj		$(OUTD)/sc_inthd.obj	$(OUTD)/sc_via82.obj	$(OUTD)/sc_sbliv.obj	$(OUTD)/sc_sbl24.obj &
	$(OUTD)/stackio.obj		$(OUTD)/stackisr.obj	$(OUTD)/sbisr.obj		$(OUTD)/int31.obj		$(OUTD)/rmwrap.obj		$(OUTD)/mixer.obj &
	$(OUTD)/hapi.obj		$(OUTD)/dprintf.obj		$(OUTD)/vioout.obj		$(OUTD)/djdpmi.obj		$(OUTD)/uninst.obj &
	$(OUTD)/malloc.obj		$(OUTD)/sbrk.obj		$(OUTD)/fileacc.obj
	
C_OPT_FLAGS=-q -mf -oxa -ecc -5s -fp5 -fpi87 -wcd=111
# OW's wpp386 doesn't like the -ecc option
CPP_OPT_FLAGS=-q -oxa -mf -bc -5s -fp5 -fpi87 
C_EXTRA_FLAGS=
!ifdef NOFM
C_EXTRA_FLAGS= $(C_EXTRA_FLAGS) -DNOFM
!endif
LD_FLAGS=
LD_EXTRA_FLAGS=op M=$(OUTD)/$(NAME).map

INCLUDES=-I$(WATCOM)\h
LIBS=

# define recognized file extensions so the uppercase variants work
.SUFFIXES: .ASM .C .CPP

{src}.asm{$(OUTD)}.obj
	@$(ASM) -q -D?MODEL=flat -Istartup $(A_DEBUG_FLAGS) -Fo$@ $<

{src}.c{$(OUTD)}.obj
        @$(CC) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CFLAGS) -Isrc $(INCLUDES) -fo=$@ $<
{src}.C{$(OUTD)}.obj
        @$(CC) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CFLAGS) -Isrc $(INCLUDES) -fo=$@ $<

{src}.cpp{$(OUTD)}.obj
        @$(CPP) $(C_DEBUG_FLAGS) $(CPP_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CPPFLAGS) -Isrc $(INCLUDES) -fo=$@ $<
{src}.CPP{$(OUTD)}.obj
        @$(CPP) $(C_DEBUG_FLAGS) $(CPP_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CPPFLAGS) -Isrc $(INCLUDES) -fo=$@ $<

{mpxplay}.c{$(OUTD)}.obj
        @$(CC) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CFLAGS) -Impxplay -Isrc $(INCLUDES) -fo=$@ $<
{mpxplay}.C{$(OUTD)}.obj
        @$(CC) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CFLAGS) -Impxplay -Isrc $(INCLUDES) -fo=$@ $<

{startup}.asm{$(OUTD)}.obj
        @$(ASM) -q -zcw -D?MODEL=flat $(A_DEBUG_FLAGS) -Fo$@ $<
{startup}.ASM{$(OUTD)}.obj
        @$(ASM) -q -zcw -D?MODEL=flat $(A_DEBUG_FLAGS) -Fo$@ $<

all: $(OUTD) $(OUTD)\$(NAME).exe $(OUTD16)\$(NAME)16.exe

$(OUTD):
	@mkdir $(OUTD)

$(OUTD)\$(NAME).exe: $(OUTD)\$(NAME).lib
	@$(LINK) @<<
format win pe runtime console
file $(OUTD)\main.obj, $(OUTD)\linear.obj
name $@
libpath $(WATCOM)\lib386\dos;$(WATCOM)\lib386
libfile cstrtdhx.obj
lib $(OUTD)\$(NAME).lib
op q,m=$(OUTD)\$(NAME).map,stub=loadpero.bin,stack=0x10000,heap=0x1000
!if $(USEJWL)
segment CONST readonly
segment CONST2 readonly
!endif
<<
	@patchpe $*.exe

$(OUTD16)\$(NAME)16.exe: .always
	@wmake -h -f OW16.mak debug=$(DEBUG)

$(OUTD)\$(NAME).lib: $(OBJFILES)
	@$(LIB) -q -b -n $(OUTD)\$(NAME).lib $(OBJFILES)

$(OUTD)/ac97mix.obj:   mpxplay\AC97MIX.C
$(OUTD)/au_cards.obj:  mpxplay\AU_CARDS.C
$(OUTD)/dmairq.obj:    mpxplay\DMAIRQ.C
$(OUTD)/physmem.obj:   mpxplay\PHYSMEM.C
$(OUTD)/memory.obj:    mpxplay\MEMORY.C
$(OUTD)/pcibios.obj:   mpxplay\PCIBIOS.C
$(OUTD)/sc_e1371.obj:  mpxplay\SC_E1371.C
$(OUTD)/sc_ich.obj:    mpxplay\SC_ICH.C
$(OUTD)/sc_inthd.obj:  mpxplay\SC_INTHD.C
$(OUTD)/sc_sbl24.obj:  mpxplay\SC_SBL24.C
$(OUTD)/sc_sbliv.obj:  mpxplay\SC_SBLIV.C
$(OUTD)/sc_via82.obj:  mpxplay\SC_VIA82.C
$(OUTD)/timer.obj:     mpxplay\TIMER.C
$(OUTD)/djdpmi.obj:    src\DJDPMI.ASM
$(OUTD)/dprintf.obj:   src\DPRINTF.ASM
$(OUTD)/fileacc.obj:   src\FILEACC.ASM
$(OUTD)/hapi.obj:      src\HAPI.ASM
$(OUTD)/int31.obj:     src\INT31.ASM
$(OUTD)/linear.obj:    src\LINEAR.C
$(OUTD)/main.obj:      src\MAIN.C
$(OUTD)/mixer.obj:     src\MIXER.ASM
$(OUTD)/pic.obj:       src\PIC.C
$(OUTD)/ptrap.obj:     src\PTRAP.C
$(OUTD)/sbisr.obj:     src\SBISR.ASM
$(OUTD)/sndisr.obj:    src\SNDISR.C
$(OUTD)/stackio.obj:   src\STACKIO.ASM
$(OUTD)/stackisr.obj:  src\STACKISR.ASM
$(OUTD)/tsf.obj:       src\TSF.C
$(OUTD)/uninst.obj:    src\UNINST.ASM
$(OUTD)/vdma.obj:      src\VDMA.C
$(OUTD)/vioout.obj:    src\VIOOUT.ASM
$(OUTD)/virq.obj:      src\VIRQ.C
$(OUTD)/vmpu.obj:      src\VMPU.C
$(OUTD)/vsb.obj:       src\VSB.C
!ifndef NOFM
$(OUTD)/dbopl.obj:     src\DBOPL.CPP
$(OUTD)/vopl3.obj:     src\VOPL3.CPP
	@$(CPP) $(C_DEBUG_FLAGS) -q -oxa -mf -bc -ecc -5s -fp5 -fpi87 $(C_EXTRA_FLAGS) $(CPPFLAGS) $(INCLUDES) -fo=$@ $<
!endif
$(OUTD)/malloc.obj:    startup\MALLOC.ASM
$(OUTD)/sbrk.obj:      startup\SBRK.ASM


# to avoid any issues with 16-bit relocations in PE binaries,
# the 16-bit code is included in binary format into rmwrap.asm.

$(OUTD)/rmwrap.obj:    src\rmwrap.asm src\rmcode1.asm src\rmcode2.asm
	@$(ASM) -q -bin -Fl$(OUTD)\ -Fo$(OUTD)\rmcode1.bin src\rmcode1.asm
	@$(ASM) -q -bin -Fl$(OUTD)\ -Fo$(OUTD)\rmcode2.bin src\rmcode2.asm
	@$(ASM) -q -D?MODEL=flat -Fo$@ -DOUTD=$(OUTD) src\rmwrap.asm

clean: .SYMBOLIC
	@wmake -h -f OW16.mak debug=$(DEBUG) clean
	@del $(OUTD)\$(NAME).exe
	@del $(OUTD)\$(NAME).lib
	@del $(OUTD)\*.obj
