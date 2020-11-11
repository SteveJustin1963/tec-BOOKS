; ===============================================
; CamelForth for the Intel 8086
; (c) 1996 Bradford J. Rodriguez
; Permission is granted to freely copy, modify,
; and distribute this program for personal or
; educational use.  Commercial inquiries should
; be directed to the author at 115 First St.,
; #105, Collingwood, Ontario L9Y 4W3 Canada
;
; CAMEL86H.ASM: High Level Words
;   Source code is for Borland Turbo Assembler.
;   Forth words are documented as follows:
;x   NAME     stack -- stack    description
;   where x=C for ANS Forth Core words, X for ANS
;   Extensions, Z for internal or private words.
; ===============================================
; REVISION HISTORY
; v1.0  alpha test version, 17 Dec 96
; ===============================================

; SYSTEM VARIABLES & CONSTANTS ==================

;C BL      -- char            an ASCII space
    head BLANK,2,'BL',docon
        dw 20h

;Z tibsize  -- n         size of TIB
    head TIBSIZE,7,'TIBSIZE',docon
        dw 124          ; 2 chars safety zone

;X tib     -- a-addr     Terminal Input Buffer
;  HEX 80 USER TIB       8086: above user area
    head TIB,3,'TIB',douser
        dw 80h

;Z u0      -- a-addr       current user area adrs
;  0 USER U0
    head U0,2,'U0',douser
        dw 0

;C >IN     -- a-addr        holds offset into TIB
;  2 USER >IN
    head TOIN,3,'>IN',douser
        dw 2

;C BASE    -- a-addr       holds conversion radix
;  4 USER BASE
    head BASE,4,'BASE',douser
        dw 4

;C STATE   -- a-addr       holds compiler state
;  6 USER STATE
    head STATE,5,'STATE',douser
        dw 6

;Z dp      -- a-addr       holds dictionary ptr
;  8 USER DP
    head _DP,2,'DP',douser
        dw 8

;Z 'source  -- a-addr      two cells: len, adrs
; 10 USER 'SOURCE
    head TICKSOURCE,7,<27h,'SOURCE'>,douser
        dw 10

;Z latest    -- a-addr     last word in dict.
;   14 USER LATEST
    head LATEST,6,'LATEST',douser
        dw 14

;Z hp       -- a-addr     HOLD pointer
;   16 USER HP
    head HP,2,'HP',douser
        dw 16

;Z LP       -- a-addr     Leave-stack pointer
;   18 USER LP
    head LP,2,'LP',douser
        dw 18

;Z IDP    -- a-addr        ROM dictionary pointer
;   20 USER IDP
    head IDP,3,'IDP',douser
        dw 20

;Z HDP    -- a-addr     Header dictionary pointer
;   22 USER HDP
    head HDP,3,'HDP',douser
        dw 22

;X PAD       -- a-addr    user PAD buffer
;                         = end of hold area!
    head PAD,3,'PAD',douser
        dw 128h

;Z l0       -- a-addr     bottom of Leave stack
    head L0,2,'L0',douser
        dw 180h

;Z r0       -- a-addr     end of return stack
    head R0,2,'R0',docon
        dw 100h  ; temporary ???

;Z s0       -- a-addr     end of parameter stack
    head S0,2,'S0',docon
        dw 200h  ; temporary ???

;Z uinit    -- addr  initial values for user area
    head UINIT,5,'UINIT',dorom
        DW 0,0,10,0     ; reserved,>IN,BASE,STATE
        DW ramdict      ; DP
        DW 0,0          ; SOURCE init'd elsewhere
ilatest: DW link        ; LATEST, patched later
        DW 0,0          ; HP,LP init'd elsewhere
        DW romdict      ; IDP
        DW headdict     ; HDP

;Z #init    -- n    #bytes of user area init data
    head NINIT,5,'#INIT',docon
        DW 24

; ARITHMETIC OPERATORS ==========================

;C S>D    n -- d          single -> double prec.
;   DUP 0< ;
    head STOD,3,'S>D',docolon
        dw DUPE,ZEROLESS,EXIT

;Z ?NEGATE  n1 n2 -- n3  negate n1 if n2 negative
;   0< IF NEGATE THEN ;        ...a common factor
    head QNEGATE,7,'?NEGATE',docolon
        DW ZEROLESS,qbranch,QNEG1,NEGATE
QNEG1:  DW EXIT

;C ABS     n1 -- +n2     absolute value
;   DUP ?NEGATE ;
    head ABBS,3,'ABS',docolon
        DW DUPE,QNEGATE,EXIT

;X DNEGATE   d1 -- d2     negate double precision
;   SWAP INVERT SWAP INVERT 1 M+ ;
    head DNEGATE,7,'DNEGATE',docolon
        DW SWAP,INVERT,SWAP,INVERT,LIT,1,MPLUS
        DW EXIT

;Z ?DNEGATE  d1 n -- d2   negate d1 if n negative
;   0< IF DNEGATE THEN ;       ...a common factor
    head QDNEGATE,8,'?DNEGATE',docolon
        DW ZEROLESS,qbranch,DNEG1,DNEGATE
DNEG1:  DW EXIT

;X DABS     d1 -- +d2    absolute value dbl.prec.
;   DUP ?DNEGATE ;
    head DABS,4,'DABS',docolon
        DW DUPE,QDNEGATE,EXIT

;C M*     n1 n2 -- d    signed 16*16->32 multiply
;   2DUP XOR >R        carries sign of the result
;   SWAP ABS SWAP ABS UM*
;   R> ?DNEGATE ;
    head MSTAR,2,'M*',docolon
        DW TWODUP,XORR,TOR
        DW SWAP,ABBS,SWAP,ABBS,UMSTAR
        DW RFROM,QDNEGATE,EXIT

;C SM/REM   d1 n1 -- n2 n3   symmetric signed div
;   2DUP XOR >R              sign of quotient
;   OVER >R                  sign of remainder
;   ABS >R DABS R> UM/MOD
;   SWAP R> ?NEGATE
;   SWAP R> ?NEGATE ;
; Ref. dpANS-6 section 3.2.2.1.
    head SMSLASHREM,6,'SM/REM',docolon
        DW TWODUP,XORR,TOR,OVER,TOR
        DW ABBS,TOR,DABS,RFROM,UMSLASHMOD
        DW SWAP,RFROM,QNEGATE,SWAP,RFROM,QNEGATE
        DW EXIT

;C FM/MOD   d1 n1 -- n2 n3   floored signed div'n
;                            courtesy of Ed Smeda
;   DUP >R  SM/REM  2DUP  1 <  AND  IF
;     SWAP R@ +  SWAP 1-  THEN
;   R> DROP ;
; Ref. dpANS-6 section 3.2.2.1.
    head FMSLASHMOD,6,'FM/MOD',docolon
	DW DUPE,TOR,SMSLASHREM
        DW TWODUP,LIT,1,LESS,ANDD,qbranch,FMMOD1
        DW SWAP,RFETCH,PLUS,SWAP,ONEMINUS
FMMOD1: DW RFROM,DROP,EXIT

; old (incorrect) version
;   DUP >R              save divisor
;   SM/REM
;   DUP 0< IF           if quotient negative,
;       SWAP R> +         add divisor to rem'dr
;       SWAP 1-           decrement quotient
;   ELSE R> DROP THEN ;
;
;        DW DUPE,TOR,SMSLASHREM
;        DW DUPE,ZEROLESS,qbranch,FMMOD1
;        DW SWAP,RFROM,PLUS,SWAP,ONEMINUS
;        DW branch,FMMOD2
;FMMOD1: DW RFROM,DROP
;FMMOD2: DW EXIT

;C *      n1 n2 -- n3       signed multiply
;   M* DROP ;
    head STAR,1,'*',docolon
        dw MSTAR,DROP,EXIT

;C /MOD   n1 n2 -- n3 n4    signed divide/rem'dr
;   >R S>D R> FM/MOD ;
    head SLASHMOD,4,'/MOD',docolon
        dw TOR,STOD,RFROM,FMSLASHMOD,EXIT

;C /      n1 n2 -- n3       signed divide
;   /MOD nip ;
    head SLASH,1,'/',docolon
        dw SLASHMOD,NIP,EXIT

;C MOD    n1 n2 -- n3       signed remainder
;   /MOD DROP ;
    head MODD,3,'MOD',docolon
        dw SLASHMOD,DROP,EXIT

;C */MOD  n1 n2 n3 -- n4 n5    n1*n2/n3, rem&quot
;   >R M* R> FM/MOD ;
    head SSMOD,5,'*/MOD',docolon
        dw TOR,MSTAR,RFROM,FMSLASHMOD,EXIT

;C */     n1 n2 n3 -- n4        n1*n2/n3
;   */MOD nip ;
    head STARSLASH,2,'*/',docolon
        dw SSMOD,NIP,EXIT

;C MAX    n1 n2 -- n3       signed maximum
;   2DUP < IF SWAP THEN DROP ;
    head MAX,3,'MAX',docolon
        dw TWODUP,LESS,qbranch,MAX1,SWAP
MAX1:   dw DROP,EXIT

;C MIN    n1 n2 -- n3       signed minimum
;   2DUP > IF SWAP THEN DROP ;
    head MIN,3,'MIN',docolon
        dw TWODUP,GREATER,qbranch,MIN1,SWAP
MIN1:   dw DROP,EXIT

; DOUBLE OPERATORS ==============================

;C 2@    a-addr -- x1 x2    fetch 2 cells
;   DUP CELL+ @ SWAP @ ;
;   the lower address will appear on top of stack
    head TWOFETCH,2,'2@',docolon
        dw DUPE,CELLPLUS,FETCH,SWAP,FETCH,EXIT

;C 2!    x1 x2 a-addr --    store 2 cells
;   SWAP OVER ! CELL+ ! ;
;   the top of stack is stored at the lower adrs
    head TWOSTORE,2,'2!',docolon
        dw SWAP,OVER,STORE,CELLPLUS,STORE,EXIT

;C 2DROP  x1 x2 --          drop 2 cells
;   DROP DROP ;
    head TWODROP,5,'2DROP',docolon
        dw DROP,DROP,EXIT

;C 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
;   OVER OVER ;
    head TWODUP,4,'2DUP',docolon
        dw OVER,OVER,EXIT

;C 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2  per diagram
;   ROT >R ROT R> ;
    head TWOSWAP,5,'2SWAP',docolon
        dw ROT,TOR,ROT,RFROM,EXIT

;C 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
;   >R >R 2DUP R> R> 2SWAP ;
    head TWOOVER,5,'2OVER',docolon
        dw TOR,TOR,TWODUP,RFROM,RFROM
        dw TWOSWAP,EXIT

; INPUT/OUTPUT ==================================

;C COUNT   c-addr1 -- c-addr2 u  counted->adr/len
;   DUP CHAR+ SWAP C@ ;
    head COUNT,5,'COUNT',docolon
        dw DUPE,CHARPLUS,SWAP,CFETCH,EXIT

;C CR      --               output newline
;   0D EMIT 0A EMIT ;
    head CR,2,'CR',docolon
        dw lit,0dh,EMIT,lit,0ah,EMIT,EXIT

;C SPACE   --               output a space
;   BL EMIT ;
    head SPACE,5,'SPACE',docolon
        dw BLANK,EMIT,EXIT

;C SPACES   n --            output n spaces
;   BEGIN DUP WHILE SPACE 1- REPEAT DROP ;
    head SPACES,6,'SPACES',docolon
SPCS1:  DW DUPE,qbranch,SPCS2
        DW SPACE,ONEMINUS,branch,SPCS1
SPCS2:  DW DROP,EXIT

;Z umin     u1 u2 -- u      unsigned minimum
;   2DUP U> IF SWAP THEN DROP ;
    head UMIN,4,'UMIN',docolon
        DW TWODUP,UGREATER,QBRANCH,UMIN1,SWAP
UMIN1:  DW DROP,EXIT

;Z umax    u1 u2 -- u       unsigned maximum
;   2DUP U< IF SWAP THEN DROP ;
    head UMAX,4,'UMAX',docolon
        DW TWODUP,ULESS,QBRANCH,UMAX1,SWAP
UMAX1:  DW DROP,EXIT

;C ACCEPT  c-addr +n -- +n'  get line from term'l
;   OVER + 1- OVER      -- sa ea a
;   BEGIN KEY           -- sa ea a c
;   DUP 0D <> WHILE
;       DUP EMIT        -- sa ea a c
;       DUP 8 = IF  DROP 1-    >R OVER R> UMAX
;             ELSE  OVER C! 1+ OVER UMIN
;       THEN            -- sa ea a
;   REPEAT              -- sa ea a c
;   DROP NIP SWAP - ;
    head ACCEPT,6,'ACCEPT',docolon
        DW OVER,PLUS,ONEMINUS,OVER
ACC1:   DW KEY,DUPE,LIT,0DH,NOTEQUAL,QBRANCH,ACC5
        DW DUPE,EMIT,DUPE,LIT,8,EQUAL,QBRANCH,ACC3
        DW DROP,ONEMINUS,TOR,OVER,RFROM,UMAX
        DW BRANCH,ACC4
ACC3:   DW OVER,CSTORE,ONEPLUS,OVER,UMIN
ACC4:   DW BRANCH,ACC1
ACC5:   DW DROP,NIP,SWAP,MINUS,EXIT

;C TYPE    c-addr +n --     type line to term'l
;   ?DUP IF
;     OVER + SWAP DO I C@ EMIT LOOP
;   ELSE DROP THEN ;
    head TYP,4,'TYPE',docolon
        DW QDUP,QBRANCH,TYP4
        DW OVER,PLUS,SWAP,XDO
TYP3:   DW II,CFETCH,EMIT,XLOOP,TYP3
        DW BRANCH,TYP5
TYP4:   DW DROP
TYP5:   DW EXIT


; HARVARD MODEL EXTENSIONS (split Code & Data)

;Z ICOUNT  c-addr1 -- c-addr2 u  counted->adr/len
;   DUP CHAR+ SWAP IC@ ;          from Code space
    head ICOUNT,6,'ICOUNT',docolon
        dw DUPE,CHARPLUS,SWAP,ICFETCH,EXIT

;Z ITYPE   c-addr +n --       type line to term'l
;   ?DUP IF                       from Code space
;     OVER + SWAP DO I IC@ EMIT LOOP
;   ELSE DROP THEN ;
    head ITYPE,5,'ITYPE',docolon
        DW QDUP,QBRANCH,ITYP4
        DW OVER,PLUS,SWAP,XDO
ITYP3:  DW II,ICFETCH,EMIT,XLOOP,ITYP3
        DW BRANCH,ITYP5
ITYP4:  DW DROP
ITYP5:  DW EXIT

;Z (IS")     -- c-addr u   run-time code for S"
;   R> ICOUNT 2DUP + ALIGNED >R  ;
; Harvard model, for string stored in Code space
; e.g. as used by ."
    head XISQUOTE,5,'(IS")',docolon
        DW RFROM,ICOUNT,TWODUP,PLUS,ALIGNED,TOR
        DW EXIT

;Z (S")     -- c-addr u   run-time code for S"
;   R@ I@                     get Data address
;   R> CELL+ DUP IC@ CHAR+    -- Dadr Radr+2 n+1
;   2DUP + ALIGNED >R         -- Dadr Iadr n+1
;   >R OVER R> I->D           -- Dadr
;   COUNT ;
; Harvard model, for string stored in Code space
; which is copied to Data space.
    head XSQUOTE,4,'(S")',docolon
        DW RFETCH,IFETCH
        DW RFROM,CELLPLUS,DUPE,ICFETCH,CHARPLUS
        DW TWODUP,PLUS,ALIGNED,TOR
        DW TOR,OVER,RFROM,ITOD,COUNT,EXIT

;C IS"      --            compile in-line string
;   COMPILE (IS")  [ HEX ]
;   22 IWORD
;   IC@ 1+ ALIGNED IALLOT ; IMMEDIATE
; Harvard model: string is stored in Code space
    immed ISQUOTE,3,'IS"',docolon
        DW LIT,XISQUOTE,COMMAXT
        DW LIT,22H,IWORD
        DW ICFETCH,ONEPLUS,ALIGNED,IALLOT,EXIT

;C S"       --             compile in-line string
;   COMPILE (S")  [ HEX ]
;   HERE I,                     data address
;   22 IWORD
;   IC@ 1+ ALIGNED
;   DUP ALLOT IALLOT ; IMMEDIATE
; Harvard model: string is stored in Code space
    immed SQUOTE,2,'S"',docolon
        DW LIT,XSQUOTE,COMMAXT
        DW HERE,ICOMMA,LIT,22H,IWORD
        DW ICFETCH,ONEPLUS,ALIGNED
        DW DUPE,ALLOT,IALLOT,EXIT

;C ."       --         compile string to print
;   POSTPONE IS"  POSTPONE ITYPE ; IMMEDIATE
    immed DOTQUOTE,2,'."',docolon
        DW ISQUOTE
        DW LIT,ITYPE,COMMAXT
        DW EXIT

;Z IWORD     c -- c-addr       WORD to Code space
;   WORD
;   IHERE TUCK OVER C@ CHAR+ D->I ;
    head IWORD,5,'IWORD',docolon
        DW WORDD,IHERE,TUCK,OVER,CFETCH
        DW CHARPLUS,DTOI,EXIT

; SEPARATE HEADER EXTENSIONS

;Z HCOUNT  c-addr1 -- c-addr2 u  counted->adr/len
;   DUP CHAR+ SWAP HC@ ;          from Head space
    head HCOUNT,6,'HCOUNT',docolon
        dw DUPE,CHARPLUS,SWAP,HCFETCH,EXIT

;Z HTYPE   c-addr +n --       type line to term'l
;   ?DUP IF                       from Head space
;     OVER + SWAP DO I HC@ EMIT LOOP
;   ELSE DROP THEN ;
    head HTYPE,5,'HTYPE',docolon
        DW QDUP,QBRANCH,HTYP4
        DW OVER,PLUS,SWAP,XDO
HTYP3:  DW II,HCFETCH,EMIT,XLOOP,HTYP3
        DW BRANCH,HTYP5
HTYP4:  DW DROP
HTYP5:  DW EXIT

;Z HWORD     c -- c-addr       WORD to Head space
;   WORD
;   HHERE TUCK OVER C@ CHAR+ D->H ;
    head HWORD,5,'HWORD',docolon
        DW WORDD,HHERE,TUCK,OVER,CFETCH
        DW CHARPLUS,DTOH,EXIT

; NUMERIC OUTPUT ================================
; Numeric conversion is done l.s.digit first, so
; the output buffer is built backwards in memory.

; Some double-precision arithmetic operators are
; needed to implement ANSI numeric conversion.

;Z UD/MOD   ud1 u2 -- u3 ud4   32/16->32 divide
;   >R 0 R@ UM/MOD  ROT ROT R> UM/MOD ROT ;
    head UDSLASHMOD,6,'UD/MOD',docolon
        DW TOR,LIT,0,RFETCH,UMSLASHMOD,ROT,ROT
        DW RFROM,UMSLASHMOD,ROT,EXIT

;Z UD*      ud1 d2 -- ud3      32*16->32 multiply
;   DUP >R UM* DROP  SWAP R> UM* ROT + ;
    head UDSTAR,3,'UD*',docolon
        DW DUPE,TOR,UMSTAR,DROP
        DW SWAP,RFROM,UMSTAR,ROT,PLUS,EXIT

;C HOLD  char --        add char to output string
;   -1 HP +!  HP @ C! ;
    head HOLD,4,'HOLD',docolon
        DW LIT,-1,HP,PLUSSTORE
        DW HP,FETCH,CSTORE,EXIT

;C <#    --             begin numeric conversion
;   PAD HP ! ;          (initialize Hold Pointer)
    head LESSNUM,2,'<#',docolon
        DW PAD,HP,STORE,EXIT

;Z >digit   n -- c      convert to 0..9A..Z
;   [ HEX ] DUP 9 > 7 AND + 30 + ;
    head TODIGIT,6,'>DIGIT',docolon
        DW DUPE,LIT,9,GREATER,LIT,7,ANDD,PLUS
        DW LIT,30H,PLUS,EXIT

;C #     ud1 -- ud2     convert 1 digit of output
;   BASE @ UD/MOD ROT >digit HOLD ;
    head NUM,1,'#',docolon
        DW BASE,FETCH,UDSLASHMOD,ROT,TODIGIT
        DW HOLD,EXIT

;C #S    ud1 -- ud2     convert remaining digits
;   BEGIN # 2DUP OR 0= UNTIL ;
    head NUMS,2,'#S',docolon
NUMS1:  DW NUM,TWODUP,ORR,ZEROEQUAL,qbranch,NUMS1
        DW EXIT

;C #>    ud1 -- c-addr u    end conv., get string
;   2DROP HP @ PAD OVER - ;
    head NUMGREATER,2,'#>',docolon
        DW TWODROP,HP,FETCH,PAD,OVER,MINUS,EXIT

;C SIGN  n --           add minus sign if n<0
;   0< IF 2D HOLD THEN ;
    head SIGN,4,'SIGN',docolon
        DW ZEROLESS,qbranch,SIGN1,LIT,2DH,HOLD
SIGN1:  DW EXIT

;C U.    u --           display u unsigned
;   <# 0 #S #> TYPE SPACE ;
    head UDOT,2,'U.',docolon
        DW LESSNUM,LIT,0,NUMS,NUMGREATER,TYP
        DW SPACE,EXIT

;C .     n --           display n signed
;   <# DUP ABS 0 #S ROT SIGN #> TYPE SPACE ;
    head DOT,1,'.',docolon
        DW LESSNUM,DUPE,ABBS,LIT,0,NUMS
        DW ROT,SIGN,NUMGREATER,TYP,SPACE,EXIT

;C DECIMAL  --      set number base to decimal
;   10 BASE ! ;
    head DECIMAL,7,'DECIMAL',docolon
        DW LIT,10,BASE,STORE,EXIT

;X HEX     --       set number base to hex
;   16 BASE ! ;
    head HEX,3,'HEX',docolon
        DW LIT,16,BASE,STORE,EXIT

; DICTIONARY MANAGEMENT =========================

;C HERE    -- addr      returns dictionary ptr
;   DP @ ;
    head HERE,4,'HERE',docolon
        dw _DP,FETCH,EXIT

;C ALLOT   n --         allocate n bytes in dict
;   DP +! ;
    head ALLOT,5,'ALLOT',docolon
        dw _DP,PLUSSTORE,EXIT

;C ,    x --           append cell to dict
;   HERE ! 1 CELLS ALLOT ;
    head COMMA,1,',',docolon
        dw HERE,STORE,lit,1,CELLS,ALLOT,EXIT

;C C,   char --        append char to dict
;   HERE C! 1 CHARS ALLOT ;
    head CCOMMA,2,'C,',docolon
        dw HERE,CSTORE,lit,1,CHARS,ALLOT,EXIT

; The following additional words support the
; "Harvard" model, with separate address spaces
; for Instructions (Code) and Data.  ANSI
; requires DP to manage the Data space, so a
; separate Instruction Dictionary Pointer, IDP,
; is added to manage the Code space.  Also added:
;   I@ IC@ I! IC! I->D D->I   (in the primitives)
;   ITYPE ICOUNT IWORD        (above)
;   IHERE IALLOT I, IC,       (below)
; It should be possible to convert the Harvard
; implementation to a combined-code-and-data
; system, by equating these words to their
; Data-space counterparts.

;C IHERE    -- addr   returns Code dictionary ptr
;   IDP @ ;
    head IHERE,5,'IHERE',docolon
        dw IDP,FETCH,EXIT

;C IALLOT   n --    allocate n bytes in Code dict
;   IDP +! ;
    head IALLOT,6,'IALLOT',docolon
        dw IDP,PLUSSTORE,EXIT

;C I,    x --           append cell to Code dict
;   IHERE I! 1 CELLS IALLOT ;
    head ICOMMA,2,'I,',docolon
        dw IHERE,ISTORE,lit,1,CELLS,IALLOT,EXIT

;C IC,   char --        append char to Code dict
;   IHERE IC! 1 CHARS IALLOT ;
    head ICCOMMA,3,'IC,',docolon
        dw IHERE,ICSTORE,lit,1,CHARS,IALLOT,EXIT

; The following additional words support
; separate Header space.  A Header Dictionary
; pointer, HDP, is added to manage this space.
; Also added:
;   H@ HC@ H! HC! N=     (in the primitives)
;   HHERE HALLOT H, HC,  (below)

;C HHERE    -- addr   returns Head dictionary ptr
;   HDP @ ;
    head HHERE,5,'HHERE',docolon
        dw HDP,FETCH,EXIT

;C HALLOT   n --    allocate n bytes in Head dict
;   HDP +! ;
    head HALLOT,6,'HALLOT',docolon
        dw HDP,PLUSSTORE,EXIT

;C H,    x --           append cell to Head dict
;   HHERE H! 1 CELLS HALLOT ;
    head HCOMMA,2,'H,',docolon
        dw HHERE,HSTORE,lit,1,CELLS,HALLOT,EXIT

;C HC,   char --        append char to Head dict
;   HHERE HC! 1 CHARS HALLOT ;
    head HCCOMMA,3,'HC,',docolon
        dw HHERE,HCSTORE,lit,1,CHARS,HALLOT,EXIT

; INTERPRETER ===================================
; Note that NFA>LFA, NFA>CFA, IMMED?, and FIND
; are dependent on the structure of the Forth
; header.  This may be common across many CPUs,
; or it may be different.

;C SOURCE   -- adr n    current input buffer
;   'SOURCE 2@ ;        length is at lower adrs
    head SOURCE,6,'SOURCE',docolon
        DW TICKSOURCE,TWOFETCH,EXIT

;X /STRING  a u n -- a+n u-n   trim string
;   ROT OVER + ROT ROT - ;
    head SLASHSTRING,7,'/STRING',docolon
        DW ROT,OVER,PLUS,ROT,ROT,MINUS,EXIT

;Z >counted  src n dst --     copy to counted str
;   2DUP C! CHAR+ SWAP CMOVE ;
    head TOCOUNTED,8,'>COUNTED',docolon
        DW TWODUP,CSTORE,CHARPLUS,SWAP,CMOVE,EXIT

;C WORD   char -- c-addr n   word delim'd by char
;   DUP  SOURCE >IN @ /STRING   -- c c adr n
;   DUP >R   ROT SKIP           -- c adr' n'
;   OVER >R  ROT SCAN           -- adr" n"
;   DUP IF CHAR- THEN        skip trailing delim.
;   R> R> ROT -   >IN +!        update >IN offset
;   TUCK -                      -- adr' N
;   HERE >counted               --
;   HERE                        -- a
;   BL OVER COUNT + C! ;    append trailing blank
    head WORDD,4,'WORD',docolon
        DW DUPE,SOURCE,TOIN,FETCH,SLASHSTRING
        DW DUPE,TOR,ROT,SKIP
        DW OVER,TOR,ROT,SCAN
        DW DUPE,qbranch,WORD1,ONEMINUS  ; char-
WORD1:  DW RFROM,RFROM,ROT,MINUS,TOIN,PLUSSTORE
        DW TUCK,MINUS
        DW HERE,TOCOUNTED,HERE
        DW BLANK,OVER,COUNT,PLUS,CSTORE,EXIT

;Z NFA>LFA   nfa -- lfa    name adr -> link field
;   3 - ;
    head NFATOLFA,7,'NFA>LFA',docolon
        DW LIT,3,MINUS,EXIT

;Z NFA>CFA   nfa -- cfa    name adr -> code field
;   HCOUNT 7F AND + H@ ;   mask off 'smudge' bit
; Separate headers model: cfa stored after name
    head NFATOCFA,7,'NFA>CFA',docolon
        DW HCOUNT
        DW LIT,07FH,ANDD,PLUS,HFETCH,EXIT

;Z IMMED?    nfa -- f      fetch immediate flag
;   1- HC@ ;                     nonzero if immed
    head IMMEDQ,6,'IMMED?',docolon
        DW ONEMINUS,HCFETCH,EXIT

;C FIND   c-addr -- c-addr 0   if not found
;C                  xt  1      if immediate
;C                  xt -1      if "normal"
;   LATEST @ BEGIN             -- a nfa
;       2DUP OVER C@ CHAR+     -- a nfa a nfa n+1
;       N=                     -- a nfa f
;       DUP IF
;           DROP
;           NFA>LFA H@ DUP     -- a link link
;       THEN
;   0= UNTIL                   -- a nfa  OR  a 0
;   DUP IF
;       NIP DUP NFA>CFA        -- nfa xt
;       SWAP IMMED?            -- xt iflag
;       0= 1 OR                -- xt 1/-1
;   THEN ;
    head FIND,4,'FIND',docolon
        DW LATEST,FETCH
FIND1:  DW TWODUP,OVER,CFETCH,CHARPLUS
        DW NEQUAL,DUPE,qbranch,FIND2
        DW DROP,NFATOLFA,HFETCH,DUPE
FIND2:  DW ZEROEQUAL,qbranch,FIND1
        DW DUPE,qbranch,FIND3
        DW NIP,DUPE,NFATOCFA
        DW SWAP,IMMEDQ,ZEROEQUAL,LIT,1,ORR
FIND3:  DW EXIT

;C LITERAL  x --        append numeric literal
;   STATE @ IF ['] LIT ,XT I, THEN ; IMMEDIATE
; This tests STATE so that it can also be used
; interpretively.  (ANSI doesn't require this.)
    immed LITERAL,7,'LITERAL',docolon
        DW STATE,FETCH,qbranch,LITER1
        DW LIT,LIT,COMMAXT,ICOMMA
LITER1: DW EXIT

;Z DIGIT?   c -- n -1   if c is a valid digit
;Z            -- x  0   otherwise
;   [ HEX ] DUP 39 > 100 AND +     silly looking
;   DUP 140 > 107 AND -   30 -     but it works!
;   DUP BASE @ U< ;
    head DIGITQ,6,'DIGIT?',docolon
        DW DUPE,LIT,39H,GREATER,LIT,100H,ANDD,PLUS
        DW DUPE,LIT,140H,GREATER,LIT,107H,ANDD
        DW MINUS,LIT,30H,MINUS
        DW DUPE,BASE,FETCH,ULESS,EXIT

;Z ?SIGN   adr n -- adr' n' f  get optional sign
;Z  advance adr/n if sign; return NZ if negative
;   OVER C@                 -- adr n c
;   2C - DUP ABS 1 = AND    -- +=-1, -=+1, else 0
;   DUP IF 1+               -- +=0, -=+2
;       >R 1 /STRING R>     -- adr' n' f
;   THEN ;
    head QSIGN,5,'?SIGN',docolon
        DW OVER,CFETCH,LIT,2CH,MINUS,DUPE,ABBS
        DW LIT,1,EQUAL,ANDD,DUPE,qbranch,QSIGN1
        DW ONEPLUS,TOR,LIT,1,SLASHSTRING,RFROM
QSIGN1: DW EXIT

;C >NUMBER  ud adr u -- ud' adr' u'
;C                      convert string to number
;   BEGIN
;   DUP WHILE
;       OVER C@ DIGIT?
;       0= IF DROP EXIT THEN
;       >R 2SWAP BASE @ UD*
;       R> M+ 2SWAP
;       1 /STRING
;   REPEAT ;
    head TONUMBER,7,'>NUMBER',docolon
TONUM1: DW DUPE,qbranch,TONUM3
        DW OVER,CFETCH,DIGITQ
        DW ZEROEQUAL,qbranch,TONUM2,DROP,EXIT
TONUM2: DW TOR,TWOSWAP,BASE,FETCH,UDSTAR
        DW RFROM,MPLUS,TWOSWAP
        DW LIT,1,SLASHSTRING,branch,TONUM1
TONUM3: DW EXIT

;Z ?NUMBER  c-addr -- n -1      string->number
;Z                 -- c-addr 0  if convert error
;   DUP  0 0 ROT COUNT      -- ca ud adr n
;   ?SIGN >R  >NUMBER       -- ca ud adr' n'
;   IF   R> 2DROP 2DROP 0   -- ca 0   (error)
;   ELSE 2DROP NIP R>
;       IF NEGATE THEN  -1  -- n -1   (ok)
;   THEN ;
    head QNUMBER,7,'?NUMBER',docolon
        DW DUPE,LIT,0,DUPE,ROT,COUNT
        DW QSIGN,TOR,TONUMBER,qbranch,QNUM1
        DW RFROM,TWODROP,TWODROP,LIT,0
        DW branch,QNUM3
QNUM1:  DW TWODROP,NIP,RFROM,qbranch,QNUM2,NEGATE
QNUM2:  DW LIT,-1
QNUM3:  DW EXIT

;Z INTERPRET    i*x c-addr u -- j*x
;Z                      interpret given buffer
; This is a common factor of EVALUATE and QUIT.
; ref. dpANS-6, 3.4 The Forth Text Interpreter
;   'SOURCE 2!  0 >IN !
;   BEGIN
;   BL WORD DUP C@ WHILE        -- textadr
;       FIND                    -- a 0/1/-1
;       ?DUP IF                 -- xt 1/-1
;           1+ STATE @ 0= OR    immed or interp?
;           IF EXECUTE ELSE ,XT THEN
;       ELSE                    -- textadr
;           ?NUMBER
;           IF POSTPONE LITERAL     converted ok
;           ELSE COUNT TYPE 3F EMIT CR ABORT  err
;           THEN
;       THEN
;   REPEAT DROP ;
    head INTERPRET,9,'INTERPRET',docolon
        DW TICKSOURCE,TWOSTORE,LIT,0,TOIN,STORE
INTER1: DW BLANK,WORDD,DUPE,CFETCH,qbranch,INTER9
        DW FIND,QDUP,qbranch,INTER4
        DW ONEPLUS,STATE,FETCH,ZEROEQUAL,ORR
        DW qbranch,INTER2
        DW EXECUTE,branch,INTER3
INTER2: DW COMMAXT
INTER3: DW branch,INTER8
INTER4: DW QNUMBER,qbranch,INTER5
        DW LITERAL,branch,INTER6
INTER5: DW COUNT,TYP,LIT,3FH,EMIT,CR,ABORT
INTER6:
INTER8: DW branch,INTER1
INTER9: DW DROP,EXIT

;C EVALUATE  i*x c-addr u -- j*x  interprt string
;   'SOURCE 2@ >R >R  >IN @ >R
;   INTERPRET
;   R> >IN !  R> R> 'SOURCE 2! ;
    head EVALUATE,8,'EVALUATE',docolon
        DW TICKSOURCE,TWOFETCH,TOR,TOR
        DW TOIN,FETCH,TOR,INTERPRET
        DW RFROM,TOIN,STORE,RFROM,RFROM
        DW TICKSOURCE,TWOSTORE,EXIT

;C QUIT     --    R: i*x --    interpret from kbd
;   L0 LP !  R0 RP!   0 STATE !
;   BEGIN
;       TIB DUP TIBSIZE ACCEPT  SPACE
;       INTERPRET
;       STATE @ 0= IF CR ." OK" THEN
;   AGAIN ;
    head QUIT,4,'QUIT',docolon
        DW L0,LP,STORE
        DW R0,RPSTORE,LIT,0,STATE,STORE
QUIT1:  DW TIB,DUPE,TIBSIZE,ACCEPT,SPACE
        DW INTERPRET
        DW STATE,FETCH,ZEROEQUAL,qbranch,QUIT2
        DW CR,XISQUOTE
        DB 3,'ok '
        DW ITYPE
QUIT2:  DW branch,QUIT1

;C ABORT    i*x --   R: j*x --   clear stk & QUIT
;   S0 SP!  QUIT ;
    head ABORT,5,'ABORT',docolon
        DW S0,SPSTORE,QUIT   ; QUIT never returns

;Z ?ABORT   f c-addr u --      abort & print msg
;   ROT IF ITYPE ABORT THEN 2DROP ;
    head QABORT,6,'?ABORT',docolon
        DW ROT,qbranch,QABO1,ITYPE,ABORT
QABO1:  DW TWODROP,EXIT

;C ABORT"  i*x 0  -- i*x   R: j*x -- j*x  x1=0
;C         i*x x1 --       R: j*x --      x1<>0
;   POSTPONE IS" POSTPONE ?ABORT ; IMMEDIATE
    immed ABORTQUOTE,6,'ABORT"',docolon
        DW ISQUOTE
        DW LIT,QABORT,COMMAXT
        DW EXIT

;C '    -- xt           find word in dictionary
;   BL WORD FIND
;   0= ABORT" ?" ;
    head TICK,1,27h,docolon
        DW BLANK,WORDD,FIND,ZEROEQUAL,XISQUOTE
        DB 1,'?'
        DW QABORT,EXIT

;C CHAR   -- char           parse ASCII character
;   BL WORD 1+ C@ ;
    head CHAR,4,'CHAR',docolon
        DW BLANK,WORDD,ONEPLUS,CFETCH,EXIT

;C [CHAR]   --          compile character literal
;   CHAR  ['] LIT ,XT  I, ; IMMEDIATE
    immed BRACCHAR,6,'[CHAR]',docolon
        DW CHAR
        DW LIT,LIT,COMMAXT
        DW ICOMMA,EXIT

;C (    --                     skip input until )
;   [ HEX ] 29 WORD DROP ; IMMEDIATE
    immed PAREN,1,'(',docolon
        DW LIT,29H,WORDD,DROP,EXIT

; COMPILER ======================================

;C CREATE   --      create an empty definition
;   LATEST @ H, 0 HC,         link & immed field
;   HHERE LATEST !            new "latest" link
;   BL HWORD HC@ 1+ HALLOT    name field
;   IHERE H,                  store cfa in header
;   docreate ,CF              code field
;   HERE I, ;           store data adr (Harvard)
; Harvard model, separate Code and Data spaces.
; Separate headers model.
    head CREATE,6,'CREATE',docolon
        DW LATEST,FETCH,HCOMMA,LIT,0,HCCOMMA
        DW HHERE,LATEST,STORE
        DW BLANK,HWORD,HCFETCH,ONEPLUS,HALLOT
        DW IHERE,HCOMMA
        DW LIT,docreate,COMMACF
        DW HERE,ICOMMA,EXIT
        
;Z (DOES>)  --      run-time action of DOES>
;   R>              adrs of headless DOES> def'n
;   LATEST @ NFA>CFA    code field to fix up
;   !CF ;
    head XDOES,7,'(DOES>)',docolon
        DW RFROM,LATEST,FETCH,NFATOCFA,STORECF
        DW EXIT

;C DOES>    --      change action of latest def'n
;   COMPILE (DOES>)
;   dodoes ,CALL ; IMMEDIATE
    immed DOES,5,'DOES>',docolon
        DW LIT,XDOES,COMMAXT
        DW LIT,dodoes,COMMACALL,EXIT

;C RECURSE  --      recurse current definition
;   LATEST @ NFA>CFA ,XT ; IMMEDIATE
    immed RECURSE,7,'RECURSE',docolon
        DW LATEST,FETCH,NFATOCFA,COMMAXT,EXIT

;C [        --      enter interpretive state
;   0 STATE ! ; IMMEDIATE
    immed LEFTBRACKET,1,'[',docolon
        DW LIT,0,STATE,STORE,EXIT

;C ]        --      enter compiling state
;   -1 STATE ! ;
    head RIGHTBRACKET,1,']',docolon
        DW LIT,-1,STATE,STORE,EXIT

;Z HIDE     --      "hide" latest definition
;   LATEST @ DUP HC@ 80 OR SWAP HC! ;
    head HIDE,4,'HIDE',docolon
        DW LATEST,FETCH,DUPE,HCFETCH,LIT,80H,ORR
        DW SWAP,HCSTORE,EXIT

;Z REVEAL   --      "reveal" latest definition
;   LATEST @ DUP HC@ 7F AND SWAP HC! ;
    head REVEAL,6,'REVEAL',docolon
        DW LATEST,FETCH,DUPE,HCFETCH,LIT,7FH,ANDD
        DW SWAP,HCSTORE,EXIT

;C IMMEDIATE   --   make last def'n immediate
;   1 LATEST @ 1- HC! ;   set immediate flag
    head IMMEDIATE,9,'IMMEDIATE',docolon
        DW LIT,1,LATEST,FETCH,ONEMINUS,HCSTORE
        DW EXIT

;C :        --      begin a colon definition
;   CREATE HIDE ] !COLON ;
    head COLON,1,':',docolon
        DW CREATE,HIDE,RIGHTBRACKET,STORCOLON
        DW EXIT

;C ;
;   REVEAL  ,EXIT
;   POSTPONE [  ; IMMEDIATE
    immed SEMICOLON,1,';',docolon
        DW REVEAL,CEXIT
        DW LEFTBRACKET,EXIT

;C [']  --         find word & compile as literal
;   '  ['] LIT ,XT  I, ; IMMEDIATE
; When encountered in a colon definition, the
; phrase  ['] xxx  will cause   LIT,xxt  to be
; compiled into the colon definition (where
; (where xxt is the execution token of word xxx).
; When the colon definition executes, xxt will
; be put on the stack.  (All xt's are one cell.)
    immed BRACTICK,3,<5bh,27h,5dh>,docolon
        DW TICK               ; get xt of 'xxx'
        DW LIT,LIT,COMMAXT    ; append LIT action
        DW ICOMMA,EXIT        ; append xt literal

;C POSTPONE  --   postpone compile action of word
;   BL WORD FIND
;   DUP 0= ABORT" ?"
;   0< IF   -- xt  non immed: add code to current
;                  def'n to compile xt later.
;       ['] LIT ,XT  I,     add "LIT,xt,COMMAXT"
;       ['] ,XT ,XT         to current definition
;   ELSE  ,XT      immed: compile into cur. def'n
;   THEN ; IMMEDIATE
    immed POSTPONE,8,'POSTPONE',docolon
        DW BLANK,WORDD,FIND,DUPE,ZEROEQUAL,XISQUOTE
        DB 1,'?'
        DW QABORT,ZEROLESS,qbranch,POST1
        DW LIT,LIT,COMMAXT,ICOMMA
        DW LIT,COMMAXT,COMMAXT,branch,POST2
POST1:  DW COMMAXT
POST2:  DW EXIT
               
;Z COMPILE   --   append inline execution token
;   R> DUP CELL+ >R @ ,XT ;
; The phrase ['] xxx ,XT appears so often that
; this word was created to combine the actions
; of LIT and ,XT.  It takes an inline literal
; execution token and appends it to the dict.
;    head COMPILE,7,'COMPILE',docolon
;        DW RFROM,DUP,CELLPLUS,TOR
;        DW FETCH,COMMAXT,EXIT
; N.B.: not used in the current implementation

; CONTROL STRUCTURES ============================

;C IF       -- adrs    conditional forward branch
;   ['] qbranch ,BRANCH  IHERE DUP ,DEST ;
;   IMMEDIATE
    immed IFF,2,'IF',docolon
        DW LIT,qbranch,COMMABRANCH
        DW IHERE,DUPE,COMMADEST,EXIT

;C THEN     adrs --        resolve forward branch
;   IHERE SWAP !DEST ; IMMEDIATE
    immed THEN,4,'THEN',docolon
        DW IHERE,SWAP,STOREDEST,EXIT

;C ELSE     adrs1 -- adrs2    branch for IF..ELSE
;   ['] branch ,BRANCH  IHERE DUP ,DEST
;   SWAP  POSTPONE THEN ; IMMEDIATE
    immed ELSS,4,'ELSE',docolon
        DW LIT,branch,COMMABRANCH
        DW IHERE,DUPE,COMMADEST
        DW SWAP,THEN,EXIT

;C BEGIN    -- adrs        target for bwd. branch
;   IHERE ; IMMEDIATE
    immed BEGIN,5,'BEGIN',docode
        mov ax,OFFSET IHERE
        jmp ax

;C UNTIL    adrs --   conditional backward branch
;   ['] qbranch ,BRANCH  ,DEST ; IMMEDIATE
;   conditional backward branch
    immed UNTIL,5,'UNTIL',docolon
        DW LIT,qbranch,COMMABRANCH
        DW COMMADEST,EXIT

;X AGAIN    adrs --      uncond'l backward branch
;   ['] branch ,BRANCH  ,DEST ; IMMEDIATE
;   unconditional backward branch
    immed AGAIN,5,'AGAIN',docolon
        DW LIT,branch,COMMABRANCH
        DW COMMADEST,EXIT

;C WHILE    adrs1 -- adrs2 adrs1
;                           branch for WHILE loop
;   POSTPONE IF SWAP ; IMMEDIATE
    immed WHILE,5,'WHILE',docolon
        DW IFF,SWAP,EXIT

;C REPEAT   adrs2 adrs1 --     resolve WHILE loop
;   POSTPONE AGAIN POSTPONE THEN ; IMMEDIATE
    immed REPEAT,6,'REPEAT',docolon
        DW AGAIN,THEN,EXIT

;Z >L   x --   L: -- x        move to leave stack
;   CELL LP +!  LP @ ! ;      (L stack grows up)
    head TOL,2,'>L',docolon
        DW CELL,LP,PLUSSTORE,LP,FETCH,STORE,EXIT

;Z L>   -- x   L: x --      move from leave stack
;   LP @ @  CELL NEGATE LP +! ;
    head LFROM,2,'L>',docolon
        DW LP,FETCH,FETCH
        DW CELL,NEGATE,LP,PLUSSTORE,EXIT

;C DO       -- adrs   L: -- 0
;   ['] xdo ,XT   IHERE     target for bwd branch
;   0 >L ; IMMEDIATE           marker for LEAVEs
    immed DO,2,'DO',docolon
        DW LIT,xdo,COMMAXT,IHERE
        DW LIT,0,TOL,EXIT

;Z ENDLOOP   adrs xt --   L: 0 a1 a2 .. aN --
;   ,BRANCH  ,DEST                backward loop
;   BEGIN L> ?DUP WHILE POSTPONE THEN REPEAT ;
;                                 resolve LEAVEs
; This is a common factor of LOOP and +LOOP.
    head ENDLOOP,7,'ENDLOOP',docolon
        DW COMMABRANCH,COMMADEST
LOOP1:  DW LFROM,QDUP,qbranch,LOOP2
        DW THEN,branch,LOOP1
LOOP2:  DW EXIT

;C LOOP    adrs --   L: 0 a1 a2 .. aN --
;   ['] xloop ENDLOOP ;  IMMEDIATE
    immed LOO,4,'LOOP',docolon
        DW LIT,xloop,ENDLOOP,EXIT

;C +LOOP   adrs --   L: 0 a1 a2 .. aN --
;   ['] xplusloop ENDLOOP ;  IMMEDIATE
    immed PLUSLOOP,5,'+LOOP',docolon
        DW LIT,xplusloop,ENDLOOP,EXIT

;C LEAVE    --    L: -- adrs
;   ['] UNLOOP ,XT
;   ['] branch ,BRANCH   IHERE DUP ,DEST  >L
;   ; IMMEDIATE      unconditional forward branch
    immed LEAV,5,'LEAVE',docolon
        DW LIT,unloop,COMMAXT
        DW LIT,branch,COMMABRANCH
        DW IHERE,DUPE,COMMADEST,TOL,EXIT

; OTHER OPERATIONS ==============================

;X WITHIN   n1|u1 n2|u2 n3|u3 -- f   n2<=n1<n3?
;  OVER - >R - R> U< ;          per ANS document
    head WITHIN,6,'WITHIN',docolon
        DW OVER,MINUS,TOR,MINUS,RFROM,ULESS,EXIT

;C MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
;  >R 2DUP SWAP DUP R@ +     -- ... dst src src+n
;  WITHIN IF  R> CMOVE>        src <= dst < src+n
;       ELSE  R> CMOVE  THEN ;          otherwise
    head MOVE,4,'MOVE',docolon
        DW TOR,TWODUP,SWAP,DUPE,RFETCH,PLUS
        DW WITHIN,qbranch,MOVE1
        DW RFROM,CMOVEUP,branch,MOVE2
MOVE1:  DW RFROM,CMOVE
MOVE2:  DW EXIT

;C DEPTH    -- +n        number of items on stack
;   SP@ S0 SWAP - 2/ ;   16-BIT VERSION!
    head DEPTH,5,'DEPTH',docolon
        DW SPFETCH,S0,SWAP,MINUS,TWOSLASH,EXIT

;C ENVIRONMENT?  c-addr u -- false   system query
;                         -- i*x true
;   2DROP 0 ;       the minimal definition!
    head ENVIRONMENTQ,12,'ENVIRONMENT?',docolon
        DW TWODROP,LIT,0,EXIT

; UTILITY WORDS AND STARTUP =====================

;X WORDS    --          list all words in dict.
;   LATEST @ BEGIN
;       DUP HCOUNT 7F AND HTYPE SPACE
;       NFA>LFA H@
;   DUP 0= UNTIL
;   DROP ;
    head WORDS,5,'WORDS',docolon
        DW LATEST,FETCH
WDS1:   DW DUPE,HCOUNT,LIT,07FH,ANDD,HTYPE,SPACE
        DW NFATOLFA,HFETCH
        DW DUPE,ZEROEQUAL,qbranch,WDS1
        DW DROP,EXIT

;X LDUMP  adr n seg --   dump memory
;  ROT ROT OVER + SWAP DO
;    I OVER LC@ .  LOOP DROP ;
    head LDUMP,5,'LDUMP',docolon
        DW ROT,ROT,OVER,PLUS,SWAP,xdo
LDUMP1: DW II,OVER,LCFETCH,DOT,xloop,LDUMP1
        DW DROP,EXIT

;X .S      --           print stack contents
;   SP@ S0 - IF
;       SP@ S0 2 - DO I S@ U. -2 +LOOP
;   THEN ;
    head DOTS,2,'.S',docolon
        DW SPFETCH,S0,MINUS,qbranch,DOTS2
        DW SPFETCH,S0,LIT,2,MINUS,XDO
DOTS1:  DW II,SFETCH,UDOT,LIT,-2,XPLUSLOOP,DOTS1
DOTS2:  DW EXIT

;Z COLD     --      cold start Forth system
;   UINIT U0 #INIT I->D      init user area
;   ." Z80 CamelForth etc."
;   ABORT ;
    head COLD,4,'COLD',docolon
        DW UINIT,U0,NINIT,ITOD
        DW XISQUOTE
        DB 35,'8086 CamelForth v1.0  14 Dec 1996'
        DB 0dh,0ah
        DW ITYPE,ABORT      ; ABORT never returns

