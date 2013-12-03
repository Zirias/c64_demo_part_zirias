;
; C64 startup code
;

.export         __LOADADDR__: absolute = 1
.segment        "LOADADDR"
.addr           *+2

.code
                .word   @bs_next
                .word   $17
                .byte   $9E,"2061"
                .byte   $00
@bs_next:       .word   0

; vim: et:si:ts=8:sts=8:sw=8
