SYS		= c64
LINKCFG		= ld65.cfg
AS		= ca65
LD		= ld65
C1541		= c1541

AFLAGS		= -t $(SYS) -g
LDFLAGS		= -Ln $(BINARY).lbl -m $(BINARY).map -C $(LINKCFG)

BINARY		= demo
MODULES		= gfx-core.o gfx-line.o soundtable.o snd_play.o ziri_ambi.o \
			rasterfx.o

DISKFILE	= ziri-demo
DISKNAME	= zirias
PRGNAME		= zirias
DISKID		= zz

OBJS		= c64startup.o $(BINARY).o $(MODULES)

all:	$(OBJS)
	$(LD) -o $(BINARY) $(LDFLAGS) $(OBJS)

disk:	all
	mkdir -p disks
	$(C1541) \
		-format $(DISKNAME),$(DISKID) d64 disks/$(DISKFILE).d64 \
		-attach disks/$(DISKFILE).d64 \
		-write $(BINARY) $(PRGNAME).prg

%.o:	%.s
	$(AS) -o $@ $(AFLAGS) $<
	
clean:
	rm -f $(BINARY)
	rm -f *.o
	rm -f *.map
	rm -f *.lbl
	rm -fr disks

.PHONY:	disk all clean

