;
; C64 startup code
;

.segment	"STARTUP"

		.word	bs_head
bs_head:	.word	@bs_next
		.word	$17
		.byte	$9E,"2061"
		.byte	$00
@bs_next:	.word	0

