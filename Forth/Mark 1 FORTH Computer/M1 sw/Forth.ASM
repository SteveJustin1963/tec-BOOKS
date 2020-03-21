; Mark 1 FORTH Computer
; fig-FORTH
; Copyright (c) Andrew Holme 2003-2006
; http://www.holmea.demon.co.uk

.Model Tiny
.Code

FLAG_SMUDGE     EQU 20h
FLAG_IMMEDIATE  EQU 40h
FLAG_STATE      EQU FLAG_IMMEDIATE  ; Compared to [nfa]
FIND_MASK       EQU 2Fh

KEY_BS          EQU 8

UP              EQU 2000h
TIB             EQU 2020h
RamDict         EQU 2080h

                ; =====================================

                DW 0FFFFh       ; Hardware interrupt
                DW Reset        ; Hardware reset

                ; =====================================

Reset           DW UART_Init
                DW COLD

                ; =====================================

                Link = 0

__Head          MACRO CFA, Name, Flags, Opcode

                Local NFA, LFA

    NFA:        DB Flags+LFA-NFA-1, Name
    LFA:        DW Link, NFA
    CFA:        DB Opcode

                Link = NFA
                ENDM

                ; =====================================

$Head           MACRO CFA, Name, Op
                __Head CFA, Name, 0, Op
                ENDM

$Colon          MACRO CFA, Name
                __Head CFA, Name, 0, OP_ENTER
                ; DW Trace
                ENDM

$Immed          MACRO CFA, Name
                __Head CFA, Name, FLAG_IMMEDIATE, OP_ENTER
                ENDM

                ; =====================================

                Include OPS.INC

                $Head Lit           'LIT'       OP_LIT
                $Head Execute       'EXECUTE'   OP_EXECUTE
                $Head Branch        'BRANCH'    OP_BRANCH
                $Head OBranch       '0BRANCH'   OP_0BRANCH
                $Head _Loop         '(LOOP)'    OP_LOOP
                $Head _PlusLoop     '(+LOOP)'   OP_PLUSLOOP
                $Head _Do           '(DO)'      OP_DO
                $Head I             'I'         OP_R
                $Head Leave         'LEAVE'     OP_LEAVE

                $Head BitAND        'AND'       OP_AND
                $Head BitOR         'OR'        OP_OR
                $Head BitXOR        'XOR'       OP_XOR

                $Head Exit          ';S'        OP_EXIT
                $Head FromR         'R>'        OP_R_FROM
                $Head ToR           '>R'        OP_TO_R
                $Head R             'R'         OP_R
                $Head ZeroEq        '0='        OP_0_EQ
                $Head ZeroLt        '0<'        OP_0_LT
                $Head Plus          '+'         OP_PLUS
                $Head DPlus         'D+'        OP_D_PLUS
                $Head Minus         'MINUS'     OP_MINUS
                $Head DMinus        'DMINUS'    OP_D_MINUS

                $Head Over          'OVER'      OP_OVER
                $Head Drop          'DROP'      OP_DROP
                $Head Swap          'SWAP'      OP_SWAP
                $Head Dupe          'DUP'       OP_DUP

                $Head Fetch         '@'         OP_FETCH
                $Head CFetch        'C@'        OP_C_FETCH
                $Head Pling         '!'         OP_PLING
                $Head CPling        'C!'        OP_C_PLING

                $Head UMUL, 'U*', OP_MUL_BEGIN
                DB 16 DUP(OP_MUL_BIT), OP_MUL_END

                $Head UDIV, 'U/', OP_DIV_BEGIN
                DB 16 DUP(OP_DIV_BIT), OP_DIV_END

                ; =====================================

UART_Init:      DB OP_ENTER
                DW Lit, 0, UART_Command
                DW Lit, 0, UART_Command
                DW Lit, 0, UART_Command
                DW Lit, 040h, UART_Command
                DW Lit, 0CEh, UART_Command
                DW Lit, 005h, UART_Command
                DW Exit

UART_Command:   DB OP_ENTER
                DW Lit, 0E001h, CPling              ; 0E001 C!
                DW Exit

                ; =====================================

                $Colon Emit, 'EMIT'
                DW Lit, 0E000h, CPling              ; 0E000 C!
Emit1:          DW Lit, 0E001h, CFetch              ; BEGIN 0E001 C@
                DW Lit, 1, BitAND, OBranch, Emit1   ; 1 AND UNTIL
                DW Exit

                $Colon Key, 'KEY'
Key1:           DW QryTerminal, OBranch, Key1       ; BEGIN ?TERMINAL UNTIL
                DW Lit, 0E000h, CFetch              ; 0E000 C@
                DW Exit

                $Colon CR, 'CR'
                DW Lit, 13, Emit
                DW Lit, 10, Emit, Exit

                $Colon QryTerminal, '?TERMINAL'
                DW Lit, 0E001h, CFetch              ; 0E000 C@
                DW Two, BitAND, ZeroEq, ZeroEq      ; 2 AND 0= 0=
                DW Exit

                ; =====================================

                $Colon Count, 'COUNT'
                DW Dupe, OnePlus, Swap, CFetch, Exit

                $Colon Typ, 'TYPE'
                DW QryDupe, OBranch, Type1, Over, Plus, Swap, _Do
Type0:          DW I, CFetch, Emit, _Loop, Type0, Branch, Type2
Type1:          DW Drop
Type2:          DW Exit

                $Colon Space, 'SPACE'
                DW Blank, Emit, Exit

                $Colon Spaces, 'SPACES'
                DW Zero, Max, QryDupe, OBranch, Spaces2, Zero, _Do
Spaces1:        DW Space, _Loop, Spaces1
Spaces2:        DW Exit

                $Colon _DotQuote, '(.")'
                DW R, Count, Dupe, OnePlus, FromR, Plus, ToR, Typ, Exit

                $Immed DotQuote, '."'
                DW Lit, '"'
                DW UserState, Fetch, OBranch, DQ1, Compile, _DotQuote
                DW Werd, Here, CFetch, OnePlus, Allot, Branch, DQ2
DQ1:            DW Werd, Here, Count, Typ
DQ2:            DW Exit

                ; =====================================

                $Colon CMove, 'CMOVE'
                DW Zero, _Do
CMove1:         DW Over, I, Plus, CFetch
                DW Over, I, Plus, CPling
                DW _Loop, CMove1, Drop, Drop, Exit

                $Colon Fill, 'FILL'
                DW Swap, ToR, Over, CPling, Dupe, OnePlus, FromR, One, Subtract, CMove, Exit

                $Colon Erase, 'ERASE'
                DW Zero, Fill, Exit

                $Colon Blanks, 'BLANKS'
                DW Blank, Fill, Exit

                ; =====================================

                $Colon Variable, 'VARIABLE'
                DW Builds, Two, Allot, Does, Exit

                $Colon Constant, 'CONSTANT'
                DW Builds, Comma, Does
DoConst:        DW Fetch, Exit

$Const          MACRO Label, Name, Value
                $Head Label, Name, OP_DOES
                DW DoConst
                DW Value
                ENDM

                $Const Zero     '0'   0
                $Const One      '1'   1
                $Const Two      '2'   2
                $Const Three    '3'   3
                $Const Blank    'BL' 20h

                ; =====================================

UserDef         MACRO Label, Name, Offset
                $Const Label, Name, UP+Offset
                ENDM

User0:          DW TIB                  ; TIB
                DW 001Fh                ; WIDTH
                DW 1                    ; WARNING
                DW RAMDICT              ; DP
                DW UserLink-User0+UP    ; CONTEXT
                DW UserLink-User0+UP    ; CURRENT
UserLink:       DW LastLink             ; Last word

INIT_SIZE       EQU $-User0

                UserDef UserTIB,        'TIB',      00h
                UserDef UserWidth,      'WIDTH',    02h
                UserDef UserWarning,    'WARNING',  04h
                UserDef UserDP,         'DP',       06h
                UserDef UserContext,    'CONTEXT',  08h
                UserDef UserCurrent,    'CURRENT',  0Ah

                UserDef UserIN,         'IN',       12h
                UserDef UserOUT,        'OUT',      14h
                UserDef UserState,      'STATE',    16h
                UserDef UserBase,       'BASE',     18h
                UserDef UserDPL,        'DPL',      1Ah
                UserDef UserFLD,        'FLD',      1Ch
                UserDef UserHLD,        'HLD',      1Eh

                ; =====================================

                $Colon PlusPling, '+!'
                DW Swap, Over, Fetch, Plus, Swap, Pling, Exit

                $Colon Toggle, 'TOGGLE'
                DW Over, Fetch, BitXOR, Swap, Pling, Exit

                $Colon OnePlus, '1+'
                DW One, Plus, Exit
                                 
                $Colon TwoPlus, '2+'
                DW Two, Plus, Exit

                $Colon Here, 'HERE'
                DW UserDP, Fetch, Exit

                $Colon Allot, 'ALLOT'
                DW UserDP, PlusPling, Exit

                $Colon Comma, ','
                DW Here, Pling, Two, Allot, Exit

                $Colon CComma, 'C,'
                DW Here, CPling, One, Allot, Exit

                $Colon Subtract, '-'
                DW Minus, Plus, Exit;

                $Colon Equals, '='
                DW Subtract, ZeroEq, Exit

                $Colon LessThan '<'
                DW Subtract, ZeroLt, Exit

                $Colon GreaterThan, '>'
                DW Swap, LessThan, Exit

                $Colon Rot, 'ROT'
                DW ToR, Swap, FromR, Swap, Exit

                $Colon TwoDup, '2DUP'
                DW Over, Over, Exit

                $Colon NIP, 'NIP'
                DW Swap, Drop, Exit

                $Colon QryDupe, '?DUP'
                DW Dupe, OBranch, QryDupe1, Dupe
QryDupe1:       DW Exit

                $Colon ULess, 'U<' ; ( u u -- t )
                ; Unsigned compare of top two items.

                DW TwoDup,BitXOR,ZeroLt
                DW OBranch,ULES1
                DW SWAP,DROP,ZeroLt,EXIT
ULES1:          DW SUBtract,ZeroLt,EXIT

                ; =====================================

                $Colon Latest, 'LATEST'
                DW UserCurrent, Fetch, Fetch, Exit

                $Colon PFA2CFA, 'PFA>CFA'
                DW One, Subtract, Exit

                $Colon PFA2NFA, 'PFA>NFA'
                DW Three, Subtract, Fetch, Exit

                $Colon NFA2LFA, 'NFA>LFA'
                DW Dupe, CFetch, Lit, 1Fh, BitAND, Plus, OnePlus, Exit

                $Colon NFA2PFA, 'NFA>PFA'
                DW NFA2LFA, Lit, 5, Plus, Exit

                $Colon IdDot, 'ID.'
                DW Dupe, OnePlus, Swap, CFetch, Lit, 1Fh, BitAND, Typ, Space, Exit

                ; =====================================

                $Colon Message, 'MESSAGE'
                DW _DotQuote
                DB 6, 'MSG # '
                DW dot, Exit

                $Colon Error, 'ERROR'
                DW UserWARNING, Fetch, ZeroLt, OBranch, Error1, Abort
Error1:         DW Here, Count, Typ, _DotQuote
                DB 2, '? '
                DW Message, Quit

                $Colon QryError, '?ERROR'
                DW Swap, OBranch, QryError1, Error
QryError1:      DW Drop, Exit

                $Colon QryComp, '?COMP'
                DW UserState, Fetch, ZeroEq, Lit, 11h, QryError, Exit

                $Colon QryExec, '?EXEC'
                DW UserState, Fetch, Lit, 12h, QryError, Exit

                $Colon QryPairs, '?PAIRS'
                DW Subtract, Lit, 13h, QryError, Exit

                ; =====================================

                $Immed Colon, ':'
                DW QryExec, Create, SquareClose, Lit, OP_ENTER, CComma, Exit
                
                $Immed Semi, ';'
                DW Compile, Exit, Smudge, SquareOpen, Exit

                $Colon Immediate, 'IMMEDIATE'
                DW Latest, Lit, FLAG_IMMEDIATE, Toggle, Exit

                $Colon Compile, 'COMPILE'
                DW QryComp, FromR, Dupe, TwoPlus, ToR, Fetch, Comma, Exit

                $Immed SquareOpen, '['
                DW Zero, UserState, Pling, Exit

                $Colon SquareClose, ']'
                DW Lit, FLAG_STATE, UserState, Pling, Exit

                $Colon Smudge, 'SMUDGE'
                DW Latest, Lit, FLAG_SMUDGE, Toggle, Exit

                $Colon Builds, '<BUILDS'
                DW Create, Smudge, Lit, OP_DOES, CComma, Zero, Comma, Exit

                $Colon Does, 'DOES>'
                DW FromR, Latest, NFA2PFA, Pling, Exit

                $Immed RoundOpen, '('
                DW Lit, ')', Werd, Exit

                $Colon Hex, 'HEX'
                DW Lit, 10h, UserBase, Pling, Exit

                $Colon Decimal, 'DECIMAL'
                DW Lit, 0Ah, UserBase, Pling, Exit

                ; =====================================

                $Colon Digit, 'DIGIT' ; ( c base -- u f )
                DW TOR,LIT,'0',SUBtract
                DW LIT,9,OVER,LessThan
                DW OBranch,DGTQ1
                DW LIT,7,SUBtract
                DW DUPe,LIT,10,LESSThan,BitOR
DGTQ1:          DW DUPe,FromR,ULESS,EXIT

                $Colon _Number, '(NUMBER)'
_Number0:       DW OnePlus, Dupe, ToR                       ; l h a'
                DW CFetch, UserBASE, Fetch, Digit           ; l h d f
                DW OBranch, _Number2                        ; l h d

                DW Swap, UserBASE, Fetch, UMul, Drop        ; l d h*base
                DW Rot, UserBASE, Fetch, UMul               ; WORD:d WORD:h*base DWORD:l*base
                DW DPlus                                    ; l h
                DW UserDPL, Fetch, OnePlus                  ; l h dpl++
                DW OBranch, _Number1
                DW One, UserDPL, PlusPling
_Number1:       DW FromR, Branch, _Number0                  ; l h a'
_Number2:       DW Drop, FromR, Exit                        ; l h a'

                $Colon Number, 'NUMBER' ( here -- l h )
                DW Zero, Zero, Rot, Dupe, OnePlus           ; 0 0 a a+1
                DW CFetch, Lit, '-', Equals                 ; 0 0 a neg?
                DW Dupe, ToR, Subtract                      ; 0 0 a'
                DW Lit, -1
Number0:        DW UserDPL, Pling, _Number                  ; l h a
                DW Dupe, CFetch, Blank, Subtract            ; l h a bl?
                DW OBranch, Number1                         ; l h a
                DW Dupe, CFetch, Lit, '.', Subtract         ; l h a dot?
                DW Zero, QryError, Zero, Branch, Number0    ; l h a 0
Number1:        DW Drop, FromR, OBranch, Number2, DMinus    ; l h
Number2:        DW Exit

                ; =====================================

                $Colon Enclose, 'ENCLOSE' ; ( addr delim -- addr 1st ew nc )

                ;   >R                  delim on rack
                ;   DUP DUP             a a a
                ;   BEGIN
                ;1      DUP C@          a a a b
                ;       BL = WHILE
                ;       1+
                ;   REPEAT              a a a1
                ;2  2DUP                a a a1 a a1
                ;                       a a a2 a a1
                ;   SWAP                a a a2 a1 a
                ;   -                   a a a2 o1
                ;   ROT                 a a2 o1 a
                ;   ROT                 a o1 a a2
                ;   BEGIN
                ;3      DUP C@ 0= IF
                ;4          SWAP - DUP  a o1 o2 o2
                ;           R> DROP
                ;           EXIT
                ;       THEN
                ;       DUP C@          a o1 a a2 b2
                ;       R - WHILE 1+    a o1 a a2++
                ;   REPEAT
                ;5  R> DROP
                ;   SWAP - DUP 1+ ;     a o1 o2 o2+1

                DW ToR, Dupe, Dupe                                  ; a a a
Enclose1:       DW Dupe, CFetch, Blank, Equals                      ; a a a bl?
                DW OBranch, Enclose2                                ; a a a
                DW OnePlus, Branch, Enclose1                        ; a a a++
Enclose2:       DW TwoDup, Swap, Subtract, Rot, Rot                 ; a o1 a a1
Enclose3:       DW Dupe, CFetch                                     ; a o1 a a1 c1
                DW OBranch, Enclose4                                ; a o1 a a1
                DW Dupe, CFetch, R, Subtract                        ; a o1 a a1 c1-delim
                DW OBranch, Enclose5                                ; a o1 a a1
                DW OnePlus, Branch, Enclose3                        ; a o1 a a1++
Enclose4:       DW Swap, Subtract, Dupe, FromR, Drop, Exit          ; a o1 eol eol
Enclose5:       DW FromR, Drop, Swap, Subtract, Dupe, OnePlus, Exit ; a o1 od od+1

                $Colon Werd, 'WORD' ; ( delim -- )

                DW UserTIB, Fetch                   ; delim tib
                DW UserIN, Fetch, Plus, Swap        ; addr delim
                DW Enclose                          ; addr 1st ew nc                      
                DW Here, Lit, 22h, Blanks           ; addr 1st ew nc  NEEDED?
                DW UserIN, PlusPling                ; addr 1st ew
                DW Over, Subtract, ToR, R           ; addr 1st ew-1st (length on rack)
                DW Here, CPling                     ; addr 1st
                DW Plus, Here, OnePlus, FromR       ; addr1 here+1 len
                DW CMove, Exit

                ; =====================================

strncmp:        DB OP_ENTER     ; strncmp ( a b n - f ) assumes n>0

                DW Rot, Rot                                     ; n a b
strncmp1:       DW Over, CFetch                                 ; n a b [a]
                DW Over, CFetch                                 ; n a b [a] [b]
                DW Subtract                                     ; n a b f
                DW OBranch, strncmp2
                DW Drop, Drop, Exit                             ; n

strncmp2:       DW Rot, One, Subtract, Dupe, OBranch, strncmp9  ; a b n-1
                DW Rot, One, Plus                               ; b n-1 a+1
                DW Rot, One, Plus, Branch, strncmp1             ; n-1 a+1 b+1

strncmp9:       DW Nip, Nip, Exit                               ; 0

                $Colon Find, '-FIND'

                DW Blank, Werd, Here, Latest        ; a nfa

Find1:          DW Over, CFetch                     ; a nfa [a]
                DW Over, CFetch                     ; a nfa [a] [nfa]
                DW Lit, FIND_MASK, BitAND           ; a nfa [a] len
                DW Equals, OBranch, Find2           ; a nfa

                DW Over, OnePlus                    ; a nfa a+1
                DW Over, Dupe, OnePlus, Swap        ; a nfa a+1 nfa+1 nfa
                DW CFetch, Lit, 1Fh, BitAND         ; a nfa a+1 nfa+1 len
                DW strncmp                          ; a nfa f
                DW Obranch, Find3                   ; a nfa

Find2:          DW NFA2LFA, Fetch                   ; a link
                DW Dupe, OBranch, Find4             ; a 0 | a nfa
                DW Branch, Find1                    ; a nfa

Find3:          DW Nip, Dupe, NFA2PFA               ; nfa pfa
                DW Swap, CFetch, Lit, -1            ; pfa [nfa] -1

Find4:          DW Exit

                ; =====================================

                $Colon Create, 'CREATE'
                DW Find                             ; here 0  |  pfa len-byte t
                DW OBranch, Create1
                DW Drop, PFA2NFA, IdDot
                DW Lit, 4, Message, Space
                DW Here
Create1:        DW Dupe, Dupe                       ; nfa nfa nfa
                DW CFetch                           ; nfa nfa len
                DW UserWIDTH, Fetch, Min, Dupe      ; nfa nfa len len
                DW OnePlus, Allot                   ; nfa nfa len
                DW Lit, FLAG_SMUDGE, BitOR          ; nfa nfa len-byte
                DW Over, CPling                     ; nfa nfa
                DW Latest, Comma                    ; nfa nfa       // Link = Latest
                DW Comma                            ; nfa           // Back = NFA
                DW UserCURRENT, Fetch, Pling        ;
                DW Exit

                $Immed SquareCompile, '[COMPILE]'
                DW Find, ZeroEq, Zero, QryError, Drop, PFA2CFA, Comma, Exit

                $Immed Literal, 'LITERAL'
                DW UserSTATE, Fetch, OBranch, Literal1, Compile, Lit, Comma
Literal1:       DW Exit

                $Immed DLiteral, 'DLITERAL'
                DW UserSTATE, Fetch, OBranch, DLiteral1, Swap, Literal, Literal
DLiteral1:      DW Exit

                ; =====================================

                $Colon Expect, 'EXPECT' ; ( tib max -- )
                DW Over, Plus, Over, _Do                        ; tib
Expect0:        DW Key                                          ; tib key
                DW Dupe, Lit, KEY_BS, Equals                    ; tib key bs?
                DW OBranch, Expect1
                DW Drop, Lit, 8, Over, I, Equals                ; tib 8 first?
                DW FromR, Over                                  ; tib 8 first? idx first?
                DW Subtract, Two, Subtract                      ; tib 8 first? idx-1|idx-2
                DW ToR                                          ; tib 8 first? 
                DW Plus                                         ; Convert BS to BELL
                DW Branch, Expect4                              ; tib 7|8
Expect1:        DW Dupe, Lit, 0Dh, Equals                       ; tib key cr?
                DW OBranch, Expect2
                DW Leave, Drop, Blank, Zero, Branch, Expect3    ; tib blank 0
Expect2:        DW Dupe                                         ; tib key key
Expect3:        DW I, CPling                                    ; tib key
                DW Zero, I, OnePlus, Pling                      ; tib key       // null terminate
Expect4:        DW Emit, _Loop, Expect0                         ; tib
                DW Drop, Exit                                   ; 

                $Immed EndOfText                                ; Zero length name
                DW FromR, Drop, Exit

                $Colon Interpret, 'INTERPRET'
Interpret0:     DW Find, OBranch, Interpret3
                DW UserSTATE, Fetch, LessThan, OBranch, Interpret1
                DW PFA2CFA, Comma, Branch, Interpret0
Interpret1:     DW PFA2CFA, Execute, Branch, Interpret0
Interpret3:     DW Number
                DW UserDPL, Fetch, OnePlus, OBranch, Interpret4
                DW DLiteral, Branch, Interpret0
Interpret4:     DW Drop, Literal, Branch, Interpret0

                $Colon Query, 'QUERY'
                DW UserTIB, Fetch, Lit, 50h, Expect, Zero, UserIN, Pling, Exit

                $Colon Quit, 'QUIT'
                DW SquareOpen
Quit0:          DW CR, Query, Interpret
                DW UserSTATE, Fetch, ZeroEq, OBranch, Quit1, _DotQuote
                DB 3, ' OK'
Quit1:          DW Branch, Quit0

                $Colon Abort, 'ABORT'
                DW Decimal
                DW CR, _DotQuote
                DB 5, 'FORTH'
                DW Quit

                $Colon COLD, 'COLD'
                DW Lit, User0, Lit, UP, Lit, INIT_SIZE, CMove
                DW Abort

                ; =====================================

                $Colon S2D, 'S->D'
                DW Dupe, ZeroLt, Exit

                $Colon PlusMinus, '+-'
                DW ZeroLt, OBranch, PlusMinus1, Minus
PlusMinus1:     DW Exit

                $Colon DPlusMinus, 'D+-'
                DW ZeroLt, OBranch, DPlusMinus1, DMinus
DPlusMinus1:    DW Exit

                $Colon Abs, 'ABS'
                DW Dupe, PlusMinus, Exit

                $Colon DAbs, 'DABS'
                DW Dupe, DPlusMinus, Exit

                $Colon Min, 'MIN'
                DW Over, Over, GreaterThan, OBranch, Min1, Swap
Min1:           DW Drop, Exit

                $Colon Max, 'MAX'
                DW Over, Over, LessThan, OBranch, Max1, Swap
Max1:           DW Drop, Exit

                ; -----

                $Colon MMul, 'M*'
                ; Signed 16*16 -> 32
                DW Over, Over, BitXOR, ToR, Abs, Swap, Abs, UMul, FromR, DPlusMinus, Exit

                $Colon Multiply, '*'
                ; Unsigned 16*16 -> 16
                DW UMul, Drop, Exit

                ; -----

                $Colon MulDivMod, '*/MOD'
                ; Signed 16*16/16 -> 16r 16q (via 32 intermediate)
                DW ToR, MMul, FromR, MDiv, Exit

                $Colon MulDiv, '*/'
                DW MulDivMod, Swap, Drop, Exit

                ; -----

                $Colon MDiv, 'M/'
                ; Signed 32/16 -> 16r 16q
                DW Over                 ; sl sh sd sh
                DW ToR, ToR             ; sl sh             sh sd
                DW DAbs                 ; ul uh             sh sd
                DW R                    ; ul uh sd          sh sd
                DW Abs                  ; ul uh ud          sh sd
                DW UDiv                 ; ur uq             sh sd
                DW FromR                ; ur uq sd          sh
                DW R                    ; ur uq sd sh       sh
                DW BitXOR               ; ur uq sign        sh
                DW PlusMinus            ; ur sq             sh
                DW Swap                 ; sq ur             sh
                DW FromR                ; sq ur sh
                DW PlusMinus            ; sq ?r
                DW Swap, Exit           ; ?r sq

                $Colon DivMod, '/MOD'
                ; Signed 16/16 -> 16r 16q
                DW ToR, S2D, FromR, MDiv, Exit

                ; -----

                $Colon Divide, '/'
                DW DivMod, Swap, Drop, Exit

                $Colon Modulo, 'MOD'
                DW DivMod, drop, Exit

                ; -----

                $Colon MDivMod, 'M/MOD'
                ; Unsigned 32/16 -> 16r 32q
                ; >R 0 R U/ R> SWAP >R U/ R> ( l h d -- r l h )
                ;
                ;>R         l h             d
                ;0          l h 0           d
                ;R          l h 0 d         d
                ;U/         l r1 q1         d
                ;R>         l r1 q1 d
                ;SWAP       l r1 d q1
                ;>R         l r1 d          q1
                ;U/         r2 q2           q1
                ;R>         r2 q2 q1

                DW ToR, Zero, R, UDiv, FromR, Swap, ToR, UDiv, FromR, Exit

                ; =====================================

                $Immed Tick, "'"
                DW Find, ZeroEq, Zero, QryError, Drop, Literal, Exit

                $Colon Back, 'BACK'
                DW Comma, Exit

                $Immed __Begin, 'BEGIN'
                DW QryComp, Here, One, Exit

                $Immed __EndIf, 'ENDIF'
                DW QryComp, Two, QryPairs, Here, Swap, Pling, Exit

                $Immed __Then, 'THEN'
                DW __EndIf, Exit

                $Immed __Do, 'DO'
                DW Compile, _Do, Here, Three, Exit

                $Immed __Loop, 'LOOP'
                DW Three, QryPairs, Compile, _Loop, Back, Exit

                $Immed __PlusLoop, '+LOOP'
                DW Three, QryPairs, Compile, _PlusLoop, Back, Exit

                $Immed __Until, 'UNTIL'
                DW One, QryPairs, Compile, OBranch, Back, Exit

                $Immed __End, 'END'
                DW __Until, Exit

                $Immed __Again, 'AGAIN'
                DW One, QryPairs, Compile, Branch, Back, Exit

                $Immed __Repeat, 'REPEAT'
                DW ToR, ToR, __Again, FromR, FromR, Two, Subtract, __EndIf, Exit

                $Immed __If, 'IF'
                DW Compile, OBranch, Here, Zero, Comma, Two, Exit

                $Immed __Else, 'ELSE'
                DW Two, QryPairs, Compile, Branch, Here, Zero, Comma
                DW Swap, Two, __EndIf, Two, Exit

                $Immed __While, 'WHILE'
                DW __If, TwoPlus, Exit

                ; =====================================

                $Colon Hold, 'HOLD'
                DW Lit, -1, UserHLD, PlusPling, UserHLD, Fetch, CPling, Exit
                
                $Colon PAD, 'PAD'
                DW Here, Lit, 44h, Plus, Exit
                
                $Colon LessHash, '<#'
                DW PAD, UserHLD, Pling, Exit

                $Colon HashMore, '#>'
                DW Drop, Drop, UserHLD, Fetch, PAD, Over, Subtract, Exit

                $Colon Sign, 'SIGN'
                DW Rot, ZeroLt, OBranch, Sign1, Lit, '-', Hold
Sign1:          DW Exit

                $Colon Hash, '#'
                DW UserBASE, Fetch, MDivMod, Rot
                DW Lit, 9, Over, LessThan, OBranch, Hash1, Lit, 7, Plus
Hash1:          DW Lit, '0', Plus, Hold, Exit

                $Colon HashS, '#S'
HashS0:         DW Hash, Over, Over, BitOR, ZeroEq, OBranch, HashS0, Exit

                $Colon DdotR, 'D.R'
                DW ToR, Swap, Over, DAbs, LessHash, HashS, Sign, HashMore
                DW FromR, Over, Subtract, Spaces, Typ, Exit

                $Colon Ddot, 'D.'
                DW Zero, DdotR, Space, Exit

                $Colon dotR, '.R'
                DW ToR, S2D, FromR, DdotR, Exit

                $Colon dot, '.'
                DW S2D, Ddot, Exit

                $Colon Qry, '?'
                DW Fetch, dot, Exit

                ; =====================================

                LastLink = Link

                END

