;
; show text in 80col mode
;
; Felix Palmen <felix@palmen-it.de> -- 2013-11-29
;

.export T80_DRAWPAGE
.export T80_ROW
.export T80_COL
.export T80_FONT_L
.export T80_FONT_H

.export t80_putc

T80_DRAWPAGE    = $8b

T80_ROW         = $b7
T80_COL         = $b8

T80_FONT_L      = $8e
T80_FONT_H      = $8f

PUTS_L          = $fa
PUTS_H          = $fb

CHAR_L          = $b5
CHAR_H          = $b6
WCOL            = $fd

.segment "ADDATA"

char:           .res 8

.segment "AMIGADOS"

; get address of character data
; in:   a               character block offset in font
; out:  CHAR_L          address
getcharaddr:
                sta     CHAR_L
                lda     #0
                sta     CHAR_H
                lda     CHAR_L
                asl     a
                rol     CHAR_H
                asl     a
                rol     CHAR_H
                asl     a
                rol     CHAR_H
                sta     CHAR_L
                lda     T80_FONT_L
                clc
                adc     CHAR_L
                sta     CHAR_L
                lda     T80_FONT_H
                adc     CHAR_H
                sta     CHAR_H
                rts

; get address of screen position
; in:   T80_DRAWPAGE    first page of graphics screen
; in:   T80_ROW         text row (0-24)
; in:   WCOL            text column (0-39)
; out:  PUTS_L          screen position address
getputaddr:
                lda     #0
                sta     PUTS_H
                lda     T80_ROW
                asl     a
                asl     a
                asl     a
                asl     a
                rol     PUTS_H
                asl     a
                rol     PUTS_H
                asl     a
                rol     PUTS_H
                sta     PUTS_L
                lda     PUTS_H
                adc     T80_ROW
                adc     T80_DRAWPAGE
                sta     PUTS_H
                lda     WCOL
                asl     a
                asl     a
                asl     a
                bcc     thispage1
                inc     PUTS_H
                clc
thispage1:      adc     PUTS_L
                bcc     thispage2
                inc     PUTS_H
thispage2:      sta     PUTS_L
                rts

; put character on screen in 80col mode
; in:   a               character code (petscii)
; in:   T80_FONT_L      address of 80col font to use
; in:   T80_DRAWPAGE    first page of graphics screen
; in:   T80_ROW         text row (0-23)
; in:   T80_COL         text column (0-76)
t80_putc:
                clc
                lsr     a
                bcs     char_1
char_0:         jsr     getcharaddr
                ldy     #7
loop1:          lda     (CHAR_L),y
                and     #$f0
                sta     char,y
                dey
                bpl     loop1
                clc
                lda     T80_COL
                adc     #1
                lsr     a
                sta     WCOL
                bcs     c0_put_l
c0_put_h:       jsr     getputaddr
                ldy     #7
loop2:          lda     (PUTS_L),y
                and     #$0f
                ora     char,y
                sta     (PUTS_L),y
                dey
                bpl     loop2
                rts
c0_put_l:       jsr     getputaddr
                ldy     #7
loop3:          lda     (PUTS_L),y
                and     #$f0
                lsr     a
                lsr     a
                lsr     a
                lsr     a
                lsr     a               ;shift to carry
                ora     char,y
                ror     a
                ror     a
                ror     a
                ror     a
                sta     (PUTS_L),y
                dey
                bpl     loop3
                rts
char_1:         jsr     getcharaddr
                ldy     #7
loop4:          lda     (CHAR_L),y
                and     #$0f
                sta     char,y
                dey
                bpl     loop4
                clc
                lda     T80_COL
                adc     #1
                lsr     a
                sta     WCOL
                bcs     c1_put_l
c1_put_h:       jsr     getputaddr
                ldy     #7
loop5:          lda     (PUTS_L),y
                asl     a
                asl     a
                asl     a
                asl     a
                asl     a               ;shift to carry
                ora     char,y
                rol     a
                rol     a
                rol     a
                rol     a
                sta     (PUTS_L),y
                dey
                bpl     loop5
                rts
c1_put_l:       jsr     getputaddr
                ldy     #7
loop6:          lda     (PUTS_L),y
                and     #$f0
                ora     char,y
                sta     (PUTS_L),y
                dey
                bpl     loop6
                rts

; vim: et:si:ts=8:sts=8:sw=8
