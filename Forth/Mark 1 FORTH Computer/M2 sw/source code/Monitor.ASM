.model tiny
.code

                Include Mk2.INC

                ; ----------------------------------------------

$NEXT           MACRO
                immed   alu_b, pc, Next
                ENDM

                ; ----------------------------------------------

                ORG 0

Zero:           immed   alu_b, w, Vectors-Zero      ; mov W, Vectors
                rdword  pc, w                       ; jmp Boot

Next            EQU $-Zero

                rdword  w, ip                       ; mov W, [IP]
                immed   alu_add, ip, 2              ; add IP, 2
                rdword  pc, w                       ; jmp [W]

Vectors         DW Boot
                DW 8000h    ; PSP
                DW 7000h    ; RSP
                DW Main     ; IP

Boot:           immed   alu_add, w, 2               ; add W, 2
                rdword  psp, w                      ; mov PSP, [W]
                immed   alu_add, w, 2               ; add W, 2
                rdword  rsp, w                      ; mov RSP, [W]
                immed   alu_add, w, 2               ; add W, 2
                rdword  ip, w                       ; mov IP, Main

                $NEXT                               ; jmp NEXT

                ; ----------------------------------------------

Enter:          $PUSH   ip, rsp
                immed   alu_add, w, 2
                r2r     alu_a, ip, w
                $NEXT

Exit            DW $+2
                $PULL   ip, rsp
                $NEXT

                ; ----------------------------------------------

Lit             DW $+2
                rdword  w, ip
                immed   alu_add, ip, 2
                $PUSH   w, psp
                $NEXT

                ; ----------------------------------------------

IOFetch         DW $+2
                rdword  w, psp
                ior     w, w
                wrword  w, psp
                $NEXT

IOPling         DW $+2
                $PULL   8, psp
                $PULL   9, psp
                iow     9, 8
                $NEXT

Fetch           DW $+2
                rdword  w, psp
                rdword  w, w
                wrword  w, psp
                $NEXT

CFetch          DW $+2
                rdword  w, psp
                rdbyte  w, w
                wrword  w, psp
                $NEXT

CPling          DW $+2
                $PULL   8, psp
                $PULL   9, psp
                wrbyte  9, 8
                $NEXT

                ; ----------------------------------------------

OBranch         DW $+2
                testm   psp
                immed   alu_add, psp, 2
                cond    cond_beq, OBranch_1

                immed   alu_add, ip, 2
                $NEXT

OBranch_1:      rdword  ip, ip
                $NEXT

                ; ----------------------------------------------

Branch          DW $+2
                rdword  ip, ip
                $NEXT

                ; ----------------------------------------------

$BinaryOp       MACRO alu_func

                DW $+2

                $PULL           8, psp
                rdword          9, psp
                r2r alu_func    8, 9
                wrword          8, psp
                $NEXT

                ENDM

                ; ----------------------------------------------

BitAND:         $BinaryOp alu_And
Plus:           $BinaryOp alu_Add
Subtract:       $BinaryOp alu_Sub

                ; ----------------------------------------------

TestTOS         MACRO cond_true
                LOCAL $1

                DW $+2

                testm psp
                cond cond_true $1

                immed alu_b 8 0
                wrword 8 psp
                $NEXT

$1:             immed alu_not_b 8 0
                wrword 8 psp
                $NEXT

                ENDM

                ; ----------------------------------------------

ZeroEq:         TestTOS cond_BEQ
ZeroLt:         TestTOS cond_BMI

                ; ----------------------------------------------

Equals          DW Enter, Subtract, ZeroEq, Exit
LessThan        DW Enter, Subtract, ZeroLt, Exit

                ; ----------------------------------------------

Dupe            DW $+2
                rdword  8, psp
                $PUSH   8, psp
                $NEXT

Swap            DW $+2
                $PULL   8, psp
                rdword  9, psp
                wrword  8, psp
                $PUSH   9, psp
                $NEXT

Drop            DW $+2
                immed alu_add,  psp, 2
                $NEXT

Over            DW $+2
                immed alu_add,  psp, 2
                rdword      8,  psp             
                immed alu_sub,  psp, 4
                wrword      8,  psp
                $NEXT

                ; ----------------------------------------------

R               DW $+2
                rdword  8, rsp
                $PUSH   8, psp
                $NEXT

FromR           DW $+2
                $PULL   8, rsp
                $PUSH   8, psp
                $NEXT

ToR             DW $+2
                $PULL   8, psp
                $PUSH   8, rsp
                $NEXT

                ; ----------------------------------------------

_Do             DW $+2
                $PULL 8, psp
                $PULL 9, psp
                $PUSH 9, rsp
                $PUSH 8, rsp
                $NEXT

_Loop           DW $+2
                $PULL 8 rsp
                immed alu_add 8 1
                rdword 9 rsp

                r2r alu_sub 9 8
                cond cond_bcs _Loop_1

                $PUSH 8 rsp
                rdword ip ip
                $NEXT

_Loop_1:        immed alu_add rsp 2
                immed alu_add ip 2
                $NEXT

                ; ----------------------------------------------

UART_Base       EQU 0C000h

UART_Init       DW Enter
                DW Lit, 0, UART_Command
                DW Lit, 0, UART_Command
                DW Lit, 0, UART_Command
                DW Lit, 040h, UART_Command
                DW Lit, 0CEh, UART_Command
                DW Lit, 007h, UART_Command
                DW Exit

UART_Command    DW Enter
                DW Lit, UART_Base+1, IOPling                ; xxx1 IO!
                DW Exit

UART_Emit       DW Enter
UART_Emit_1     DW Lit, UART_Base+1, IOFetch                ; BEGIN xxx1 IO@
                DW Lit, 1, BitAND, OBranch, UART_Emit_1     ; 1 AND UNTIL
                DW Lit, UART_Base, IOPling                  ; xxx0 IO!
                DW Exit

                ; ----------------------------------------------

Emit            EQU UART_Emit
Init            EQU UART_Init

Space           DW Enter, Lit, 32, Emit, Exit
                    
CRLF            DW Enter
                DW Lit, 13, Emit
                DW Lit, 10, Emit
                DW Exit

Key             DW Enter
Key1            DW QryTerminal, OBranch, Key1       ; BEGIN ?TERMINAL UNTIL
                DW Lit, UART_Base, IOFetch          ; C000 IO@
                DW Exit

QryTerminal     DW Enter
                DW Lit, UART_Base+1, IOFetch        ; C001 IO@
                DW Lit, 2, BitAND, ZeroEq, ZeroEq   ; 2 AND 0= 0=
                DW Exit

                ; ----------------------------------------------

Main            DW Init
                DW CRLF
                DW Lit, 'M', Emit
                DW Lit, 'o', Emit
                DW Lit, 'n', Emit
                DW Lit, 'i', Emit
                DW Lit, 't', Emit
                DW Lit, 'o', Emit
                DW Lit, 'r', Emit
                
Prompt          DW CRLF
                DW Lit, '>', Emit
Prompt_1        DW Key, Dupe, Emit

                DW Case, ':', Rx
                DW Case, 'g', Go
                DW Case, 'G', Go
                DW Case, 'c', Count
                DW Case, 'C', Count
                DW Case, 'd', Dump
                DW Case, 'D', Dump
                DW Case, 's', Soak
                DW Case, 'S', Soak
                DW Case, 'b', Block
                DW Case, 'B', Block

                DW Drop, Branch, Prompt

                ; =====================================

Case            DW Enter                ; key
                DW R, Fetch             ; key cmd
                DW Over, Equals         ; key f
                DW OBranch, Case1

                DW Drop
                DW FromR, Lit, 2, Plus, Fetch
                DW ToR, Exit

Case1           DW FromR, Lit, 4, Plus
                DW ToR, Exit

                ; =====================================

Rx              DW GetByte                          ; ( - n )
                DW Dupe, OBranch, RxOK              ; :00000001FF ?

                DW GetWord, GetByte, Drop           ; ( - n a )
                DW Swap, Over, Plus, Swap, _Do
Rx1             DW GetByte, R, CPling, _Loop, Rx1
                DW GetByte, Drop
                DW Key, Lit, 13, Equals, OBranch, RxErr
                DW Key, Drop
                DW Branch, Prompt
                
RxOK            DW Drop 
RxOK1           DW Key, Lit, 13, Equals, OBranch, RxOK1
                DW Key, Drop
                DW CRLF
                DW Lit, 'O', Emit
                DW Lit, 'K', Emit
                DW Branch, Prompt

RxErr           DW CRLF
                DW Lit, 'E', Emit
                DW Lit, 'r', Emit
                DW Lit, 'r', Emit
RxErr1          DW Branch, RxErr1

                ; =====================================

Go              DW CRLF, Lit, 4000h, ToR, Exit

                ; =====================================

GetWord         DW Enter
                DW GetByte, LShift4, LShift4, GetByte, Plus
                DW Exit

GetByte         DW Enter
                DW GetDigit, LShift4, GetDigit, Plus
                DW Exit

GetDigit        DW Enter
                DW Key
                DW Lit, '0', Subtract
                DW Lit, 9, Over, LessThan
                DW OBranch, DGTQ1
                DW Lit, 7, Subtract
DGTQ1:          DW Exit

LShift4         DW Enter
                DW Dupe, Plus
                DW Dupe, Plus
                DW Dupe, Plus
                DW Dupe, Plus
                DW Exit

                ; =================================================================================
                ; =================================================================================
                ; =================================================================================

Count           DW Lit, 0               
Count_1         DW CRLF
                DW Alpha, Lit, 32, Emit, Dupe, Print
                DW Lit, 1, Plus
                DW Branch, Count_1

Alpha           DW Enter
                DW Lit, 91, Lit, 65, _Do
Alpha_1         DW R, Emit, _Loop, Alpha_1
                DW Exit

                ; ----------------------------------------------

$ASL            MACRO r
                r2r alu_asl, r, r
                ENDM

$ROL            MACRO r
                r2r alu_rol, r, r
                ENDM

                ; ----------------------------------------------

Divisor         EQU 8
DivHi_Rem       EQU 9
DivLo_Quot      EQU 10
DivTemp         EQU 11

$DivBit         MACRO
                LOCAL $1

                $ROL            DivHi_Rem

                r2r alu_a       DivTemp, Divisor
                r2r alu_sub     DivTemp, DivHi_Rem      ; Temp = DivHi_Rem - Divisor

                cond cond_bcc   $1                      ; branch if <
                r2r alu_a       DivHi_Rem, DivTemp      ; DivHi_Rem = Temp

$1:             $ROL            DivLo_Quot

                ENDM

                ; ----------------------------------------------

Divide          DW $+2

                $PULL   Divisor,    psp
                $PULL   DivHi_Rem,  psp
                $PULL   DivLo_Quot, psp
                    
                $ASL    DivLo_Quot

                $DivBit
                $DivBit
                $DivBit     
                $DivBit

                $DivBit
                $DivBit
                $DivBit
                $DivBit

                $DivBit
                $DivBit
                $DivBit
                $DivBit

                $DivBit
                $DivBit
                $DivBit
                $DivBit

                $PUSH   DivLo_Quot, psp
                $PUSH   DivHi_Rem,  psp

                $NEXT

                ; ----------------------------------------------

Digit:          DW Enter
                DW Lit,  0
                DW Lit, 10
                DW Divide
                DW Lit, '0'
                DW Plus
                DW Swap
                DW Exit

Print:          DW Enter
                DW Digit
                DW Digit
                DW Digit
                DW Digit
                DW Digit
                DW Drop
                DW Emit
                DW Emit
                DW Emit
                DW Emit
                DW Emit
                DW Exit

                ; =================================================================================

DotNibble       DW Enter
                DW Lit,  0
                DW Lit, 16
                DW Divide
                DW Dupe, Lit, 10, LessThan, OBranch, DotNibble_1
                DW Lit, '0',    Plus, Swap, Exit

DotNibble_1     DW Lit, 'A'-10, Plus, Swap, Exit

DotByte         DW Enter
                DW DotNibble
                DW DotNibble
                DW Drop
                DW Emit
                DW Emit
                DW Exit

DotWord         DW Enter
                DW DotNibble
                DW DotNibble
                DW DotNibble
                DW DotNibble
                DW Drop
                DW Emit
                DW Emit
                DW Emit
                DW Emit
                DW Exit

                ; =================================================================================

Dump16          DW Enter, CRLF
                DW Dupe, DotWord, Space, Lit, 16, Lit, 0, _Do
Dump_1          DW Dupe, R, Plus, CFetch, Space, DotByte, _Loop, Dump_1
                DW Drop, Exit

Dump            DW GetWord, Dump16, Branch, Prompt

Soak            DW GetWord
Soak_1          DW Dupe, Dump16, Branch, Soak_1

Block           DW GetWord, Lit, 8, Lit, 0, _Do
Block_1         DW Dupe, Dump16, Lit, 16, Plus, _Loop, Block_1, Drop, Branch, Prompt


                ; =================================================================================

                END
