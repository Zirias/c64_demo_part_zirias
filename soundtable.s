;
; table with frequencies
;
; chromatic over 6 octaves
;

.export snd_tbl

.segment "MUDATA"

snd_tbl:
        .byte   $3B,$02,$5D,$02,$81,$02,$A7,$02,$CF,$02,$FA,$02
        .byte   $27,$03,$57,$03,$8A,$03,$C0,$03,$F9,$03,$34,$04
        .byte   $76,$04,$BA,$04,$01,$05,$4E,$05,$9E,$05,$F4,$05
        .byte   $4F,$06,$AF,$06,$14,$07,$80,$07,$F2,$07,$6B,$08
        .byte   $EB,$08,$73,$09,$03,$0A,$9B,$0A,$3D,$0B,$E8,$0B
        .byte   $9D,$0C,$5D,$0D,$28,$0E,$00,$0F,$E4,$0F,$D6,$10
        .byte   $D1,$11,$E6,$12,$06,$14,$37,$15,$79,$16,$D0,$17
        .byte   $3A,$19,$BA,$1A,$51,$1C,$00,$1E,$C9,$1F,$AD,$21
        .byte   $AD,$23,$CC,$25,$0C,$28,$6D,$2A,$F3,$2C,$9F,$2F
        .byte   $74,$32,$74,$35,$A2,$38,$00,$3C,$91,$3F,$59,$43
        .byte   $5A,$47,$98,$4B,$17,$50,$DA,$54,$E6,$59,$3E,$5F
        .byte   $E8,$64,$E8,$6A,$44,$71,$00,$78,$23,$7F,$B2,$86

; vim: et:si:ts=8:sts=8:sw=8
