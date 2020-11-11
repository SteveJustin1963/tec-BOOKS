; ===============================================
; CamelForth for the Intel 8086
; (c) 1996 Bradford J. Rodriguez
; Permission is granted to freely copy, modify,
; and distribute this program for personal or
; educational use.  Commercial inquiries should
; be directed to the author at 115 First St.,
; #105, Collingwood, Ontario L9Y 4W3 Canada
;
; CAMEL86D.ASM: CPU and Model Dependencies
;   Source code is for Borland Turbo Assembler.
;   Forth words are documented as follows:
;x   NAME     stack -- stack    description
;   where x=C for ANS Forth Core words, X for ANS
;   Extensions, Z for internal or private words.
;
; Direct-Threaded Forth model for Intel 8086
;   cell size is   16 bits (2 bytes)
;   char size is    8 bits (1 byte)
;   address unit is 8 bits (1 byte), i.e.,
;       addresses are byte-aligned.
; ===============================================

; ALIGNMENT AND PORTABILITY OPERATORS ===========
; Many of these are synonyms for other words,
; and so are defined as CODE words.

;C ALIGN    --                         align HERE
    head ALIGNN,5,'ALIGN',docode
noop:   next

;C ALIGNED  addr -- a-addr       align given addr
    head ALIGNED,7,'ALIGNED',docode
        mov ax,OFFSET noop
        jmp ax

;Z CELL     -- n                 size of one cell
    head CELL,4,'CELL',docon
        dw 2

;C CELL+    a-addr1 -- a-addr2      add cell size
;   2 + ;
    head CELLPLUS,5,'CELL+',docode
        inc bx
        inc bx
        next

;C CELLS    n1 -- n2            cells->adrs units
    head CELLS,5,'CELLS',docode
        mov ax,OFFSET twostar
        jmp ax

;C CHAR+    c-addr1 -- c-addr2   add char size
    head CHARPLUS,5,'CHAR+',docode
        mov ax,OFFSET oneplus
        jmp ax

;C CHARS    n1 -- n2            chars->adrs units
    head CHARS,5,'CHARS',docode
        mov ax,OFFSET noop
        jmp ax

;C >BODY    xt -- a-addr      adrs of CREATE data
;   3 + I@ ;                   8086 (3 byte CALL)
    head TOBODY,5,'>BODY',docolon
        DW LIT,3,PLUS,IFETCH,EXIT

;X COMPILE,  xt --         append execution token
; I called this word ,XT before I discovered that
; it is defined in the ANSI standard as COMPILE,.
; On a DTC Forth this simply appends xt (like , )
; but on an STC Forth this must append 'CALL xt'.
    head COMMAXT,8,'COMPILE,',docode
        mov ax,OFFSET ICOMMA
        jmp ax

;Z !CF    adrs cfa --   set code action of a word
;   0E9 OVER IC!        store 'JMP adrs' instr
;   TUCK 3 + -          compute relative offset
;   SWAP 1+ I! ;        8086 VERSION
; Depending on the implementation this could
; append CALL adrs or JUMP adrs.
    head STORECF,3,'!CF',docolon
        DW LIT,0E9H,OVER,ICSTORE
        DW TUCK,LIT,3,PLUS,MINUS
        DW SWAP,ONEPLUS,ISTORE,EXIT

;Z ,CF    adrs --       append a code field
;   IHERE !CF 3 IALLOT ;  8086 VERSION (3 bytes)
    head COMMACF,3,',CF',docolon
        DW IHERE,STORECF,LIT,3,IALLOT,EXIT

;Z ,CALL  adrs --       append a subroutine CALL
    head COMMACALL,5,',CALL',docolon
        DW IHERE
        DW LIT,0E8H,OVER,ICSTORE
        DW TUCK,LIT,3,PLUS,MINUS
        DW SWAP,ONEPLUS,ISTORE
        DW LIT,3,IALLOT,EXIT

;Z !COLON   --      change code field to docolon
;   -5 IALLOT docolon-adrs ,CF ;
; This should be used immediately after CREATE.
; This is made a distinct word, because on an STC
; Forth, colon definitions have no code field.
    head STORCOLON,6,'!COLON',docolon
        DW LIT,-5,IALLOT
        DW LIT,docolon,COMMACF,EXIT

;Z ,EXIT    --      append hi-level EXIT action
;   ['] EXIT ,XT ;
; This is made a distinct word, because on an STC
; Forth, it appends a RET instruction, not an xt.
    head CEXIT,5,',EXIT',docolon
        DW LIT,EXIT,COMMAXT,EXIT

; CONTROL STRUCTURES ============================
; These words allow Forth control structure words
; to be defined portably.

;Z ,BRANCH   xt --    append a branch instruction
; xt is the branch operator to use, e.g. qbranch
; or (loop).  It does NOT append the destination
; address.  On the 8086 this is equivalent to ,XT
    head COMMABRANCH,7,',BRANCH',docode
        mov ax,OFFSET COMMAXT
        jmp ax

;Z ,DEST   dest --        append a branch address
; This appends the given destination address to
; the branch instruction. On the 8086 this is 'I,'
; ...other CPUs may use relative addressing.
    head COMMADEST,5,',DEST',docode
        mov ax,OFFSET ICOMMA
        jmp ax

;Z !DEST   dest adrs --    change a branch dest'n
; Changes the destination address found at 'adrs'
; to the given 'dest'.  On the 8086 this is 'I!'
; ...other CPUs may need relative addressing.
    head STOREDEST,5,'!DEST',docode
        mov ax,OFFSET ISTORE
        jmp ax

; HEADER STRUCTURE ==============================
; The structure of the Forth dictionary headers
; (name, link, immediate flag, and "smudge" bit)
; does not necessarily differ across CPUs.  This
; structure is not easily factored into distinct
; "portable" words; instead, it is implicit in
; the definitions of FIND and CREATE, and also in
; NFA>LFA, NFA>CFA, IMMED?, IMMEDIATE, HIDE, and
; REVEAL.  These words must be (substantially)
; rewritten if either the header structure or its
; inherent assumptions are changed.

