;
; kickstart.s
;
; load the rest of the demo
;

.include "fastload.inc"

.import __AMIGADOS_LOAD__

CHROUT          = $ffd2
READY           = $a474

.segment "BOOT"

                .word   $02bc           ; load address for binary
                .assert *=$02bc, error  ; check linker placed us correctly

; BASIC header -- must be here if loaded with ",8" only
basichdr:       .word   $080a           ; next basic line, in "KICKSTART"
                .word   $17             ; 23
                .byte   $9E             ; SYS
                .byte   "2159", 0
                .word   0               ; placed at $080a in "KICKSTART"
basichdrlen     = *-basichdr

; show what is loading:
ks_loadmsg:     .byte   " kickstart..."
ks_loadmsglen   = *-ks_loadmsg
ks_load:        ldx     #0
ks_loop:        lda     ks_loadmsg,x
                jsr     CHROUT
                inx
                cpx     #ks_loadmsglen
                bne     ks_loop
                lda     #<loader
                sta     $326
                lda     #>loader
                sta     $327
                rts

; entry of hijacked STOP routine
                .assert *=$02ed, error
                lda     #$f6    ;repair stop check vector right away (only the
                sta     $329    ;hi-byte was altered, that's why *=$02ed)
                lda     #<loader        ;change end of file to start adress
                sta     $ae             ;of the main code
                lda     #>loader
                sta     $af
                jsr     ks_load
                jmp     $f6ed   ;jump back to normal loading routine

;the system vectors at $300-$327 must remain intact to allow normal basic/kernal
;operation and therefore the loader must contain the proper bytes for these:

                .assert *=$0300, error  ;the vector table for basic/kernal
                .word $e38b     ;$300 vector: print basic error message ($e38b)
                .word $a483     ;$302 vector: basic warm start ($a483)
                .word $a57c     ;$304 vector: tokenize basic text ($a57c)
                .word $a71a     ;$306 vector: basic text list ($a71a)
                .word $a7e4     ;$308 vector: basic char. dispatch ($a7e4)
                .word $ae86     ;$30a vector: basic token evaluation ($ae86)
                .byte 0,0,0,0   ;$30c temp storage cpu registers

                jmp $b248       ;$310 usr function, jmp+address
                .byte 0         ;$313 unused

                .word $ea31     ;$314 Vector: Hardware Interrupt ($ea31)
                .word $fe66     ;$316 Vector: BRK Instr. Interrupt ($fe66)
                .word $fe47     ;$318 Vector: Non-Maskable Interrupt ($fe47)
                .word $f34a     ;$31a kernal open routine vector ($f34a)
                .word $f291     ;$31c kernal close routine vector ($f291)
                .word $f20e     ;$31e kernal chkin routine ($f20e)
                .word $f250     ;$320 kernal chkout routine ($f250)
                .word $f333     ;$322 kernal clrchn routine vector ($f333)
                .word $f157     ;$324 kernal chrin routine ($f157)

                .word $f1ca     ;$326 kernal chrout routine ($f1ca)
                ;HERE'S THE TRAP:
                .word $02ed     ;$328: kernal stop routine Vector ($f6ed)

.segment "KICKSTART"

loader:
                .assert *=$086f, error  ; check linker placed us correctly
                lda     #$f1
                cmp     $327
                beq     normalstart     ; didn't autostart
                sta     $327
                lda     #$ca
                sta     $326
                pla
                pla
                lda     #$20            ; JSR opcode
                sta     amigadosjmp
                ldx     #basichdrlen - 1 ; copy BASIC header to 0801
hdrcopyloop:    lda     basichdr,x
                sta     $801,x
                dex
                bpl     hdrcopyloop
                ldx     #0
doneloop:       lda     ks_done,x
                jsr     CHROUT
                inx
                cpx     #ks_donelen
                bne     doneloop
normalstart:    ldx     #0
ksmsgloop:      lda     ks_msg,x
                jsr     CHROUT
                inx
                cpx     #ks_msglen
                bne     ksmsgloop
                jsr     initfastload
                lda     #' '
                sta     fl_filename
                sta     fl_filename+1
                lda     #<__AMIGADOS_LOAD__
                sta     fl_loadaddr
                lda     #>__AMIGADOS_LOAD__
                sta     fl_loadaddr+1
                jsr     fastload
                sei
                lda     #$4c
                sta     loader
                lda     fl_run+1
                sta     loader+1
                lda     fl_run+2
                sta     loader+2
                cli
amigadosjmp:    jmp     fl_run
                lda     #$4c            ; JMP opcode
                sta     amigadosjmp
                jmp     READY

.segment "KSDATA"

ks_msg:         .byte   13, 13, "c=64 kickstart by zirias 12/2013", 13, 13
                .byte   "booting amigados", 13
ks_msglen       = *-ks_msg

ks_done:        .byte   " done.", 13
ks_donelen      = *-ks_done

; vim: et:si:ts=8:sts=8:sw=8
