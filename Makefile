SYS		= c64
AS		= ca65
LD		= ld65
AFLAGS		= -t $(SYS) -g
LDFLAGS		= -t $(SYS) -Ln $(BINARY).lbl -m $(BINARY).map

BINARY		= demo
MODULES		= gfx-core.o gfx-line.o soundtable.o snd_play.o ziri_ambi.o \
			rasterfx.o

OBJS		= c64startup.o $(BINARY).o $(MODULES)

all:	$(OBJS)
	$(LD) $(LDFLAGS) -o $(BINARY) $(OBJS)

%.o:	%.s
	$(AS) -o $@ $(AFLAGS) $<
	
clean:
	rm -f $(BINARY)
	rm -f *.o

