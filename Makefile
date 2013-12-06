SYS		= c64
AS		= ca65
LD		= ld65

AFLAGS		= -t $(SYS) -g

DISKFILE	= ziri-demo

HCC		= gcc
HCFLAGS		= -O2 -g0

OBJECTS		= kickstart.o fastload.o music.o gfx-core.o gfx-line.o \
		  	soundtable.o snd_play.o ziri_ambi.o rasterfx.o \
			text80.o font.o sprites.o spritezone.o \
			marquee_sprites.o topborder_sprites.o
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

cc1541_EXTRA =
bmp2c64_EXTRA =

endif

HTOOLS		= tools$(PSEP)bmp2c64$(EXE) tools$(PSEP)cc1541$(EXE)

BINARIES = demo_kickstart demo_amigados demo_music
DISKNAME = 'C=64 WORKBENCH'
DISKID = 'AMIGA'

all:	demo

demo:	$(OBJECTS) $(LINKCFG)
	$(LD) -odemo $(LDFLAGS) $(OBJECTS)

disk:	all tools$(PSEP)cc1541$(EXE)
	$(MDP) disks
	tools$(PSEP)cc1541 -x \
		-n$(DISKNAME) -i$(DISKID) \
		-d \
		-f'  DEMO: MUSIC   ' -d \
		-f'                ' -d \
		-f'  RELEASE 0.5B  ' -d \
		-f'  2013/12/04    ' -d \
		-f'  BY ZIRIAS     ' -d \
		-f'                ' -d \
		-f'C64 AMIGA FILES:' -d \
		-d \
		-f'KICKSTART       ' -wdemo_kickstart \
		-f'AMIGADOS        ' -u -s15 -wdemo_amigados \
		-f'MUSIC           ' -u -s15 -wdemo_music \
		-d \
		disks$(PSEP)$(DISKFILE).d64

tools$(PSEP)cc1541$(EXE):	tools$(PSEP)cc1541.o $(cc1541_EXTRA)
	-$(HCC) -o$@ $^

tools$(PSEP)bmp2c64$(EXE):	tools$(PSEP)bmp2c64.o $(bmp2c64_EXTRA)
	-$(HCC) -o$@ $^

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

mrproper:	clean
	$(RMF) font.s
	$(RMF) topborder_sprites.s

.PHONY:	disk all demo clean mrproper

.SUFFIXES:

# vim: noet:si:ts=8:sts=8:sw=8
