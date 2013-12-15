.include "spritezone.inc"
.include "text80.inc"
.include "vicconfig.inc"

.export con_scrollscr

.segment "AMIGADOS"

con_scrollscr:
                ldy     #92
cs_outer:       lda     rowoffsets-1,y
                sta     cs_read1base+1
                lda     rowoffsets+3,y
                sta     cs_write1base+1
                dey
                lda     rowoffsets-1,y
                sta     cs_read1base
                lda     rowoffsets+3,y
                sta     cs_write1base
                dey
                lda     rowoffsets-1,y
                sta     cs_read2base+1
                lda     rowoffsets+3,y
                sta     cs_write2base+1
                dey
                lda     rowoffsets-1,y
                sta     cs_read2base
                lda     rowoffsets+3,y
                sta     cs_write2base
                ldx     #0
cs_read1base    = *+1
cs_inner:       lda     $ffff,x
cs_write1base   = *+1
                sta     $ffff,x
cs_read2base    = *+1
                lda     $ffff,x
cs_write2base   = *+1
                sta     $ffff,x
                inx
                cpx     #$a0
                bne     cs_inner
                dey
                bne     cs_outer
                rts

.segment "ADDATA"

rowoffsets:
                .word   vic_bitmap + $1d60, vic_bitmap + $1cc0
                .word   vic_bitmap + $1c20, vic_bitmap + $1b80
                .word   vic_bitmap + $1ae0, vic_bitmap + $1a40
                .word   vic_bitmap + $19a0, vic_bitmap + $1900
                .word   vic_bitmap + $1860, vic_bitmap + $17c0
                .word   vic_bitmap + $1720, vic_bitmap + $1680
                .word   vic_bitmap + $15e0, vic_bitmap + $1540
                .word   vic_bitmap + $14a0, vic_bitmap + $1400
                .word   vic_bitmap + $1360, vic_bitmap + $12c0
                .word   vic_bitmap + $1220, vic_bitmap + $1180
                .word   vic_bitmap + $10e0, vic_bitmap + $1040
                .word   vic_bitmap + $fa0, vic_bitmap + $f00
                .word   vic_bitmap + $e60, vic_bitmap + $dc0
                .word   vic_bitmap + $d20, vic_bitmap + $c80
                .word   vic_bitmap + $be0, vic_bitmap + $b40
                .word   vic_bitmap + $aa0, vic_bitmap + $a00
                .word   vic_bitmap + $960, vic_bitmap + $8c0
                .word   vic_bitmap + $820, vic_bitmap + $780
                .word   vic_bitmap + $6e0, vic_bitmap + $640
                .word   vic_bitmap + $5a0, vic_bitmap + $500
                .word   vic_bitmap + $460, vic_bitmap + $3c0
                .word   vic_bitmap + $320, vic_bitmap + $280
                .word   vic_bitmap + $1e0, vic_bitmap + $140
                .word   vic_bitmap + $a0, vic_bitmap

; vim: et:si:ts=8:sts=8:sw=8
