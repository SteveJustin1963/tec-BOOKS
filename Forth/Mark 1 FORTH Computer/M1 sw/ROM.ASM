; Mark 1 FORTH Computer
; Microcode ROM
; Copyright (c) Andrew Holme 2003-2006
; http://www.holmea.demon.co.uk

                    ; Cold start
                    ; Vector at RAM $0002 = PFA of COLD
                    
RESET:              mov w, 0            ; W = $0002
                    inc w
                    inc w

                    dis

                    mov ip.l, [w]       ; IP = PFA from vector
                    inc w
                    mov ip.h, [w]

Next:               mov w.l, [ip]       ; W = XT, IP = IP+2
                    inc ip
                    mov w.h, [ip]
                    inc ip

                    bis 3               ; Interrupt?

                    mov op, [w]         ; OP = [CFA]
                    inc w               ; W = PFA
                    xop

                    ; Interrupt handler
                    ; Vector at RAM $0000 = PFA of IRQ

IRQ:                dec rsp             ; Push IP
                    mov rs, ip

                    mov w, 0            ; W = $0000
                    jmp 4               ; Execute IRQ

;HALT:              bis 1
;                   xop
;                   jmp Next

ENTER:              dec rsp             ; Push IP
                    mov rs, ip
                    mov ip, w           ; IP = PFA
                    jmp Next

EXIT:               mov ip, rs          ; Pop IP
                    inc rsp
                    jmp Next

LIT:                dec psp
                    mov tos.l, [ip]
                    inc ip
                    mov tos.h, [ip]
                    inc ip
                    jmp Next

EXECUTE:            mov w, tos          ; W = XT
                    inc psp

                    jmp 13

BRANCH:             mov w.l, [ip]
                    inc ip
                    mov w.h, [ip]
                    mov ip, w
                    jmp Next

0BRANCH:            mov w.l, [ip]
                    inc ip
                    mov w.h, [ip]
                    inc ip

                    alu not
                    mov a, tos.l
                    bne 4
                    mov a, tos.h
                    bne 2
                    mov ip, w

                    inc psp
                    jmp Next

LOOP:               mov w, rs
                    inc w
                    mov rs, w

                    inc rsp

                    alu sub
                    mov a, w.l
                    mov b, rs.l
                    alu sbb
                    mov a, w.h
                    mov b, rs.h

                    mov w.l, [ip]
                    inc ip
                    mov w.h, [ip]
                    inc ip

                    bcs 4

                    mov ip, w           ; Loop again
                    dec rsp
                    jmp Next

                    inc rsp             ; Finished
                    jmp Next

PLUSLOOP:           alu add
                    mov a, rs.l
                    mov b, tos.l
                    mov w.l, f
                    alu adc
                    mov a, rs.h
                    mov b, tos.h
                    mov w.h, f

                    inc psp
                    mov rs, w

                    inc rsp

                    alu sub
                    mov a, w.l
                    mov b, rs.l
                    alu sbb
                    mov a, w.h
                    mov b, rs.h

                    mov w.l, [ip]
                    inc ip
                    mov w.h, [ip]
                    inc ip

                    bcs 4

                    mov ip, w           ; Loop again
                    dec rsp
                    jmp Next

                    inc rsp             ; Finished
                    jmp Next

DO:                 mov w, tos
                    inc psp
                    dec rsp
                    mov rs, tos
                    inc psp
                    dec rsp
                    mov rs, w
                    jmp Next

MUL_BEGIN:          inc psp             ; Multiplicand

                    dec rsp 
                    mov rs, tos         ; RS = Multiplicand
                    mov tos, 0          ; Product LO = 0

                    dec psp
                    jmp 13

MUL_BIT:            inc psp             ; Product LO

                    alu asl
                    mov a, tos.l
                    mov tos.l, f

                    alu rol
                    mov a, tos.h
                    mov tos.h, f

                    dec psp             ; Product HI / Multiplier

                    alu rol
                    mov a, tos.l
                    mov tos.l, f

                    alu rol
                    mov a, tos.h
                    mov tos.h, f

                    bcs 1
                    jmp 13
                    
                    inc psp             ; Product LO

                    alu add
                    mov a, tos.l
                    mov b, rs.l
                    mov tos.l, f
                    
                    alu adc
                    mov a, tos.h
                    mov b, rs.h
                    mov tos.h, f
                    
                    dec psp             ; Product HI

                    alu adc
                    mov a, tos.l
                    mov b, 0
                    mov tos.l, f

                    alu adc
                    mov a, tos.h
                    mov tos.h, f

                    jmp 13

MUL_END:            inc rsp
                    jmp Next

DIV_BEGIN:          dec rsp             ; Save IP
                    mov rs, ip

                    dec rsp             ; RS = Divisor
                    mov rs, tos         

                    inc psp             ; Dividend HI
                    inc psp             ; Dividend LO
                    
                    alu asl             ; Shift LO into carry
                    mov a, tos.l
                    mov tos.l, f

                    alu rol
                    mov a, tos.h
                    mov tos.h, f

                    jmp 13

DIV_BIT:            dec psp             ; Dividend HI / Remainder

                    alu rol
                    mov a, tos.l
                    mov tos.l, f

                    alu rol
                    mov a, tos.h
                    mov tos.h, f

                    mov ip, tos         ; Save

                    alu sub
                    mov a, tos.l
                    mov b, rs.l
                    mov tos.l, f

                    alu sbb
                    mov a, tos.h
                    mov b, rs.h
                    mov tos.h, f

                    bcs 2
                    mov tos, ip

                    inc psp             ; Dividend LO / Quotient

                    alu rol
                    mov a, tos.l
                    mov tos.l, f

                    alu rol
                    mov a, tos.h
                    mov tos.h, f

                    jmp 13

DIV_END:            dec psp             ; Dividend HI / Remainder
                    mov rs, tos
                    inc psp
                    mov w, tos
                    mov tos, rs
                    dec psp
                    mov tos, w

                    inc rsp
                    mov ip, rs
                    inc rsp
                    jmp Next

AND:                alu and
                    mov w, tos
                    inc psp
                    mov a, tos.l
                    mov b, w.l
                    mov tos.l, f
                    mov a, tos.h
                    mov b, w.h
                    mov tos.h, f
                    jmp Next

OR:                 alu or
                    mov w, tos
                    inc psp
                    mov a, tos.l
                    mov b, w.l
                    mov tos.l, f
                    mov a, tos.h
                    mov b, w.h
                    mov tos.h, f
                    jmp Next

XOR:                alu xor
                    mov w, tos
                    inc psp
                    mov a, tos.l
                    mov b, w.l
                    mov tos.l, f
                    mov a, tos.h
                    mov b, w.h
                    mov tos.h, f
                    jmp Next

LEAVE:              mov w, rs
                    inc rsp
                    mov rs, w
                    dec rsp
                    jmp Next

R_FROM:             dec psp
                    mov tos, rs
                    inc rsp
                    jmp Next
                    
TO_R:               dec rsp
                    mov rs, tos
                    inc psp
                    jmp Next

R:                  dec psp
                    mov tos, rs
                    jmp Next

0_EQ:               alu not             ; 0=
                    mov a, tos.l
                    bne 1
                    mov a, tos.h
                    mov w, 0
                    bne 1
                    dec w
                    mov tos, w
                    jmp Next

0_LT:               alu not             ; 0<
                    mov a, tos.h
                    mov w,0             ; Setup 0
                    b?? 1               ; Branch if sign bit = 0
                    dec w
                    mov tos, w
                    jmp Next

PLUS:               mov w, tos          ; +
                    inc psp
                    
                    alu add             ; tsl = tsl + wl
                    mov a, tos.l
                    mov b, w.l
                    mov tos.l, f
                    
                    alu adc             ; tsh = tsh + wh + c
                    mov a, tos.h
                    mov b, w.h
                    mov tos.h, f
                    
                    jmp Next

D_PLUS:             dec rsp             ; D+
                    mov rs, tos         ; Move lower HI Word to RS

                    inc psp             ; Lower LO Word

                    dec rsp
                    mov rs, tos         ; Move lower LO Word to RS

                    inc psp             ; Upper HI Word
                    inc psp             ; Upper LO Word
                    
                    alu add
                    mov a, tos.l
                    mov b, rs.l
                    mov tos.l, f

                    alu adc
                    mov a, tos.h
                    mov b, rs.h
                    mov tos.h, f

                    dec psp             ; Upper HI Word
                    inc rsp             ; Lower HI Word

                    alu adc
                    mov a, tos.l
                    mov b, rs.l
                    mov tos.l, f

                    alu adc
                    mov a, tos.h
                    mov b, rs.h
                    mov tos.h, f

                    inc rsp
                    jmp Next

MINUS:              mov a, 0

                    alu sub
                    mov b, tos.l
                    mov tos.l, f

                    alu sbb
                    mov b, tos.h
                    mov tos.h, f

                    jmp Next

D_MINUS:            mov a, 0            ; DMINUS
                    inc psp             ; LO

                    alu sub
                    mov b, tos.l
                    mov tos.l, f

                    alu sbb
                    mov b, tos.h
                    mov tos.h, f

                    dec psp

                    alu sbb
                    mov b, tos.l
                    mov tos.l, f

                    alu sbb
                    mov b, tos.h
                    mov tos.h, f

                    jmp Next

OVER:               inc psp
                    mov w, tos
                    dec psp
                    dec psp
                    mov tos, w
                    jmp Next

DROP:               inc psp
                    jmp Next
                    
SWAP:               dec rsp
                    mov rs, tos
                    inc psp
                    mov w, tos
                    mov tos, rs
                    dec psp
                    mov tos, w
                    inc rsp
                    jmp Next

DUP:                mov w, tos
                    dec psp
                    mov tos, w
                    jmp Next

FETCH:              mov w, tos          ; @
                    mov tos.l, [w]
                    inc w
                    mov tos.h, [w]
                    jmp Next
                    
C_FETCH:            mov w, tos          ; C@
                    mov tos.l, [w]
                    mov tos.h, 0
                    jmp Next

PLING:              mov w, tos          ; !
                    inc psp
                    mov [w], tos.l
                    inc w
                    mov [w], tos.h
                    inc psp
                    jmp Next

C_PLING:            mov w, tos          ; C!
                    inc psp
                    mov [w], tos.l
                    inc psp
                    jmp Next

DOES:               dec rsp             ; Push IP
                    mov rs, ip

                    mov ip.l, [w]       ; IP <- High level action
                    inc w
                    mov ip.h, [w]
                    inc w

                    dec psp             ; Push PFA+2
                    mov tos, w

                    jmp Next
