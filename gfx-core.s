;
; basic gfx-functions and global variables
;

.include "vic.inc"

.export gfx_init
.export gfx_done
.export gfx_setcolor
.export gfx_clear
.export gfx_plot

.export PLOT_XL
.export PLOT_XH
.export PLOT_Y
.export PLOT_MODE

PLOT_XL         = $fa
PLOT_XH         = $fb
PLOT_Y          = $fc
PLOT_MODE       = $f9

.segment "ADDATA"

gfx_drawpage:   .byte   $60
gfx_colpage:    .byte   $5c

.segment "AMIGADOS"

gfx_init:
                lda     CIA2_DATA_A
                and     #%11111110
                sta     CIA2_DATA_A
                lda     VIC_CTL1
                ora     #%00100000
                sta     VIC_CTL1
                lda     VIC_MEMCTL
                and     #%01111111
                ora     #%01111000
                sta     VIC_MEMCTL
                rts

gfx_done:
                lda     CIA2_DATA_A
                ora     #%00000011
                sta     CIA2_DATA_A
                lda     VIC_CTL1
                and     #%11011111
                sta     VIC_CTL1
                lda     VIC_MEMCTL
                and     #%00010111
                sta     VIC_MEMCTL
                rts

gfx_setcolor:
                stx     $9e
                asl     a
                asl     a
                asl     a
                asl     a
                adc     $9e
                ldx     gfx_colpage
                stx     $9f
                ldy     #0
                sty     $9e
                ldx     #$04
sc_loop:        sta     ($9e),y
                iny
                bne     sc_loop
                inc     $9f
                dex
                bne     sc_loop
                rts

gfx_clear:
                lda     #0
                tay
                sta     $9e
                ldx     gfx_drawpage
                stx     $9f
                ldx     #$20
cl_loop:        sta     ($9e),y
                iny
                bne     cl_loop
                inc     $9f
                dex
                bne     cl_loop
                rts

gfx_plot:
                ldx     PLOT_Y
                ldy     PLOT_XL
                tya
                and     #$f8
                clc
                adc     gfx_tabl,x
                sta     $9e
                lda     PLOT_XH
                adc     gfx_tabh,x
                sta     $9f
                lda     gfx_bits,y
                ldy     #0
                bit     PLOT_MODE
                bvs     cp_set
                bmi     cp_inv
cp_del:         eor     #$ff
                and     ($9e),y
                sta     ($9e),y
                rts
cp_set:         ora     ($9e),y
                sta     ($9e),y
                rts
cp_inv:         eor     ($9e),y
                sta     ($9e),y
                rts

.segment "ADDATA"
gfx_tabl:       .byte   $00,$01,$02,$03,$04,$05,$06,$07
                .byte   $40,$41,$42,$43,$44,$45,$46,$47
                .byte   $80,$81,$82,$83,$84,$85,$86,$87
                .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
                .byte   $00,$01,$02,$03,$04,$05,$06,$07
                .byte   $40,$41,$42,$43,$44,$45,$46,$47
                .byte   $80,$81,$82,$83,$84,$85,$86,$87
                .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
                .byte   $00,$01,$02,$03,$04,$05,$06,$07
                .byte   $40,$41,$42,$43,$44,$45,$46,$47
                .byte   $80,$81,$82,$83,$84,$85,$86,$87
                .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
                .byte   $00,$01,$02,$03,$04,$05,$06,$07
                .byte   $40,$41,$42,$43,$44,$45,$46,$47
                .byte   $80,$81,$82,$83,$84,$85,$86,$87
                .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
                .byte   $00,$01,$02,$03,$04,$05,$06,$07
                .byte   $40,$41,$42,$43,$44,$45,$46,$47
                .byte   $80,$81,$82,$83,$84,$85,$86,$87
                .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
                .byte   $00,$01,$02,$03,$04,$05,$06,$07
                .byte   $40,$41,$42,$43,$44,$45,$46,$47
                .byte   $80,$81,$82,$83,$84,$85,$86,$87
                .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
                .byte   $00,$01,$02,$03,$04,$05,$06,$07

gfx_tabh:       .byte   $60,$60,$60,$60,$60,$60,$60,$60
                .byte   $61,$61,$61,$61,$61,$61,$61,$61
                .byte   $62,$62,$62,$62,$62,$62,$62,$62
                .byte   $63,$63,$63,$63,$63,$63,$63,$63
                .byte   $65,$65,$65,$65,$65,$65,$65,$65
                .byte   $66,$66,$66,$66,$66,$66,$66,$66
                .byte   $67,$67,$67,$67,$67,$67,$67,$67
                .byte   $68,$68,$68,$68,$68,$68,$68,$68
                .byte   $6A,$6A,$6A,$6A,$6A,$6A,$6A,$6A
                .byte   $6B,$6B,$6B,$6B,$6B,$6B,$6B,$6B
                .byte   $6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C
                .byte   $6D,$6D,$6D,$6D,$6D,$6D,$6D,$6D
                .byte   $6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F
                .byte   $70,$70,$70,$70,$70,$70,$70,$70
                .byte   $71,$71,$71,$71,$71,$71,$71,$71
                .byte   $72,$72,$72,$72,$72,$72,$72,$72
                .byte   $74,$74,$74,$74,$74,$74,$74,$74
                .byte   $75,$75,$75,$75,$75,$75,$75,$75
                .byte   $76,$76,$76,$76,$76,$76,$76,$76
                .byte   $77,$77,$77,$77,$77,$77,$77,$77
                .byte   $79,$79,$79,$79,$79,$79,$79,$79
                .byte   $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A
                .byte   $7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B
                .byte   $7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C
                .byte   $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E

gfx_bits:       .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01
                .byte   $80,$40,$20,$10,$08,$04,$02,$01

; vim: et:si:ts=8:sts=8:sw=8
