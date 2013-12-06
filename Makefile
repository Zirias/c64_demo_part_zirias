SYS		= c64
AS		= ca65
LD		= ld65

AFLAGS		= -t $(SYS) -g

DISKFILE	= ziri-demo

HCC		= gcc
HCFLAGS		= -O2 -g0
HTOOLS		= tools/bmp2c64 tools/cc1541

OBJECTS		= kickstart.o fastload.o music.o gfx-core.o gfx-line.o \
		  	soundtable.o snd_play.o ziri_ambi.o rasterfx.o \
			text80.o font.o sprites.o spritezone.o \
			marquee_sprites.o topborder_sprites.o
LINKCFG = demo.cfg
LDFLAGS	= -Ln demo.lbl -m demo.map -C $(LINKCFG)

all:	demo

demo:	$(OBJECTS) $(LINKCFG)
	$(LD) -odemo $(LDFLAGS) $(OBJECTS)

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
		-f'                ' -d \
		-f'C64 AMIGA FILES:' -d \
		-d \
		-f'KICKSTART       ' -wdemo_kickstart \
		-f'AMIGADOS        ' -u -s15 -wdemo_amigados \
		-f'MUSIC           ' -u -s15 -wdemo_music \
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
	-if [ -x tools/bmp2c64 ]; then tools/bmp2c64 -s ADDATA $< >font.s; fi

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
	    echo '.segment "ADDATA"' >>topborder_sprites.s; \
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

.PHONY:	disk all demo clean mrproper

.SUFFIXES:

# vim: noet:si:ts=8:sts=8:sw=8
