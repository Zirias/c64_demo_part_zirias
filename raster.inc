; control routines
.import raster_on
.import raster_off
.import raster_install

; for raster payload implementors
.importzp RASTER_SAVE_A         ; saved by default
.importzp RASTER_SAVE_X         ; saved by default
.importzp RASTER_SAVE_Y         ; save y here as needed
.importzp RASTER_TBL_OFFSET     ; save index (in x) here as needed
.import raster_bottom           ; jump here to exit payload
.import raster_tbl_base         ; current raster table, get arguments from 
                                ; here with dex -- lda raster_tbl,x
.import raster_top              ; restore fffe/ffff to this after dbl irq

; default payloads (use in custom raster tables)
.import raster_keycheck

; vim: ft=asm:et:si:ts=8:sts=8:sw=8
