;
; chainload.s
;
; variation of fastload.s especially for loading kickstart
;

.import __DRVCODE1_LOAD__
.import __DRVCODE1_RUN__
.import __DRVCODE1_SIZE__
DRVCODE1_END = __DRVCODE1_LOAD__ + __DRVCODE1_SIZE__
.import __KSENTRY_LOAD__

.export chainload
.export ld_devnum

STATUS          = $90
MESSAGES        = $9d
FA              = $ba

LISTEN          = $ffb1
SECOND          = $ff93
UNLSN           = $ffae
CIOUT           = $ffa8

drvcode_chunk   = $20

temp1           = $02
temp2           = $03
stackptrstore   = $04

.segment "LDBSS"

loadbuffer:     .res 254

.segment "LOADER"

ld_devnum       = *+1
il_device:      lda     #0
                jsr     LISTEN
                lda     #$6f
                jmp     SECOND

chainload:
                tsx
                stx     stackptrstore
                lda     #<__DRVCODE1_LOAD__
                sta     il_chunkstart
                lda     #>__DRVCODE1_LOAD__
                sta     il_chunkstart+1
                lda     #<__DRVCODE1_RUN__
                sta     mwcmd+2
                lda     #>__DRVCODE1_RUN__
                sta     mwcmd+1
il_mwloop:      jsr     il_device
                ldx     #mwcmd_size - 1
il_sendmw:      lda     mwcmd,x
                jsr     CIOUT
                dex
                bpl     il_sendmw
                ldx     #0
il_chunkstart   = *+1
il_mwbyte:      lda     __DRVCODE1_LOAD__,x
                jsr     CIOUT
                inx
                cpx     #drvcode_chunk
                bne     il_mwbyte
                jsr     UNLSN
                lda     mwcmd+2
                clc
                adc     #drvcode_chunk
                sta     mwcmd+2
                bcc     il_nohigh
                inc     mwcmd+1
il_nohigh:      lda     il_chunkstart
                clc
                adc     #drvcode_chunk
                sta     il_chunkstart
                tax
                bcc     il_nohigh2
                inc     il_chunkstart+1
il_nohigh2:     lda     il_chunkstart+1
                cpx     #<DRVCODE1_END
                sbc     #>DRVCODE1_END
                bcc     il_mwloop

                jsr     il_device
                ldx     #mecmd_size - 1
il_sendme:      lda     mecmd,x
                jsr     CIOUT
                dex
                bpl     il_sendme
                jsr     UNLSN

fl_delay:       dex
                bne     fl_delay
                lda     #0
                sta     temp2
                lda     #<__KSENTRY_LOAD__
                sta     fl_loadaddr
                lda     #>__KSENTRY_LOAD__
                sta     fl_loadaddr+1
fl_loop:        jsr     fl_getbyte
fl_loadaddr     = *+1
                sta     __KSENTRY_LOAD__
                inc     fl_loadaddr
                bne     fl_loop
                inc     fl_loadaddr+1
                jmp     fl_loop

fl_getbyte:     ldx     temp2
                beq     fl_fillbuffer
                lda     loadbuffer-1,x
                dex
                stx     temp2
                rts

fl_fillbuffer:  jsr     fl_get
                cmp     #$01
                bcc     fl_loadend
                beq     fl_loadend
                sbc     #1
                sta     temp2
                ldx     #0
fl_gnbloop:     jsr     fl_get
                sta     loadbuffer,x
                inx
                cpx     temp2
                bcc     fl_gnbloop
                bcs     fl_getbyte

fl_loadend:
                ldx     stackptrstore
                txs
                rts

fl_get:         bit     $dd00
                bvc     fl_get
                lda     #$0f
                and     $dd00
                sta     $dd00
                nop
                ldy     #$08
fl_bitloop:     nop
                nop
                lda     #$10
                eor     $dd00
                sta     $dd00
                asl
                rol     temp1
                lda     temp1
                dey
                bne     fl_bitloop
                rts

.segment "DRVCODE1"

RETRIES         = 5
acsbf           = $01
trkbf           = $08
sctbf           = $09
iddrv0          = $12
id              = $16
datbf           = $14
buf             = $0400

                lda     #$08
                sta     $1800

                ldx     #19
                ldy     #0
dirloop:        stx     trkbf
                sty     sctbf
                jmp     load
error:          lda     #$01
loadend:        jsr     sendbyte
                lda     $1800
                and     #$f7
                sta     $1800
                lda     #$04
loadend_wait:   bit     $1800
                bne     loadend_wait
                ldy     #$00
                sty     $1800
                rts

found:          iny
nextsect:       lda     buf,y
                sta     trkbf
                beq     loadend
                lda     buf+1,y
                sta     sctbf
load:           jsr     readsect
                bcc     error
                ldy     #$ff
                lda     buf
                bne     sendblk
                ldy     buf+1
sendblk:        tya
sendloop:       jsr     sendbyte
                lda     buf,y
                dey
                bne     sendloop
                beq     nextsect

readsect:       ldy     #RETRIES
retry:          cli
                jsr     success
                lda     #$80
                sta     acsbf
poll1:          lda     acsbf
                bmi     poll1
                sei
                cmp     #1
                beq     success
                lda     id
                sta     iddrv0
                lda     id+1
                sta     iddrv0+1
                dey
                bne     retry
failure:        clc
success:        lda     $1c00
                eor     #$08            ; LED switch
                sta     $1c00
                rts

sendbyte:       sta     datbf
                tya
                pha
                ldy     #$04
                lda     $1800
                and     #$f7
                sta     $1800
                tya
s1:             asl     datbf
                ldx     #$02
                bcc     s2
                ldx     #$00
s2:             bit     $1800
                bne     s2
                stx     $1800
                asl     datbf
                ldx     #$02
                bcc     s3
                ldx     #$00
s3:             bit     $1800
                beq     s3
                stx     $1800
                dey
                bne     s1
                txa
                ora     #$08
                sta     $1800
                pla
                tay
                rts

getbyte:        ldy     #8
recvbit:        lda     #$85
                and     $1800
                bmi     gotatn
                beq     recvbit
                lsr
                lda     #$02
                bcc     rskip
                lda     #$08
rskip:          sta     $1800
                ror     datbf
rwait:          lda     $1800
                and     #$05
                eor     #$05
                beq     rwait
                lda     #0
                sta     $1800
                dey
                bne     recvbit
                lda     datbf
                rts
gotatn:         pla
                pla
                rts

.segment "LDDATA"

mwcmd:          .byte   drvcode_chunk, >__DRVCODE1_RUN__
                .byte   <__DRVCODE1_RUN__, "w-m"
mwcmd_size      = *-mwcmd

mecmd:          .byte   >__DRVCODE1_RUN__, <__DRVCODE1_RUN__, "e-m"
mecmd_size      = *-mecmd


; vim: et:si:ts=8:sts=8:sw=8
