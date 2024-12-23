; EMPL 1.0
; Copyright 1977 by Erik T. Mueller
; WS end: flaw prohibits > 32K
BOOT EQU 0
BDOS EQU BOOT+5
CONIN EQU 1
CONOUT EQU 2
CONSTAT EQU 0BH
CONDRCT EQU 6
XSP EQU 3FFFH
MEMTOP EQU 3FFFH ; 04
MSBMSK EQU 0FF00H ; 01
  ORG 100H
EMPL:
   LHLD STKSET
   SPHL
;   LXI SP, MEMTOP
   JMP EMPL2
; input routine address
INPUT:
   CALL XINPUT
   CPI 81H ; ^A
   JNZ XN1
   MVI A,'_'+80H
   JMP OUTCTL
XN1:      ; 01
   CPI 84H ; ^D
   JNZ XN2
   MVI A,'/'+80H
   JMP OUTCTL
XN2:      ; 01
   CPI 87H ; ^G
   JNZ XN3
   MVI A,'\'+80H
   JMP OUTCTL
XN3:      ; 01
   CPI 8BH ; ^K
   JNZ XN4
   MVI A,'['+80H
   JMP OUTCTL
XN4:      ; 01
   CPI 8CH ; ^L
   JNZ OUTCTL
   MVI A,']'+80H
OUTCTL:
   PUSH PSW
   CALL OUTPUT
   POP PSW
   RET
; OUTPUT:    ; 27
;   JMP OUT2
CKLTR: ; 0D
   CPI 'A'+80H
   CMC
   RNC
   CPI 'Z'+81H
   RET
BSKSP:     ; 07
   MOV A,M
   CPI 0A0H ; SP
   RNZ
   DCX H
   JMP BSKSP
CRLF:      ; 09
   MVI A,8DH ; CR
   CALL OUTPUT
   MVI A,8AH
   CALL OUTPUT
   RET
NINT:      ; Warm Enter point
; WS end: flaw prohibits > 32K
   LHLD STKSET
   SPHL
;   LXI SP, MEMTOP
   LXI B, REX
   PUSH B
   LXI B, -1
   PUSH B
   CALL CLRS
   LXI H, 0
   SHLD BCPR
   SHLD CPROG
   LXI H, LBUF
   SHLD BEGST
   MVI A,8DH ; CR
   MOV M,A
   INX H
   MVI A,8AH
   MOV M,A
   INX H
   MVI A,0FFH
   MOV M,A
   INX H
   MOV M,A
   LXI H, -1
   SHLD LN
   LHLD WSEND
; WS start
; :0215a40000172e
   SHLD EOS
   LHLD WSBP+1
   SHLD WS
   LHLD EOS
   XCHG
   LHLD WS
LL:      ; 01
   CALL CHLDE
   SHLD PTCH3
   JZ LLS
   CALL SRTRM
   MOV A,M
   CPI 04H
   JZ LLS
   INX H
   MOV C,M
   INX H
   MOV B,M
   DAD B
   JMP LL
LLS:      ; 02
   LHLD PTCH3
   SHLD VARBGN
   JMP DWC
EMPL2:      ; 01
   LXI B, REX
   PUSH B
   LXI B, -1
   PUSH B
; WS start + 2
WSBP:
   LXI H, WSBUF
   SHLD VARBGN
   SHLD WS
   SHLD EOS
   LXI H, 0
   SHLD BCPR
   SHLD CPROG
   LHLD IC
   INX H
   SHLD IC
   CALL CLRS
   LXI H, EMPLETC
   CALL PTXTH
XMODE:      ; 07
   LXI H, -1
   CALL XXPXO
   CALL INDNT
   CALL GETLN
   LXI H, LBUF
   CALL SKSP
   CPI '&'+80H
   JZ TFD
   JMP EXEC
TFD:      ; 01
   INX H
   CALL SKSP
   CALL CKLTR
   LXI H, LBUF
   JNC EXEC
   JMP DEF
EXEC:      ; 04
   SHLD BEGST
XQT:      ; 02
   CALL SKSP
   CPI ')'+80H
   JZ COMM
   CALL CNSF
   CALL INT
   MOV A,M
   CPI '%'+80H
   JZ XSTR
   CPI 88H ; ^H =:
   JZ GOTO
   CPI ']'+80H
   JZ PRIVC
   CPI 8DH ; CR
   JZ NLINE
BKK:      ; 01
   CALL CKLTR
   JNC PRT
   CALL SKEO
   CALL SKSP
   CPI 89H ; ^I :=
   JZ ASGN
   CPI ':'+80H
   INX H
;   JZ EXEC
   JZ XQT
   DCX H
   DCX H
   CPI 8DH ; CR
   JZ PROG
   JMP PRT
REX:      ; 07
   LXI B, REX
   PUSH B
   LXI B, -1
   PUSH B
   JMP XMODE
PROG:      ; 01
   CALL SBO
   SHLD SOBJ
   CALL SFF
   CPI 08H
   JNZ PRT
   LHLD LN
   MOV A,H
   CPI 0FFH
   JNZ EPL
   MOV A,L
   CPI 0FFH
   JZ XPRGRM
EPL:      ; 01
   LHLD BEGST
PR2:  ; ??
   CALL SCR
   MOV E,M
   INX H
   MOV D,M
   MOV A,E
   CPI 0FFH
   JNZ EPX2
   MOV A,D
   CPI 0FFH
   JZ XPRGRM
EPX2:      ; 01
   PUSH D
   INX H
   INX H
   SHLD BEGST
   PUSH H
   LHLD CPROG
   PUSH H
   LHLD BCPR
   PUSH H
   LXI H, PRN
   PUSH H
   LXI H, -1
   PUSH H
DPRO:  ; ??
   JMP XPRGRM
PRN:      ; 02
   POP H
   SHLD BCPR
   POP H
   SHLD CPROG
   POP H
   SHLD BEGST
   POP H
   SHLD LN
   LHLD BEGST
   JMP XQT
GOTO:      ; 01
   CALL EXPR
   LHLD EOS
   MOV A,M
   ORA A
   JNZ NZ
   INX H
   MOV A,M
   ORA A
   JZ NLINE
   JMP CT2
NZ:      ; 01
   INX H
CT2:      ; 01
   INX H
   MOV C,M
   INX H
   MOV B,M
   LHLD BCPR
   MOV A,H
   ORA A
   JNZ KG
   MOV A,L
   ORA A
   JZ XMODE
KG:      ; 02
   INX H
   MOV A,B
   CMP M
   DCX H
   JC EP2
   JNZ NL
   MOV A,C
   CMP M
   JC EP2
   JNZ NL
   JMP EXLIN
NL:      ; 02
   INX H
   INX H
   MOV A,M
   ADD L
   MOV L,A
   MVI A,00H
   ADC H
   MOV H,A
   INX H
   JMP KG
XSTR:      ; 01
   CALL EXPR
   LXI H, LBUF
   XCHG
   LHLD EOS
   MOV C,M
   INX H
   MOV B,M
   PUSH D
   LXI D, 058H
   CALL CBCDE
   CNC ERR ; STRING TOO LARGE TO EXEC
   POP D
SF1:   ; 01
   INX H
   CALL CBCZ
   JZ DRD
   MOV A,M
   ORI 80H
   STAX D
   INX D
   INX H
   DCX B
   JMP SF1
DRD:      ; 01
   MVI A,8DH ; CR
   STAX D
   LXI H, LBUF
   INX D
   MVI A,0FFH
   STAX D
   INX D
   STAX D
   JMP XQT
ASGN:      ; 01
   CALL EXPR
   JMP NLINE
PRT:      ; 03
   LHLD BEGST
NIT:      ; 01
   CALL SKSP
   CPI 0A2H ; '"'
   JZ TXT
SSE:      ; 01
   STA  PFLG
   CALL EXPR
   LDA  PTCH5
   ORA A
   JZ TAL
   CALL PRVC
   INX H
   INX H
TAL:      ; 04
   MOV A,M
   CPI ';'+80H
   JZ CCR
   CPI 8DH ; CR
   JZ BF7
   INX H
   JMP TAL
BF7:      ; 01
   LDA  PTCH5
   ORA A
   CNZ CRLF
   JMP NLINE
CCR:      ; 01
   INX H
   MOV A,M
   CPI 8DH ; CR
   JZ NLINE
   JMP NIT
TXT:      ; 01
   INX H
   MOV A,M
   CPI '%'+80H
   DCX H
   JZ SSE
   MVI A,01H
   STA  PTCH5
;   JMP TXT2
TXT2:      ; 02
   INX H
   MOV A,M
   CPI 8DH ; CR
   JZ TAL
   CPI 0A2H ; '"'
   JZ TAL
   CPI ';'+80H
   JZ TAL
   CALL OUTPUT
   JMP TXT2
PRVC:      ; 02
   PUSH H
   LHLD EOS
   MOV C,M
   INX H
   MOV B,M
PRTT:      ; 01
   CALL CBCZ
   JNZ NP1
   POP H
   RET
NP1:      ; 01
   INX H
   MOV E,M
   INX H
   MOV D,M
   LDA  PFLG
   CPI '$'+80H
   CZ PS
   CNZ PBINBCD
   DCX B
   JMP PRTT
PS:      ; 01
   MOV A,E
   ORI 80H
   CALL OUTPUT
   XRA A
   RET
XPRG:      ; 01
   LHLD BFD
   SHLD CPROG
   MOV H,B
   MOV L,C
PXQT:      ; 01
   CPI 08H
   JZ SSTR
   CPI 0BH
   JZ PXQT2
   CALL SRTRM
PXQT2:      ; 01
   CALL SRTRM
   CALL SRTRM
SSTR:      ; 01
   SHLD BCPR
EXLIN:      ; 03
   MOV E,M
   INX H
   MOV D,M
   INX H
   XCHG
   SHLD LN
   XCHG
   INX H
   JMP EXEC
COMM:      ; 01
   INX H
   SHLD TLOC
   CALL SKSP
   CPI 'Q'+80H
   JZ QUIT
 ; patch here for )SAVE )RESTORE
   INX H
   CALL SKSP
   CPI 'L'+80H
   JZ EMPL
   CPI 'N'+80H
   JZ FNS
   CPI 'A'+80H
   JZ VARS
   CPI 'I'+80H
   JZ SI
   CPI 'U'+80H
   JZ PVRSI
   CPI 'R'+80H
   JZ ERASE
   CPI 'C'+80H
   JZ SCREEN
   CPI 'T'+80H
   JZ XMODE
FNS:      ; 01
   LHLD VARBGN
   MOV B,H
   MOV C,L
   LHLD WS
PRTO:      ; 02
   CALL CBCHL
   JZ PR25
   CALL PTXTH
   INX H
   MOV A,M
   CPI 04H
   JZ SV
   INX H
   MOV E,M
   INX H
   MOV D,M
   DAD D
DLM:      ; 01
   MVI A, ';'+80H
   CALL OUTPUT
   JMP PRTO
SV:      ; 01
   INX H
   INX H
   MOV E,M
   INX H
   MOV D,M
   INX H
   XCHG
   DAD H
   DAD D
   JMP DLM
PR25:      ; 01
   CALL CRLF
   JMP DWC
VARS:      ; 01
   LHLD EOS
   MOV B,H
   MOV C,L
   LHLD VARBGN
   JMP PRTO
SCREEN:      ; 01
   CALL CLRS
   JMP DWC
; WS end: flaw prohibits > 32K
PVRSI:      ; 01
   LHLD STKSET
   SPHL
;   LXI SP, MEMTOP
   LXI B, REX
   PUSH B
   LXI B, -1
   PUSH B
DWC:      ; 07
   LHLD TLOC
   JMP NLINE
SI:      ; 01
   LHLD CPROG
   MOV A,H
   ORA A
   JNZ KGIL
   MOV A,L
   ORA A
   JZ PSZ
KGIL:      ; 01
   CALL PTXTH
   LHLD LN
   MOV D,H
   MOV E,L
   CALL PRLN
   MVI A,0A0H ; SP
   CALL OUTPUT
   MVI A,'*'+80H
   CALL OUTPUT
   CALL CRLF
PWS:  ; ???
   LXI H, 0
   DAD SP
   SHLD PBSP+1
CFP:      ; 04
   POP D
   MOV A,E
   CPI 0FFH
   JNZ CFP
   MOV A,D  ; Listing patch
   CPI 0FFH
   JNZ CFP
   POP D
   MOV A,E
   CPI ( PRN AND 0FFH )
   JZ TPRN ; 0344
   CPI ( FNR AND 0FFH )
   JZ TFNR ; 033B
   CPI ( REX AND 0FFH )
   JNZ CFP
   MOV A,D
   CPI ( REX / 100H )
   CNZ ERR ; Internal SI error
PBSP:      ; 02
   LXI SP, XSP
   JMP PSZ
TFNR:      ; 01
   MOV A,D
   CPI ( FNR / 100H )
   JZ PPR
   CALL ERR ; Internal SI error
TPRN:      ; 01
   MOV A,D
   CPI ( PRN  / 100H )
   CNZ ERR ; Internal SI error
PPR:      ; 01
   POP B
   POP H
   POP B
   POP D
   MOV B,D
   MOV C,E
   SHLD SRE2
   LXI H, 0
   DAD SP
   SHLD PTRSP+1
   LXI SP, LBUFX
   LHLD SRE2
   CALL PTXTH
   MOV D,B
   MOV E,C
   CALL PRLN
   MVI A,0A0H ; SP
   CALL OUTPUT
   MVI A,'^'+80H
   CALL OUTPUT
   CALL CRLF
PTRSP:
   LXI SP, 0
   JMP CFP
ERASE:      ; 01
   CALL SKEO
   CALL SKSP
   SHLD SOBJ
   CALL SFF
   ORA A
   JP DF
   CALL SFV
   ORA A
   CM ERR ; OBJ ALREADY ERASED
DF:      ; 01
   STA  PTCH6
   CALL DVAR
   LDA  PTCH6
   CPI 04H
   JZ DWC
PRIVC:      ; 01
   INX H
   SHLD TLOC
   CALL SKSP
   CPI 'B'+80H
   JZ BUYR
   CPI 'I'+80H
   JZ ICON
ILLPRV:      ; 02
   CALL ERR ; Ill Priv Command
BUYR:      ; 01
   CALL PSWD
   LXI H, BYR
BPT2:      ; 01
   MOV A,M
   INX H
   CPI 0FFH
   JZ DWC
   RRC
   CALL OUTPUT
   JMP BPT2
ICON:      ; 01
   CALL PSWD
   LHLD IC
   XCHG
   CALL BINBCD
   CALL CRLF
   JMP DWC
PSWD:      ; 02
   CALL SKEO
   CALL SKSP
   CPI 85H ; ^E
   JNZ ILLPRV
   INX H
   MOV A,M
   CPI 9AH ; ^Z
   JNZ ILLPRV
   RET
NLINE:      ; 06
   LHLD BEGST
   CALL SCR
   MOV A,M
   CPI 0FFH
   JNZ EXLIN
   INX H
   MOV A,M
   CPI 0FFH
   DCX H
   JNZ EXLIN
EPROG: ; ???
   LHLD LN
   MOV A,H
   CPI 0FFH
   JNZ EP2
   MOV A,L
   CPI 0FFH
   JZ XMODE
EP2:      ; 05
   POP D
   MOV A,D
   CPI 0FFH
   JNZ EP2
   MOV A,E
   CPI 0FFH
   JNZ EP2
   RET
EXPR:    ; 05
   CALL SCRS  ; scan for end line
   DCX H
EX2:      ; 03
   CALL CNSF ; check workspace size
   CALL INT ; break?
   LXI B, 0
   PUSH B
   LXI B, 1
   PUSH B
   LXI B, '+'+80H
   PUSH B
NT:      ; 01
   POP B
   MOV A,C
   CPI 89H ; ^I :=
   JZ EASGN
   PUSH B
   DCX H
   CALL BSKSP
   CPI 0A7H  ; '
   JZ SCON
   CPI '$'+80H
   JZ QUOQUAD
   CPI '@'+80H
   JZ QUAD
   CPI ')'+80H
   JZ PEX
   CALL CKLTR
   JC VAR
   CALL CHEKN
   JC NCONS
   CALL ERR ; UNKN OPERAND TYPE IN EXPRESSION
SCON:      ; 01
   CALL PSS
   DCX H
   JMP DEVAL
QUOQUAD:      ; 01
   DCX H
   SHLD TLOC
   CALL GETLN
   LXI H, LBUF
   CALL SCR
   DCX H
   CALL PSS
   LHLD TLOC
   JMP DEVAL
QUAD:      ; 01
   MVI A,'@'+80H
   CALL OUTPUT
   MVI A,':'+80H
   CALL OUTPUT
   DCX H
   PUSH H
   CALL GETLN
   LXI H, LBUF
   CALL EXPR
   POP H
   CALL PBIS
   JMP DEVAL
PEX:      ; 01
   CALL EX2
   CALL PBIS
   JMP DEVAL
NCONS:      ; 01
   LXI B, 0
CTS:      ; 01
   CALL SBC
   JNC PZ
   CALL BCBIN
   DCX H
   PUSH D
   INX B
   CALL SBC
   DCX H
   JMP CTS
PZ:      ; 01
   PUSH B
   INX H
   JMP DEVAL
SBC:      ; 02
   CALL BSKSP
   CALL CHEKN
   DCX H
   RNC
CBA:      ; 01
   MOV A,M
   CALL CHEKN
   DCX H
   JC CBA
   CPI '-'+80H
   STC
   CMC
   JNZ PTN
   MOV A,M
   CALL CHEKN
   JNC CK
   CMC
PTN:      ; 01
   INX H
CK:      ; 01
   INX H
   CMC
   RET
VAR:      ; 01
   CALL SBO
   CALL CVO
DEVAL:      ; 05
   XCHG
   LHLD EOS
   XCHG
   CALL STDR
   POP B
   MOV A,C
   STA  OPR
   MOV A,B
   STA  OPR1
   XCHG
   SHLD RVAL
   XCHG
   CALL STDR
DVAD:
   MVI A,01H
   STA  PTCH5
   JMP PDYAD
SCMC:      ; 05
   CALL BSKSP
   MOV A,M
   CALL KOF
   PUSH B
   CPI 01H
   JZ MOND
   CPI 02H
   JZ NT
EXITEXP:  ; ???
   POP B
   XCHG
   LHLD EOS
   XCHG
   CALL STDR
   RET
MOND:      ; 01
   POP B
   MOV A,C
   STA  OPR
   MOV A,B
   STA  OPR1
   XCHG
   LHLD EOS
   XCHG
   CALL STDR
   JMP PMONAD
PDYAD:      ; 01
   PUSH H
   LHLD OPR
   MOV A,H
   ORA A
   JNZ FNC
   MOV A,L
   POP H
   SHLD RAXX
   LHLD EOS
   XCHG
   LHLD RVAL
   CPI ','+80H
   JZ CATN
   CPI '['+80H
   JZ INDX
   MOV C,M
   XRA A
   STA  FLG
   LDAX D
   STA  SZ
   CMP C
   JNZ LNE
   INX H
   INX D
   MOV B,M
   LDAX D
   STA  SZ1
   CMP B
   DCX H
   DCX D
   JNZ LNE
   INX H
   INX D
   CALL SEV
DV:      ; 04
   CALL CBCZ
   JZ FWE
   PUSH B
   PUSH H
   LDAX D
   MOV B,A
   PUSH D
   DCX D
   LDAX D
   MOV C,A
   MOV D,M
   DCX H
   MOV E,M
   CALL DDUP
   SHLD RES
   POP D
   POP H
   POP B
   DCX H
   DCX H
   DCX D
   DCX D
   DCX B
   SHLD SPEC
   LHLD RES
   PUSH H
   LHLD SPEC
   LDA  FLG
   CPI 01H
   JNZ NRV
   INX H
   INX H
   JMP DV
NRV:      ; 01
   CPI 02H
   JNZ DV
   INX D
   INX D
   JMP DV
FWE:      ; 01
   LHLD SZ
   PUSH H
   LHLD RAXX
   JMP SCMC
LNE:      ; 02
   MOV A,M
   CPI 01H
   JNZ RVI
   INX H
   MOV A,M
   ORA A
   JNZ BF12
   MVI A,01H
   STA  FLG
   INX H
   INX H
   LDAX D
   MOV C,A
   INX D
   LDAX D
   MOV B,A
LNE2:  ; ???
   PUSH H
   CALL SEV
   POP H
OOSISY:      ; 01
   MOV A,C
   STA  SZ
   MOV A,B
   STA  SZ1
   JMP DV
BF12:      ; 01
   DCX H
RVI:      ; 02
   LDAX D
   CPI 01H
RVI2:      ; 01
   CNZ ERR ; Len of Vect not matched
   INX D
   LDAX D
   ORA A
   JNZ RVI2
   MVI A,02H
   STA  FLG
   INX D
   INX D
   MOV C,M
   INX H
   MOV B,M
   PUSH D
   CALL SEV
   POP D
   JMP OOSISY
SEV:      ; 03
   PUSH B
   PUSH H
   MOV H,B
   MOV L,C
   DAD H
   PUSH H
   DAD D
   MOV D,H
   MOV E,L
   POP H
   POP B
   DAD B
   POP B
   RET
FNC1:
   XTHL
   SHLD PTCH8
   XTHL
   POP PSW
   CALL STV
   LHLD AEOWS
   SHLD EOS
   LHLD SOBJ
   CALL SRTRM
   XCHG
   PUSH D
   XTHL
   LHLD PTCH8
   XTHL
   RET
FNC:      ; 01
   CALL ARV
   XCHG
   CALL FNC1
SS:      ; 01
   CALL RESAEOW
   LHLD LN
   PUSH H
   LHLD BEGST
   PUSH H
   LHLD CPROG
   PUSH H
   LHLD BCPR
   PUSH H
   LXI H, FNR
   PUSH H
   LXI H, -1
   PUSH H
   LHLD OPR
   SHLD CPROG
   CALL SRTRM
   MOV A,M
   INX H
   INX H
   INX H
   JMP PXQT
FNR:      ; 01
   POP H
   SHLD BCPR
   POP H
   SHLD CPROG
   POP H
   SHLD BEGST
   POP H
   SHLD LN
   LHLD EOS
   XCHG
FN7:      ; 01
   POP H
   MOV A,L
   STAX D
   INX D
   CPI 0FFH
   JNZ FN7
   POP H
   SHLD LOCTX
   LHLD EOS
   CALL CVO
   LHLD LOCTX
   MVI A,01H
   STA  PTCH5
   JMP SCMC
PMONAD:      ; 01
   PUSH H
   LHLD OPR
   MOV A,H
   ORA A
   JNZ MFN
   POP H
   INX H
   MOV A,M
   DCX H
   SHLD RAXX
   LHLD EOS
   MOV C,M
   INX H
   MOV B,M
   CPI '\'+80H
   JZ IOT
   CPI '^'+80H
   JZ LEN
   CPI '%'+80H
   JZ RED
   XCHG
   MOV H,B
   MOV L,C
   SHLD SZ
   DAD H
   DAD D
   MOV B,D
   MOV C,E
MV:      ; 01
   CALL CBCHL
   JZ FWM
   MOV D,M
   DCX H
   MOV E,M
   DCX H
   CALL DMVD
   PUSH D
   JMP MV
FWM:      ; 01
   LHLD SZ
   PUSH H
MR:      ; 03
   LHLD RAXX
   JMP SCMC
MFN:      ; 01
   CALL ARV
   LHLD EOS
   XCHG
   CALL STDR
   JMP SS
LEN:      ; 01
   LHLD EOS
   MVI M,01H
   INX H
   MVI M,00H
   INX H
   MOV M,C
   INX H
   MOV M,B
   JMP DL2
IOT:      ; 01
   INX H
   MOV C,M
   INX H
   MOV B,M
   PUSH H
   MOV H,B
   MOV L,C
   SHLD SZ
   POP H
PHS:      ; 01
   CALL CBCZ
   JZ PIS
   PUSH B
   DCX B
   CALL CNSF
   JMP PHS
PIS:      ; 01
   LHLD SZ
   PUSH H
   JMP MR
CATN:      ; 01
   LDAX D
   MOV C,A
   INX D
   LDAX D
   MOV B,A
   MOV E,M
   INX H
   MOV D,M
   INX H
   XCHG
   PUSH H
   DAD B
   PUSH H
   LHLD EOS
   MOV B,H
   MOV C,L
   POP H
   MOV A,L
   STAX B
   INX B
   MOV A,H
   STAX B
   LHLD RVAL
   MOV B,H
   MOV C,L
   POP H
   DAD H
   DAD B
CA2:      ; 01
   CALL CBCHL
   JZ DL2
   LDAX D
   STAX B
   INX B
   INX D
   LDAX D
   STAX B
   INX B
   INX D
   JMP CA2
DL2:      ; 02
   CALL PBIS
   JMP MR
INDX:      ; 01
   MOV C,M
   INX H
   MOV B,M
   PUSH H
   MOV H,B
   MOV L,C
   SHLD SZ
   MOV H,B
   MOV L,C
   DAD H
   POP D
   PUSH D
   DAD D
   MOV B,H
   MOV C,L
   LHLD EOS
   XCHG
   POP H
   SHLD STDP
IL2:      ; 02
   CALL CBCHL
   JZ DNE3
   LDAX B
   MOV H,A
   DCX B
   LDAX B
   MOV L,A
   DCX B
   DAD H
   DAD D
   MOV A,M
   STA  LI
   INX H
   MOV A,M
   STA  LI1
   LHLD LI
   PUSH H
   LHLD STDP
   JMP IL2
DNE3:      ; 01
   LHLD SZ
   PUSH H
   LHLD RAXX
   JMP SCMC
DMVD:      ; 01
   LDA  OPR
   CPI '_'+80H
   JNZ CABS1
   CALL NEGT
   RET
CABS1: ; 01
   CPI '!'+80H
   JNZ CNOT
   MOV A,D
   ORA A
   RP
   CALL NEGT
   RET
CNOT:      ; 01
   CPI '&'+80H
   JNZ CRND
   MOV A,D
   ORA A
   JNZ NOT1
   MOV A,E
   ORA A
   JZ MKO
NOT1:      ; 01
   LXI D, 0
   RET
MKO:      ; 01
   LXI D, 1
   RET
CRND:      ; 01
   CPI '?'+80H
   CNZ ERR ; Incorrect Nond Oper
   PUSH H
   PUSH D
   LHLD MLOC
   LXI D, XP1
   CALL CMPHLDE
   JC OK
   LXI H, 0
OK:      ; 01
   MOV A,M
   INX H
   MOV E,M
   INX H
   SHLD MLOC
   POP H
   XCHG
   PUSH B
   CALL DIVID
   POP B
   INX H
   XCHG
   POP H
   RET
RED:      ; 01
   XCHG
   LHLD RAXX
   CALL BSKSP
   DCX H
   SHLD RAXX
   STA  OPR
   MOV H,B
   MOV L,C
   DAD H
   DAD D
   XCHG
   CALL CBCZ
   JNZ INV
   LXI H, 0
CBK:      ; 01
   PUSH H
   JMP MR
INV:      ; 01
   LDAX D
   MOV H,A
   DCX D
   LDAX D
   DCX D
   MOV L,A
   DCX B
   CALL CBCZ
   JNZ R1
R2:      ; 01
   PUSH H
   LXI H, 1
   JMP CBK
R1:      ; 02
   PUSH B
   LDAX D
   MOV B,A
   DCX D
   LDAX D
   DCX D
   MOV C,A
   PUSH D
   MOV D,H
   MOV E,L
   PUSH B
   PUSH D
   POP B
   POP D
   CALL DDUP
   POP D
   POP B
   DCX B
   CALL CBCZ
   JNZ R1
   JMP R2
PSZ:      ; 02
   LHLD AEOWS
   XCHG
   LHLD PBSP+1
   CALL NEGT
   DAD D
   XCHG
   CALL BINBCD
   LXI H, FREE
   CALL PTXTH
   JMP DWC
DDUP:      ; 02
   LDA  OPR
   CPI '+'+80H
   JNZ CMI
ADD1:      ; 01
   MOV H,B
   MOV L,C
   DAD D
   RET
CMI:      ; 01
   CPI '-'+80H
   JNZ CTI
   CALL NEGT
   JMP ADD1
CTI:      ; 01
   CPI '*'+80H
   JNZ CDI
   MOV A,B
   XRA D
   PUSH PSW
   MOV A,B
MULT:      ; 01
   CALL SETPOS
   MOV A,D
   CMP B
   JC RVRS
   JNZ M1
   MOV A,E
   CMP C
   JC RVRS
M1:      ; 03
   MOV A,B
   ORA A
   JNZ RT
   MOV A,C
   ORA A
   JZ M2
RT:      ; 01
   DAD D
   DCX B
   JMP M1
M2:      ; 01
   POP PSW
M3:      ; 02
   RP
   XCHG
   CALL NEGT
   XCHG
   RET
NEGTB:      ; 01
   PUSH D
   MOV D,B
   MOV E,C
   CALL NEGT
   MOV B,D
   MOV C,E
   POP D
   RET
SETPOS:      ; 02
   ORA A
   CM NEGTB
   MOV A,D
   ORA A
   CM NEGT
   LXI H, 0
   RET
XBLDE:      ; 02
   PUSH B
   PUSH D
   POP B
   POP D
   RET
RVRS:      ; 02
   CALL XBLDE
   JMP M1
CDI:      ; 01
   CPI '/'+80H
   JNZ CRT
   CALL BF22
   MOV H,B
   MOV L,C
   JMP M3
CRT:      ; 01
   CPI '.'+80H
   JNZ CLT
   CALL XBLDE
   CALL BF22
   JMP M3
CLT:      ; 01
   MOV H,B
   MOV L,C
   MOV A,H
   XRA D
   JP DC
   XCHG
   CALL CMPHLDE
   XCHG
   JMP DC1
DC:      ; 01
   CALL CMPHLDE
DC1:      ; 01
   PUSH PSW
   LXI H, 0
   LDA  OPR
   CPI '<'+80H
   JNZ LG1
   POP PSW
   RNC
   INX H
   RET
LG1:      ; 01
   CPI 99H ; ^Y <=
   JNZ LG2
   POP PSW
   INX H
   RC
   RZ
   DCX H
   RET
LG2:      ; 01
   CPI '>'+80H
   JNZ LG3
   POP PSW
   RC
   RZ
   INX H
   RET
LG3:      ; 01
   CPI 8EH ; ^N >=
   JNZ LG4
   POP PSW
   RC
   INX H
   RET
LG4:      ; 01
   CPI '='+80H
   JNZ LG5
   POP PSW
   RNZ
   INX H
   RET
LG5:      ; 01
   CPI '#'+80H
   JNZ CMIN
   POP PSW
   RZ
   INX H
   RET
CMIN:      ; 01
   CPI 0A7H ; '''
   JNZ CMAX
   POP PSW
   MOV H,D
   MOV L,E
   RNC
   MOV H,B
   MOV L,C
   RET
CMAX:      ; 01
   CPI 0A2H ; '"'
   CNZ ERR ; Ill Oper in Reduction
   POP PSW
   MOV H,D
   MOV L,E
   RC
   MOV H,B
   MOV L,C
   RET
DIVD:      ; 01
   MOV A,B
   CALL SETPOS
   MOV H,B
   MOV L,C
DIVID:      ; 02
   PUSH H
   MOV L,H
   MVI H,00H
   MOV A,D
   ORA A
   JNZ CHKIF ; DIV 0?
   MOV A,E
   ORA A
   JNZ CHKIF
   CALL ERR ; Div by Zero
BF22:      ; 02
   MOV A,B
   XRA D
   PUSH PSW
   CALL DIVD
   POP PSW
   RET
CHKIF:      ; 02
   CALL DD
   MOV B,C
   MOV A,L
   POP H
   MOV H,A
   CALL DD ; DE=REM HL=QUO
   RET
DD:      ; 02
   MVI C,0FFH
DDX:      ; 01
   INR C
   CALL DEHLM
   JNC DDX
   DAD D
   RET
DEHLM:      ; 01
   MOV A,L
   SUB E
   MOV L,A
   MOV A,H
   SBB D
   MOV H,A
   RET
AQQ:      ; 02
   STA  PFLG
   CALL STDR
   CALL PBIS
   CALL PRVC
   CALL CRLF
   DCX H
BF25:      ; 02
   XRA A
   STA  PTCH5
   JMP SCMC
DVAR:      ; 02
   LHLD EOS
   MOV B,H
   MOV C,L
   LHLD BFD
   CALL SRTRM
   MOV A,M
   CPI 04H
   JNZ KFP
   INX H
   INX H
   MOV E,M
   INX H
   MOV D,M
   INX H
   XCHG
   DAD H
   DAD D
PSD:      ; 01
   XCHG
   LHLD BFD
RDF:      ; 01
   CALL CBCDE
   JZ SEOSW
   LDAX D
   MOV M,A
   INX D
   INX H
   JMP RDF
SEOSW:      ; 01
   SHLD EOS
   RET
KFP:      ; 01
   INX H
   MOV E,M
   INX H
   MOV D,M
   DAD D
   JMP PSD
STV:      ; 04
   XTHL
   SHLD TEMP
   XTHL
   POP D
   SHLD SOBJ
   CALL SFV
   ORA A
   JM NND
   CALL DVAR
NND:      ; 01
   LHLD EOS
   XCHG
   LHLD SOBJ
   CALL SPRT
   MVI A,04H
   STAX D
   INX D
   XRA A
   STAX D
   INX D
   XCHG
   SHLD EOS
   XCHG
   CALL STDR
   PUSH H
   XTHL
   LHLD TEMP
   XTHL
   RET
VAN:      ; 01
   CALL SBO
   CALL STV
   CALL PBIS
   LHLD AEOWS
   SHLD EOS
REST:      ; 01
   LHLD SOBJ
   DCX H
   JMP BF25
ASIGN:      ; 01
   XCHG
   CALL PBIS
WWPR   ; ???
   CALL STV
   LHLD AEOWS
   SHLD EOS
   LHLD SOBJ
   CALL SRTRM
   XCHG
   RET
IDV:      ; 01
   CALL EX2
   CALL BSKSP
   CALL CKLTR
   CNC ERR ; Var not present in indexing
   CALL SBO
   SHLD SOBJ
   CALL SFV
   MOV H,B
   MOV L,C
   SHLD SBD
   LDAX B
   MOV H,A
   DCX B
   LDAX B
   MOV L,A
   SHLD SZ
   LHLD EOS
   MOV E,M
   INX H
   MOV D,M
   POP B
   MOV A,B
   CMP D
ILCK:      ; 01
   CNZ ERR ; Len of Index not = Len of Val to assign
   MOV A,C
   CMP E
   JNZ ILCK
   XCHG
   DAD H
   DAD D
   XCHG
DLP2:      ; 01
   CALL CHLDE
   JZ BF27
   INX H
   MOV C,M
   INX H
   MOV B,M
   SHLD TEM2
   LHLD SZ
   MOV A,H
   CMP B
IGT:      ; 01
   CC ERR ; Index > Len of Var
   MOV A,L
   CMP C
   JC IGT
   LHLD SBD
   PUSH D
   XCHG
   MOV H,B
   MOV L,C
   POP B
   DAD H
   DAD D
   POP D
   MOV M,D
   DCX H
   MOV M,E
   MOV D,B
   MOV E,C
   LHLD TEM2
   JMP DLP2
BF27:      ; 01
   LXI H, REST
   SHLD RA
   LHLD SBD
   DCX H
   JMP PBS
DASGN:      ; 01
   LHLD VTA
   PUSH D
   LXI D, 1
   PUSH D
   CALL STV
   LHLD AEOWS
   SHLD EOS
   LHLD VTA
   JMP BLP5
EASGN:      ; 01
   DCX H
   PUSH H
   LHLD EOS
   XCHG
   POP H
   CALL BSKSP
   CPI '$'+80H
   JZ AQQ
   CPI '@'+80H
   JZ AQQ
   CPI ')'+80H
   JZ IDV
   CALL CKLTR
   JC VAN
   CALL ERR ; Unkn Assign Oper type
KOF:      ; 01
   CALL CKLTR
   JC TIF
   LXI D, DYADT
CNDO:      ; 01
   LDAX D
   CPI 0FFH
   JZ MO
   CMP M
   INX D
   JNZ CNDO
   MOV C,A
   MVI B,00H
SD:      ; 01
   MVI A,02H
   RET
MO:      ; 01
   LXI D, MONADT
CNMO:      ; 01
   LDAX D
   CPI 0FFH
   JZ NSO
   CMP M
   INX D
   JNZ CNMO
   MOV C,A
   MVI B,00H
SM:      ; 01
   MVI A,01H
   DCX H
   RET
NSO:      ; 01
   MVI A,04H
   DCX H
   RET
TIF:      ; 01
   CALL SBO
   PUSH H
   SHLD SOBJ
   CALL SFF
   ORA A
   CM ERR ; Func not found
   LHLD BFD
   MOV B,H
   MOV C,L
   POP H
   CPI 09H
   JZ SD
   CPI 0BH
   JZ SM
   CALL ERR ; Not a Func
SCRS:      ; 02 scan for cr or ;
   MOV A,M
   INX H
   CPI 8DH ; CR
   RZ
   CPI ';'+80H
   RZ
   JMP SCRS
SCR:      ; 06 scan for cr only
   MOV A,M
   INX H
   CPI 8DH ; CR
   JNZ SCR
   RET
PSS:      ; 02
   XTHL
   SHLD RA
   XTHL
   POP B
   LXI B, 0
   MVI D,00H
SLB:      ; 01
   DCX H
   MOV A,M
   CPI 0A7H ; '''
   JZ BF
   CPI 8DH ; CR
   JZ BF
   ANI 7FH
   MOV E,A
   INX B
   PUSH D
   JMP SLB
BF:      ; 02
   PUSH B
   PUSH B
   XTHL
   LHLD RA
   XTHL
   RET
SBO:      ; 06
   MOV A,M
   CALL CKLTR
   DCX H
   JC SBO
   INX H
   INX H
   RET
INT:      ; 02
; control-c check port
   PUSH H
   PUSH B
   PUSH D
   MVI E,0FFH
   MVI C,CONSTAT
   CALL BDOS
   ORA A
   JZ INT2
   MVI C,CONIN
   CALL BDOS
INT2:
   POP D
   POP B
   POP H
   CPI 03  ; ^C
   JZ BREAK
   RET
BREAK:
   LXI H, BREAKP
   CALL PTXTH
   JMP XMODE
CVO:      ; 02
   XTHL
   SHLD RA
   XTHL
   POP B
   SHLD SOBJ
   DCX H
   SHLD TLOC
   CALL SFV
   CPI 80H
   CZ ERR  ; VAR OR FUNC NOT FOUND
   LDAX B
   MOV D,A
   DCX B
   LDAX B
   MOV E,A
   MOV H,D
   MOV L,E
   SHLD ETEMP
   INX B
   DAD H
   DAD B
   XCHG
PNV:      ; 01
   CALL CBCDE
   JZ FP2
   LDAX D
   MOV H,A
   DCX D
   LDAX D
   MOV L,A
   PUSH H
   DCX D
   CALL CNSF
   JMP PNV
FP2:      ; 01
   LHLD ETEMP
   PUSH H
   LHLD TLOC
   PUSH H
   XTHL
   LHLD RA
   XTHL
   RET
CBCDE:      ; 04
   MOV A,B
   CMP D
   RNZ
   MOV A,C
   CMP E
   RET
CHLDE:      ; 04
   MOV A,H
   CMP D
   RNZ
   MOV A,L
   CMP E
   RET
PUTRVL:      ; 01
   XTHL
   SHLD RA
   XTHL
   POP B
   SHLD TLOC
   LHLD RVAL
   JMP PBS
PBIS:      ; 06
   XTHL
   SHLD RA
   XTHL
   POP B
   SHLD TLOC
   LHLD EOS
PBS:      ; 02
   MOV C,M
   INX H
   MOV B,M
   XCHG
   MOV H,B
   MOV L,C
   DAD H
   DAD D
   DCX D
   DCX D
PB2:      ; 01
   MOV B,M
   DCX H
   MOV C,M
   DCX H
   PUSH B
   CALL CHLDE
   JNZ PB2
   LHLD TLOC
   PUSH H
   XTHL
   LHLD RA
   XTHL
   RET
STDR:      ; 07
   XTHL
   SHLD RA
   XTHL
   POP B
   SHLD TLOC
   POP B
   MOV A,C
   STAX D
   INX D
   MOV A,B
   STAX D
   MOV H,B
   MOV L,C
   DAD H
   DAD D
ST2:      ; 01
   CALL CHLDE
   JZ SR
   POP B
   INX D
   MOV A,C
   STAX D
   INX D
   MOV A,B
   STAX D
   JMP ST2
SR:      ; 01
   INX D
   XCHG
   SHLD AEOWS
   XCHG
   CALL CNSF
   LHLD TLOC
   PUSH H
   XTHL
   LHLD RA
   XTHL
   RET
RESAEOW:      ; 03
   PUSH H
   LHLD EOS
   SHLD AEOWS
   POP H
   RET
CNSF:      ; 07  Check ws full
   PUSH H
   PUSH D
   LHLD AEOWS
   XCHG
   CALL NEGT
   XCHG
   DAD SP
   MOV A,H
   ORA A
   JZ OOSPC
   POP D
   POP H
   RET
OOSPC:
; WS end: flaw prohibits > 32K
   LHLD STKSET
   SPHL
;   LXI SP, MEMTOP
   LXI B, REX
   PUSH B
   LXI B, -1
   PUSH B
   CALL RESAEOW
   CALL ERR ; Work Space full
XXPXO:      ; 01
   SHLD LN
   CALL RESAEOW
   RET
SRTRM:      ; 10
   MOV A,M
   CPI 0FFH
   INX H
   JNZ SRTRM
   RET
CBCHL:      ; 04
   MOV A,B
   CMP H
   RNZ
   MOV A,C
   CMP L
   RET
ARV:      ; 02
   XTHL
   SHLD SRE1
   XTHL
   POP D
   CALL SRTRM
   MVI D,00H
   INX H
   INX H
   INX H
FN3:      ; 01
   MOV A,M
   INX H
   INR D
   CPI 0FFH
   JNZ FN3
   MVI B,00H
FN5:      ; 01
   DCX H
   MOV C,M
   PUSH B
   DCR D
   JNZ FN5
   CALL SRTRM
   XCHG
   XCHG
   CALL PUTRVL
   XCHG
   LHLD EOS
   CALL ASIGN
   PUSH D
   XTHL
   LHLD SRE1
   XTHL
   RET
CBCZ:      ; 07
   MOV A,B
   ORA A
   RNZ
   MOV A,C
   ORA A
   RET
SFF:      ; 06
   PUSH D
   PUSH H
   LHLD SOBJ
   XCHG
   LHLD WS
   MOV B,H
   MOV C,L
   LHLD VARBGN
   XCHG
NPRO2:      ; 02
   PUSH H
   MOV H,B
   MOV L,C
   SHLD BFD
   POP H
   MOV A,B
   CMP D
   JNZ SF2
   MOV A,C
   CMP E
   JZ NM
SF2:      ; 02
   LDAX B
   CPI 0FFH
   JZ ALM
   CMP M
   INX B
   INX H
   JZ SF2
SFS:      ; 01
   LDAX B
   CPI 0FFH
   INX B
   JNZ SFS
OHW:      ; 01
   LDAX B
   CPI 04H
   JZ NOH
   INX B
   PUSH D
   LDAX B
   MOV E,A
   INX B
   LDAX B
   MOV D,A
   MOV H,B
   MOV L,C
   DAD D
   MOV B,H
   MOV C,L
   POP D
AO:      ; 01
   LHLD SOBJ
   JMP NPRO2
ALM:      ; 01
   MOV A,M
   CALL CKLTR
   INX B
   JC OHW
   LDAX B
   INX B
   INX B
   INX B
SF4:      ; 01
   POP H
   POP D
   RET
NM:      ; 01
   MVI A,80H
   JMP SF4
SFV:      ; 04
   PUSH D
   PUSH H
   LHLD SOBJ
   XCHG
   LHLD VARBGN
   MOV B,H
   MOV C,L
   LHLD EOS
   XCHG
   JMP NPRO2
NOH:      ; 01
   INX B
   INX B
   LDAX B
   MOV L,A
   INX B
   LDAX B
   MOV H,A
   INX B
   DAD H
   DAD B
   MOV B,H
   MOV C,L
   JMP AO
BCBIN:      ; 04
   PUSH B
   LXI D, 0
   MOV A,M
   STA  SGNBIT
   CPI '-'+80H
   JNZ NP2
   INX H
   MOV A,M
NP2:      ; 02
   ANI 0FH
   MOV B,D
   MOV C,E
   XCHG
   DAD H
   DAD H
   DAD B
   DAD H  ; times 10
   MVI B,0
   MOV C,A
   DAD B
   XCHG
   INX H
   MOV A,M
   CALL CHEKN
   JC NP2
   LDA  SGNBIT
   CPI '-'+80H
   CZ NEGT
   POP B
   RET
NEGT:      ; 0B
   MOV A,E
   CMA
   MOV E,A
   MOV A,D
   CMA
   MOV D,A
   INX D
   RET
LPES:      ; 02
   INX B
   LDAX B
   CPI 8DH ; CR
   JNZ LPES
   INX B
   DAD D
   JMP SF
SKSP:      ; 11
   MOV A,M
   CPI 0A0H ; SP
   RNZ
   INX H
   JMP SKSP
SKEO:      ; 07
   MOV A,M
   CALL CKLTR
   RNC
   INX H
   JMP SKEO
CHEKN:      ; 08
   CPI '0'+80H
   CMC
   RNC
   CPI '9'+1+80H
   RET
; clear screen routine address
CLRS:      ; 05
   JMP XCLRSCN
PRLN:      ; 04
   MVI A,'['+80H
   CALL OUTPUT
   CALL BINBCD
   MVI A,']'+80H
OUTPUT:      ; 01
   CPI 88H ; ^H
   JNZ P1
   MVI A,'='+80H
   CALL XOUTPUT
   MVI A,':'+80H
   JMP XOUTPUT
P1:      ; 01
   CPI 89H ; ^I
   JNZ P2
   MVI A,':'+80H
   CALL XOUTPUT
   MVI A,'='+80H
   JMP XOUTPUT
P2:      ; 01
   CPI 8EH ; ^N
   JNZ P3
   MVI A,'>'+80H
   CALL XOUTPUT
   MVI A,'='+80H
   JMP XOUTPUT
P3:      ; 01
   CPI 99H ; ^Y
   JNZ P4
   MVI A,'<'+80H
   CALL XOUTPUT
   MVI A,'='+80H
   JMP XOUTPUT
P4:
   JMP XOUTPUT
BINBCD:      ; 05
   PUSH H
   PUSH D
   PUSH B
   XCHG
   LXI D, 000AH
   PUSH D
   MVI B,00H
   MOV A,H
   ORA A
   JP BB2
   MVI A,'-'+80H
   CALL OUTPUT
   XCHG
   CALL NEGT
   XCHG
BB2:      ; 02
   CALL DIVID
   MOV A,B
   ORA C
   JZ BB3
   PUSH H
   MOV H,B
   MOV L,C
   JMP BB2
BB3:      ; 01
   MOV E,L
BB4:      ; 01
   MOV A,E
   CPI 0AH
   JZ BB5
   POP D
   ADI 0B0H
   CALL OUTPUT
   JMP BB4
BB5:      ; 01
   POP B
   POP D
   POP H
   RET
PBINBCD:      ; 01
   MVI A,0A0H ; SP
   CALL OUTPUT
   CALL BINBCD
   MVI A,0A0H ; SP
   CALL OUTPUT
   RET
GETLN:      ; 05
   LXI H, LBUF
CLR:      ; 01
   MVI M,0A0H ; SP
   INX H
   MOV A,L
   CPI (LBUFX AND 0FFH)
   JNZ CLR
   LXI H, LBUF
NCHR:      ; 03
   CALL INPUT
   CPI 98H ; ^X <CAN>
   JNZ NOTR
   CALL CLRS
   CALL INDNT
   JMP GETLN
NOTR:      ; 01
   CPI 82H ; ^B
   JNZ NOB
   DCX H
   LXI D ,LBUF
   CALL CHLDE
   CC ERR ; Backspace < then line buff
; backspace character
   MVI A,'\'+80H ; BS
   CALL OUTPUT
   JMP NCHR
NOB:      ; 01
   CPI 86H ; ^F
   JNZ NFSP
   INX H
   LXI D ,LBUFX
   CALL CHLDE
   CNC ERR ; Beyond end of line buff
; forward space character
   MVI A, 20H ; space could be arrow
   CALL OUTPUT
   JMP NCHR
NFSP:      ; 01
   MOV M,A
   INX H
   CPI 8DH ; CR
   JZ TDI
   LXI D ,LBUFX
   CALL CHLDE
   CNC ERR ; More then 72 chars
   JMP NCHR
TDI:      ; 01
   CALL CRLF
   MVI M,0FFH
   INX H
   MVI M,0FFH
   RET
ERR:      ; 1C
   POP H
   MOV A,L
   MOV L,A
   SHLD ERRN
   CALL CRLF
   LHLD LN
   MOV A,H
   CPI 0FFH
   JNZ ND
   MOV A,L
   CPI 0FFH
   JZ HET
   CPI 0FEH
   JZ SMF
ND:      ; 01
   LHLD CPROG
   CALL PTXTH
   LHLD LN
   XCHG
   CALL PRLN
   LHLD BEGST
PRL:      ; 01
   MOV A,M
   CALL OUTPUT
   INX H
   CPI 8DH ; CR
   JNZ PRL
HET:      ; 01
   XRA A
   STA  DF1
ERT:      ; 01
   LXI H, ERROR
   CALL PTXTH
   LHLD ERRN
   XCHG
   CALL BINBCD
   CALL CRLF
   LDA  DF1
   CPI 02H
   JZ DMODE
   JMP XMODE
SMF:      ; 01
   MVI A,02H
   STA  DF1
   JMP ERT
DEF:      ; 01
   CALL CNSF
   INX H
   MVI B,00H
   CALL PSIS
   SHLD FOBJ
   CALL SO
   SHLD SCOBJ
   CALL SO
   SHLD TOBJ
   CALL SO
   SHLD LOBJ
   CALL SKEO
   CALL SKSP
   CPI 8DH ; CR
   JNZ DF5
DF2:      ; 01
   MVI L,00H
   LXI D, LBUF
DNC:      ; 02
   LDAX D
   CPI 8DH ; CR
   JZ DF3
   CALL CKLTR
   INX D
   JNC DNC
   INR L
   JMP DNC
DF3:      ; 01
   MOV A,L
   STA  NOL
   MOV A,B
   CPI 01H
   JZ PROD
   CPI 03H
   JZ MFD
   CPI 04H
   JZ DFD
DF5:      ; 01
   CALL ERR ; Wrong amount of objects in func def
SO:      ; 03
   CALL SKEO
   CPI 8DH ; CR
   JZ FDONG
   INX H
PSIS:      ; 01
   CALL SKSP
   CALL CKLTR
   CNC ERR ; Bad Syntax in Func Def
   INR B
   RET
FDONG:      ; 01
   POP D
   JMP DF2
PROD:      ; 01
   LHLD FOBJ
   SHLD SOBJ
   CALL SFF
   PUSH H
   LHLD BFD
   SHLD CPROG
   POP H
   ANI 88H
   JM NEWP
   CZ ERR ; Var found to match prog?
   MOV H,B
   MOV L,C
   SHLD BCPR
   DCX H
   DCX H
   DCX H
   MOV A,M
   CPI 08H
   JZ IDM
   INX H
   INX H
   INX H
   CPI 0BH ; <MONAD>
   JZ XXM
   CALL SRTRM
XXM:      ; 01
   CALL SRTRM
   CALL SRTRM
   SHLD BCPR
IDM:      ; 03
   LHLD STKSET
   SPHL
;   LXI SP, MEMTOP
   LXI B, REX
   PUSH B
   LXI B, -1
   PUSH B
DMODE:      ; 07
   LXI H, -2
   SHLD LN
   MVI A,'>'+80H
   CALL OUTPUT
   CALL GETLN
   LXI H, LBUF
   CALL SKSP
   CPI '&'+80H
   JZ STLX
   CPI '@'+80H
   JZ LIST
   CPI '$'+80H
   JZ REN
   CPI 8DH ; CR
   JZ DMODE
   CALL CHEKN
   CNC ERR ; Ill Cmnd in Def mode
   CALL BCBIN
   PUSH H
   LHLD BCPR
TN2:      ; 01
   INX H
   MOV A,M
   CMP D
   DCX H
   JNZ CM2
   MOV A,M
   CMP E
CM2:      ; 01
   JC NL1
   SHLD BEGST
   POP H
   PUSH PSW
   CALL SKSP
   CPI 8DH ; CR
   JZ DELT
   POP PSW
   JNZ DKO
   PUSH D
   PUSH H
   CALL KILINE
   POP H
   POP D
DKO:      ; 01
   MVI C,04H
   PUSH H
   PUSH D
IHR:      ; 01
   INX H
   MOV A,M
   INR C
   CPI 8DH ; CR
   JNZ IHR
   MOV A,C
   STA  AMC
   LHLD BEGST
   PUSH H
   LHLD EOS
   MOV D,H
   MOV E,L
   MVI B,00H
   DAD B
   POP B
   SHLD AEOWS
   CALL CNSF
   SHLD EOS
   CALL CUL
   POP D
   POP H
   MOV A,E
   STAX B
   INX B
   MOV A,D
   STAX B
   INX B
   LDA  AMC
   SUI 03H
   STAX B
INS:      ; 01
   INX B
   MOV A,M
   STAX B
   CPI 8DH ; CR
   INX H
   JNZ INS
   JMP DMODE
DELT:      ; 01
   POP PSW
   JNZ DMODE
   CALL KILINE
   JMP DMODE
KILINE:      ; 02
   LHLD EOS
   XCHG
   LHLD BEGST
   MOV B,H
   MOV C,L
   INX H
   INX H
FEL:      ; 01
   INX H
   MOV A,M
   CPI 8DH ; CR
   JNZ FEL
   INX H
UF2:      ; 01
   MOV A,M
   STAX B
   MOV A,D
   CMP H
   JNZ CO2
   MOV A,E
   CMP L
CO2:      ; 01
   INX B
   INX H
   JNZ UF2
   DCX B
   MOV H,B
   MOV L,C
   SHLD EOS
   RET
CUL:      ; 03
   LDAX D
   MOV M,A
   MOV A,B
   CMP D
   JNZ SR2
   MOV A,C
   CMP E
SR2:      ; 01
   DCX D
   DCX H
   JNZ CUL
   RET
NL1:      ; 01
   INX H
   INX H
   INX H
   CALL SCR
   JMP TN2
NEWP:      ; 01
   LDA  NOL
   ADI 06H
   STA  NOL
   CALL SHDR
   MVI A,08H
   CALL SRO
   CALL IDA
   JMP IDM
MFD:      ; 01
   LHLD SCOBJ
   SHLD SOBJ
   CALL SFF
   PUSH H
   LHLD BFD
   SHLD CPROG
   POP H
   ANI 80H
   JM NMF
   CALL ERR ; Ill redef of Nomadic Func Header
DFD:      ; 01
   LHLD TOBJ
   SHLD SOBJ
   CALL SFF
   PUSH H
   LHLD BFD
   SHLD CPROG
   POP H
   ANI 80H
   JM NDF
   CALL ERR ; Ill Redef of Dyadic Func Header
NDF:      ; 01
   LDA  NOL
   ADI 09H
   STA  NOL
   CALL SHDR
   MVI A,09H
   CALL SRO
   LHLD FOBJ
   CALL SPRT
   LHLD SCOBJ
   CALL SPRT
   LHLD LOBJ
   CALL SPRT
   CALL IDA
   JMP IDM
NMF:      ; 01
   LDA  NOL
   ADI 08H
   STA  NOL
   CALL SHDR
   MVI A,0BH
   CALL SRO
   LHLD FOBJ
   CALL SPRT
   LHLD TOBJ
   CALL SPRT
   CALL IDA
   JMP IDM
SPRT:      ; 08
   MOV A,M
   CALL CKLTR
   JNC D2
   STAX D
   INX D
   INX H
   JMP SPRT
D2:      ; 01
   MVI A,0FFH
   STAX D
   INX D
   RET
SRO:      ; 03
   STAX D
   INX D
   INX D
   INX D
   RET
SHDR:      ; 03
   LHLD EOS
   XCHG
   LHLD CPROG
   PUSH H
   MOV H,D
   MOV L,E
   LDA  NOL
   MOV C,A
   MVI B,00H
   DAD B
   SHLD EOS
   POP B
   CALL CUL
   MOV D,B
   MOV E,C
   LHLD SOBJ
   CALL SPRT
   RET
IDA:      ; 03
   MVI A,0FFH
   STAX D
   MOV H,D
   MOV L,E
   SHLD BCPR
   INX D
   STAX D
   INX D
   XCHG
   SHLD VARBGN
   RET
REN:      ; 01
   INX H
   CALL SKSP
   CALL CHEKN
   JC RN3
   LXI D, 000AH
   JMP RN7
RN3:      ; 01
   CALL BCBIN
RN7:      ; 01
   LHLD BCPR
   MOV B,H
   MOV C,L
   MOV H,D
   MOV L,E
SF:      ; 01
   LDAX B
   CPI 0FFH
   JNZ OK1
   INX B
   LDAX B
   CPI 0FFH
   DCX B
   JNZ OK1
   JMP DMODE
OK1:      ; 02
   MOV A,L
   STAX B
   INX B
   MOV A,H
   STAX B
   JMP LPES
LIST:      ; 01
   CALL CLRS
   INX H
   CALL SKSP
   CALL CHEKN
   JC LF1
   LXI D, 0
   JMP LF2
LF1:      ; 01
   CALL BCBIN
LF2:      ; 01
   LHLD BCPR
LF3:      ; 01
   SHLD SOL
   MOV C,M
   INX H
   MOV B,M
   INX H
   MOV A,C
   CPI 0FFH
   JNZ LF2X
   MOV A,B
   CPI 0FFH
   JZ PTCH2
LF2X:      ; 01
   CALL CBCDE
   JNC PTCH2
   INX H
   CALL SCR
   JMP LF3
PTCH2:      ; 02
   LHLD CPROG
   CALL INDNT
   MVI A,'&'+80H
   CALL OUTPUT
   SHLD FOBJ
L2:      ; 01
   MOV A,M
   CPI 0FFH
   INX H
   JNZ L2
   MOV A,M
   CPI 08H
   JZ PROG1
   MOV B,A
   INX H
   INX H
   INX H
   CALL PTXTH
   MVI A,89H ; ^I :=
   CALL OUTPUT
   INX H
   MOV A,B
   CPI 0BH
   PUSH PSW
   PUSH H
   CZ PRSP
   POP H
   CALL PTXTH
   POP PSW
   JZ LP3
   MVI A,0A0H ; SP
   CALL OUTPUT
   PUSH H
   CALL PRSP
   POP H
   INX H
   CALL PTXTH
   JMP LP3
PROG1:      ; 01
   CALL PRFO
LP3:      ; 02
   CALL CRLF
   LHLD SOL
CL2:      ; 01
   MOV E,M
   INX H
   MOV D,M
   INX H
   MOV A,E
   CPI 0FFH
   JNZ LP4
   MOV A,D
   CPI 0FFH
   JZ DONL
LP4:      ; 01
   CALL PRLN
   MVI A,0A0H ; CR
   CALL OUTPUT
LP5:      ; 01
   INX H
   MOV A,M
   CALL OUTPUT
   CPI 8DH ; CR
   JNZ LP5
   MVI A,8AH
   CALL OUTPUT
   INX H
   JMP CL2
DONL:      ; 01
   CALL INDNT
   CALL CRLF
   JMP DMODE
PTXTH:      ; 0D
   MOV A,M
   CPI 0FFH
   RZ
   CALL OUTPUT
   INX H
   JMP PTXTH
PRFO:      ; 02
   LHLD FOBJ
   JMP PTXTH
PRSP:      ; 02
   CALL PRFO
   MVI A,0A0H ; SP
   CALL OUTPUT
   RET
STLX:      ; 01
   LHLD CPROG
   CALL SRTRM
   INX H
   MOV B,H
   MOV C,L
   LHLD BCPR
   DCX H
FED:      ; 02
   INX H
   MOV A,M
   CPI 0FFH
   JNZ FED
   INX H
   MOV A,M
   CPI 0FFH
   JNZ FED
   MOV D,B
   MOV E,C
   CALL NEGT
   PUSH H
   DAD D
   MOV A,L
   STAX B
   INX B
   MOV A,H
   STAX B
   POP H
SSRH:      ; 01
   INX H
   XCHG
   LHLD EOS
   MOV A,D
   CMP H
   JNZ NES
   MOV A,E
   CMP L
   JZ NSIT
NES:      ; 01
   XCHG
   PUSH H
   CALL SRTRM
   MOV A,M
   POP H
   CPI 04H
   JZ NSIT
DPPP:      ; 02
   INX H
   MOV A,M
   CPI 0FFH
   JNZ DPPP
   INX H
   MOV A,M
   CPI 0FFH
   JNZ DPPP
   JMP SSRH
NSIT:      ; 02
   SHLD VARBGN
   LHLD BCPR
CONS:      ; 01
   MOV E,M
   INX H
   MOV D,M
   INX H
   INX H
   CALL CKE
   JZ XMODE
   SHLD VTA
   MOV A,M
   CALL CKLTR
   JC PROSC
BLP5:      ; 03
   MOV A,M
   CPI 8DH ; CR
   INX H
   JNZ BLP5
   JMP CONS
PROSC:      ; 01
   CALL SKEO
   CPI ':'+80H
   JZ DASGN
   JMP BLP5
CKE:      ; 01
   MOV A,D
   CPI 0FFH
   RNZ
   MOV A,E
   CPI 0FFH
   RET
INDNT:      ; 04
   PUSH B
   MVI B,05H
   MVI A,0A0H ; SP
ND1:      ; 01
   CALL OUTPUT
   DCR B
   JNZ ND1
   POP B
   RET
XPRGRM:      ; 03
   MVI A,08H
XP1:      ; 01
   JMP XPRG
CMPHLDE:      ; 03
   MOV A,H
   CMP D
   RNZ
   MOV A,L
   CMP E
   RET
DYADT:      ; List of operations
   DB  0ABH,0ADH,0AAH,0AFH,0A7H,0A2H,0AEH,0BCH,99H
   DB  0BEH,8EH,0BDH,0A3H,0ACH,0DBH,89H,0FFH
MONADT:      ; List of operations
   DB  0DFH,0A1H,0A6H,0BFH,0DCH,0DEH,0A5H,0FFH
EMPLETC:      ; 01
   ; EMPL 1.0
   DB  0C5H,0CDH,0D0H,0CCH,0A0H,0B1H,0AEH,0B0H,8DH,8AH
   ; CLEAR WS
   DB  0C3H,0CCH,0C5H,0C1H,0D2H,0A0H,0D7H
   DB  0D3H,8DH,8AH,0FFH
FREE:      ; 01
   DB  0A0H,0C6H,0D2H,0C5H,0C5H,8DH,8AH,0FFH
BREAKP:      ; 01
   DB  8DH,8AH,0C2H,0D2H,0C5H,0C1H,0CBH,8DH,8AH,0FFH
ERROR:      ; 01
   DB  8DH,8AH,0C5H,0D2H,0D2H,0CFH,0D2H,0A0H,0FFH
PFLG:      ; 03
   DB  0C2H,8DH
LBUF:      ; 0B
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
   DB  0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H,0A0H
LBUFX:      ; 01 Must be after LBUF
   DB  00H,00H
AEOWS:      ; 09
   DB  02H,2AH
TEMP:      ; 02
   DB  92H,09H
SBD:      ; 03
   DB  00H,00H
TEM2:      ; 02
   DB  00H,00H
VTA:      ; 03
   DB  00H,00H
ETEMP:      ; 02
   DB  06H,00H
ERRN:      ; 02
   DB  3AH,04H
FOBJ:      ; 06
   DB  00H,00H
SCOBJ:      ; 03
   DB  00H,00H
TOBJ:      ; 03
   DB  00H,00H
LOBJ:      ; 02
   DB  00H,00H
NOL:      ; 08
   DB  00H
FLG:      ; 04
   DB  01H
SGNBIT:      ; 02
   DB  0B6H
DF1:      ; 03
   DB  00H
VARBGN:      ; 08
   DB  02H,2AH
WS:      ; 05
   DB  02H,2AH
EOS:      ; 28
   DB  02H,2AH
BCPR:      ; 10
   DB  00H,00H
CPROG:      ; 10
   DB  00H,00H
IC:      ; 03
   DB  05H,00H
LN:      ; 0C
   DB  0FFH,0FFH
BEGST:      ; 0E
   DB  45H,12H
SOBJ:      ; 11
   DB  45H,12H
BFD:      ; 08
   DB  10H,20H
TLOC:      ; 0C
   DB  46H,12H
RAXX:      ; 07
   DB  44H,12H
OPR:      ; 09
   DB  0ABH
OPR1 :      ; 02
   DB  00H
RVAL:      ; 04
   DB  30H,20H
RA:      ; 0A
   DB  0F2H,04H
SZ:      ; 0B
   DB  06H
SZ1:      ; 02
   DB  00H
RES:      ; 02
   DB  01H,00H
SPEC:      ; 02
   DB  31H,20H
LOCTX:      ; 02
   DB  00H,00H
STDP:      ; 02
   DB  00H,00H
LI:      ; 02
   DB  00H
LI1:      ; 01
   DB  00H
MLOC:      ; 02
   DB  30H,05H
AMC:      ; 02
   DB  00H,00H
SRE1:      ; 02
   DB  00H,00H
SRE2:      ; 02
   DB  00H,00H,00H,00H
BYR:      ; 01
   ; V1.00J
   DB  0ADH,63H,5DH,61H,61H,95H,1BH,15H
   ; OX1777
   DB  9FH,0B1H,63H,6FH,6FH,6FH,6FH,1BH,15H,0FFH
PTCH3:      ; 02
   DB  01H,00H
PTCH5:      ; 06
   DB  01H
PTCH6:      ; 02
   DB  00H
PTCH8:      ; 02
   DB  00H,00H
QUIT:      ; 01
   LHLD EOS
; WS start
   SHLD WSEND
; operating system address
   JMP SYST
SOL:      ; 02
   DB  29H,11H
;   DB  0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
; I/O Routines
XINPUT:      ; 01
   PUSH H
   PUSH B
   PUSH D
XINP1:
   MVI E,0FFH
   MVI C,CONDRCT
   CALL BDOS
   ORA A
   JZ XINP1
   ORI 80H
   POP D
   POP B
   POP H
   RET
XOUTPUT:      ; 01
   PUSH H
   PUSH B
   PUSH D
   PUSH PSW
   MVI C,CONDRCT
   ANI 7FH
   MOV E,A
   CALL BDOS
   POP PSW
   POP D
   POP B
   POP H
   RET
XCLRSCN:      ; 01
   MVI A,0DH
   CALL XOUTPUT
   MVI A,0AH
   JMP XOUTPUT
; end I/O Routines
SYST:      ; 01
;   HLT
   JMP BOOT
STKSET: DW MEMTOP
WSEND: DS 2  ; EQU 1700H ;  02
WSBUF: DS 100 ;  EQU 1702H ; 01
   END
