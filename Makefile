SYS		= c64
AS		= ca65
LD		= ld65

AFLAGS		= -t $(SYS) -g

DISKFILE	= ziri-demo

HCC		= gcc
HCFLAGS		= -O2 -g0
HTOOLS		= tools/bmp2c64 tools/cc1541

BINARIES	= loader kickstart amigados music

loader_OBJS	= c64startup.o loader.o gfx-core.o gfx-line.o soundtable.o \
		  	snd_play.o ziri_ambi.o rasterfx.o text80.o font.o \
			sprites.o spritezone.o marquee_sprites.o \
			topborder_sprites.o
loader_LDFLAGS	= -Ln loader.lbl -m loader.map -C c64-asm.cfg

kickstart_OBJS	=
kickstart_LINKCFG =
kickstart_LDFLAGS = -Ln kickstart.lbl -m kickstart.map -C c64-asm.cfg

amigados_OBJS	=
amigados_LINKCFG =
amigados_LDFLAGS = -Ln amigados.lbl -m amigados.map -C c64-asm.cfg

music_OBJS	=
music_LINKCFG	=
music_LDFLAGS	= -Ln music.lbl -m music.map -C c64-asm.cfg

all:	$(BINARIES)

loader:	$(loader_OBJS)
	$(LD) -oloader $(loader_LDFLAGS) $(loader_OBJS)

kickstart:
	touch kickstart

amigados:
	touch amigados

music:
	touch music

disk:	all tools/cc1541
	mkdir -p disks
	tools/cc1541 -x \
		-n'C=64 WORKBENCH' -i'AMIGA' \
		-d \
		-f'  DEMO: MUSIC   ' -d \
		-f'                ' -d \
		-f'  RELEASE 0.5B  ' -d \
		-f'  2013/12/04    ' -d \
		-f'  BY ZIRIAS     ' -d \
		-d \
		-f'  BOOTLOADER    ' -wloader \
		-d \
		-f'                ' -d \
		-f'C64 AMIGA FILES:' -d \
		-d \
		-f'KICKSTART       ' -u -wkickstart \
		-f'AMIGADOS        ' -u -wamigados \
		-f'MUSIC           ' -u -wmusic \
		-d \
		disks/$(DISKFILE).d64

tools/cc1541:	tools/cc1541.o
	-$(HCC) -o$@ $^

tools/bmp2c64:	tools/bmp2c64.o
	-$(HCC) -o$@ $^

%.o:		%.c
	-$(HCC) -c -o$@ $(HCFLAGS) $<

%.o:		%.s
	$(AS) -o$@ $(AFLAGS) $<

font.s:		res/font_topaz_80col_petscii_western.bmp tools/bmp2c64
	-if [ -x tools/bmp2c64 ]; then tools/bmp2c64 $< >font.s; fi

topborder_sprites.s: tools/bmp2c64 \
		res/sprite_black_r.bmp \
		res/sprite_blue_r.bmp \
		res/sprite_blue_l3.bmp \
		res/sprite_blue_0_l2.bmp \
		res/sprite_blue_0_l1.bmp \
		res/sprite_white_r.bmp \
		res/sprite_white_l2.bmp \
		res/sprite_white_l1.bmp \
		res/sprite_blue_1_l2.bmp \
		res/sprite_blue_1_l1.bmp
	-if [ -x tools/bmp2c64 ]; then \
	    echo '.export topborder_sprites' >topborder_sprites.s; \
	    echo '.rodata' >>topborder_sprites.s; \
	    echo 'topborder_sprites:' >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_black_r.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_blue_r.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_blue_l3.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_blue_0_l2.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_blue_0_l1.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_white_r.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_white_l2.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_white_l1.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_blue_1_l2.bmp >>topborder_sprites.s; \
	    tools/bmp2c64 res/sprite_blue_1_l1.bmp >>topborder_sprites.s; \
	fi

clean:
	rm -f $(BINARIES)
	rm -f *.o
	rm -f *.map
	rm -f *.lbl
	rm -fr disks
	rm -f tools/*.o
	rm -f $(HTOOLS)

mrproper:	clean
	rm -f font.s
	rm -f topborder_sprites.s

.PHONY:	disk all clean mrproper

.SUFFIXES:

# vim: noet:si:ts=8:sts=8:sw=8
