initPlayer      lda #animIdle
                sta $07f8               ;set sprite pointer
                lda #$40
                sta $d000               ;set sprite x pos
                lda #$a0
                sta $d001               ;set sprite y pos
                lda #$01
                sta $d015               ;enable sprite 0
                sta $d01c               ;set multicolor sprite 0
                lda #$08
                sta $d027               ;set sprite color
                rts

updatePlayer    jsr playerMove
                ldx jumpPos
                lda $d001
                cpx #$00
                beq @end                ;jumpPos == 0 => no jump
                cpx #sineTableHalf
                bcs @falling
                sbc sineTable-1,x       ;jumping
                jmp @updateY
@falling        adc sineTable-1,x
@updateY        sta $d001
                cpx #sineTableLen
                beq @end
                inx
                stx jumpPos
@end            jsr playerGravity
                jsr playerAnim
                rts

playerAnim      lda animCounter
                cmp #animSpeed
                bcc @incCount
                lda #$00
                sta animCounter
                ldx animFrame
                inx
                cpx #animLen
                bne @updateFrame
                ldx #$00
@updateFrame    stx animFrame
                txa
                adc animOffset
                tax
                lda animations,x
                sta $07f8
@incCount       inc animCounter
@end            rts
                

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
                lda walkRight
                sta animOffset
@moveLeft       checkJoy joyLeft, @moveUp
                dec $d000
                lda walkLeft
                sta animOffset
@moveUp         checkJoy joyUp, @end
                lda jumpPos
                cmp #$00
                bne @end
                inc jumpPos
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
                sta zeroPtr
                lda rowTable+1,y
                sta zeroPtr+1
                lda $d000
                lsr                             ;xpos / 8
                lsr
                lsr
                sbc #$01                        ;center offset
                tay
                lda $d010
                and #$01
                cmp #$01                        ;if upper bit is used, add 31 to charPtr
                bne @chkOverflow               
                tya
                clc
                adc #$1f
                tay
@chkOverflow    tya
                cmp #$28                        ;make sure that position overflows with x-position
                bcc @checkChar
                ldy #$27
@checkChar      lda (zeroPtr),y
                cmp #$80
                bcc @checkFall
@onGround       lda jumpPos
                cmp #sineTableHalf
                bcc @end
                txa                             ;rowcollision stored in x register
                asl                             
                asl
                adc #$1d
                sta $d001                       ;move sprite to ground
                lda #$00
                sta jumpPos
                jmp @end
@checkFall      lda jumpPos                     ;if not on ground and jumpPos == 0, start falling
                cmp #$00
                bne @end
                lda #sineTableHalf
                sta jumpPos
@end            rts

animIdle = $80
animLen = $03
animSpeed = $04
idleRight = $00
idleLeft = $03
walkRight = $06
walkLeft = $09
animations      BYTE $80,$80,$80                ;idle right     $00
                BYTE $81,$81,$81                ;idle left      $03
                BYTE $82,$83,$84                ;walk right     $06
                BYTE $85,$86,$87                ;walk left      $09
animOffset      BYTE $06
animCounter     BYTE $00
animFrame       BYTE $00

zeroPtr = $FB
rowTable        BYTE $0400,$0428,$0450,$0478,$04A0,$04C8,$04F0,$0518,$0540,$0568,$0590,$05B8,$05E0,$0608,$0630,$0658,$0680,$06A8,$06D0,$06F8,$0720,$0748,$0770,$0798,$0400
jumpPos         BYTE $17

sineTableLen = 45
sineTableHalf= 22
sineTable       BYTE $03,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$03