;
; kickstart.s
;
; provide some lowest-level functions like IRQ handling and VIC configuration
; boot AmigaDOS ;)
;

.include "vic.inc"
.include "vicconfig.inc"
.include "fastload.inc"
.include "raster.inc"

.exportzp TMP_0
.exportzp TMP_1
.exportzp TMP_2
.exportzp TMP_3
.exportzp TMP_4
.exportzp TMP_5
.exportzp TMP_6
.exportzp TMP_7
.exportzp TMP_8
.exportzp TMP_9
.exportzp TMP_A
.exportzp TMP_B
.exportzp TMP_C
.exportzp TMP_D
.exportzp TMP_E
.exportzp TMP_F

.import __AMIGADOS_LOAD__
.import __ZPSAVE_LOAD__

.segment "ZPSAVE"
.res 0  ; force segment definition

CHROUT          = $ffd2
GETKB           = $f142

.segment "KSBSS"
border_save:    .res 1
bg_save:        .res 1
memctl_save:    .res 1
vicctl1_save:   .res 1

.segment "ZPSYS": zeropage
; temporary variables for system code
TMP_0:          .res 1
TMP_1:          .res 1
TMP_2:          .res 1
TMP_3:          .res 1
TMP_4:          .res 1
TMP_5:          .res 1
TMP_6:          .res 1
TMP_7:          .res 1
TMP_8:          .res 1
TMP_9:          .res 1
TMP_A:          .res 1
TMP_B:          .res 1
TMP_C:          .res 1
TMP_D:          .res 1
TMP_E:          .res 1
TMP_F:          .res 1

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

                ; save zeropage
                jsr     ks_zpsave

                ; check if amigados is in place
                lda     dosloaded
                bne     noload

                ; load amigados
                lda     #$ab
                sta     fl_filename
                lda     #$c0
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

noload:         ; "disable" NMI using no-ack trick
                sei

                lda     #<nmi_disable
                sta     $0318
                lda     #>nmi_disable
                sta     $0319
                lda     #0
                sta     $dd0e
                sta     $dd04
                sta     $dd05
                lda     #$81
                sta     $dd0d
                lda     #1
                sta     $dd0e

                ; configure VIC and enable raster IRQ handling
                jsr     vic_init
                jsr     raster_on

                ; run amigados
amigadosentry:  jsr     $ffff

                ; disable raster IRQ handling, reset VIC to normal
                jsr     raster_off
                jsr     vic_done

                ; re-enable normal NMI
                lda     #$47
                sta     $0318
                lda     #$fe
                sta     $0319
                lda     #1
                sta     $dd0d
                lda     $dd0d

                ; restore zeropage
                jsr     ks_zprest

                ; restore vic config
                lda     vicctl1_save
                sta     VIC_CTL1
                lda     border_save
                sta     BORDER_COLOR
                lda     bg_save
                sta     BG_COLOR_0

                ; clear leftover keys from buffer
eat_keys:       jsr     GETKB
                bne     eat_keys
                
                rts

.segment "KICKSTART"

ks_zpsave:
                ldx     #2
kszps_loop:     lda     $00,x
                sta     __ZPSAVE_LOAD__-2,x
                inx
                bne     kszps_loop
                rts

ks_zprest:
                ldx     #2
kszpr_loop:     lda     __ZPSAVE_LOAD__-2,x
                sta     $00,x
                inx
                bne     kszpr_loop
                rts

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

nmi_disable:    rti

.segment "KSDATA"

dosloaded:      .byte   0

ks_msg:         .byte   13, 13, "c=64 kickstart by zirias 12/2013", 13, 13
                .byte   "booting amigados", 13
ks_msglen       = *-ks_msg

ks_done:        .byte   " done.", 13
ks_donelen      = *-ks_done

; vim: et:si:ts=8:sts=8:sw=8
