;
; kickstart.s
;
; load the rest of the demo
;

.include "vic.inc"
.include "vicconfig.inc"
.include "fastload.inc"
.include "raster.inc"

.import __AMIGADOS_LOAD__

CHROUT          = $ffd2
GETKB           = $f142

.segment "KSBSS"
border_save:    .res 1
bg_save:        .res 1
memctl_save:    .res 1
vicctl1_save:   .res 1

.segment "KSENTRY"
kickstart:
                ldx     #0
ksmsgloop:      lda     ks_msg,x
                jsr     CHROUT
                inx
                cpx     #ks_msglen
                bne     ksmsgloop

                jsr     initfastload

                ; save vic config
                lda     BORDER_COLOR
                sta     border_save
                lda     BG_COLOR_0
                sta     bg_save
                lda     VIC_CTL1
                sta     vicctl1_save

                ; check if amigados is in place
                lda     dosloaded
                bne     noload

                ; load amigados
                lda     #'-'
                sta     fl_filename
                sta     fl_filename+1
                lda     #<__AMIGADOS_LOAD__
                sta     fl_loadaddr
                lda     #>__AMIGADOS_LOAD__
                sta     fl_loadaddr+1
                jsr     fastload
                inc     dosloaded
                lda     fl_run+1
                sta     amigadosentry+1
                lda     fl_run+2
                sta     amigadosentry+2

noload:         ; configure VIC and enable raster IRQ handling
                jsr     vic_init
                jsr     raster_on

                ; run amigados
amigadosentry:  jsr     $ffff

                ; disable raster IRQ handling, reset VIC to normal
                jsr     raster_off
                jsr     vic_done

                ; clear leftover keys from buffer
eat_keys:       jsr     GETKB
                bne     eat_keys
                
                ; restore vic config
                lda     vicctl1_save
                sta     VIC_CTL1
                lda     border_save
                sta     BORDER_COLOR
                lda     bg_save
                sta     BG_COLOR_0

                rts

.segment "KICKSTART"

vic_init:
                lda     CIA2_DATA_A
                and     #vic_bankselect_and
                sta     CIA2_DATA_A
                lda     VIC_MEMCTL
                sta     memctl_save
                lda     #vic_memctl_text
                sta     VIC_MEMCTL
                rts

vic_done:
                lda     CIA2_DATA_A
                ora     #%00000011
                sta     CIA2_DATA_A
                lda     memctl_save
                sta     VIC_MEMCTL
                rts

.segment "KSDATA"

dosloaded:      .byte   0

ks_msg:         .byte   13, 13, "c=64 kickstart by zirias 12/2013", 13, 13
                .byte   "booting amigados", 13
ks_msglen       = *-ks_msg

ks_done:        .byte   " done.", 13
ks_donelen      = *-ks_done

; vim: et:si:ts=8:sts=8:sw=8
