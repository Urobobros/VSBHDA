
# create vsbhda16.exe with Open Watcom v2.0 and JWasm.
# to create the binary, enter
#   wmake -f ow16.mak
# optionally, for a debug version, enter
#   wmake -f ow16.mak debug=1

!ifndef DEBUG
DEBUG=0
!endif

WATCOM=\ow20
# activate next line if FM synth should be deactivated
#NOFM=1

CC=$(WATCOM)\binnt\wcc386
CPP=$(WATCOM)\binnt\wpp386
LINK=$(WATCOM)\binnt\wlink
#LINK=jwlink
LIB=$(WATCOM)\binnt\wlib
ASM=jwasm.exe

NAME=vsbhda16
NAME2=sndcard

!if $(DEBUG)
OUTD=ow16d
C_DEBUG_FLAGS=-D_DEBUG
A_DEBUG_FLAGS=-D_DEBUG -Fl=$*
!else
OUTD=ow16
C_DEBUG_FLAGS=-D_LOG
A_DEBUG_FLAGS=
!endif

OBJFILES = &
	$(OUTD)/main.obj		$(OUTD)/sndisr.obj		$(OUTD)/ptrap.obj		$(OUTD)/linear.obj		$(OUTD)/pic.obj &
	$(OUTD)/vsb.obj			$(OUTD)/vdma.obj		$(OUTD)/virq.obj		$(OUTD)/vmpu.obj		$(OUTD)/tsf.obj &
!ifndef NOFM
	$(OUTD)/dbopl.obj		$(OUTD)/vopl3.obj &
!endif
	$(OUTD)/stackio.obj		$(OUTD)/stackisr.obj	$(OUTD)/sbisr.obj		$(OUTD)/int31.obj		$(OUTD)/rmwrap.obj		$(OUTD)/mixer.obj &
	$(OUTD)/hapi.obj		$(OUTD)/dprintf.obj		$(OUTD)/vioout.obj		$(OUTD)/djdpmi.obj		$(OUTD)/uninst.obj &
	$(OUTD)/auhlp16.obj		$(OUTD)/ldmod16.obj		$(OUTD)/sbrk.obj		$(OUTD)/malloc.obj		$(OUTD)/rte200.obj &
	$(OUTD)/fileacc.obj

OBJFILES2 = &
	$(OUTD)/ac97mix.obj		$(OUTD)/au_cards.obj &
	$(OUTD)/dmairq.obj		$(OUTD)/pcibios.obj		$(OUTD)/memory.obj		$(OUTD)/physmem.obj		$(OUTD)/timer.obj &
	$(OUTD)/sc_e1371.obj	$(OUTD)/sc_ich.obj		$(OUTD)/sc_inthd.obj	$(OUTD)/sc_via82.obj	$(OUTD)/sc_sbliv.obj	$(OUTD)/sc_sbl24.obj &
	$(OUTD)/djdpmi.obj		$(OUTD)/dprintf.obj		$(OUTD)/vioout.obj		$(OUTD)/sbrk.obj		$(OUTD)/malloc.obj &
	$(OUTD)/libmain.obj   

C_OPT_FLAGS=-q -oxa -ms -ecc -5s -fp5 -fpi87 -wcd=111
# OW's wpp386 doesn't like the -ecc option ("function modifier cannot be used ...")
CPP_OPT_FLAGS=-q -oxa -ms -bc -5s -fp5 -fpi87 
C_EXTRA_FLAGS=-DNOTFLAT
!ifdef NOFM
C_EXTRA_FLAGS= $(C_EXTRA_FLAGS) -DNOFM
!endif

INCLUDES=-I$(WATCOM)\h
LIBS=

# define recognized file extensions for Linux builds
.SUFFIXES: .ASM .C .CPP

{src}.asm{$(OUTD)}.obj
        @$(ASM) -q -DNOTFLAT -Istartup -D?MODEL=small $(A_DEBUG_FLAGS) -Fo$@ $<
{src}.ASM{$(OUTD)}.obj
        @$(ASM) -q -DNOTFLAT -Istartup -D?MODEL=small $(A_DEBUG_FLAGS) -Fo$@ $<

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
        @$(ASM) -q -zcw -DNOTFLAT -D?MODEL=small $(A_DEBUG_FLAGS) -Fo$@ $<
{startup}.ASM{$(OUTD)}.obj
        @$(ASM) -q -zcw -DNOTFLAT -D?MODEL=small $(A_DEBUG_FLAGS) -Fo$@ $<

{startup}.c{$(OUTD)}.obj
        @$(CC) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CFLAGS) $(INCLUDES) -fo=$@ $<
{startup}.C{$(OUTD)}.obj
        @$(CC) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CFLAGS) $(INCLUDES) -fo=$@ $<

all: $(OUTD) $(OUTD)\$(NAME).exe $(OUTD)\$(NAME2).drv

$(OUTD):
	@mkdir $(OUTD)

$(OUTD)\$(NAME).exe: $(OUTD)\$(NAME).lib $(OUTD)\cstrt16x.obj $(OUTD)\init1632.obj
	@$(LINK) @<<
format dos 
file $(OUTD)\cstrt16x, $(OUTD)\main, $(OUTD)\init1632 name $@
libpath $(WATCOM)\lib386\dos;$(WATCOM)\lib386
lib $*.lib
op q,statics,m=$*.map
disable 80
<<

$(OUTD)\$(NAME2).drv: $(OUTD)\$(NAME2).lib $(OUTD)\dstrt16x.obj
	@$(LINK) @<<
format dos 
file $(OUTD)\dstrt16x name $@
libpath $(WATCOM)\lib386\dos;$(WATCOM)\lib386
lib $*.lib
op q,statics,m=$*.map
disable 80
<<

$(OUTD)\$(NAME).lib: $(OBJFILES)
	@$(LIB) -q -b -n $(OUTD)\$(NAME).lib $(OBJFILES)

$(OUTD)\$(NAME2).lib: $(OBJFILES2)
	@$(LIB) -q -b -n $(OUTD)\$(NAME2).lib $(OBJFILES2)

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

$(OUTD)/auhlp16.obj:   src\AUHLP16.ASM
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
$(OUTD)/rte200.obj:    src\RTE200.ASM
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
	@$(CPP) $(C_DEBUG_FLAGS) -q -oxa -ms -bc -ecc -5s -fp5 -fpi87 $(C_EXTRA_FLAGS) $(CPPFLAGS) $(INCLUDES) -fo=$@ $<
!endif

$(OUTD)/cstrt16x.obj:  startup\CSTRT16X.ASM
$(OUTD)/dstrt16x.obj:  startup\DSTRT16X.ASM
$(OUTD)/ldmod16.obj:   startup\LDMOD16.ASM
$(OUTD)/init1632.obj:  startup\INIT1632.ASM
$(OUTD)/malloc.obj:    startup\MALLOC.ASM
$(OUTD)/sbrk.obj:      startup\SBRK.ASM
$(OUTD)/libmain.obj:   startup\LIBMAIN.C

# the 16-bit code is included in binary format into rmwrap.asm.

$(OUTD)/rmwrap.obj:    src\RMWRAP.ASM src\RMCODE1.ASM src\RMCODE2.ASM
        @$(ASM) -q -bin -Fl$(OUTD)\ -Fo$(OUTD)\rmcode1.bin src\RMCODE1.ASM
        @$(ASM) -q -bin -Fl$(OUTD)\ -Fo$(OUTD)\rmcode2.bin src\RMCODE2.ASM
        @$(ASM) -q -DNOTFLAT -D?MODEL=small -Fo$@ -DOUTD=$(OUTD) src\RMWRAP.ASM

clean: .SYMBOLIC
	@del $(OUTD)\$(NAME).lib
	@del $(OUTD)\$(NAME2).lib
	@del $(OUTD)\$(NAME).exe
	@del $(OUTD)\$(NAME2).drv
	@del $(OUTD)\*.obj
	@del $(OUTD)\*.map
	@del $(OUTD)\*.lst
	@del $(OUTD)\rmcode.bin
