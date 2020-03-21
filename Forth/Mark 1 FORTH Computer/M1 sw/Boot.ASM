; Mark 1 FORTH Computer
; Monitor
; Copyright (c) Andrew Holme 2003-2006
; http://www.holmea.demon.co.uk

.Model Tiny
.Code

                DW 0FFFFh       ; Hardware interrupt
                DW Reset        ; Hardware reset

                ; =====================================

Reset           DW UART_Init
                DW _DotQuote
                DB 7, 'Monitor'
                
Prompt          DW CR, Lit, '>', Emit
Prompt1         DW Key, Dupe, Emit

                DW Case, ':', Rx
                DW Case, 'g', Go
                DW Case, 'G', Go

                DW Drop, Branch, Prompt

                ; =====================================

Case            DB OP_ENTER                     ; key
                DW R, Fetch                     ; key cmd
                DW Over, Equals                 ; key f
                DW OBranch, Case1

                DW Drop
                DW FromR, Lit, 2, Plus, Fetch
                DW ToR, Exit

Case1           DW FromR, Lit, 4, Plus
                DW ToR, Exit

                ; =====================================

Rx              DW GetByte                      ; ( - n )
                DW Dupe, OBranch, RxOK          ; :00000001FF ?

                DW GetWord, GetByte, Drop       ; ( - n a )
                DW Swap, Over, Plus, Swap, _Do
Rx1             DW GetByte, I, CPling, _Loop, Rx1
                DW GetByte, Drop
                DW Key, Lit, 13, Equals, OBranch, RxErr
                DW Branch, Prompt1
                
RxOK            DW Drop 
RxOK1           DW Key, Lit, 13, Equals, OBranch, RxOK1
                DW CR, _DotQuote
                DB 5, 'Rx OK'
                DW Branch, Prompt

RxErr           DW CR, _DotQuote
                DB 5, "Error"
RxErr1          DW Branch, RxErr1

                ; =====================================

Go              DW CR, Lit, 2000h, ToR, Exit

                ; =====================================

GetWord         DB OP_ENTER
                DW GetByte, LShift4, LShift4, GetByte, Plus
                DW Exit

GetByte         DB OP_ENTER
                DW GetDigit, LShift4, GetDigit, Plus
                DW Exit

GetDigit        DB OP_ENTER
                DW Key
                DW Lit, '0', Subtract
                DW Lit, 9, Over, LessThan
                DW OBranch, DGTQ1
                DW Lit, 7, Subtract
DGTQ1:          DW Exit

                ; =====================================

UART_Init       DB OP_ENTER
                DW Lit, 0, UART_Command
                DW Lit, 0, UART_Command
                DW Lit, 0, UART_Command
                DW Lit, 040h, UART_Command
                DW Lit, 0CEh, UART_Command
                DW Lit, 005h, UART_Command
                DW Exit

UART_Command    DB OP_ENTER
                DW Lit, 0E001h, CPling              ; 0E001 C!
                DW Exit

                ; =====================================

Emit            DB OP_ENTER
                DW Lit, 0E000h, CPling              ; 0E000 C!
Emit1           DW Lit, 0E001h, CFetch              ; BEGIN 0E001 C@
                DW Lit, 1, BitAND, OBranch, Emit1      ; 1 AND UNTIL
                DW Exit

Key             DB OP_ENTER
Key1            DW QryTerminal, OBranch, Key1       ; BEGIN ?TERMINAL UNTIL
                DW Lit, 0E000h, CFetch              ; 0E000 C@
                DW Exit

CR              DB OP_ENTER
                DW Lit, 13, Emit
                DW Lit, 10, Emit, Exit

QryTerminal     DB OP_ENTER
                DW Lit, 0E001h, CFetch              ; 0E000 C@
                DW Lit, 2, BitAND, ZeroEq, ZeroEq   ; 2 AND 0= 0=
                DW Exit

                ; =====================================

Count           DB OP_ENTER
                DW Dupe, Lit, 1, Plus, Swap, CFetch, Exit

_DotQuote       DB OP_ENTER
                DW R, Count, Dupe, Lit, 1, Plus, FromR, Plus, ToR
                DW Over, Plus, Swap, _Do
Type0:          DW I, CFetch, Emit, _Loop, Type0, Branch, Type2
Type1:          DW Drop
Type2:          DW Exit

                ; =====================================

Equals          DB OP_ENTER
                DW Subtract, ZeroEq, Exit

Subtract        DB OP_ENTER
                DW Minus, Plus, Exit

LessThan        DB OP_ENTER
                DW Subtract, ZeroLt, Exit

LShift4         DB OP_ENTER
                DW Dupe, Plus
                DW Dupe, Plus
                DW Dupe, Plus
                DW Dupe, Plus
                DW Exit

                ; =====================================

                Include OPS.INC

Lit             DB OP_LIT
Execute         DB OP_EXECUTE
Branch          DB OP_BRANCH
OBranch         DB OP_0BRANCH
_Loop           DB OP_LOOP
_PlusLoop       DB OP_PLUSLOOP
_Do             DB OP_DO
I               DB OP_R
Leave           DB OP_LEAVE

BitAND          DB OP_AND
BitOR           DB OP_OR
BitXOR          DB OP_XOR

Exit            DB OP_EXIT
FromR           DB OP_R_FROM
ToR             DB OP_TO_R
R               DB OP_R
ZeroEq          DB OP_0_EQ
ZeroLt          DB OP_0_LT
Plus            DB OP_PLUS
DPlus           DB OP_D_PLUS
Minus           DB OP_MINUS
DMinus          DB OP_D_MINUS

Over            DB OP_OVER
Drop            DB OP_DROP
Swap            DB OP_SWAP
Dupe            DB OP_DUP

Fetch           DB OP_FETCH
CFetch          DB OP_C_FETCH
Pling           DB OP_PLING
CPling          DB OP_C_PLING

                END
