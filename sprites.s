.include "spritezone.inc"
.include "vic.inc"
.include "vicconfig.inc"

.export sprites_topborder
.export sprites_topborder1
.export sprites_cursor
.export sprites_marquee

.import topborder_sprites
.import marquee_sprites

.segment "AMIGADOS"

sprites_topborder:
                lda     #0
                sta     sprite_0_show
                sta     SPRITE_SHOW
tb_copy1:       lda     topborder_sprites,x
                sta     vic_spriteset_0,x
                inx
                bne     tb_copy1
tb_copy2:       lda     topborder_sprites+$100,x
                sta     vic_spriteset_0+$100,x
                inx
                bne     tb_copy2
                lda     #$3e
                sta     sprite_0_0_x
                sta     sprite_0_1_x
		lda	#$29
                sta     sprite_0_5_x
		lda	#$48
                sta     sprite_0_2_x
                lda     #$30
                sta     sprite_0_3_x
                lda     #$18
                sta     sprite_0_4_x
                sta     sprite_0_7_x
                lda     #$23
                sta     sprite_0_6_x
                lda     #%00100011
                sta     sprite_0_x_h
		lda	#0
                sta     sprite_0_dbl_y
                sta     sprite_0_0_col
                sta     sprite_0_layer
                sta     sprite_0_multi
		lda	#%00100000
                sta     sprite_0_dbl_x
                lda     #6
                sta     sprite_0_1_col
                sta     sprite_0_2_col
                sta     sprite_0_3_col
                sta     sprite_0_4_col
		lda	#1
                sta     sprite_0_5_col
                sta     sprite_0_6_col
                sta     sprite_0_7_col
                lda     #27
                sta     sprite_0_0_y
                sta     sprite_0_1_y
                sta     sprite_0_2_y
                sta     sprite_0_3_y
                sta     sprite_0_4_y
		lda	#29
                sta     sprite_0_5_y
                sta     sprite_0_6_y
                sta     sprite_0_7_y
                lda     #$ff
                sta     sprite_0_show
                rts

sprites_topborder1:
		lda	#0
		sta	sprite_0_show
		sta	SPRITE_SHOW
		ldx	#$80
tb1_copy:	lda	topborder_sprites+$200,x
		sta	vic_spriteset_0+$c0,x
		dex
		bpl	tb1_copy
		lda	#$25
		sta	sprite_0_6_x
                lda     #$ff
                sta     sprite_0_show
		rts

sprites_cursor:
                lda     #0
                sta     sprite_1_show
                sta     SPRITE_SHOW
                ldx     #$3f
cr_copy:        lda     cursor_sprite,x
                sta     vic_spriteset_1,x
                dex
                bpl     cr_copy
                lda     #$1c
                sta     sprite_1_0_x
                lda     #$52
                sta     sprite_1_0_y
                lda     #0
                sta     sprite_1_x_h
                sta     sprite_1_dbl_x
                sta     sprite_1_dbl_y
                sta     sprite_1_multi
                lda     #10
                sta     sprite_1_0_col
                lda     #1
                sta     sprite_1_layer
                sta     sprite_1_show
                rts

sprites_marquee:
                ldx     #0
                stx     sprite_1_show
                stx     SPRITE_SHOW
mq_copy1:       lda     marquee_sprites,x
                sta     vic_spriteset_1,x
                inx
                bne     mq_copy1
mq_copy2:       lda     marquee_sprites+$100,x
                sta     vic_spriteset_1+$100,x
                inx
                bne     mq_copy2
                lda     #$70
                sta     sprite_1_0_x
                lda     #$88
                sta     sprite_1_1_x
                lda     #$a0
                sta     sprite_1_2_x
                lda     #$b8
                sta     sprite_1_3_x
                lda     #$d0
                sta     sprite_1_4_x
                lda     #$e8
                sta     sprite_1_5_x
                lda     #$00
                sta     sprite_1_6_x
                lda     #$18
                sta     sprite_1_7_x
                lda     #$c0
                sta     sprite_1_x_h
                lda     #0
                sta     sprite_1_mcol_1
                sta     sprite_1_dbl_x
                sta     sprite_1_dbl_y
                lda     #7
                sta     sprite_1_mcol_2
                lda     #12
                sta     sprite_1_0_col
                sta     sprite_1_1_col
                sta     sprite_1_2_col
                sta     sprite_1_3_col
                sta     sprite_1_4_col
                sta     sprite_1_5_col
                sta     sprite_1_6_col
                sta     sprite_1_7_col
                lda     #0
                sta     sprite_1_0_y
                sta     sprite_1_1_y
                sta     sprite_1_2_y
                sta     sprite_1_3_y
                sta     sprite_1_4_y
                sta     sprite_1_5_y
                sta     sprite_1_6_y
                sta     sprite_1_7_y
                sta     sprite_1_layer
                lda     #$ff
                sta     sprite_1_multi
                sta     sprite_1_show
                rts

.segment "ADDATA"

cursor_sprite:
                .byte   %11110000,%00000000,%00000000
                .byte   %11110000,%00000000,%00000000
                .byte   %11110000,%00000000,%00000000
                .byte   %11110000,%00000000,%00000000
                .byte   %11110000,%00000000,%00000000
                .byte   %11110000,%00000000,%00000000
                .byte   %11110000,%00000000,%00000000
                .byte   %11110000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   %00000000,%00000000,%00000000
                .byte   0

; vim: et:si:ts=8:sts=8:sw=8
