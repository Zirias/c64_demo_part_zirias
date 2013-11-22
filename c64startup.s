;
; C64 startup code
;

.export         __LOADADDR__: absolute = 1
.segment        "LOADADDR"
        .addr   *+2

.segment	"CODE"
		.word	@bs_next
		.word	$17
		.byte	$9E,"2061"
		.byte	$00
@bs_next:	.word	0

