initPlayer      lda #animIdle
                sta $07f8               ;set sprite pointer
                lda #$40
                sta $d000               ;set sprite x pos
                lda #$a0
                sta $d001               ;set sprite y pos
                lda #$01
                sta $d015               ;enable sprite 0
                sta $d01c               ;set multicolor sprite 0
                lda #$01
                sta $d027               ;set sprite color
                rts

updatePlayer    jsr playerMove
                ldx jumpPos
                cpx #$00
                beq @end                ;jumpPos == 0 => no jump
                lda $d001               ;check if tile is above player
                jsr collPosY
                sbc #$04
                jsr strPosY
                lda $d000
                jsr collPosX
                getOverflowBit $01
                jsr ldCharAtPos
                cmp #$e0                ;if solid tile, stop jump
                bne @checkJump          ;else continue jump
                lda #sineTableHalf+1      ;make jump fall
                sta jumpPos
@checkJump      lda $d001
                ldx jumpPos
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
                clc
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
                bne @checkIdle
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
                bne @checkIdle
                lda #$ff
                sta $d000
@flipUpper      lda $d010
                eor #01
                sta $d010
@checkIdle      lda animOffset
                cmp #$04
                bcc @moveRight
                sbc #$06                        ;offset from walk to idleLeft
                sta animOffset
@moveRight      checkJoy joyRight, @moveLeft
                inc $d000
                lda #walkRight
                sta animOffset
@moveLeft       checkJoy joyLeft, @moveUp
                dec $d000
                lda #walkLeft
                sta animOffset
@moveUp         checkJoy joyUp, @end
                lda jumpPos
                cmp #$00
                bne @end
                inc jumpPos
@end            rts

playerGravity   lda $d001
                jsr collPosY
                jsr strPosY
                lda $d000
                jsr collPosX
                getOverflowBit $01
                jsr ldCharAtPos
                cmp #$80
                bcc @checkFall
@onGround       lda jumpPos
                cmp #sineTableHalf
                bcc @end
                lda collPos+1                   ;get row collision 
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

jumpPos         BYTE $17
sineTableLen = 45
sineTableHalf= 22
sineTable       BYTE $03,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$03