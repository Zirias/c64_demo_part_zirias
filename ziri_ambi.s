;
; Zirias ambigram in 8 lines and 20 cols
;

.include "vicconfig.inc"

LINE1   = vic_bitmap + $0B90
LINE2   = vic_bitmap + $0CD0
LINE3   = vic_bitmap + $0E10
LINE4   = vic_bitmap + $0F50
LINE5   = vic_bitmap + $1090
LINE6   = vic_bitmap + $11D0
LINE7   = vic_bitmap + $1310
LINE8   = vic_bitmap + $1450

length  = 160

.export ziri_ambi

.segment "MUSIC"

ziri_ambi:
                ldx     #length
loop1:          lda     ambi1-1,x
                sta     LINE1-1,x
                dex
                bne     loop1
                ldx     #length
loop2:          lda     ambi2-1,x
                sta     LINE2-1,x
                dex
                bne     loop2
                ldx     #length
loop3:          lda     ambi3-1,x
                sta     LINE3-1,x
                dex
                bne     loop3
                ldx     #length
loop4:          lda     ambi4-1,x
                sta     LINE4-1,x
                dex
                bne     loop4
                ldx     #length
loop5:          lda     ambi5-1,x
                sta     LINE5-1,x
                dex
                bne     loop5
                ldx     #length
loop6:          lda     ambi6-1,x
                sta     LINE6-1,x
                dex
                bne     loop6
                ldx     #length
loop7:          lda     ambi7-1,x
                sta     LINE7-1,x
                dex
                bne     loop7
                ldx     #length
loop8:          lda     ambi8-1,x
                sta     LINE8-1,x
                dex
                bne     loop8
                rts

.segment "MUDATA"

ambi1:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$01,$03,$0F
        .byte   $00,$00,$00,$00,$3F,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$C0,$F8,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$FF
        .byte   $00,$00,$00,$00,$01,$07,$0F,$FF
        .byte   $00,$00,$00,$03,$87,$C7,$C7,$C7
        .byte   $00,$00,$00,$C0,$E0,$F0,$F0,$E0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$1E,$3F,$3F,$3F,$3F,$3F,$3E
        .byte   $00,$00,$00,$80,$80,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
ambi2:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $1F,$3F,$38,$70,$60,$00,$00,$1F
        .byte   $FF,$FF,$FF,$FF,$7F,$1F,$00,$E0
        .byte   $FF,$FF,$FF,$FF,$FF,$FE,$00,$00
        .byte   $FF,$FF,$FF,$FF,$FF,$3F,$3F,$FF
        .byte   $FF,$FF,$FE,$F8,$F0,$C0,$80,$00
        .byte   $87,$07,$07,$03,$01,$00,$00,$00
        .byte   $E0,$C0,$C0,$80,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $3E,$1C,$00,$00,$00,$00,$38,$FC
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$01,$07
        .byte   $00,$00,$00,$00,$00,$00,$FC,$FF
        .byte   $00,$00,$00,$00,$00,$00,$02,$0C
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
ambi3:  .byte   $00,$03,$07,$0F,$1F,$3F,$3E,$7E
        .byte   $FF,$F8,$E0,$C0,$00,$00,$00,$00
        .byte   $F8,$7E,$0F,$07,$07,$03,$07,$07
        .byte   $03,$07,$0F,$BF,$FF,$FF,$FF,$FF
        .byte   $FC,$F8,$F0,$FC,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$80,$80,$C1
        .byte   $07,$0F,$3F,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$80,$81,$C1,$C3,$C1,$E1,$E0
        .byte   $30,$7C,$FE,$FE,$FF,$FF,$FF,$FF
        .byte   $0F,$1F,$3F,$7F,$FF,$EF,$C7,$87
        .byte   $83,$E7,$E7,$C3,$C1,$81,$80,$00
        .byte   $FC,$FE,$FE,$FF,$FE,$FE,$FE,$FE
        .byte   $00,$00,$00,$0F,$0F,$07,$07,$07
        .byte   $1F,$31,$E0,$E0,$C0,$C0,$C0,$C0
        .byte   $FF,$FF,$FF,$7F,$7F,$3F,$1F,$1F
        .byte   $FC,$FC,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$E0,$FC,$FF,$FF,$FF
        .byte   $00,$00,$01,$03,$0F,$FF,$FF,$F8
        .byte   $00,$40,$E0,$E0,$FF,$FF,$FF,$7F
        .byte   $00,$00,$00,$00,$E0,$E0,$C0,$C0
ambi4:  .byte   $7E,$7E,$7E,$7E,$7F,$7F,$7F,$3F
        .byte   $00,$03,$03,$03,$03,$87,$FF,$FF
        .byte   $07,$87,$F3,$F9,$FC,$FE,$FE,$FF
        .byte   $FF,$F1,$C0,$80,$00,$00,$00,$00
        .byte   $FF,$FF,$3F,$1F,$0F,$0F,$0F,$07
        .byte   $E1,$E1,$E0,$E0,$E0,$E0,$E0,$E0
        .byte   $FF,$FF,$FF,$3F,$1F,$0F,$07,$07
        .byte   $E0,$E0,$F0,$F0,$F8,$F8,$F8,$F8
        .byte   $FF,$FF,$7F,$7F,$7F,$7F,$7F,$7F
        .byte   $06,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE
        .byte   $0F,$0F,$1F,$1F,$1F,$1F,$1F,$1F
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$E0
        .byte   $0F,$0F,$0F,$07,$07,$07,$07,$07
        .byte   $FF,$FF,$FF,$FF,$E0,$E0,$E0,$E0
        .byte   $FF,$FF,$F0,$80,$00,$00,$00,$00
        .byte   $E0,$E0,$E0,$E0,$F0,$F8,$FE,$FF
        .byte   $3F,$0F,$00,$00,$03,$07,$1F,$FF
        .byte   $80,$00,$00,$00,$E0,$F0,$F8,$FC
ambi5:  .byte   $3F,$1F,$07,$00,$00,$00,$01,$03
        .byte   $FC,$F0,$C0,$00,$00,$00,$FC,$FE
        .byte   $FF,$1F,$0F,$07,$07,$03,$07,$1F
        .byte   $00,$00,$00,$00,$0F,$3F,$FF,$FF
        .byte   $07,$07,$07,$7F,$FF,$FF,$FF,$FF
        .byte   $E0,$E0,$E0,$E0,$E0,$F0,$F0,$F8
        .byte   $03,$03,$03,$03,$03,$03,$03,$03
        .byte   $F8,$F8,$F8,$F8,$F8,$F0,$F0,$E0
        .byte   $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$60,$E1
        .byte   $FE,$FE,$FE,$FE,$FE,$FE,$FF,$FF
        .byte   $1F,$1F,$1F,$0F,$0F,$07,$07,$07
        .byte   $E0,$F0,$F8,$F8,$FE,$FF,$FF,$FF
        .byte   $07,$07,$07,$07,$07,$07,$87,$83
        .byte   $F0,$F0,$F0,$F8,$FC,$FF,$FF,$FF
        .byte   $00,$00,$00,$01,$03,$0F,$FF,$FF
        .byte   $7F,$7F,$3F,$9F,$CF,$E3,$E0,$E0
        .byte   $FF,$E3,$C0,$C0,$C0,$C0,$00,$00
        .byte   $FE,$FE,$FE,$FE,$7E,$7E,$7E,$7E
ambi6:  .byte   $03,$07,$07,$00,$00,$00,$00,$00
        .byte   $FF,$FF,$FF,$0F,$07,$07,$00,$00
        .byte   $FF,$FF,$FC,$C0,$80,$00,$00,$00
        .byte   $FF,$FF,$7F,$0F,$01,$00,$00,$00
        .byte   $FF,$FF,$FF,$FF,$FF,$3F,$3F,$30
        .byte   $F8,$FC,$FC,$FE,$FF,$FF,$FF,$FF
        .byte   $03,$03,$03,$07,$07,$84,$F8,$F0
        .byte   $E0,$E0,$E0,$F0,$E0,$00,$00,$00
        .byte   $7F,$7F,$7F,$FF,$7F,$7F,$7F,$3F
        .byte   $00,$01,$83,$C3,$E7,$E7,$C3,$00
        .byte   $E1,$F7,$FF,$FE,$FC,$FC,$F0,$00
        .byte   $FF,$FF,$FF,$FF,$7F,$3F,$1C,$00
        .byte   $07,$87,$C3,$C3,$83,$01,$00,$00
        .byte   $FF,$FF,$FF,$FF,$FE,$F8,$E0,$00
        .byte   $03,$01,$00,$00,$00,$00,$00,$00
        .byte   $FF,$FF,$FF,$7F,$0F,$1F,$3F,$7F
        .byte   $FF,$FF,$FF,$FF,$F8,$E0,$C0,$00
        .byte   $E0,$C0,$E0,$E0,$F0,$7C,$3F,$07
        .byte   $00,$00,$00,$01,$03,$0F,$FF,$FC
        .byte   $7C,$FC,$F8,$F0,$E0,$C0,$00,$00
ambi7:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $60,$00,$00,$00,$00,$00,$00,$00
        .byte   $3F,$0C,$00,$00,$00,$00,$00,$00
        .byte   $C0,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $1E,$00,$00,$00,$00,$38,$38,$7C
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$01,$03,$03,$07,$07
        .byte   $00,$00,$00,$C0,$C0,$E0,$E1,$E3
        .byte   $01,$03,$07,$1F,$3F,$7F,$FF,$FF
        .byte   $FE,$FC,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$3F,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$F0,$FC,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$00,$06,$0E,$1C,$BC,$F8,$F0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
ambi8:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$01,$01,$00,$00,$00,$00
        .byte   $FC,$FC,$FC,$FC,$FC,$F8,$30,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $0F,$0F,$07,$07,$00,$00,$00,$00
        .byte   $E3,$E3,$E1,$C0,$00,$00,$00,$00
        .byte   $FC,$E0,$80,$00,$00,$00,$00,$00
        .byte   $03,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$3F,$07,$00,$00,$00,$00,$00
        .byte   $FF,$FF,$FE,$00,$00,$00,$00,$00
        .byte   $E0,$80,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

; vim: et:si:ts=8:sts=8:sw=8
