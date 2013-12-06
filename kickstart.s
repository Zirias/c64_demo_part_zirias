;
; kickstart.s
;
; load the rest of the demo
;

.export basicsysaddr

.import initfastload
.import fastload
.import fl_filename
.import fl_loadaddr

.import amigados

.segment "KICKSTART"

		.word	$0801
                .word   bs_next
                .word   $17		; 23
                .byte   $9E		; SYS
basicsysaddr:	.byte	"2062", 0
                .byte	0
bs_next:	.word   0

loader:
		jsr	initfastload
		lda	#'a'
		sta	fl_filename
		lda	#'m'
		sta	fl_filename+1
		lda	#0
		sta	fl_loadaddr
		lda	#$12
		sta	fl_loadaddr+1
		jsr	fastload
		jmp	amigados

; vim: et:si:ts=8:sts=8:sw=8
