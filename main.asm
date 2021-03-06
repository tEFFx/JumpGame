; 10 SYS (4096)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

*=$1000
init            jsr clearScr
                jsr drawRoom
                lda #$02                ;set up sprite multicolor
                sta $d025
                lda #$05
                sta $d026
                jsr initPlayer
                sei                     ;set up irq routine
                ldy #$7f/4
                sty $dc0d
                sty $dd0d
                lda $dc0d
                lda $dd0d
                lda #$01
                sta $d01a
                lda #<irq
                ldx #>irq
                sta $0314
                stx $0315
                lda #$00
                sta $d012
                lda $d011
                and #$7f
                sta $d011
                cli
@border         lda #$00
                sta $3fff
@wait249        lda #$f9
                cmp $d012
                bne @wait249
                lda $d011
                and #$f7
                sta $d011
@wait255        lda #$ff
                cmp $d012
                bne @wait255
                lda $d011
                ora #$08
                sta $d011
                jmp @border

irq             dec $d019
                jsr updatePlayer
                jsr incBg
                jmp $ea81 

bgCol           dec $d019
                jsr incBg
                jmp $ea81

incBg           ldy currBg
                lda bgTable,y
                sta $d021
                cpy #$00
                beq @setBg
                cpy #bgLen-1
                beq @setBg
                lda #borderCol
@setBg          sta $d020
                cpy #bgLen-1
                beq @resetIrq
@nextIrq        sei
                lda #<bgCol
                ldx #>bgCol
                sta $0314
                stx $0315
                lda rasterRows,y
                sta $d012
                cli
                iny
                jmp @end
@resetIrq       sei
                lda #<irq
                ldx #>irq
                sta $0314
                stx $0315
                lda #$00
                sta $d012
                cli
                ldy #$00
@end            sty currBg
                rts

clearScr        lda #$20
                ldx #$00
@loop           sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $06e8,x
                inx
                bne @loop
                rts

bgLen = 5
borderCol = $02
currBg          BYTE $00
bgTable         BYTE 8,15,12,11,0
rasterRows      BYTE 49,116,182,250
rowTable        BYTE $0400,$0428,$0450,$0478,$04A0,$04C8,$04F0,$0518,$0540,$0568,$0590,$05B8,$05E0,$0608,$0630,$0658,$0680,$06A8,$06D0,$06F8,$0720,$0748,$0770,$0798,$07C0
colorRamTable   BYTE $D800,$D828,$D850,$D878,$D8A0,$D8C8,$D8F0,$D918,$D940,$D968,$D990,$D9B8,$D9E0,$DA08,$DA30,$DA58,$DA80,$DAA8,$DAD0,$DAF8,$DB20,$DB48,$DB70,$DB98,$DBC0
zeroPtr = $FB
zeroPtr1 = $FE

Incasm "drawRoom.asm"
Incasm "joystick.asm"
Incasm "collisionDetection.asm"
Incasm "player.asm"
Incasm "sprites.asm"                    ;$2000
Incasm "rooms.asm"                      ;$4000