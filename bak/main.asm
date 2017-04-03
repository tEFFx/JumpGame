
*=$1000
init            jsr drawRoom
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
                jmp *

irq             dec $d019
                jsr updatePlayer
                jmp $ea81 

Incasm "drawRoom.asm"
Incasm "joystick.asm"
Incasm "collisionDetection.asm"
Incasm "player.asm"
Incasm "sprites.asm"                    ;$2000
Incasm "rooms.asm"                      ;$4000