zeroPtr = $FB
rowTable        BYTE $0400,$0428,$0450,$0478,$04A0,$04C8,$04F0,$0518,$0540,$0568,$0590,$05B8,$05E0,$0608,$0630,$0658,$0680,$06A8,$06D0,$06F8,$0720,$0748,$0770,$0798,$0400
collPos         BYTE $00,$00

collPosY        adc #$01                        ;offset some pixels
                lsr                             ;ypos / 4 (rowTable contains 16bit pointers)
                lsr
                sbc #$07                        ;offset for top border
                rts                             ;ypos offset is doubled (1 char = 2 offset)

strPosY         and #$fe                        ;avoid uneven numbers
                sta collPos+1
                tay
                lda rowTable,y
                sta zeroPtr
                lda rowTable+1,y
                sta zeroPtr+1
                rts

collPosX        lsr                             ;xpos / 8
                lsr
                lsr
                sbc #$01                        ;center offset
                rts

ldCharAtPos     bne @chkOverflow               
                tya
                clc
                adc #$1f
                tay
@chkOverflow    tya
                cmp #$28                        ;make sure that position overflows with x-position
                bcc @end
                ldy #$27
@end            sty collPos
                ;lda #$00
                ;sta (zeroPtr),y
                lda (zeroPtr),y
                ;lda #$80
                rts

defm getOverflowBit
                tay
                lda $d010
                and #/1
                cmp #/1                        ;if upper bit is used, add 31 to charPtr
                endm