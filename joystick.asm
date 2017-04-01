joyUp   =       #$01
joyDown =       #$02
joyLeft =       #$04
joyRight=       #$08
joyFire =       #$10

defm            checkJoy        ;/1 = joy button, /2 = check fail routine
                lda $dc00
                and #/1
                cmp #/1
                beq /2
                endm