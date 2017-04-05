xCurr           BYTE $00
yCurr           BYTE $00
xEnd            BYTE $00
yEnd            BYTE $00
char            BYTE $00
color           BYTE $00
currOffset      BYTE $00

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

defm strRoomData
                lda room0+/1,x
                sta /2
                endm

drawRoom        lda #$00
                sta currOffset
@loop           ldx currOffset
                cpx room0               ;first byte is length
                beq @end
                strRoomData 1, xCurr
                strRoomData 2, xEnd
                inc xEnd
                strRoomData 6, char
                strRoomData 5, color
                strRoomData 4, yEnd
                inc yEnd
                strRoomData 3, yCurr
                tax
@rowLoop        cpx yEnd             ;compare with end y
                beq @incOffset          ;go to next shape if over
                txa
                asl
                tay
                setPointers
                ldy xCurr
@colLoop        cpy xEnd             ;compare with end x
                beq @incRow
                lda char
                sta (zeroPtr),y
                lda color
                sta (zeroPtr1),y
                iny
                jmp @colLoop
@incRow         inx
                jmp @rowLoop
@incOffset      lda currOffset
                clc
                adc #$06
                sta currOffset
                jmp @loop
@end            rts