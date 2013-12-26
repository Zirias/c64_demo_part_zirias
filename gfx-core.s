;
; basic gfx-functions and global variables
;

.include "vic.inc"
.include "vicconfig.inc"
.include "kickstart.inc"

.export gfx_on
.export gfx_off
.export gfx_setcolor
.export gfx_clear
.export gfx_plot

.exportzp PLOT_XL
.exportzp PLOT_XH
.exportzp PLOT_Y
.exportzp PLOT_MODE

.segment "ZPSYS": zeropage
PLOT_XL:        .res 1
PLOT_XH:        .res 1
PLOT_Y:         .res 1
PLOT_MODE:      .res 1

.segment "KICKSTART"

gfx_on:
                lda     VIC_CTL1
                ora     #%00100000
                sta     VIC_CTL1
                lda     #vic_memctl_hires
                sta     VIC_MEMCTL
                rts

gfx_off:
                lda     VIC_CTL1
                and     #%11011111
                sta     VIC_CTL1
                lda     #vic_memctl_text
                sta     VIC_MEMCTL
                rts

gfx_setcolor:
                stx     TMP_0
                asl     a
                asl     a
                asl     a
                asl     a
                adc     TMP_0
                ldx     #>vic_colram
                stx     TMP_1
                ldy     #0
                sty     TMP_0
                ldx     #$04
sc_loop:        sta     (TMP_0),y
                iny
                bne     sc_loop
                inc     TMP_1
                dex
                bne     sc_loop
                rts

gfx_clear:
                lda     #0
                tay
                sta     TMP_0
                ldx     #>vic_bitmap
                stx     TMP_1
                ldx     #$20
cl_loop:        sta     (TMP_0),y
                iny
                bne     cl_loop
                inc     TMP_1
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
                sta     TMP_0
                lda     PLOT_XH
                adc     gfx_tabh,x
                sta     TMP_1
                lda     gfx_bits,y
                ldy     #0
                bit     PLOT_MODE
                bvs     cp_set
                bmi     cp_inv
cp_del:         eor     #$ff
                and     (TMP_0),y
                sta     (TMP_0),y
                rts
cp_set:         ora     (TMP_0),y
                sta     (TMP_0),y
                rts
cp_inv:         eor     (TMP_0),y
                sta     (TMP_0),y
                rts

.segment "KSDATA"
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

bh00 = (vic_bitmap >> 8)
bh01 = bh00 + $01
bh02 = bh00 + $02
bh03 = bh00 + $03
bh05 = bh00 + $05
bh06 = bh00 + $06
bh07 = bh00 + $07
bh08 = bh00 + $08
bh0a = bh00 + $0a
bh0b = bh00 + $0b
bh0c = bh00 + $0c
bh0d = bh00 + $0d
bh0f = bh00 + $0f
bh10 = bh00 + $10
bh11 = bh00 + $11
bh12 = bh00 + $12
bh14 = bh00 + $14
bh15 = bh00 + $15
bh16 = bh00 + $16
bh17 = bh00 + $17
bh19 = bh00 + $19
bh1a = bh00 + $1a
bh1b = bh00 + $1b
bh1c = bh00 + $1c
bh1e = bh00 + $1e
bh1f = bh00 + $1f

gfx_tabh:       .byte   bh00,bh00,bh00,bh00,bh00,bh00,bh00,bh00
                .byte   bh01,bh01,bh01,bh01,bh01,bh01,bh01,bh01
                .byte   bh02,bh02,bh02,bh02,bh02,bh02,bh02,bh02
                .byte   bh03,bh03,bh03,bh03,bh03,bh03,bh03,bh03
                .byte   bh05,bh05,bh05,bh05,bh05,bh05,bh05,bh05
                .byte   bh06,bh06,bh06,bh06,bh06,bh06,bh06,bh06
                .byte   bh07,bh07,bh07,bh07,bh07,bh07,bh07,bh07
                .byte   bh08,bh08,bh08,bh08,bh08,bh08,bh08,bh08
                .byte   bh0a,bh0a,bh0a,bh0a,bh0a,bh0a,bh0a,bh0a
                .byte   bh0b,bh0b,bh0b,bh0b,bh0b,bh0b,bh0b,bh0b
                .byte   bh0c,bh0c,bh0c,bh0c,bh0c,bh0c,bh0c,bh0c
                .byte   bh0d,bh0d,bh0d,bh0d,bh0d,bh0d,bh0d,bh0d
                .byte   bh0f,bh0f,bh0f,bh0f,bh0f,bh0f,bh0f,bh0f
                .byte   bh10,bh10,bh10,bh10,bh10,bh10,bh10,bh10
                .byte   bh11,bh11,bh11,bh11,bh11,bh11,bh11,bh11
                .byte   bh12,bh12,bh12,bh12,bh12,bh12,bh12,bh12
                .byte   bh14,bh14,bh14,bh14,bh14,bh14,bh14,bh14
                .byte   bh15,bh15,bh15,bh15,bh15,bh15,bh15,bh15
                .byte   bh16,bh16,bh16,bh16,bh16,bh16,bh16,bh16
                .byte   bh17,bh17,bh17,bh17,bh17,bh17,bh17,bh17
                .byte   bh19,bh19,bh19,bh19,bh19,bh19,bh19,bh19
                .byte   bh1a,bh1a,bh1a,bh1a,bh1a,bh1a,bh1a,bh1a
                .byte   bh1b,bh1b,bh1b,bh1b,bh1b,bh1b,bh1b,bh1b
                .byte   bh1c,bh1c,bh1c,bh1c,bh1c,bh1c,bh1c,bh1c
                .byte   bh1e,bh1e,bh1e,bh1e,bh1e,bh1e,bh1e,bh1e

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
