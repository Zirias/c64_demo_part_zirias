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
TOOLS		= tools/bmp2c64 tools/cc1541

all:	$(OBJS)
	$(LD) -o $(BINARY) $(LDFLAGS) $(OBJS)

disk:	all tools/cc1541
	mkdir -p disks
	tools/cc1541 -x \
		-n$(DISKNAME) -i$(DISKID) \
		-d \
		-f$(PRGNAME) -w$(BINARY) \
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
	rm -f $(BINARY)
	rm -f *.o
	rm -f *.map
	rm -f *.lbl
	rm -fr disks
	rm -f tools/*.o
	rm -f $(TOOLS)

mrproper:	clean
	rm -f font.s
	rm -f topborder_sprites.s

.PHONY:	disk all clean mrproper

# vim: noet:si:ts=8:sts=8:sw=8
