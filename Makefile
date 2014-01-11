SYS		= c64
AS		= ca65
LD		= ld65

AFLAGS		= -t $(SYS) -g

DISKFILE	= ziri-demo

HCC		= gcc
HCFLAGS		= -O2 -g0

OBJECTS		= loader.o chainloader.o \
		kickstart.o fastload.o amigados.o gfx-core.o gfx-line.o \
		  	soundtable.o snd_play.o ziri_ambi.o raster.o \
			text80.o font.o sprites.o spritezone.o \
			marquee_sprites.o topborder_sprites.o \
			keyboard.o kbinput.o console.o cmdline.o music.o
LINKCFG = demo.cfg
LDFLAGS	= -Ln demo.lbl -m demo.map -C $(LINKCFG)

ifeq ($(OS),Windows_NT)

EXE = .exe
CMDSEP = &
PSEP = \\
CPF = copy /y
RMF = del /f /q
RMFR = -rd /s /q
MDP = -md
XIF = if exist
XTHEN = (
XFI = )
CATIN = copy /b
CATADD = +
CATOUT =

cc1541_EXTRA = tools\\getopt.o
bmp2c64_EXTRA = tools\\getopt.o
HCFLAGS += -DWIN32=1

else

EXE =
CMDSEP = ;
PSEP = /
CPF = cp -f
RMF = rm -f
RMFR = rm -fr
MDP = mkdir -p
XIF = if [ -x
XTHEN = ]; then
XFI = ; fi
CATIN = cat
CATADD = 
CATOUT = >

cc1541_EXTRA =
bmp2c64_EXTRA =

endif

mkd64bin = tools$(PSEP)mkd64$(PSEP)mkd64$(EXE)

HTOOLS = tools$(PSEP)bmp2c64$(EXE)

BINARIES = demo_boot demo_loader demo_bootload demo_kickstart \
	   demo_amigados demo_music

DISKNAME = 'C=64 WORKBENCH'
DISKID = 'AMIGA'

all:	demo

demo:	$(OBJECTS) $(LINKCFG)
	$(LD) -odemo $(LDFLAGS) $(OBJECTS)
	$(CATIN) demo_boot $(CATADD)demo_loader $(CATOUT)demo_bootloader

disk:	all $(mkd64bin)
	$(MDP) disks
	$(mkd64bin) -mcbmdos -mseparators -odisks$(PSEP)$(DISKFILE).d64 \
	  -d$(DISKNAME) -i$(DISKID) -R1 -Da0 -0 \
	  -fdemo_bootloader                    -proundtop        -S1      -w \
	  -fdemo_kickstart  -n'DEMO: AMIGADOS' -pfr -t19 -s0 -TU -S0 -i15 -w \
	  -fdemo_amigados                      -pfrmid       -TU -S0 -i15 -w \
	  -fdemo_music      -n'RELEASE 1.09A4' -pfr          -TU -S0 -i15 -w \
	  -f                -n'  2013/12/15  ' -pfr          -TD          -w \
	  -f                -n'  BY ZIRIAS   ' -pfr          -TD          -w \
	  -f                                   -proundbot    -TD          -w

tools$(PSEP)bmp2c64$(EXE):	tools$(PSEP)bmp2c64.o $(bmp2c64_EXTRA)
	-$(HCC) -o$@ $^

$(mkd64bin): tools$(PSEP)mkd64$(PSEP)Makefile
	make -C tools$(PSEP)mkd64

tools$(PSEP)mkd64$(PSEP)Makefile:
	git submodule update --init

%.o:		%.c
	-$(HCC) -c -o$@ $(HCFLAGS) $<

%.o:		%.s
	$(AS) -o$@ $(AFLAGS) $<

font.s:		res$(PSEP)font_topaz_80col_petscii_western.bmp tools$(PSEP)bmp2c64$(EXE)
	$(XIF) tools$(PSEP)bmp2c64$(EXE) $(XTHEN) \
		tools$(PSEP)bmp2c64 -s ADDATA $< >font.s $(XFI)

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
		res$(PSEP)sprite_blue_1_l1.bmp \
		topborder_sprites_head.s
	$(XIF) tools$(PSEP)bmp2c64$(EXE) $(XTHEN) \
	    $(CPF) topborder_sprites_head.s topborder_sprites.s $(CMDSEP) \
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
	$(RMF) $(BINARIES)
	$(RMF) *.o
	$(RMF) *.map
	$(RMF) *.lbl
	$(RMFR) disks
	$(RMF) tools$(PSEP)*.o
	$(RMF) $(HTOOLS)
	make -C tools$(PSEP)mkd64 clean

mrproper:	clean
	$(RMF) font.s
	$(RMF) topborder_sprites.s

.PHONY:	disk all demo clean mrproper

.SUFFIXES:

# vim: noet:si:ts=8:sts=8:sw=8
