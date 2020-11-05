screensize equ &4000
org &8100
ld hl,&c000
ld de, &c000+1
ld bc, screensize-1
ld (hl),0
ldir
ret
