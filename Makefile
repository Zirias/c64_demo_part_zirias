SYS		= c64
SYSCFG		= c64-asm.cfg
AS		= ca65
LD		= ld65
AFLAGS		= -t $(SYS) -g
LDFLAGS		= -Ln $(BINARY).lbl -m $(BINARY).map -C $(SYSCFG)

BINARY		= demo
MODULES		= gfx-core.o gfx-line.o soundtable.o snd_play.o ziri_ambi.o \
			rasterfx.o

OBJS		= c64startup.o $(BINARY).o $(MODULES)

all:	$(OBJS)
	$(LD) -o $(BINARY) $(LDFLAGS) $(OBJS)

%.o:	%.s
	$(AS) -o $@ $(AFLAGS) $<
	
clean:
	rm -f $(BINARY)
	rm -f *.o

