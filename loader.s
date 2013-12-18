;
; loader.s
;
; boot loader for kickstart
; loads kickstart to $c000 and installs BASIC stub to run it
;
; optionally auto-startable with load"*",8,1
;

.import __KSENTRY_LOAD__
.import chainload
.import ld_devnum
.import ks_devnum

CHROUT          = $ffd2
READY           = $a474

.segment "BOOTCODE"

                .word   $02bc           ; load address for binary
                .assert *=$02bc, error  ; check linker placed us correctly

; BASIC header -- must be here if loaded with ",8" only
                .word   $080a           ; next basic line, in "LOADER"
                .word   $17             ; 23
                .byte   $9E             ; SYS
                .byte   "2159", 0
                .word   0               ; placed at $080a in "LOADER"

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
                ;hijack STOP here:
                .word $02ed     ;$328: kernal stop routine Vector ($f6ed)

.segment "LOADER"

loader:
                .assert *=$086f, error  ; check linker placed us correctly
                lda     #$f1
                cmp     $327
                beq     loading         ; no autostart

                ; repair CHROUT vector
                sta     $327
                lda     #$ca
                sta     $326

                ; forget the (bogus) return address
                pla
                pla

                ; and instead use the "READY." routine
                lda     #>(READY-1)
                pha
                lda     #<(READY-1)
                pha

                jmp     load

                ; print loading message
loading:        ldx     #0
ldmsgloop:      lda     ld_loading,x
                jsr     CHROUT
                inx
                cpx     #ld_loadinglen
                bne     ldmsgloop

                ; started from BASIC -> program line will grow by one
                inc     $7a

load:           lda     $ba
                sta     ld_devnum       ; set bootloader device number
                jsr     chainload

                ; print "done."
                ldx     #0
doneloop:       lda     ld_done,x
                jsr     CHROUT
                inx
                cpx     #ld_donelen
                bne     doneloop

                ; copy BASIC header to correct location ($801)
                ldx     #ks_basichdrlen - 1
hdrcopyloop:    lda     ks_basichdr,x
                sta     $801,x
                dex
                bpl     hdrcopyloop

                lda     $ba
                sta     ks_devnum       ; set kickstart device number
                ; execute kickstart
                jmp     __KSENTRY_LOAD__

.segment "LDDATA"

ld_loading:     .byte   13, "loading kickstart..."
ld_loadinglen   = *-ld_loading

ld_done:        .byte   " done.", 13
ld_donelen      = *-ld_done

ks_basichdr:    .word   $080b           ; next basic line
                .word   $17             ; 23
                .byte   $9E             ; SYS
                .byte   "49152", 0
                .word   0               ; placed at $080b after copied
ks_basichdrlen  = *-ks_basichdr

; vim: et:si:ts=8:sts=8:sw=8
