initPlayer      lda #$80
                sta $07f8               ;set sprite pointer
                lda #$10
                sta $d000               ;set sprite x pos
                lda #$a0
                sta $d001               ;set sprite y pos
                lda #$01
                sta $d015               ;enable sprite 0
                sta $d01c               ;set multicolor sprite 0
                lda #$05
                sta $d027               ;set sprite color
                rts

updatePlayer    jsr playerMove
                jsr playerGravity
                rts
                

playerMove      lda $d010
                and #$01
                cmp #$01
                beq @isUpper
                lda $d000
                cmp #$ff
                bne @checkLow
                lda #$00
                sta $d000
                jmp @flipUpper
@checkLow       clc
                cmp #$00
                bne @moveRight
                lda #$56
                sta $d000
                jmp @flipUpper
@isUpper        lda $d000
                cmp #$57
                bne @checkLower
                lda #$00
                sta $d000
                jmp @flipUpper
@checkLower     clc
                cmp #$00
                bne @moveRight
                lda #$ff
                sta $d000
@flipUpper      lda $d010
                eor #01
                sta $d010
@moveRight      checkJoy joyRight, @moveLeft
                inc $d000
@moveLeft       checkJoy joyLeft, @moveUp
                dec $d000
@moveUp         checkJoy joyUp, @end
                dec $d001
                dec $d001
                dec $d001
                dec $d001
@end            rts

playerGravity   lda $d001
                adc #$01                        ;offset some pixels
                lsr                             ;ypos / 4 (rowTable contains 16bit pointers)
                lsr
                sbc #$07                        ;offset for top border
                and #$fe                        ;avoid uneven numbers
                tay
                tax                             ;store in x for later use
                lda rowTable,y
                sta charPtr
                lda rowTable+1,y
                sta charPtr+1
                lda $d000
                lsr                             ;xpos / 8
                lsr
                lsr
                sbc #$01                        ;center offset
                tay
                lda $d010
                and #$01
                cmp #$01                        ;if upper bit is used, add 31 to charPtr
                bne @checkChar
                tya
                clc
                adc #$1f
                tay
@checkChar      lda (charPtr),y
                cmp #$80
                bcs @onGround
                inc $d001
@onGround       rts

charPtr = $FB
rowTable        BYTE $0400,$0428,$0450,$0478,$04A0,$04C8,$04F0,$0518,$0540,$0568,$0590,$05B8,$05E0,$0608,$0630,$0658,$0680,$06A8,$06D0,$06F8,$0720,$0748,$0770,$0798