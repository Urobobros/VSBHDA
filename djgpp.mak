
	# create vsbhdad.exe with DJGPP and JWasm.
# to create a debug version, enter: make -f djgpp.mak DEBUG=1
# note that JWasm v2.17+ is needed ( understands -djgpp option )

ifndef DEBUG
DEBUG=0
endif

NAME=vsbhda

ifeq ($(DEBUG),1)
OUTD=djgppd
C_DEBUG_FLAGS=-D_DEBUG
else
OUTD=djgpp
C_DEBUG_FLAGS=
endif

vpath_src=src MPXPLAY
vpath %.c $(vpath_src)
vpath %.C $(vpath_src)
vpath %.cpp $(vpath_src)
vpath %.CPP $(vpath_src)
vpath %.asm $(vpath_src)
vpath %.ASM $(vpath_src)
vpath_header=src mpxplay
vpath %.h $(vpath_header)
vpath_obj=./$(OUTD)/
vpath %.o $(vpath_obj)

ifndef CROSS
CROSS=
endif

CC=$(CROSS)gcc
CXX=$(CROSS)g++
LD=$(CXX)
AR=$(CROSS)ar
STRIP=$(CROSS)strip
EXE2COFF=exe2coff

# recognized extensions for building on case-sensitive systems
.SUFFIXES: .o .C .CPP .ASM

OBJFILES=\
        $(OUTD)/MAIN.o          $(OUTD)/SNDISR.o        $(OUTD)/PTRAP.o        $(OUTD)/DBOPL.o          $(OUTD)/LINEAR.o        $(OUTD)/PIC.o\
        $(OUTD)/VSB.o           $(OUTD)/VDMA.o          $(OUTD)/VIRQ.o         $(OUTD)/VOPL3.o          $(OUTD)/VMPU.o          $(OUTD)/TSF.o\
        $(OUTD)/AC97MIX.o       $(OUTD)/AU_CARDS.o\
        $(OUTD)/DMAIRQ.o        $(OUTD)/PCIBIOS.o       $(OUTD)/MEMORY.o       $(OUTD)/PHYSMEM.o        $(OUTD)/TIMER.o\
        $(OUTD)/SC_E1371.o      $(OUTD)/SC_ICH.o        $(OUTD)/SC_INTHD.o     $(OUTD)/SC_VIA82.o       $(OUTD)/SC_SBLIV.o      $(OUTD)/SC_SBL24.o\
        $(OUTD)/STACKIO.o       $(OUTD)/STACKISR.o      $(OUTD)/SBISR.o        $(OUTD)/INT31.o          $(OUTD)/RMWRAP.o        $(OUTD)/MIXER.o\
        $(OUTD)/HAPI.o          $(OUTD)/DPRINTF.o       $(OUTD)/VIOOUT.o       $(OUTD)/DJDPMI.o         $(OUTD)/UNINST.o        $(OUTD)/FILEACC.o

INCLUDE_DIRS=src MPXPLAY
SRC_DIRS=src MPXPLAY

C_OPT_FLAGS=-Os -fno-asynchronous-unwind-tables
C_EXTRA_FLAGS=-march=i386
LD_FLAGS=$(addprefix -Xlinker ,$(LD_EXTRA_FLAGS))
LD_EXTRA_FLAGS=-Map $(OUTD)/$(NAME).map

INCLUDES=$(addprefix -I,$(INCLUDE_DIRS))
LIBS=-lstdc++ -lm

COMPILE.asm.o=jwasm.exe -q -djgpp -Istartup -D?MODEL=small -DDJGPP -Fo$@ $<
COMPILE.c.o=$(CC) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CFLAGS) $(INCLUDES) -x c -c $< -o $@
COMPILE.cpp.o=$(CXX) $(C_DEBUG_FLAGS) $(C_OPT_FLAGS) $(C_EXTRA_FLAGS) $(CPPFLAGS) $(INCLUDES) -c $< -o $@

$(OUTD)/%.o: src/%.c
	$(COMPILE.c.o)

$(OUTD)/%.o: src/%.C
	$(COMPILE.c.o)

$(OUTD)/%.o: src/%.cpp
	$(COMPILE.cpp.o)

$(OUTD)/%.o: src/%.CPP
	$(COMPILE.cpp.o)

$(OUTD)/%.o: src/%.asm
	$(COMPILE.asm.o)

$(OUTD)/%.o: src/%.ASM
	$(COMPILE.asm.o)

$(OUTD)/%.o: mpxplay/%.c
	$(COMPILE.c.o)

$(OUTD)/%.o: mpxplay/%.C
	$(COMPILE.c.o)

all:: $(OUTD) $(OUTD)/$(NAME)d.exe

$(OUTD):
	@mkdir $(OUTD)

$(OUTD)/$(NAME)d.exe:: $(OUTD)/$(NAME).ar
	$(LD) -o $@ $(OUTD)/MAIN.o $(OUTD)/$(NAME).ar $(LD_FLAGS) $(LIBS)
	$(STRIP) -s $@
	-@$(EXE2COFF) $@ >/dev/null 2>&1 || true

$(OUTD)/$(NAME).ar:: $(OBJFILES)
	$(AR) --target=coff-go32 -rc $(OUTD)/$(NAME).ar $(OBJFILES)

# to avoid problems with 16-bit relocations, the 16-bit code
# is included in binary format into rmwrap.asm.

$(OUTD)/RMWRAP.o: RMWRAP.ASM RMCODE1.ASM RMCODE2.ASM
	jwasm.exe -q -bin -Fl$(OUTD)/ -Fo$(OUTD)/rmcode1.bin src/RMCODE1.ASM
	jwasm.exe -q -bin -Fl$(OUTD)/ -Fo$(OUTD)/rmcode2.bin src/RMCODE2.ASM
	jwasm.exe -q -djgpp -D?MODEL=small -DOUTD=$(OUTD) -Fo$@ src/RMWRAP.ASM

$(OUTD)/AC97MIX.o:  MPXPLAY/AC97MIX.C   MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/AC97MIX.H
	$(COMPILE.c.o)
$(OUTD)/AU_CARDS.o: MPXPLAY/AU_CARDS.C  MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H src/CONFIG.H
	$(COMPILE.c.o)
$(OUTD)/DMAIRQ.o:   MPXPLAY/DMAIRQ.C    MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H
	$(COMPILE.c.o)
$(OUTD)/MEMORY.o:   MPXPLAY/MEMORY.C
	$(COMPILE.c.o)
$(OUTD)/PCIBIOS.o:  MPXPLAY/PCIBIOS.C   MPXPLAY/PCIBIOS.H
	$(COMPILE.c.o)
$(OUTD)/PHYSMEM.o:  MPXPLAY/PHYSMEM.C
	$(COMPILE.c.o)
$(OUTD)/SC_E1371.o: MPXPLAY/SC_E1371.C  MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H MPXPLAY/PCIBIOS.H MPXPLAY/AC97MIX.H
	$(COMPILE.c.o)
$(OUTD)/SC_ICH.o:   MPXPLAY/SC_ICH.C    MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H MPXPLAY/PCIBIOS.H MPXPLAY/AC97MIX.H
	$(COMPILE.c.o)
$(OUTD)/SC_INTHD.o: MPXPLAY/SC_INTHD.C  MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H MPXPLAY/PCIBIOS.H MPXPLAY/SC_INTHD.H
	$(COMPILE.c.o)
$(OUTD)/SC_SBL24.o: MPXPLAY/SC_SBL24.C  MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H MPXPLAY/PCIBIOS.H MPXPLAY/AC97MIX.H MPXPLAY/SC_SBL24.H MPXPLAY/EMU10K1.H
	$(COMPILE.c.o)
$(OUTD)/SC_SBLIV.o: MPXPLAY/SC_SBLIV.C  MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H MPXPLAY/PCIBIOS.H MPXPLAY/AC97MIX.H MPXPLAY/SC_SBLIV.H MPXPLAY/EMU10K1.H
	$(COMPILE.c.o)
$(OUTD)/SC_VIA82.o: MPXPLAY/SC_VIA82.C  MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/DMAIRQ.H MPXPLAY/PCIBIOS.H MPXPLAY/AC97.H
	$(COMPILE.c.o)
$(OUTD)/TIMER.o:    MPXPLAY/TIMER.C     MPXPLAY/MPXPLAY.H MPXPLAY/AU_CARDS.H MPXPLAY/TIMER.H
	$(COMPILE.c.o)

$(OUTD)/DBOPL.o:    src/DBOPL.CPP   src/DBOPL.H
	$(COMPILE.cpp.o)
$(OUTD)/LINEAR.o:   src/LINEAR.C    src/LINEAR.H src/PLATFORM.H
	$(COMPILE.c.o)
$(OUTD)/MAIN.o:     src/MAIN.C      src/LINEAR.H src/PLATFORM.H src/PTRAP.H src/VOPL3.H src/PIC.H src/CONFIG.H src/VSB.H src/VDMA.H src/VIRQ.H src/AU.H src/VERSION.H
	$(COMPILE.c.o)
$(OUTD)/PIC.o:      src/PIC.C       src/PIC.H src/PLATFORM.H src/PTRAP.H
	$(COMPILE.c.o)
$(OUTD)/PTRAP.o:    src/PTRAP.C     src/LINEAR.H src/PLATFORM.H src/PTRAP.H src/CONFIG.H
	$(COMPILE.c.o)
$(OUTD)/SNDISR.o:   src/SNDISR.C    src/LINEAR.H src/PLATFORM.H src/VOPL3.H src/PIC.H src/CONFIG.H src/VSB.H src/VDMA.H src/VIRQ.H src/CTADPCM.H src/AU.H
	$(COMPILE.c.o)
$(OUTD)/TSF.o:      src/TSF.C       tsf/TSF.H
	$(COMPILE.c.o)
$(OUTD)/VDMA.o:     src/VDMA.C      src/LINEAR.H src/PLATFORM.H src/PTRAP.H src/VDMA.H src/CONFIG.H
	$(COMPILE.c.o)
$(OUTD)/VIRQ.o:     src/VIRQ.C      src/LINEAR.H src/PLATFORM.H src/PIC.H src/PTRAP.H src/VIRQ.H src/CONFIG.H
	$(COMPILE.c.o)
$(OUTD)/VOPL3.o:    src/VOPL3.CPP   src/DBOPL.H src/VOPL3.H src/CONFIG.H
	$(COMPILE.cpp.o)
$(OUTD)/VSB.o:      src/VSB.C       src/LINEAR.H src/PLATFORM.H src/VSB.H src/CONFIG.H
	$(COMPILE.c.o)
$(OUTD)/VMPU.o:     src/VMPU.C      src/LINEAR.H src/PLATFORM.H src/VMPU.H src/CONFIG.H
	$(COMPILE.c.o)

$(OUTD)/DJDPMI.o:   src/DJDPMI.ASM
	$(COMPILE.asm.o)
$(OUTD)/DPRINTF.o:  src/DPRINTF.ASM
	$(COMPILE.asm.o)
$(OUTD)/FILEACC.o:  src/FILEACC.ASM
	$(COMPILE.asm.o)
$(OUTD)/HAPI.o:     src/HAPI.ASM
	$(COMPILE.asm.o)
$(OUTD)/INT31.o:    src/INT31.ASM
	$(COMPILE.asm.o)
$(OUTD)/MIXER.o:    src/MIXER.ASM
	$(COMPILE.asm.o)
$(OUTD)/SBISR.o:    src/SBISR.ASM
	$(COMPILE.asm.o)
$(OUTD)/STACKIO.o:  src/STACKIO.ASM
	$(COMPILE.asm.o)
$(OUTD)/STACKISR.o: src/STACKISR.ASM
	$(COMPILE.asm.o)
$(OUTD)/UNINST.o:   src/UNINST.ASM
	$(COMPILE.asm.o)
$(OUTD)/VIOOUT.o:   src/VIOOUT.ASM
	$(COMPILE.asm.o)

clean::
	del $(OUTD)\$(NAME)d.exe
	del $(OUTD)\$(NAME).ar
	del $(OUTD)\*.o

