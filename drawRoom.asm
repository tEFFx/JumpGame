currX           BYTE $00
currY           BYTE $00
currChar        BYTE $00
currLen         BYTE $00
currCol         BYTE $00

defm setPointers
                lda rowTable,y          ;store pointer to row
                sta zeroPtr
                lda rowTable+1,y
                sta zeroPtr+1
                lda colorRamTable,y
                sta zeroPtr1
                lda colorRamTable+1,y
                sta zeroPtr1+1
                endm

drawRoom        ldx #$00
@goNext         lda $4000,x
                cmp #$ff
                beq @return
                sta currY
                lda $4001,x
                sta currX
                lda $4002,x             ;store char
                sta currChar
                lda $4004,x
                and #$0f
                sta currCol
                lda $4004,x
                and #$80
                cmp #$80                ;is vertical?
                beq @vertical
                jmp @horizontal
@return         rts
@horizontal     dec currX
                lda currY
                asl
                tay
                setPointers
                lda $4003,x             ;store len
                adc currX               ;set counter
                tay
                iny
@horiLoop       cpy currX
                beq @continue
                lda currChar
                sta (zeroPtr),y
                lda currCol
                sta (zeroPtr1),y
                dey
                jmp @horiLoop
@vertical       lda $4003,x
                adc currY
                sta currLen
                dec currY
@vertLoop       lda currLen
                cmp currY
                beq @continue
                asl
                tay
                setPointers
                ldy currX
                lda currChar
                sta (zeroPtr),y
                lda currCol
                sta (zeroPtr1),y
                dec currLen
                jmp @vertLoop
@continue       inx
                inx
                inx
                inx
                inx
                jmp @goNext                
                rts

defm            drawLine                ;/1 = lineoffset
                ldx #$00
@loop           lda $4000+/1,x
                sta $0400+/1,x
                lda $43E8+/1,x
                sta $D800+/1,x
                inx
                clc
                cpx #$C8
                bne @loop
                endm

drawBg          drawLine 0
                drawLine 200
                drawLine 400
                drawLine 600
                drawLine 800
                rts