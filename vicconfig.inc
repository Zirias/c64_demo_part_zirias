; memory configuration
; --------------------

; start address of vic AS ($00, $40, $80, $c0)
vic_bank = $80

; start page of character rom in vic AS
vic_charrom = $10

; start page of screen or color memory in vic AS
vic_colpage = $0c

; start page for spriteset 0 in vic AS
vic_sprite_0_base = $0a

; start page for spriteset 1 in vic AS
vic_sprite_1_base = $08


; calculated values
; -----------------

; lowest sprite pointer value for set 0
vic_sprite_0_baseptr = vic_sprite_0_base << 2

; lowest sprite pointer value for set 1
vic_sprite_1_baseptr = vic_sprite_1_base << 2

; value to AND CIA2_DATA_A with for selecting configured bank
vic_bankselect_and = $fc + ~(vic_bank >> 6)

; MEM_CTL value for hires mode
vic_memctl_hires = (vic_colpage << 2) + 9

; MEM_CTL value for text mode
vic_memctl_text = (vic_colpage << 2) + (vic_charrom >> 4) + 1

; start address of screen / color ram in 6510 AS
vic_colram = (vic_bank + vic_colpage) << 8

; start address of bitmap data in 6510 AS
vic_bitmap = (vic_bank + $20) << 8

; start address of sprite vectors in 6510 AS
vic_sprite_vectors = ((vic_bank + vic_colpage) << 8) + $3f8

; start address of spriteset 0 in 6510 AS
vic_spriteset_0 = (vic_bank + vic_sprite_0_base) << 8

; start address of spriteset 1 in 6510 AS
vic_spriteset_1 = (vic_bank + vic_sprite_1_base) << 8

; vim: ft=asm:et:si:ts=8:sts=8:sw=8
