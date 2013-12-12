;
; kickstart.s
;
; load the rest of the demo
;

.include "fastload.inc"

.import __AMIGADOS_LOAD__

CHROUT          = $ffd2

.segment "KSENTRY"
kickstart:
                ldx     #0
ksmsgloop:      lda     ks_msg,x
                jsr     CHROUT
                inx
                cpx     #ks_msglen
                bne     ksmsgloop
                jsr     initfastload

                ; load amigados
                lda     #'-'
                sta     fl_filename
                sta     fl_filename+1
                lda     #<__AMIGADOS_LOAD__
                sta     fl_loadaddr
                lda     #>__AMIGADOS_LOAD__
                sta     fl_loadaddr+1
                jsr     fastload

                ; and run it
amigadosjmp:    jsr     fl_run
                rts

.segment "KSDATA"

ks_msg:         .byte   13, 13, "c=64 kickstart by zirias 12/2013", 13, 13
                .byte   "booting amigados", 13
ks_msglen       = *-ks_msg

ks_done:        .byte   " done.", 13
ks_donelen      = *-ks_done

; vim: et:si:ts=8:sts=8:sw=8
