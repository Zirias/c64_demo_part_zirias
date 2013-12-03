;
; define 2 sprite zones
;
; Felix Palmen <felix@palmen-it.de>  2013-11-30
;

.include "vic.inc"

; export shadow registers

; zone 0
.export sprite_0_0_x
.export sprite_0_0_y
.export sprite_0_1_x
.export sprite_0_1_y
.export sprite_0_2_x
.export sprite_0_2_y
.export sprite_0_3_x
.export sprite_0_3_y
.export sprite_0_4_x
.export sprite_0_4_y
.export sprite_0_5_x
.export sprite_0_5_y
.export sprite_0_6_x
.export sprite_0_6_y
.export sprite_0_7_x
.export sprite_0_7_y
.export sprite_0_x_h
.export sprite_0_show
.export sprite_0_dbl_y
.export sprite_0_layer
.export sprite_0_multi
.export sprite_0_dbl_x
.export sprite_0_mcol_1
.export sprite_0_mcol_2
.export sprite_0_0_col
.export sprite_0_1_col
.export sprite_0_2_col
.export sprite_0_3_col
.export sprite_0_4_col
.export sprite_0_5_col
.export sprite_0_6_col
.export sprite_0_7_col

; zone 1
.export sprite_1_0_x
.export sprite_1_0_y
.export sprite_1_1_x
.export sprite_1_1_y
.export sprite_1_2_x
.export sprite_1_2_y
.export sprite_1_3_x
.export sprite_1_3_y
.export sprite_1_4_x
.export sprite_1_4_y
.export sprite_1_5_x
.export sprite_1_5_y
.export sprite_1_6_x
.export sprite_1_6_y
.export sprite_1_7_x
.export sprite_1_7_y
.export sprite_1_x_h
.export sprite_1_show
.export sprite_1_dbl_y
.export sprite_1_layer
.export sprite_1_multi
.export sprite_1_dbl_x
.export sprite_1_mcol_1
.export sprite_1_mcol_2
.export sprite_1_0_col
.export sprite_1_1_col
.export sprite_1_2_col
.export sprite_1_3_col
.export sprite_1_4_col
.export sprite_1_5_col
.export sprite_1_6_col
.export sprite_1_7_col

; routines
.export sprite_zone0
.export sprite_zone1

; memory configuration
vic_bank = $40
vic_colpage = $1c
sprite_0_base = $10
sprite_1_base = $12

; some statically calculated values
sprite_0_baseptr = sprite_0_base << 2
sprite_1_baseptr = sprite_1_base << 2
sprite_vectors = ((vic_bank + vic_colpage) << 8) + $3f8

.bss

; define shadow registers

; zone 0

sprite_pos_0:
sprite_0_0_x:           .res 1
sprite_0_0_y:           .res 1
sprite_0_1_x:           .res 1
sprite_0_1_y:           .res 1
sprite_0_2_x:           .res 1
sprite_0_2_y:           .res 1
sprite_0_3_x:           .res 1
sprite_0_3_y:           .res 1
sprite_0_4_x:           .res 1
sprite_0_4_y:           .res 1
sprite_0_5_x:           .res 1
sprite_0_5_y:           .res 1
sprite_0_6_x:           .res 1
sprite_0_6_y:           .res 1
sprite_0_7_x:           .res 1
sprite_0_7_y:           .res 1
sprite_0_x_h:           .res 1
sprite_pos_0_size = *-sprite_pos_0-1

sprite_0_show:          .res 1

sprite_0_dbl_y:         .res 1

sprite_cfg_0:
sprite_0_layer:         .res 1
sprite_0_multi:         .res 1
sprite_0_dbl_x:         .res 1
sprite_cfg_0_size = *-sprite_cfg_0-1

sprite_col_0:
sprite_0_mcol_1:        .res 1
sprite_0_mcol_2:        .res 1
sprite_0_0_col:         .res 1
sprite_0_1_col:         .res 1
sprite_0_2_col:         .res 1
sprite_0_3_col:         .res 1
sprite_0_4_col:         .res 1
sprite_0_5_col:         .res 1
sprite_0_6_col:         .res 1
sprite_0_7_col:         .res 1
sprite_col_0_size = *-sprite_col_0-1

; zone 1

sprite_pos_1:
sprite_1_0_x:           .res 1
sprite_1_0_y:           .res 1
sprite_1_1_x:           .res 1
sprite_1_1_y:           .res 1
sprite_1_2_x:           .res 1
sprite_1_2_y:           .res 1
sprite_1_3_x:           .res 1
sprite_1_3_y:           .res 1
sprite_1_4_x:           .res 1
sprite_1_4_y:           .res 1
sprite_1_5_x:           .res 1
sprite_1_5_y:           .res 1
sprite_1_6_x:           .res 1
sprite_1_6_y:           .res 1
sprite_1_7_x:           .res 1
sprite_1_7_y:           .res 1
sprite_1_x_h:           .res 1
sprite_pos_1_size = *-sprite_pos_1-1

sprite_1_show:          .res 1

sprite_1_dbl_y:         .res 1

sprite_cfg_1:
sprite_1_layer:         .res 1
sprite_1_multi:         .res 1
sprite_1_dbl_x:         .res 1
sprite_cfg_1_size = *-sprite_cfg_1-1

sprite_col_1:
sprite_1_mcol_1:        .res 1
sprite_1_mcol_2:        .res 1
sprite_1_0_col:         .res 1
sprite_1_1_col:         .res 1
sprite_1_2_col:         .res 1
sprite_1_3_col:         .res 1
sprite_1_4_col:         .res 1
sprite_1_5_col:         .res 1
sprite_1_6_col:         .res 1
sprite_1_7_col:         .res 1
sprite_col_1_size = *-sprite_col_1-1

.code

; activate zone 0
sprite_zone0:
                ldy     #(sprite_0_baseptr + 7)
                ldx     #7
ptrloop0:       tya
                sta     sprite_vectors,x
                dey
                dex
                bpl     ptrloop0
                lda     #0
                sta     SPRITE_SHOW
                ldx     #sprite_pos_0_size
posloop0:       lda     sprite_pos_0,x
                sta     SPRITE_0_X,x
                dex
                bpl     posloop0
                lda     sprite_0_dbl_y
                sta     SPRITE_DBL_Y
                ldx     #sprite_cfg_0_size
cfgloop0:       lda     sprite_cfg_0,x
                sta     SPRITE_LAYER,x
                dex
                bpl     cfgloop0
                ldx     #sprite_col_0_size
colloop0:       lda     sprite_col_0,x
                sta     SPRITE_MCOL_1,x
                dex
                bpl     colloop0
                lda     sprite_0_show
                sta     SPRITE_SHOW
                rts

; activate zone 1
sprite_zone1:
                ldy     #(sprite_1_baseptr + 7)
                ldx     #7
ptrloop1:       tya
                sta     sprite_vectors,x
                dey
                dex
                bpl     ptrloop1
                lda     #0
                sta     SPRITE_SHOW
                ldx     #sprite_pos_1_size
posloop1:       lda     sprite_pos_1,x
                sta     SPRITE_0_X,x
                dex
                bpl     posloop1
                lda     sprite_1_dbl_y
                sta     SPRITE_DBL_Y
                ldx     #sprite_cfg_1_size
cfgloop1:       lda     sprite_cfg_1,x
                sta     SPRITE_LAYER,x
                dex
                bpl     cfgloop1
                ldx     #sprite_col_1_size
colloop1:       lda     sprite_col_1,x
                sta     SPRITE_MCOL_1,x
                dex
                bpl     colloop1
                lda     sprite_1_show
                sta     SPRITE_SHOW
                rts

; vim: et:si:ts=8:sts=8:sw=8
