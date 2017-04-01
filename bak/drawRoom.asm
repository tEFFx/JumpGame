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

drawRoom        drawLine 0
                drawLine 200
                drawLine 400
                drawLine 600
                drawLine 800
                rts