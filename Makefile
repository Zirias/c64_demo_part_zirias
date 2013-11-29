SYS		= c64
LINKCFG		= ld65.cfg
AS		= ca65
LD		= ld65
C1541		= c1541

AFLAGS		= -t $(SYS) -g
LDFLAGS		= -Ln $(BINARY).lbl -m $(BINARY).map -C $(LINKCFG)

BINARY		= demo
MODULES		= gfx-core.o gfx-line.o soundtable.o snd_play.o ziri_ambi.o \
			rasterfx.o text80.o font.o

DISKFILE	= ziri-demo
DISKNAME	= zirias
PRGNAME		= zirias
DISKID		= zz

OBJS		= c64startup.o $(BINARY).o $(MODULES)

HCC		= gcc
HCFLAGS		= -O2 -g0
TOOLS		= tools/bmp2c64

bmp2c64_OBJS	= tools/bmp2c64.o

all:	$(OBJS)
	$(LD) -o $(BINARY) $(LDFLAGS) $(OBJS)

disk:	all
	mkdir -p disks
	$(C1541) \
		-format $(DISKNAME),$(DISKID) d64 disks/$(DISKFILE).d64 \
		-attach disks/$(DISKFILE).d64 \
		-write $(BINARY) $(PRGNAME).prg

tools/bmp2c64:	tools/bmp2c64.o
	-$(HCC) -o$@ $^

tools/%.o:	tools/%.c
	-$(HCC) -c -o$@ $(HCFLAGS) $<

%.o:		%.s
	$(AS) -o$@ $(AFLAGS) $<

font.s:		res/font_topaz_80col_petscii_western.bmp $(TOOLS)
	-tools/bmp2c64 $< >font.s
	
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

.PHONY:	disk all clean mrproper
