; ===============================================
; CamelForth for the Intel 8086
; (c) 1996 Bradford J. Rodriguez
; Permission is granted to freely copy, modify,
; and distribute this program for personal or
; educational use.  Commercial inquiries should
; be directed to the author at 115 First St.,
; #105, Collingwood, Ontario L9Y 4W3 Canada
;
; CAMEL86.ASM: Code Primitives
;   Source code is for Borland Turbo Assembler.
;   Forth words are documented as follows:
;x   NAME     stack -- stack    description
;   where x=C for ANS Forth Core words, X for ANS
;   Extensions, Z for internal or private words.
;
; Direct-Threaded Forth model for Intel 8086
; 16 bit cell, 8 bit char, 8 bit (byte) adrs unit
; Separate Code, Data, Stack, and Header spaces
;
; CS:SI = IP  Forth Interpreter Pointer
; DS:DI = UP  User Pointer
; SS:SP = PSP  Parameter Stack Pointer
; SS:BP = RSP  Return Stack Pointer
;    AX = W register, scratch
;    BX = TOS (top Parameter Stack item)
;    CX = loop index
;    DX = scratch
; CS:     Code space
; DS:     Data space
; SS:     Stack space
; ES:     Header space
; ===============================================
; REVISION HISTORY
; v1.0  alpha test version              24 Dec 96
; ===============================================

; SEGMENT ALLOCATION ============================
        DOSSEG

_Stack  SEGMENT PARA STACK 'STACK'
Stack0: DB 200h DUP (?) ; 100h data, 100h return
_Stack  ENDS

_Data   SEGMENT PARA 'DATA'
User0:  DB 100h DUP (?)
_Data   ENDS

_Header  SEGMENT PARA 'EXTRA'
_Header  ENDS

_Code   SEGMENT PARA 'CODE'

        ASSUME cs:_Code,ds:_Data,ss:_Stack,es:_Header

; MACROS ========================================

link    =       0
; docode  EQU	0

head    MACRO   label,length,name,action
label:
_Header   SEGMENT
        DW link
        DB 0
link    = $
        DB length,name
        DW label
_Header  ENDS
        IFDIFI <action>,<docode>
        JMP action
        ENDIF
        ENDM

immed   MACRO   label,length,name,action
label:
_Header   SEGMENT
        DW link
        DB 1
link    = $
        DB length,name
        DW label
_Header  ENDS
        IFDIFI <action>,<docode>
        JMP action
        ENDIF
        ENDM

; INTERPRETER LOGIC =============================

NEXT    MACRO
        segcs
        lodsw
        jmp ax
        ENDM

; PROGRAM ENTRY/INITIALIZATION ==================
; MS-DOS entry point
; On entry to the program, MS-DOS will have set
; CS to the code segment, and SS:SP to the end
; of the stack segment.
reset:  mov ax,_Data    ; set DS, ES segments
        mov ds,ax
        mov ax,_Header
        mov es,ax
        mov bp,sp       ; BP is 100h below SP
        sub bp,100h
        mov di,OFFSET User0  ; initial UP
        cld             ; direction=increment
        mov ax,OFFSET cold   ; start Forth
        jmp ax

; MS-DOS TERMINAL I/O ===========================
; Input and output can be redirected.

;C EMIT     c --    output character to console
    head EMIT,4,'EMIT',docode
        mov dl,bl
        mov ah,2
        int 21h         ; write stdout
        pop bx          ; get new TOS
        next

;C KEY      -- c      get character from keyboard
    head KEY,3,'KEY',docode
        push bx
        mov ah,8        ; read stdin without echo
        int 21h
        cmp al,0ah      ; filter line feeds
        jnz key1        ;  for input redirection
        mov al,20h      ;
key1:   mov bl,al
        xor bh,bh
        next

;X KEY?     -- f    return true if char waiting
    head querykey,4,'KEY?',docode
        push bx
        mov ah,0Bh
        int 21h
        mov bl,al       ; 0=no char, -1=char
        mov bh,al
        next

;X BYE     i*x --    return to MS-DOS
    head bye,3,'BYE',docode
        mov al,bl       ; use TOS as return code
        mov ah,4ch
        int 21h

; INTERPRETER LOGIC =============================

;C EXIT     --            exit a colon definition
    head EXIT,4,'EXIT',docode
        xchg bp,sp
        pop si          ; pop old IP from ret.stk
        xchg bp,sp
        next

;Z lit      -- x    fetch inline literal to stack
; This is the primtive compiled by LITERAL.
    head lit,3,'lit',docode
        push bx         ; push old TOS
        mov bx,cs:[si]  ; fetch cell at IP to TOS
        inc si          ; and advance IP
        inc si
        next

;C EXECUTE   i*x xt -- j*x   execute Forth word
;C                           at 'xt'
    head EXECUTE,7,'EXECUTE',docode
        mov ax,bx       ; address of word -> AX
        pop bx          ; pop new TOS
        jmp ax          ; go do Forth word

; DEFINING WORDS ================================

;C VARIABLE --            define a Forth VARIABLE
;   CREATE CELL ALLOT ;
; Action of ROMable variable is that of CONSTANT;
; the constant holds the RAM address.
    head VARIABLE,8,'VARIABLE',docolon
         DW CREATE,CELL,ALLOT,EXIT

;C CONSTANT --            define a Forth constant
;   CREATE CELL NEGATE IALLOT  I,   Harvard model
;   DOES> (machine code fragment)
; Note that the constant is stored in Code space.
    head CONSTANT,8,'CONSTANT',docolon
        DW CREATE,CELL,NEGATE,IALLOT,ICOMMA,XDOES

; DOCON, code action of CONSTANT,
; entered by JMP DOCON with AX=Code Field Adrs
docon:  ; -- x
dovar:  ; -- a-addr    exec action of Harvard var
docreate: ; -- a-addr  exec action of Harv.CREATE
        add ax,3        ; param.field address
        push bx         ; push old TOS
        mov bx,ax       ; fetch contents of
        mov bx,cs:[bx]  ;   parameter field
        next

;Z USER     n --        define user variable 'n'
;   CONSTANT DOES> (machine code fragment)
    head USER,4,'USER',docolon
        DW CONSTANT,XDOES

; DOUSER, code action of USER,
; entered by CALL DOUSER
douser:  ; -- a-addr
        add ax,3        ; param.field address
        push bx         ; push old TOS
        mov bx,ax       ; fetch contents of
        mov bx,cs:[bx]  ;   parameter field
        add bx,di       ; add UP
        next

; DOCREATE's action is for a table in RAM.
; DOROM is the code action for a table in ROM;
; it returns the address of the parameter field.
; Entered by CALL DOROM
dorom:  add ax,3        ; param.field address
        push bx         ; push old TOS
        mov bx,ax       ; return PFA in TOS
        next

; DODOES, code action of DOES> clause
; entered by  AX-> JMP fragment
;                  parameter field
;                       ...
;        fragment: CALL DODOES
;                  high-level thread
; Enters high-level thread with address of
; parameter field on top of stack.
; (internal code fragment, not a Forth word)
dodoes: ; -- a-addr
        xchg bp,sp      ; push old IP on ret stk
        push si
        xchg bp,sp
        pop si          ; adrs of thread -> IP
        push bx         ; push old TOS
        add ax,3        ; adrs of param.field
        mov bx,ax       ; return Data adrs in TOS
        mov bx,cs:[bx]
        next

; Turbo Assembler quirk: DOCOLON must appear
; after CONSTANT, VARIABLE, etc., to force use
; of a long (3-byte) jump to DOCOLON.

; ENTER, a.k.a. DOCOLON, entered by JMP ENTER
; to enter a new high-level thread (colon def'n.)
; (internal code fragment, not a Forth word)
; N.B.: DOCOLON must be defined before any
; appearance of 'docolon' in a 'word' macro!
docolon:                ; (alternate name)
doenter: xchg bp,sp     ; push old IP on ret stack
        push si
        xchg bp,sp
        add ax,3        ; param field adrs -> IP
        mov si,ax
        next

; STACK OPERATIONS ==============================

;C DUP      x -- x x      duplicate top of stack
    head DUPE,3,'DUP',docode
pushtos: push bx
        next

;C ?DUP     x -- 0 | x x    DUP if nonzero
    head QDUP,4,'?DUP',docode
        or bx,bx
        jnz pushtos
        next

;C DROP     x --          drop top of stack
    head DROP,4,'DROP',docode
poptos: pop bx
        next

;C SWAP     x1 x2 -- x2 x1    swap top two items
    head SWAP,4,'SWAP',docode
        xchg bp,sp
        xchg bx,[bp]
        xchg bp,sp
        next

;C OVER    x1 x2 -- x1 x2 x1   per stack diagram
    head OVER,4,'OVER',docode
        push bx
        xchg bp,sp
        mov bx,[bp+2]
        xchg bp,sp
        next

;C ROT    x1 x2 x3 -- x2 x3 x1  per stack diagram
    head ROT,3,'ROT',docode
        pop ax
        pop dx
        push ax
        push bx
        mov bx,dx
        next

;X NIP    x1 x2 -- x2           per stack diagram
    head NIP,3,'NIP',docode
        inc sp
        inc sp
        next

;C >R    x --   R: -- x   push to return stack
    head TOR,2,'>R',docode
        xchg bp,sp
        push bx
        xchg bp,sp
        pop bx
        next

;C R>    -- x    R: x --   pop from return stack
    head RFROM,2,'R>',docode
        push bx
        xchg bp,sp
        pop bx
        xchg bp,sp
        next

;C R@    -- x     R: x -- x   fetch from rtn stk
    head RFETCH,2,'R@',docode
        push bx
        mov bx,[bp]
        next

;Z SP@  -- a-addr       get data stack pointer
    head SPFETCH,3,'SP@',docode
        push bx
        mov bx,sp
        next

;Z SP!  a-addr --       set data stack pointer
    head SPSTORE,3,'SP!',docode
        mov sp,bx
        pop bx
        next

;Z RP@  -- a-addr       get return stack pointer
    head RPFETCH,3,'RP@',docode
        push bx
        mov bx,bp
        next

;Z RP!  a-addr --       set return stack pointer
    head RPSTORE,3,'RP!',docode
        mov bp,bx
        pop bx
        next

;X TUCK   x1 x2 -- x2 x1 x2     per stack diagram
    head TUCK,4,'TUCK',docolon
        DW SWAP,OVER,EXIT

; MEMORY AND I/O OPERATIONS =====================

; DATA SPACE OPERATORS

;C !        x a-addr --   store cell in memory
    head STORE,1,'!',docode
        pop word ptr [bx]
        pop bx
        next

;C C!      char c-addr --    store char in memory
    head CSTORE,2,'C!',docode
        pop ax
        mov [bx],al
        pop bx
        next

;C @       a-addr -- x   fetch cell from memory
    head FETCH,1,'@',docode
        mov bx,[bx]
        next

;C C@     c-addr -- char   fetch char from memory
    head CFETCH,2,'C@',docode
        mov bl,[bx]
        xor bh,bh
        next

; INSTRUCTION SPACE OPERATORS (Harvard model)

;Z I!       x a-addr --    store cell in Code mem
    head ISTORE,2,'I!',docode
        pop cs: word ptr [bx]
        pop bx
        next

;Z IC!      c c-addr --    store char in Code mem
    head ICSTORE,3,'IC!',docode
        pop ax
        mov cs:[bx], al
        pop bx
        next

;Z I@       a-addr -- x  fetch cell from Code mem
    head IFETCH,2,'I@',docode
        mov bx,cs:[bx]
        next

;Z IC@      a-addr -- x  fetch char from Code mem
    head ICFETCH,3,'IC@',docode
        mov bl,cs:[bx]
        xor bh,bh
        next

; HEADER SPACE OPERATORS (Separate Headers model)

;Z H!       x a-addr --    store cell in Head mem
    head HSTORE,2,'H!',docode
        pop es: word ptr [bx]
        pop bx
        next

;Z HC!      c c-addr --    store char in Head mem
    head HCSTORE,3,'HC!',docode
        pop ax
        mov es:[bx], al
        pop bx
        next

;Z H@       a-addr -- x  fetch cell from Head mem
    head HFETCH,2,'H@',docode
        mov bx,es:[bx]
        next

;Z HC@      a-addr -- x  fetch char from Head mem
    head HCFETCH,3,'HC@',docode
        mov bl,es:[bx]
        xor bh,bh
        next

; STACK SPACE OPERATIONS (Separate Stack model)

;Z S!       x a-addr --    store cell in Head mem
    head SSTORE,2,'S!',docode
        pop ss: word ptr [bx]
        pop bx
        next

;Z S@       a-addr -- x  fetch cell from Stack
    head SFETCH,2,'S@',docode
        mov bx,ss:[bx]
        next
        
; I/O OPERATIONS

;Z PC!     char c-addr --    output char to port
    head PCSTORE,3,'PC!',docode
        mov dx,bx
        pop ax
        out dx,al
        pop bx
        next

;Z PC@     c-addr -- char   input char from port
    head PCFETCH,3,'PC@',docode
        mov dx,bx
        in al,dx
        mov bl,al
        xor bh,bh
        next

; EXTENDED MEMORY OPERATORS (OPTIONAL) ==========

;Z L!       x a-addr seg --  store cell in memory
    head LSTORE,2,'L!',docode
        mov dx,ds
        mov ds,bx
        pop bx
        pop word ptr [bx]
        pop bx
        mov ds,dx
        next

;Z LC!      c c-addr seg --  store char in memory
    head LCSTORE,3,'LC!',docode
        mov dx,ds
        mov ds,bx
        pop bx
        pop ax
        mov [bx],al
        pop bx
        mov ds,dx
        next

;Z L@    a-addr seg -- x   fetch cell from memory
    head LFETCH,2,'L@',docode
        mov dx,ds
        mov ds,bx
        pop bx
        mov bx,[bx]
        mov ds,dx
        next

;Z LC@   c-addr seg -- c   fetch char from memory
    head LCFETCH,3,'LC@',docode
        mov dx,ds
        mov ds,bx
        pop bx
        mov bl,[bx]
        xor bh,bh
        mov ds,dx
        next

;Z CS   -- seg          return Code segment
    head CSEG,2,'CS',docode
        push bx
        mov bx,cs
        next

;Z DS   -- seg          return Data segment
    head DSEG,2,'DS',docode
        push bx
        mov bx,ds
        next

;Z ES   -- seg          return Extra segment
    head ESEG,2,'ES',docode
        push bx
        mov bx,es
        next

;Z SS   -- seg          return Stack segment
    head SSEG,2,'SS',docode
        push bx
        mov bx,ss
        next

; ARITHMETIC AND LOGICAL OPERATIONS =============

;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    head PLUS,1,'+',docode
        pop ax
        add bx,ax
        next

;X M+       d n -- d         add single to double
    head MPLUS,2,'M+',docode
        pop dx
        pop ax
        add ax,bx
        adc dx,0
        push ax
        mov bx,dx
        next

;C -      n1/u1 n2/u2 -- n3/u3    subtract n1-n2
    head MINUS,1,'-',docode
        pop ax
        sub ax,bx
        mov bx,ax
        next

;C AND    x1 x2 -- x3            logical AND
    head ANDD,3,'AND',docode
        pop ax
        and bx,ax
        next

;C OR     x1 x2 -- x3           logical OR
    head ORR,2,'OR',docode
        pop ax
        or bx,ax
        next

;C XOR    x1 x2 -- x3            logical XOR
    head XORR,3,'XOR',docode
        pop ax
        xor bx,ax
        next

;C INVERT   x1 -- x2            bitwise inversion
    head INVERT,6,'INVERT',docode
        not bx
        next

;C NEGATE   x1 -- x2            two's complement
    head NEGATE,6,'NEGATE',docode
        neg bx
        next

;C 1+      n1/u1 -- n2/u2       add 1 to TOS
    head ONEPLUS,2,'1+',docode
        inc bx
        next

;C 1-      n1/u1 -- n2/u2     subtract 1 from TOS
    head ONEMINUS,2,'1-',docode
        dec bx
        next

;Z ><      x1 -- x2         swap bytes (not ANSI)
    head swapbytes,2,'><',docode
        xchg bh,bl
        next

;C 2*      x1 -- x2         arithmetic left shift
    head TWOSTAR,2,'2*',docode
        shl bx,1
        next

;C 2/      x1 -- x2        arithmetic right shift
    head TWOSLASH,2,'2/',docode
        sar bx,1
        next

;C LSHIFT  x1 u -- x2    logical L shift u places
    head LSHIFT,6,'LSHIFT',docode
        xchg bx,cx      ; count in CX, save old
        pop ax
        shl ax,cl
        mov cx,bx       ; restore old CX
        mov bx,ax       ; shifted value
        next

;C RSHIFT  x1 u -- x2    logical R shift u places
    head RSHIFT,6,'RSHIFT',docode
        xchg bx,cx      ; count in CX, save old
        pop ax
        shr ax,cl
        mov cx,bx       ; restore old CX
        mov bx,ax       ; shifted value
        next

;C +!     n/u a-addr --       add cell to memory
    head PLUSSTORE,2,'+!',docode
        pop ax
        add [bx],ax
        pop bx
        next

; COMPARISON OPERATIONS =========================

;C 0=     n/u -- flag    return true if TOS=0
    head ZEROEQUAL,2,'0=',docode
        sub bx,1        ; set cy if BX was 0
        sbb bx,bx       ; BX=1 if cy set
        next

;C 0<     n -- flag      true if TOS negative
    head ZEROLESS,2,'0<',docode
        shl bx,1        ; set cy if BX negative
        sbb bx,bx       ; BX=1 if cy set
        next

;C =      x1 x2 -- flag         test x1=x2
    head EQUAL,1,'=',docode
        pop ax
        sub ax,bx       ; x1-x2 in AX, flags set
        jz tostrue
tosfalse: xor bx,bx
        next

;X <>     x1 x2 -- flag    test not eq (not ANSI)
    head NOTEQUAL,2,'<>',docolon
        DW EQUAL,ZEROEQUAL,EXIT

;C <      n1 n2 -- flag        test n1<n2, signed
    head LESS,1,'<',docode
        pop ax
        sub ax,bx       ; n1-n2 in AX, flags set
        jge tosfalse
tostrue: mov bx,-1
        next

;C >     n1 n2 -- flag         test n1>n2, signed
    head GREATER,1,'>',docolon
        DW SWAP,LESS,EXIT

;C U<    u1 u2 -- flag       test u1<n2, unsigned
    head ULESS,2,'U<',docode
        pop ax
        sub ax,bx       ; u1-u2 in AX, flags set
        jb tostrue
        jmp tosfalse

;X U>    u1 u2 -- flag     u1>u2 unsgd (not ANSI)
    head UGREATER,2,'U>',docolon
        DW SWAP,ULESS,EXIT

; LOOP AND BRANCH OPERATIONS ====================

;Z branch   --                  branch always
    head branch,6,'branch',docode
dobranch: mov si,cs:[si]
        next

;Z ?branch   x --              branch if TOS zero
    head qbranch,7,'?branch',docode
        or bx,bx
        pop bx
        jz dobranch
        inc si
        inc si
        next

;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2
;Z                          run-time code for DO
; '83 and ANSI standard loops terminate when the
; boundary of limit-1 and limit is crossed, in
; either direction.  This can be conveniently
; implemented by making the limit 8000h, so that
; arithmetic overflow logic can detect crossing.
; I learned this trick from Laxen & Perry F83.
; fudge factor = 8000h-limit, to be added to
; the start value.
    head xdo,4,'(do)',docode
        pop ax          ; BX=index, AX=limit
        xchg bp,sp      ; push old index on R.stk
        push cx
        mov cx,8000h    ; compute 8000h-limit
        sub cx,ax       ;  "fudge factor"
        push cx         ; push on return stack
        add cx,bx       ; loop ctr = index+fudge
        xchg bp,sp
        pop bx          ; pop new TOS
        next

;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates,
; clean up the return stack and skip the branch.
; Else take the inline branch.  Note that LOOP
; terminates when index=8000h.
    head xloop,6,'(loop)',docode
        add cx,1
        jno dobranch    ; no overflow = loop
        inc si          ; overflow = loop done
        inc si
        mov cx,[bp+2]   ; restore old index
        add bp,4
        next

;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates,
; clean up the return stack and skip the branch.
; Else take the inline branch.
    head xplusloop,7,'(+loop)',docode
        add cx,bx
        pop bx
        jno dobranch    ; no overflow = loop
        inc si          ; overflow = loop done
        inc si
        mov cx,[bp+2]   ; restore old index
        add bp,4
        next

;C I        -- n   R: sys1 sys2 -- sys1 sys2
;C                  get the innermost loop index
    head II,1,'I',docode
        push bx         ; push old TOS
        mov bx,cx       ; index=loop ctr-fudge
        sub bx,[bp]
        next

;C J        -- n   R: 4*sys -- 4*sys
;C                  get the second loop index
    head JJ,1,'J',docode
        push bx         ; push old TOS
        mov bx,[bp+2]   ; outer loop ctr
        sub bx,[bp+4]   ;   - outer fudge
        next

;C UNLOOP   --   R: sys1 sys2 --  drop loop parms
    head UNLOOP,6,'UNLOOP',docode
        mov cx,[bp+2]   ; restore old index
        add bp,4
        next

; MULTIPLY AND DIVIDE ===========================

;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
    head UMSTAR,3,'UM*',docode
        pop ax
        mul bx
        push ax
        mov bx,dx
        next

;C UM/MOD   ud u1 -- u2 u3   unsigned 32/16->16
    head UMSLASHMOD,6,'UM/MOD',docode
        pop dx
        pop ax
        div bx
        push dx         ; remainder
        mov bx,ax       ; quotient
        next

; BLOCK AND STRING OPERATIONS ===================

;C FILL   c-addr u char --  fill memory with char
    head FILL,4,'FILL',docode
        xchg bp,sp      ; save regs
        push es
        push di
        push cx
        xchg bp,sp
        mov ax,ds       ; data segment
        mov es,ax
        mov ax,bx       ; character
        pop cx          ; count
        pop di          ; address
        jcxz filldone
        rep stosb
filldone:
	xchg bp,sp      ; restore regs
        pop cx
        pop di
        pop es
        xchg bp,sp
        pop bx          ; new TOS
        next

;Z I->D     c-addr1 c-addr2 u --  move Code->Data
; Block move from Code space to Data space.
    head ITOD,4,'I->D',docode
        mov ax,cs       ; source segment
        mov dx,ds       ; destination segment
        jmp segmove

;Z D->I     c-addr1 c-addr2 u --  move Data->Code
; Block move from Data space to Code space.
    head DTOI,4,'D->I',docode
        mov ax,ds       ; source segment
        mov dx,cs       ; destination segment
        jmp segmove

;Z D->H     c-addr1 c-addr2 u --  move Data->Head
; Block move from Data space to Head space.
    head DTOH,4,'D->H',docode
        mov ax,ds       ; source segment
        mov dx,es       ; destination segment
        jmp segmove

;X CMOVE   c-addr1 c-addr2 u --  move from bottom
; as defined in the ANSI optional String word set
; On byte machines, CMOVE and CMOVE> are logical
; factors of MOVE.  They are easy to implement on
; CPUs which have a block-move instruction.
    head CMOVE,5,'CMOVE',docode
        mov ax,ds       ; AX = source segment
        mov dx,ax       ; DX = destination seg
segmove: xchg bp,sp     ; save regs
        push ds
        push es
        push di
        push si
        push cx
        xchg bp,sp
        mov ds,ax       ; source segment
        mov es,dx       ; dest segment
        mov cx,bx       ; count
        pop di          ; dest adr
        pop si          ; source adr
        jcxz cmovedone
        rep movsb
cmovedone:
	xchg bp,sp      ; restore regs
        pop cx
        pop si
        pop di
        pop es
        pop ds
        xchg bp,sp
        pop bx          ; new TOS
        next

;X CMOVE>  c-addr1 c-addr2 u --  move from top
; as defined in the ANSI optional String word set
    head CMOVEUP,6,'CMOVE>',docode
        xchg bp,sp      ; save regs
        push es
        push di
        push si
        push cx
        xchg bp,sp
        mov ax,ds       ; dest segment
        mov es,ax
        mov cx,bx       ; count
        pop di          ; dest adr
        pop si          ; source adr
        jcxz cmovudone
        dec bx          ; count-1
        add di,bx       ; last byte in dest
        add si,bx       ; last byte in source
        std             ; work backwards
        rep movsb
        cld
cmovudone:
	xchg bp,sp      ; restore regs
        pop cx
        pop si
        pop di
        pop es
        xchg bp,sp
        pop bx          ; new TOS
        next

;Z SKIP   c-addr u c -- c-addr' u'
;Z                          skip matching chars
; Although SKIP, SCAN, and S= are perhaps not the
; ideal factors of WORD and FIND, they closely
; follow the string operations available on many
; CPUs, and so are easy to implement and fast.
    head skip,4,'SKIP',docode
 	xchg bp,sp     ; save regs
        push es
        push di
        push cx
        xchg bp,sp
        mov ax,ds       ; data segment
        mov es,ax
        mov ax,bx       ; char
        pop cx          ; count
        pop di          ; adr
        jcxz skipdone
        repe scasb
        jz skipdone     ; CX=0, DI ok.
        inc cx          ; mismatch found,
        dec di          ;  adjust CX,DI
skipdone:
        push di         ; updated adr
        mov bx,cx       ; updated count
	xchg bp,sp      ; restore regs
        pop cx
        pop di
        pop es
        xchg bp,sp
        next

;Z SCAN    c-addr u c -- c-addr' u'
;Z                      find matching char
    head scan,4,'SCAN',docode
 	xchg bp,sp     ; save regs
        push es
        push di
        push cx
        xchg bp,sp
        mov ax,ds       ; data segment
        mov es,ax
        mov ax,bx       ; char
        pop cx          ; count
        pop di          ; adr
        jcxz scandone
        repne scasb
        jnz scandone    ; CX=0, DI ok.
        inc cx          ; match found,
        dec di          ;  adjust CX,DI
scandone:
        push di         ; updated adr
        mov bx,cx       ; updated count
	xchg bp,sp      ; restore regs
        pop cx
        pop di
        pop es
        xchg bp,sp
        next

;Z N=    c-addr1 c-addr2 u -- n   name compare
;Z             n<0: s1<s2, n=0: s1=s2, n>0: s1>s2
; segmented model: c-addr1=>Data, c-addr2=>Header.
    head nequal,2,'N=',docode
        mov ax,ds       ; source segment
        mov dx,es       ; destination segment
        jmp segcomp

;Z S=    c-addr1 c-addr2 u -- n   string compare
;Z             n<0: s1<s2, n=0: s1=s2, n>0: s1>s2
    head sequal,2,'S=',docode
        mov ax,ds       ; AX = source segment
        mov dx,ds       ; DX = destination seg
segcomp: xchg bp,sp     ; save regs
        push ds
        push es
        push di
        push si
        push cx
        xchg bp,sp
        mov ds,ax       ; source segment
        mov es,dx       ; dest segment
        mov cx,bx       ; count
        pop di          ; dest adr
        pop si          ; source adr
        xor bx,bx       ; preclear BX
        jcxz sequdone
        repe cmpsb
        jz sequdone
        ; not equal strings: CY set if DI<SI
        ; if CY set, return +1, else return -1
        rol bx,1
        rol bx,1
        dec bx
sequdone:
	xchg bp,sp      ; restore regs
        pop cx
        pop si
        pop di
        pop es
        pop ds
        xchg bp,sp
        next

        INCLUDE camel86d.asm   ; CPU Dependencies
        INCLUDE camel86h.asm   ; High Level words

_Header SEGMENT
headdict EQU $
        ORG 0FFFEh      ; reserve a full 64K segment
        DB (?)
_Header ENDS

_Data   SEGMENT
ramdict EQU $
        ORG 0FFFEh      ; reserve a full 64K segment
        DB (?)
_Data   ENDS

romdict EQU $           ; user's code starts here
        ORG ilatest     ; set "latest" in UINIT data
        DW link
        ORG 0FFFEh      ; reserve a full 64K segment
        DB (?)
_Code   ENDS
        END reset

