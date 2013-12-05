SYS		= c64
LINKCFG		= c64-asm.cfg
AS		= ca65
LD		= ld65

AFLAGS		= -t $(SYS) -g
LDFLAGS		= -Ln $(BINARY).lbl -m $(BINARY).map -C $(LINKCFG)

BINARY		= demo
MODULES		= gfx-core.o gfx-line.o soundtable.o snd_play.o ziri_ambi.o \
			rasterfx.o text80.o font.o sprites.o spritezone.o \
			marquee_sprites.o topborder_sprites.o

DISKFILE	= ziri-demo
DISKNAME	= 'C=64 WORKBENCH'
PRGNAME		= 'ZIRIAS'
DISKID		= 'AMIGA'

OBJS		= c64startup.o $(BINARY).o $(MODULES)

HCC		= gcc
HCFLAGS		= -O2 -g0

cc1541_EXTRA	=

ifeq ($(OS),Windows_NT)

EXE = .exe
CMDSEP = &
PSEP = \\
RMF = del /f /q
RMFR = -rd /s /q
MDP = md
XIF = if exist
XTHEN = (
XFI = )

cc1541_EXTRA = tools\\popt.o
HCFLAGS += -DWIN32=1

else

EXE =
CMDSEP = ;
PSEP = /
RMF = rm -f
RMFR = rm -fr
MDP = mkdir -p
XIF = if [ -x
XTHEN = ]; then
XFI = ; fi

endif

TOOLS		= tools$(PSEP)bmp2c64$(EXE) tools$(PSEP)cc1541$(EXE)

all:	$(OBJS)
	$(LD) -o $(BINARY) $(LDFLAGS) $(OBJS)

disk:	all tools$(PSEP)cc1541$(EXE)
	$(MDP) disks
	tools$(PSEP)cc1541 -x \
		-n$(DISKNAME) -i$(DISKID) \
		-d \
		-f$(PRGNAME) -w$(BINARY) \
		-d \
		disks$(PSEP)$(DISKFILE).d64

tools$(PSEP)cc1541$(EXE):	tools$(PSEP)cc1541.o $(cc1541_EXTRA)
	-$(HCC) -o$@ $^

tools$(PSEP)bmp2c64$(EXE):	tools$(PSEP)bmp2c64.o
	-$(HCC) -o$@ $^

%.o:		%.c
	-$(HCC) -c -o$@ $(HCFLAGS) $<

%.o:		%.s
	$(AS) -o$@ $(AFLAGS) $<

font.s:		res$(PSEP)font_topaz_80col_petscii_western.bmp tools$(PSEP)bmp2c64$(EXE)
	$(XIF) tools$(PSEP)bmp2c64$(EXE) $(XTHEN) \
		tools$(PSEP)bmp2c64 $< >font.s $(XFI)

topborder_sprites.s: tools$(PSEP)bmp2c64$(EXE) \
		res$(PSEP)sprite_black_r.bmp \
		res$(PSEP)sprite_blue_r.bmp \
		res$(PSEP)sprite_blue_l3.bmp \
		res$(PSEP)sprite_blue_0_l2.bmp \
		res$(PSEP)sprite_blue_0_l1.bmp \
		res$(PSEP)sprite_white_r.bmp \
		res$(PSEP)sprite_white_l2.bmp \
		res$(PSEP)sprite_white_l1.bmp \
		res$(PSEP)sprite_blue_1_l2.bmp \
		res$(PSEP)sprite_blue_1_l1.bmp
	$(XIF) tools$(PSEP)bmp2c64$(EXE) $(XTHEN) \
	    echo '.export topborder_sprites' >topborder_sprites.s $(CMDSEP) \
	    echo '.rodata' >>topborder_sprites.s $(CMDSEP) \
	    echo 'topborder_sprites:' >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_black_r.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_blue_r.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_blue_l3.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_blue_0_l2.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_blue_0_l1.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_white_r.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_white_l2.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_white_l1.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_blue_1_l2.bmp >>topborder_sprites.s $(CMDSEP) \
	    tools$(PSEP)bmp2c64 res$(PSEP)sprite_blue_1_l1.bmp >>topborder_sprites.s \
	$(XFI)

clean:
	$(RMF) $(BINARY)
	$(RMF) *.o
	$(RMF) *.map
	$(RMF) *.lbl
	$(RMFR) disks
	$(RMF) tools$(PSEP)*.o
	$(RMF) $(TOOLS)

mrproper:	clean
	$(RMF) font.s
	$(RMF) topborder_sprites.s

.PHONY:	disk all clean mrproper

.SUFFIXES:

# vim: noet:si:ts=8:sts=8:sw=8
