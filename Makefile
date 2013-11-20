SYS		= c64
SYSCFG		= c64-asm.cfg
AS		= ca65
LD		= ld65
C1541		= c1541
DISKNAME	= ziri-demo
DISKID		= ZZ

AFLAGS		= -t $(SYS) -g
LDFLAGS		= -Ln $(BINARY).lbl -m $(BINARY).map -C $(SYSCFG)

BINARY		= demo
MODULES		= gfx-core.o gfx-line.o soundtable.o snd_play.o ziri_ambi.o \
			rasterfx.o

OBJS		= c64startup.o $(BINARY).o $(MODULES)

all:	$(OBJS)
	$(LD) -o $(BINARY) $(LDFLAGS) $(OBJS)

disk:	all
	rm -f $(DISKNAME).d64
	$(C1541) -format $(DISKNAME),$(DISKID) d64 $(DISKNAME).d64 \
		-attach $(DISKNAME).d64 -write $(BINARY) $(DISKNAME).prg

%.o:	%.s
	$(AS) -o $@ $(AFLAGS) $<
	
clean:
	rm -f $(BINARY)
	rm -f *.o
	rm -f *.map
	rm -f *.lbl
	rm -f *.d64

.PHONY:	disk all clean

