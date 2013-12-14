;
; read input from keyboard
;

.include "keyboard.inc"
.include "kbctrlcodes.inc"
.include "petscii_lc.inc"

.export kb_in

.segment "KICKSTART"

kb_in:
                jsr     kb_get
                bcs     kbi_out
                tax
                and     #%10000000
                beq     noctrl
                bit     kbi_ctrl_ind
                rts
noctrl:         txa
                tay
                lda     ctrlmap_us,y
                tax
                beq     noctrl2
                bit     kbi_ctrl_ind
noctrl2:        lda     keymap_us,y
                clv
kbi_out:        rts
                
.segment "KSDATA"

kbi_ctrl_ind:   .byte $ff

keymap_us:
                .byte   0,  0,  0,  0,  0,  0,  0,  0
                .byte   0,'e','s','z','4','a','w','3'
                .byte 'x','t','f','c','6','d','r','5'
                .byte 'v','u','h','b','8','g','y','7'
                .byte 'n','o','k','m','0','j','i','9'
                .byte ',','@',':','.','-','l','p','+'
                .byte '/','^','=',  0,  0,';','*',124
                .byte   0,'q',  0,' ','2',  0,  0,'1'
                .byte   0,  0,  0,  0,  0,  0,  0,  0
                .byte   0,'E','S','Z','$','A','W','#'
                .byte 'X','T','F','C','&','D','R','%'
                .byte 'V','U','H','B','(','G','Y', 39
                .byte 'N','O','K','M','0','J','I',')'
                .byte '<','@','[','>','-','L','P','+'
                .byte '?','^','=',  0,  0,';','*',124
                .byte   0,'Q',  0,' ','"',  0,  0,'!'

ctrlmap_us:
                .byte KBC_DOWN, KBC_F5, KBC_F3, KBC_F1, KBC_F7, KBC_RIGHT, KBC_ENTER, KBC_BACKSPACE
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,KBC_HOME,0,0,0
                .byte KBC_STOP,0,KBC_CBM,0,0,0,0,0
                .byte KBC_UP, KBC_F6, KBC_F4, KBC_F2, KBC_F8, KBC_LEFT, KBC_ENTER1, KBC_INSERT
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,KBC_CLEAR,0,0,0
                .byte KBC_RUN,0,KBC_CBM1,0,0,0,0,0

; vim: et:si:ts=8:sts=8:sw=8
