;
; demo inspired by AmigaBASIC demo
;

tbllen          = 195

.include        "gfx.inc"
.include        "vic.inc"
.include        "vicconfig.inc"
.include        "snd.inc"
.include        "sprites.inc"
.include        "amigados.inc"

.import ziri_ambi

.import raster_on
.import raster_off
.import raster_phase1
.import key_pressed

.segment "MUBSS"
from1tbl:       .res    1
from1:          .res    1
to1tbl:         .res    1
to1:            .res    1
from2tbl:       .res    1
from2:          .res    1
to2tbl:         .res    1
to2:            .res    1
countdown:      .res    1

.segment "MUMAIN"
                .word   music

.segment "MUSIC"
music:
                ; initialize:
                ldx     #0
                stx     from1tbl
                stx     from2tbl
                stx     to1tbl
                stx     to2tbl
                lda     #tbllen
                sta     from1
                sta     from2
                lda     #tbllen - 123
                sta     to1
                sta     to2
                lda     #66
                sta     countdown
                lda     #<(cotable_a-1)
                ldx     #>(cotable_a-1)
                sta     from1ptr1+1
                stx     from1ptr1+2
                sta     from1ptr2+1
                stx     from1ptr2+2
                sta     from1ptr3+1
                stx     from1ptr3+2
                sta     from2ptr1+1
                stx     from2ptr1+2
                sta     from2ptr2+1
                stx     from2ptr2+2
                sta     from2ptr3+1
                stx     from2ptr3+2
                sta     to1ptr1+1
                stx     to1ptr1+2
                sta     to1ptr2+1
                stx     to1ptr2+2
                sta     to1ptr3+1
                stx     to1ptr3+2
                sta     to2ptr1+1
                stx     to2ptr1+2
                sta     to2ptr2+1
                stx     to2ptr2+2
                sta     to2ptr3+1
                stx     to2ptr3+2
                jsr     clear_window

                ; sound:
                lda     #%00001111
                sta     $D418
                lda     #<song
                sta     snd_songptr
                lda     #>song
                sta     snd_songptr+1
                lda     #12
                sta     snd_speed
                jsr     snd_init

                ; ambigram:
                jsr     ziri_ambi

                ; sprites for marquee
                jsr     sprites_marquee
                jsr     sprites_topborder1

                ; more raster effects
                jsr     raster_phase1

                ; set drawing mode to invert
                lda     #MODE_INV
                sta     PLOT_MODE

                ; clear key
                lda     #0
                sta     key_pressed

                ; main loop
loop:           ldx     countdown
                beq     do2                     ; 2nd line already active
                dex
                stx     countdown               ; otherwise continue counting
                jmp     do1

                ; Linie 2:
do2:            ldy     from2
from2ptr1:      lda     $FFFF,y
                sta     PLOT_XL
                dey
from2ptr2:      lda     $FFFF,y
                sta     PLOT_XH
                dey
from2ptr3:      lda     $FFFF,y
                sta     PLOT_Y
                dey
                bne     cont2a
                lda     from2tbl
                eor     #1
                sta     from2tbl
                bne     from2_b
                lda     #<(cotable_a-1)
                ldx     #>(cotable_a-1)
                bne     fr2_cont
from2_b:        lda     #<(cotable_b-1)
                ldx     #>(cotable_b-1)
fr2_cont:       sta     from2ptr1+1
                stx     from2ptr1+2
                sta     from2ptr2+1
                stx     from2ptr2+2
                sta     from2ptr3+1
                stx     from2ptr3+2
                ldy     #tbllen
cont2a:         sty     from2
                ldy     to2
to2ptr1:        lda     $FFFF,y
                sta     LINETO_XL
                dey
to2ptr2:        lda     $FFFF,y
                sta     LINETO_XH
                dey
to2ptr3:        lda     $FFFF,y
                sta     LINETO_Y
                dey
                bne     cont2b
                lda     to2tbl
                eor     #1
                sta     to2tbl
                bne     to2_b
                lda     #<(cotable_a-1)
                ldx     #>(cotable_a-1)
                bne     to2_cont
to2_b:          lda     #<(cotable_b-1)
                ldx     #>(cotable_b-1)
to2_cont:       sta     to2ptr1+1
                stx     to2ptr1+2
                sta     to2ptr2+1
                stx     to2ptr2+2
                sta     to2ptr3+1
                stx     to2ptr3+2
                ldy     #tbllen
cont2b:         sty     to2
                jsr     gfx_line

                ; Linie 1:
do1:            ldy     from1
from1ptr1:      lda     $FFFF,y
                sta     PLOT_XL
                dey
from1ptr2:      lda     $FFFF,y
                sta     PLOT_XH
                dey
from1ptr3:      lda     $FFFF,y
                sta     PLOT_Y
                dey
                bne     cont1a
                lda     from1tbl
                eor     #1
                sta     from1tbl
                bne     from1_b
                lda     #<(cotable_a-1)
                ldx     #>(cotable_a-1)
                bne     fr1_cont
from1_b:        lda     #<(cotable_b-1)
                ldx     #>(cotable_b-1)
fr1_cont:       sta     from1ptr1+1
                stx     from1ptr1+2
                sta     from1ptr2+1
                stx     from1ptr2+2
                sta     from1ptr3+1
                stx     from1ptr3+2
                ldy     #tbllen
cont1a:         sty     from1
                ldy     to1
to1ptr1:        lda     $FFFF,y
                sta     LINETO_XL
                dey
to1ptr2:        lda     $FFFF,y
                sta     LINETO_XH
                dey
to1ptr3:        lda     $FFFF,y
                sta     LINETO_Y
                dey
                bne     cont1b
                lda     to1tbl
                eor     #1
                sta     to1tbl
                bne     to1_b
                lda     #<(cotable_a-1)
                ldx     #>(cotable_a-1)
                bne     to1_cont
to1_b:          lda     #<(cotable_b-1)
                ldx     #>(cotable_b-1)
to1_cont:       sta     to1ptr1+1
                stx     to1ptr1+2
                sta     to1ptr2+1
                stx     to1ptr2+2
                sta     to1ptr3+1
                stx     to1ptr3+2
                ldy     #tbllen
cont1b:         sty     to1
                jsr     gfx_line

                ; end when key pressed:
                lda     key_pressed
                bne     out
                jmp     loop
                jsr     snd_stop
out:            rts

.segment "MUDATA"
cotable_a:      .byte   $BE,$01,$3D,$B6,$01,$3D,$AE,$01,$3D,$A6,$01,$3D
                .byte   $9E,$01,$3D,$96,$01,$3D,$8E,$01,$3D,$86,$01,$3D
                .byte   $7F,$01,$3D,$77,$01,$3D,$6F,$01,$3D,$67,$01,$3D
                .byte   $5F,$01,$3D,$57,$01,$3D,$4F,$01,$3D,$47,$01,$3D
                .byte   $40,$01,$3D,$38,$01,$3D,$30,$01,$3D,$28,$01,$3D
                .byte   $20,$01,$3D,$18,$01,$3D,$10,$01,$3D,$08,$01,$3D
                .byte   $00,$01,$3D,$00,$01,$36,$00,$01,$2E,$00,$01,$26
                .byte   $00,$01,$1E,$00,$01,$16,$00,$01,$0E,$00,$01,$06
                .byte   $00,$00,$FE,$00,$00,$F7,$00,$00,$EF,$00,$00,$E7
                .byte   $00,$00,$DF,$00,$00,$D7,$00,$00,$CF,$00,$00,$C7
                .byte   $00,$00,$BF,$00,$00,$B8,$00,$00,$B0,$00,$00,$A8
                .byte   $00,$00,$A0,$00,$00,$98,$00,$00,$90,$00,$00,$88
                .byte   $00,$00,$80,$00,$00,$79,$00,$00,$71,$00,$00,$69
                .byte   $00,$00,$61,$00,$00,$59,$00,$00,$51,$00,$00,$49
                .byte   $00,$00,$41,$00,$00,$3A,$00,$00,$32,$00,$00,$2A
                .byte   $00,$00,$22,$00,$00,$1A,$00,$00,$12,$00,$00,$0A
                .byte   $00,$00,$02

cotable_b:      .byte   $07,$00,$02,$0F,$00,$02,$17,$00,$02,$1F,$00,$02
                .byte   $27,$00,$02,$2F,$00,$02,$37,$00,$02,$3F,$00,$02
                .byte   $46,$00,$02,$4E,$00,$02,$56,$00,$02,$5E,$00,$02
                .byte   $66,$00,$02,$6E,$00,$02,$76,$00,$02,$7E,$00,$02
                .byte   $85,$00,$02,$8D,$00,$02,$95,$00,$02,$9D,$00,$02
                .byte   $A5,$00,$02,$AD,$00,$02,$B5,$00,$02,$BD,$00,$02
                .byte   $C5,$00,$02,$C5,$00,$09,$C5,$00,$11,$C5,$00,$19
                .byte   $C5,$00,$21,$C5,$00,$29,$C5,$00,$31,$C5,$00,$39
                .byte   $C5,$00,$41,$C5,$00,$48,$C5,$00,$50,$C5,$00,$58
                .byte   $C5,$00,$60,$C5,$00,$68,$C5,$00,$70,$C5,$00,$78
                .byte   $C5,$00,$80,$C5,$00,$87,$C5,$00,$8F,$C5,$00,$97
                .byte   $C5,$00,$9F,$C5,$00,$A7,$C5,$00,$AF,$C5,$00,$B7
                .byte   $C5,$00,$BF,$C5,$00,$C6,$C5,$00,$CE,$C5,$00,$D6
                .byte   $C5,$00,$DE,$C5,$00,$E6,$C5,$00,$EE,$C5,$00,$F6
                .byte   $C5,$00,$FE,$C5,$01,$05,$C5,$01,$0D,$C5,$01,$15
                .byte   $C5,$01,$1D,$C5,$01,$25,$C5,$01,$2D,$C5,$01,$35
                .byte   $C5,$01,$3D

song:           .byte   7,%00010000,8,%00100000,9,%00100000
                .byte   10,%00110011,%11000100,11,%00110011,%01000100
                .byte   12,%00110011,%01110100
                .byte   2,G1,0
                .byte   1,G3,0
                .byte   4,1,A3,0
                .byte   4,1,B3,6,0
                .byte   4,1,D4,0
                .byte   4,1,C4,0
                .byte   4,1,C4,5,2,E1,0
                .byte   4,1,E4,0
                .byte   4,1,D4,0
                .byte   4,1,D4,5,2,B0,0
                .byte   4,1,G4,0
                .byte   4,1,FS4,0
                .byte   4,1,G4,5,2,E1,0
                .byte   4,1,D4,0
                .byte   4,1,B3,0
                .byte   4,1,G3,0
                .byte   4,1,A3,0
                .byte   4,1,B3,5,0
                .byte   4,1,C4,2,A0,0
                .byte   4,1,D4,0
                .byte   4,1,E4,0
                .byte   4,1,D4,5,2,B0,0
                .byte   4,1,C4,0
                .byte   4,1,B3,0
                .byte   4,1,A3,5,2,C1,0
                .byte   4,1,B3,0
                .byte   4,1,G3,0
                .byte   4,1,FS3,5,2,D1,0
                .byte   4,1,G3,0
                .byte   4,1,A3,0
                .byte   4,1,D3,5,2,FS1,0
                .byte   4,1,FS3,0
                .byte   4,1,A3,0
                .byte   4,1,C4,5,2,D1,0
                .byte   4,1,B3,0
                .byte   4,1,A3,0
                .byte   4,1,B3,5,2,G1,0
                .byte   4,1,G3,0
                .byte   4,1,A3,0
                .byte   4,1,B3,5,2,E1,0
                .byte   4,1,D4,0
                .byte   4,1,C4,0
                .byte   4,1,C4,5,2,C1,0
                .byte   4,1,E4,0
                .byte   4,1,D4,0
                .byte   4,1,D4,5,2,B0,0
                .byte   4,1,G4,0
                .byte   4,1,FS4,0
                .byte   4,1,G4,5,2,E1,0
                .byte   4,1,D4,0
                .byte   4,1,B3,0
                .byte   4,1,G3,5,2,D1,0
                .byte   4,1,A3,0
                .byte   4,1,B3,0
                .byte   4,1,A3,5,2,C1,0
                .byte   4,1,D4,0
                .byte   4,1,C4,0
                .byte   4,1,B3,5,2,CS1,0
                .byte   4,1,A3,0
                .byte   4,1,G3,0
                .byte   4,1,D3,5,2,D1,0
                .byte   4,1,G3,0
                .byte   4,1,FS3,0
                .byte   4,1,G3,5,2,G1,0
                .byte   4,1,B3,0
                .byte   4,1,D4,0
                .byte   4,1,G4,0
                .byte   4,1,D4,0
                .byte   4,1,B3,0
                .byte   4,1,G3,5,11,%00110011,%01110100,0
                .byte   4,1,B3,0
                .byte   4,1,D4,0
                .byte   4,1,G4,2,G1,3,B3,0
                .byte   0
                .byte   0
                .byte   4,7,%00100000,10,%00110011,%01110100
                .byte   1,D3,5,2,FS1,0
                .byte   0
                .byte   0
                .byte   4,1,G3,5,2,E1,6,3,C4,0
                .byte   0
                .byte   0
                .byte   4,1,A3,5,2,FS1,6,3,D4,0
                .byte   0
                .byte   0
                .byte   5,2,E1,0
                .byte   0
                .byte   0
                .byte   4,1,A3,5,2,D1,6,3,D4,0
                .byte   0
                .byte   0
                .byte   4,1,G3,5,2,E1,6,3,C4,0
                .byte   0
                .byte   0
                .byte   5,2,FS1,0
                .byte   0
                .byte   0
                .byte   4,1,D3,5,2,G1,6,3,B3,0
                .byte   0
                .byte   0
                .byte   4,1,FS3,5,2,D1,6,3,A3,0
                .byte   4,7,%00010000,10,%00110011,%11000100
                .byte   1,D3,0
                .byte   4,1,E3,0
                .byte   4,1,FS3,0
                .byte   4,1,A3,0
                .byte   4,1,G3,0
                .byte   4,1,A3,5,2,D1,6,0
                .byte   4,1,C4,0
                .byte   4,1,B3,0
                .byte   4,1,C4,5,2,D1,0
                .byte   4,1,A3,0
                .byte   4,1,FS3,0
                .byte   4,1,D3,0
                .byte   4,1,FS3,0
                .byte   4,1,A3,0
                .byte   4,1,C4,5,0
                .byte   4,1,B3,0
                .byte   4,1,A3,0
                .byte   4,7,%00100000,10,%00110011,%01110100
                .byte   1,D3,2,G1,3,B3,0
                .byte   0
                .byte   0
                .byte   5,2,FS1,0
                .byte   0
                .byte   0
                .byte   4,1,G3,5,2,E1,6,3,C4,0
                .byte   0
                .byte   0
                .byte   4,1,B3,5,2,D1,6,3,D4,0
                .byte   0
                .byte   0
                .byte   5,2,G1,0
                .byte   0
                .byte   0
                .byte   4,1,D3,5,2,B0,6,3,B3,0
                .byte   0
                .byte   0
                .byte   4,1,E3,5,2,C1,6,3,A3,0
                .byte   6,3,B3,0
                .byte   6,3,C4,0
                .byte   4,1,D3,5,2,D0,6,3,B3,0
                .byte   0
                .byte   0
                .byte   4,1,C3,6,3,A3,0
                .byte   0
                .byte   0
                .byte   4,5,6,3,G3,255

; vim: et:si:ts=8:sts=8:sw=8
