; pascal-style string
.macro          string  str
                .byte   .strlen(str), str
.endmacro

; vim: ft=asm:et:si:ts=8:sts=8:sw=8
