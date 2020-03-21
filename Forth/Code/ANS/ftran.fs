\ ******** ANS-compatible FORmula TRANslator ********
\ filenames:
\   ftran.f, ftran.fs   v. 1.0
\
\ ---------------------------------------------------
\     (C) Copyright 1997  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\       See the end of the program for GNU Public   \
\       License details.                            \
\ ---------------------------------------------------
\
\ ----------------------------------------------------------------
\ Usage examples:                                                \
\   Convert formula to Forth on the screen:                      \
\   f." a=b*c-3.17e-5/tanh(w)+abs(x)"                            \
\       x F@ FABS 3.17000E-5 w F@ FTANH F/ FNEGATE               \
\       b F@ c F@ F* F+ F+ a F!  ok                              \
\                                                                \
\   Compile formula(s) into Forth word:                          \
\       fvariable x  ok                                          \
\       fvariable w  ok                                          \
\       fvariable c  ok                                          \
\       fvariable b  ok                                          \
\       fvariable a  ok                                          \
\       : test  f" a=b*c-3.17e-5/tanh(w)+abs(x)" ;  ok           \
\       see test                                                 \
\       : TEST          X F@ FABS flit 3.17000E-5 W F@ FTANH F/  \
\                       FNEGATE B F@ C F@ F* F+ F+ A F! ;  ok    \
\ ----------------------------------------------------------------
\
\ ----------------------------------------
\ Environmental dependencies:            \
\       Separate floating point stack    \
\       ANS FLOAT and FLOAT EXT wordsets \
\       ANS TOOLS EXT wordsets           \
\       TRUE = -1  (all bits set)        \
\       .NAME    ( xt --) \ emit name    \
\ ----------------------------------------
\
\ -------------------------------------------------
\ Non STANDARD words:                             \
\     OFF (alias 0!)  store 0  to a cell          \
\     ON              store -1 to a cell          \
\     NOOP  "no operation"    : NOOP   ;          \
\     PERFORM == @ EXECUTE                        \
\     COL           (Win32Forth 3.5)              \
\     CAPS-FIND     (Win32Forth 3.5)              \
\ -------------------------------------------------
\
\ -------------------------------------------------
\ Test history:                                   \
\       Platform         Date                     \
\       ----------------------------------        \
\       Win32Forth 3.5   October 5th, 1997        \
\         disregard stack messages while loading! \
\                                                 \
\       GForth 0.3.0     October 5th, 1997        \
\ -------------------------------------------------
\
\
\ Compiler documentation:
\ ----------------------------- Backus-Naur Rules for mini FORTRAN
\ NOTATION:
\ |               -> "or",
\ +               -> "unlimited repetitions"
\ Q               -> "empty set"
\ &               -> + | -
\ %               -> * | /

\ NUMBERS:
\ fp#           -> {-|Q}{digit.digit+ | .digit digit+} exponent
\ exponent      -> {dDeE {&|Q} digit {digit|Q} {digit|Q} | Q}

\ FORMULAS:
\ assignment    -> id = expression
\ id            -> letter {letter|digit}+
\ arglist       -> ( expression {,expression}+ )
\ function      -> id arglist
\ expression    -> term | expression & term
\ term          -> factor | term % factor
\ factor        -> id | fp# | ( expression )
\                    | factor ^ factor | function
\ ------------------------------------------ end Backus-Naur Rules

\ -------------------------------------------- program begins here
\ -------------------------------------------- program begins here
FORTH-WORDLIST  SET-CURRENT     \ a precaution
marker -ftran                   \ say -ftran to remove all ANS-ly

\ ------------------------------------------ string handling words
: text    WORD   PAD  OVER C@  1+  CMOVE  PAD  ;
: $"      [CHAR] "  text  ;                 \ use as $" abcd"
: y/n?   ( char -- flag)
    DUP  [CHAR] Y =  SWAP  [CHAR] y =  OR  ;
\ -------------------------------------- end string handling words

\ ------------------- conditional definition of non-STANDARD words

$" NOOP" FIND  NIP
    0= [IF]      : NOOP   ;   [THEN]

$" PERFORM" FIND  NIP
    0=  [IF]     : PERFORM   @ EXECUTE ;  [THEN]

$" OFF" FIND  NIP
    0=  [IF]     : OFF  ( adr --)  0 SWAP ! ;  [THEN]

$" ON" FIND  NIP
    0=  [IF]     : ON  ( adr --)  -1 SWAP ! ;  [THEN]

$" CAPS-FIND" FIND  NIP
    0=  [IF]     : CAPS-FIND  FIND ;  [THEN]

\ --------------------------------------------- function vectoring
: use(    '   ;            \ pure esthetics

' NOOP  CONSTANT  'noop
: v:   CREATE  'noop  ,  DOES> PERFORM  ;
: defines    '  >BODY   STATE @
             IF   POSTPONE  LITERAL    POSTPONE  !
             ELSE   !   THEN  ;  IMMEDIATE
\ ----------------------------------------- end function vectoring


\ ------------------------------------------------------- fsm code
: ||   ' ,  ' ,  ;            \ add two xt's to data field
: wide   0  ;                 \ aesthetic, initial state = 0
: fsm:   ( width state --)    \ define fsm
    CREATE  , ( state) ,  ( width in double-cells)  ;

: ;fsm   DOES>                ( x col# adr -- x' )
         DUP >R  2@           ( x col# width state)
         *  +                 ( x col#+width*state )
         2*  2 +  CELLS       ( x relative offset )
         R@  +                ( x adr[action] )
         DUP >R               ( x adr[action] )
         PERFORM              ( x' )
         R> CELL+             ( x' adr[update] )
         PERFORM              ( x' state')
         R> !   ;             ( x' )  \ update state

: >state   POSTPONE defines  ; immediate   ( state "fsm-name" --)
\ set fsm's state  as in 0 >state fsm-name

: state> ( "fsm-name" -- state) \ get fsm's state
          '  >BODY              \ get dfa
          STATE @               \ compiling?
          IF    POSTPONE LITERAL  POSTPONE @
          ELSE  @  THEN  ;   IMMEDIATE

0 CONSTANT >0   3 CONSTANT >3   6 CONSTANT >6
1 CONSTANT >1   4 CONSTANT >4   7 CONSTANT >7
2 CONSTANT >2   5 CONSTANT >5
( FSMs with > 7 states are too darned big!)
\
\ --------------------------------------------------- end fsm code

\ The preceding words were placed in the FORTH wordlist because
\ they are more generally useful than the components of this
\ formula parser. The user is free to hide them if he likes.

WORDLIST  CONSTANT  ftran               \ create separate wordlist
ftran SET-CURRENT                       \ for FOR...TRAN... def'ns
GET-ORDER  ftran  SWAP 1+  SET-ORDER    \ make ftran findable

\ --------------------------------------------------- string stack
16 CONSTANT  max_depth

CREATE $stack   max_depth  3 *  CELLS  CELL+  ALLOT
\ 3 cells wide, cell at base_adr holds $ptr
\   increase max depth as necessary

HERE  $stack -  1 cells -  CONSTANT  $max  \ max depth (cells)

: $init   -3 cells  $stack  !  ;   $init

: $ptr    ( -- adr offset)    $stack dup  @  ;

: $lbound ( offset)    0<  ABORT" empty $stack!" ;

: ($pop)  ( adr offset -- beg end op)
          dup   $lbound                       \ bounds check
          + cell+                             ( adr[TO$])
          dup >r   cell+  2@  r>  @   ;       ( beg end op)

: $pop    ( -- beg end op)
          $ptr                                ( adr offset)
          ($pop)                              ( beg end op)
          -3 cells $stack +!  ;               \ dec $ptr

: $ubound ( offset)    $max > ABORT" $stack too deep!"  ;

: $push   ( beg end op -- )
          3 cells  $stack  +!                 \ inc $ptr
          $ptr                                ( beg end op adr offset)
          dup  $ubound                        \ bounds check
          + cell+  dup >r                     ( beg end op adr[TO$])
          !   r>  cell+  2!  ;

: $ends   ( $adr -- beg end)    \ convert $adr to ends
    COUNT   DUP >R  0>  OVER  +  R>  +  ;     \ TRUE = -1

: ends->count   ( beg end -- c-adr u)  over -  1+  ;

: make$     ( beg end -- $adr)  \ convert text to $ @ PAD
    ends->count  PAD 1+  SWAP   DUP >R  CMOVE
    R>  PAD  C!    PAD  ;

: expr.   ( beg end --)         \ emit expression
    ends->count   TYPE  SPACE ;

\ definitions for GForth

CR  .( Are you using GForth? ) KEY
y/n?  [IF]
    : col  ;
    : .name   LOOK DROP .NAME ;
[THEN]

\ The following 2 words are inserted for debugging, and can be
\ dispensed with. Say

VARIABLE testing     testing  OFF

: .$tack     \ dump the $stack
    $ptr  DUP $lbound                   \ bounds check
    \ format output
        CR  ." expressions"  52 COL  ." operators"
        CR  ." -----------"  52 COL  ." ---------"
    \ end of formatting
    ( adr offset)
    3 CELLS + 0 DO  DUP I ($pop)        ( adr beg end op)
        -ROT   CR expr.                 \ emit expression
        52 COL  .NAME                   \ emit operator
    3 CELLS  +LOOP  DROP   CR  ;

\ ----------------------------------------------- end string stack


\ -------------------------------------- words to seek operator(s)
VARIABLE  ()level                    \ place to hold parens count
: inc()   1  ()level  +!  ;
: dec()  -1  ()level  +!  ;

: >()err   -1 ABORT" Unbalanced () !" ; \ error message

: >0?    ()level  @  DUP   0< IF  >()err  EXIT  THEN
         0>  ABS  ;                  \ 0 if ()level = 0, 1 if > 0
                                     \ used in nondeterministic fsm

4 wide fsm:  <)op(>    ( col#)       \ find exposed operator
\ input     |   other    |      (          |        )    |     op   |
\ state     ---------------------------------------------------------
( visible)  || NOOP  >0  || dec()  >()err  || inc()  >1  || NOOP  >2
( hidden)   || NOOP  >1  || dec()  >0?     || inc()  >1  || NOOP  >1
( done = 2)  ;fsm

v: op->col#       \ dummy function name

: )op(       ( beg end -- adr|0 )       \ find exposed operator
      0  >state  <)op(>                 \ initialize state
      ()level    OFF                    \ initialize ()level
      0  ROT                            ( end 0 beg)
      DUP C@  [CHAR] - =  -  ROT        \ ignore leading -
      DO   I  C@   op->col#    <)op(>   \ invoke fsm
           state>  <)op(>  >2  =        \ done?
           IF  I  OR  LEAVE  THEN       \ modify flag
      -1 +LOOP                          \ search right to left
      >0?  if  >()err  then  ;          \ test for balanced ()

: parens  ( c -- c n)
          [char]  (    over =  abs          \ n=1 if c = (
          over  [char] )    = 2 and +  ;    \ n=2 if c = )

: A       ( c1 c2 -- n)   >R                \ 0 if c1 = other
          parens                            ( -- c1 0|1|2)
          SWAP  R>         = 3 AND +   ;    \ 3 if c1 = c2

: AorB    ( c1 c2 c3 -- n)   >r >r          \ 0 if c1 = other
          parens                            ( -- c1 0|1|2)
          OVER  R>         = 3 AND +        \ 3 if c1 = c2
          SWAP  R>         = 3 AND +   ;    \ 3 if c1 = c3

: )+or-(    [CHAR] -  [CHAR] +  AorB  ;     \ find exposed + or -
: )*or/(    [CHAR] *  [CHAR] /  AorB  ;     \ find exposed * or /
: )^(       [CHAR] ^  A  ;                  \ find exposed ^
: )=(       [CHAR] =  A  ;                  \ find exposed =
: ),(       [CHAR] ,  A  ;                  \ find exposed ,

\ tested September 16th, 1997 - 21:23


\ ---------------------------------- end words to seek operator(s)


\ ------------------------------------------------ data structures
v: term           \ dummy names for vectored recursion
v: factor

v: (.op)          \ re-vectorable names for compilation
v: (.fp#)
v: (do_id)


CREATE null$  1 C, BL C,
null$   $ends   2CONSTANT  null

CREATE buffer 256 ALLOT

\ -------------------------------------------- end data structures

\ -------------------------------------------------- formula input

: -bl!    ( c-adr1 c-adr2 --)
\ move string from c-adr1 to c-adr2, removing any embedded blanks
    SWAP
    COUNT  TUCK         ( adr2 n adr1+1 n)
    OVER +  SWAP        ( adr2 n end1+1 beg1)
    2>R  OVER 1+
    2R>                 ( adr2 n adr2+1 end1+1 beg1)
    DO  I C@  DUP       ( adr2 n ptr c c)
        BL =            ( adr2 n ptr c f)
        IF  2>R  1-     ( adr2 n-1)
            2R>  DROP   ( adr2 n-1 ptr)
        ELSE OVER C! 1+ ( adr2 n ptr+1)
        THEN
    LOOP
    DROP  SWAP  C!  ;

: get$    $"  buffer -bl!   buffer ;
\ ---------------------------------------------- end formula input


\ --------------------------------------------- main parsing words
\ ( $: ... ) represents $stack contents

: arrange     ( beg end --)   'noop  $push  ;

: &arrange    ( beg end ptr op --)
    >R  DUP 1-  >R          ( beg end ptr) ( r: op ptr-1)
    ROT R> R> $push         ( end ptr)
    DUP  C@   [CHAR] -  <>  ( end ptr flag)
    -                       ( end ptr if "-", else ptr+1)
    SWAP  arrange  ;        ( $: [left op] [right noop])
\ Environmental dependency: "TRUE" = -1
\ Note: keeping "-" with a term eliminates need to
\ distinguish unary - from binary -

\ ---------------------------- words to identify fp#'s and id's
\   The following version should work with a properly
\   defined >FLOAT. Unfortunately, this is not what Win32For
\   v. 3.5 offers ...

\ : fp#?      ( beg end -- flag) ( f: -- fp#)
\       ends->count  >FLOAT  DUP IF  FDROP  THEN  ;

\   Hence we must resort to a correctly designed test for fp#

: #err    -1  ABORT" Not a correctly formed fp#"    ;
5 wide fsm: (fp#)
\ input:     |   other  |   dDeE   |   digit  |   +or-   |    dp   |
\ state:  ----------------------------------------------------------
( 0: dg|.)   || noop >5 || noop >5 || 1+  >1  || noop >5 || 1+   >2
( 1: dg|.|E) || noop >5 || 1+   >3 || 1+  >1  || #err >5 || 1+   >2
( 2: dg|E)   || noop >5 || 1+   >3 || 1+  >1  || #err >5 || #err >5
( 3: dg|&)   || noop >5 || #err >5 || 1+  >4  || 1+   >4 || #err >5
( 4: dg )    || noop >5 || #err >5 || 1+  >4  || #err >5 || #err >5
;fsm
\ bug fixed, code shortened on September 27th, 1997 - 16:18


\ ============================ Automatic conversion tables
: tab:   ( #bytes -- )
    CREATE   HERE  OVER  ALLOT   SWAP  0 FILL  DOES>  +  C@  ;

: install      ( col# adr char.n char.1 -- )   \ fast fill
    SWAP 1+ SWAP   DO  2DUP I +  C!  LOOP  2DROP ;
\ ======================== end automatic conversion tables

128 TAB: [fp#]               \ convert c-adr to col#
1 ' [fp#]  >BODY  CHAR E  CHAR D  install
1 ' [fp#]  >BODY  CHAR e  CHAR d  install
2 ' [fp#]  >BODY  CHAR 9  CHAR 0  install
3 ' [fp#]  >BODY  CHAR +  +  C!
3 ' [fp#]  >BODY  CHAR -  +  C!
4 ' [fp#]  >BODY  CHAR .  +  C!

: skip-  DUP C@  [CHAR] - =  -  ;
: fp#?   ( beg end -- flag)
         SWAP
         0 >state (fp#) skip-         \ initialize
         BEGIN   DUP C@  [fp#]  (fp#)
                 2DUP  <=             \ end = beg ?
                 state> (fp#) >5 = OR \ or terminated by error?
         UNTIL   2DROP
         state> (fp#) >5 <  ;         \ success?

\   ... now wasn't that a lot of wasteful code?

128 TAB: [id]               \ convert c-adr to col#
1 ' [id]  >BODY    CHAR Z  CHAR A  install
1 ' [id]  >BODY    CHAR z  CHAR a  install
2 ' [id]  >BODY    CHAR 9  CHAR 0  install

VARIABLE id.len
: +id.len   1 id.len  +!  ;

: >1?    id.len @ 8 <  DUP  1 AND  SWAP  INVERT  2 AND +  ;
\ return 1 if id.len <= 7, 2 otherwise

3 wide fsm: (id)    ( char col# --)
\ input:     |   other  |   letter     |    digit   |
\ state      ----------------------------------------
   ( 0 )     || NOOP >2 || +id.len >1  || NOOP >2
   ( 1 )     || NOOP >2 || +id.len >1? || +id.len >1?
( done = 2)  ;fsm

\ id -> letter {letter|digit}+    1-7 chars
: id?    ( beg end -- flag)     \ f: -1 = id, -2 = null, 0 else
         2DUP  null D=  IF  2DROP  -2  EXIT  THEN
         id.len OFF             \ initialize length
         0 >state (id)          \ initialize fsm
         SWAP                   ( -- end beg)
         BEGIN   DUP C@  [id]  (id)
                 2DUP  >              \ end > beg ?
                 state> (id) 2 <  AND \ not terminated
         WHILE   1+  REPEAT   2DROP
         state> (id) 1 =  ;
\ id? tested September 20th, 1997 - 12:50

\ ------------------------ end words to identify fp#'s and id's

: >digits   ( adr -- adr')  \ skip digits rightward
    BEGIN  1+  DUP C@  [id] 2 <>  UNTIL  ;

: <digits   ( adr -- adr')  \ skip digits leftward
    BEGIN  1-  DUP C@  [id] 2 <>  UNTIL  ;

: <dDeE     ( adr -- adr')  \ skip letters leftward
    BEGIN  1-  DUP C@  [fp#] 1 <>  UNTIL  ;


: ~fp#?     ( adr[sign] -- adr|false if sign is in a fp#)
\ determine whether a + or - sign occurs within a
\ floating point #'s exponent
    DUP  >R  >digits 1-     ( adr[last_dig])
         R@  OVER = -       ( adr[ld] | adr[s]+1 if =)
    R@   <dDeE   1+         ( adr[ld] adr[E])
         <digits            ( end  beg-1 | adr[.])
    DUP C@  [CHAR] . = +    \ skip.dp
                            ( end beg-1|adr[.]-1)
    1+ <digits  1+          ( end beg)
    R@  OVER = +            ( end | adr[s]+1  beg | adr[s]-1)
    SWAP
    fp#?  INVERT  R>  AND  ;   ( ptr|0) ( f: x | nothing)


: )+or-(?   ( beg end -- ptr|0)
\ Seek exposed + or - , ignoring leading - or +- embedded in a fp#
\ -- Note: ignoring a leading - occurs in )op(
    ['] )+or-(   defines  op->col#          \ revector
    2DUP  )op(              ( beg end ptr|0)
    ?DUP 0=  IF  2DROP  0  EXIT  THEN       \ not found
    DUP   ~fp#?             ( beg end ptr ptr|0 )
    0=  IF  NIP  1-  RECURSE  ELSE  NIP NIP  THEN  ;

\ ==================================================== expression
\ expr -> term | expr & term

: .op   ( xt --)             \ emit an operator
    DUP  'noop =   IF   DROP   ELSE  (.op)    THEN  ;

: .expr  testing @  IF   CR  ." expr" .$tack   THEN  ;
\ debugging

: expr   ( $: expr op)
    $pop                        ( beg end op)
    >R                          \ save op
    2DUP  )+or-(?               \ exposed + or - ?
    ( beg end ptr|0)  ?DUP
        IF    ['] F+   &arrange .expr term RECURSE
        ELSE  arrange .expr  term
        THEN
    R>  .op  ;                  \ emit saved op
\ ================================================ end expression

\ ==================================================== assignment
\ assign -> id = expr

: .assign   testing @  IF   CR  ." assign" .$tack   THEN  ;
\ debugging

: assign      ( $adr --)
    $init                       \ clear $stack
    $ends                       ( beg end)
    ['] )=(  defines  op->col#  \ revector
    2DUP )op(                   \ = sign ?
    ( beg end ptr|0)  ?DUP
        IF    ['] F!  &arrange .assign  expr  factor
        ELSE  arrange  .assign  expr
        THEN  ;
\ assign tested September 21st, 1997 - 9:27
\ ================================================ end assignment

\ ========================================================== term 
: do_%      ( ptr -- ptr xt)    \ put 'F* or 'F/ on stack
    DUP  C@  [CHAR] *  =        \ is it * ?
        IF    ['] F*    ELSE    ['] F/    THEN  ;

: %arrange  ( beg end ptr op --)
    >R   TUCK               ( beg ptr end ptr)
    1+ SWAP                 ( beg ptr ptr+1 end)
    R> $push  1-  arrange ; ( $: [right op] [left noop])

: )*or/(?   ( beg end -- ptr|0)     \ seek exposed * or /
    ['] )*or/(  defines   op->col#  \ revector
    )op(  ;

: .term    testing @  IF  CR ." term" .$tack  THEN   ;
\ debugging

\ term -> factor | term % factor
: (term)      ( --)
    .term
    $pop                        ( beg end op)
    >R                          \ save op
    \ this section handles leading - signs
    OVER C@  [CHAR] - =             ( beg end flag) \ leading - ?
        IF   SWAP 1+ SWAP           ( beg+1 end)
             null R>      $push     ( $: null op)
             ['] FNEGATE  $push     ( $: null op term fnegate)
             term  factor  EXIT
        THEN
    \ this section does: term -> factor | term % factor
    2DUP )*or/(?                    \ exposed * or /  ?
    ( beg end ptr|0)  ?DUP
        IF    do_%   %arrange  term \ term%factor
        ELSE  arrange               \ factor only
        THEN   factor
    R>  .op  ;                  \ emit saved op

' (term)  defines  term         \ resolve forward reference
\ ====================================================== end term

\ ======================================================== factor 
\ (factor) will be defined in bottom-up (Forthian) fashion

: do_id   ( beg end op --)  -ROT
    2DUP  null  D=                  \ test for null
    IF  2DROP  .op  EXIT   THEN
    (do_id)
    DUP  ['] F! <>  IF  ['] F@  .op  THEN   .op  ;
\ do_id tested September 20th, 1997 - 12:41

: (expr)?    ( beg end -- flag)     \ "enclosed" ?
    C@  [CHAR] ) <>                 ( -- beg flag)
        IF  DROP  0  EXIT THEN      \ last char <> ")"
    C@  [CHAR] ( =    ;             \ first char = "("

: -()        ( beg end -- beg+1 end-1)
    1-  SWAP  1+  SWAP  ;

: f1^f2?    ( beg end -- flag )
    ['] )^(  defines  op->col#      \ revector
      )op(  ;

: >>->    ( end beg c -- ptr|0)     \ find 1st instance of c
      DUP  >R                       ( r: c) ( end beg c)
      ROT   1+  ROT                 ( c end+1 beg)
      DO    I C@   OVER             ( c c' c)
            =  IF    DROP  I  LEAVE  THEN
      LOOP                          ( ptr|c)
      R>  OVER  <>  AND  ;          ( ptr|0)
\ >>-> tested September 18th, 1997 - 21:23


: function?   ( beg end -- ptr|0)   \ fn -> id arglist
    2DUP                            ( beg end beg end)
    SWAP  [CHAR] (   >>->           \ find first "("
    ( beg end ptr|0)   ?DUP
    IF   1-  TUCK  1+  TUCK  >R     ( beg ptr-1 ptr end)
        (expr)?  >R  id?   R>  AND  R> AND
    ELSE  2DROP  0  THEN ;

: list!       ( --)
    $pop                        ( beg end op)
    >R                          \ save op
    ['] ),(  defines  op->col#  \ revector
    2DUP )op(                   \ exposed , ?
    ( beg end ptr|0)  ?DUP
        IF     'noop  %arrange  RECURSE
        ELSE   arrange
        THEN   expr
    R>  .op  ;                  \ emit saved op

: function!   ( beg end ptr--)  \ ptr points to (
    ROT  OVER 1-                ( end ptr beg ptr-1)
    make$  CAPS-FIND            \ look up function id
    ( end ptr xt f) 0=  ABORT" Function not defined!"
    EXECUTE                     ( end ptr xt')
    -ROT  SWAP
    -()                         \ eliminate parens
    ROT  $push  ;   ( $: arglist 'fn)

: .factor   testing @  IF  CR ." factor" .$tack  THEN  ;

: .fp#      ( beg end --)  ends->count  >FLOAT  DROP  (.fp#) ;

\ factor -> id | fp# | (expr) | factor^factor | function
: (factor)    ( $: factor op --)    \ parse factor
    $pop                        ( beg end op)
    >R                          \ save op
    2DUP  id?                   ( beg end flag)
        IF  R>  do_id  .factor  EXIT   THEN
    2DUP  fp#?                  ( beg end flag)
        IF    .fp#     R> .op   .factor EXIT   THEN
    2DUP  (expr)?               ( beg end flag)
        IF  -()   R>  $push     ( $: expr op)
                .factor  expr   EXIT
        THEN
    2DUP  f1^f2?                \ factor1 ^ factor2 ?
    ( beg end ptr|0)  ?DUP
        IF  ['] F**  %arrange  .factor ( $: f2 F** f1 noop)
            factor  factor
            R> .op  EXIT
        THEN
    2DUP  function? DUP         ( beg end ptr|0)
        IF    function!   .factor      ( $: list fn)
              list!
        ELSE  ." Not a factor!"  ABORT
        THEN
    R>  .op  ;                  \ emit saved op

' (factor) defines factor       \ resolve forward reference
\ ==================================================== end factor

\ ----------------------------------------- testing and compiling
: compile_id  ( beg end --)
    make$  CAPS-FIND            ( xt|adr f)
    0=  IF  COUNT TYPE  ."  Not found" ABORT  THEN
    COMPILE,  ;


FORTH-WORDLIST   SET-CURRENT            \ definitions to FORTH

: f."   ( formula --)           \ for testing
    ['] .NAME  defines (.op)    \ revector operators
    ['] FE.    defines (.fp#)
    ['] expr.  defines (do_id)
    get$  assign  ;

: f"    ( formula --)           \ for compiling
    state @  0= ABORT" Compile only!"
    ['] COMPILE,  defines (.op) \ revector operators
    ['] FLITERAL  defines (.fp#)
    ['] compile_id defines (do_id)
    get$ assign   ; IMMEDIATE

GET-ORDER  NIP  1-  SET-ORDER           \ hide ftran definitions
\ ------------------------------------- end testing and compiling

\ ---------------------------------------- function library
WORDLIST  CONSTANT flib
flib SET-CURRENT
\ standard real functions
' FABS   CONSTANT  abs       ' FEXP   CONSTANT  exp
' FSQRT  CONSTANT  sqrt      ' FLN    CONSTANT  log
' FSIN   CONSTANT  sin       ' FCOS   CONSTANT  cos
' FTAN   CONSTANT  tan       ' FATAN  CONSTANT  atn
' FASIN  CONSTANT  asin      ' FACOS  CONSTANT  acos
' FSINH  CONSTANT  sinh      ' FCOSH  CONSTANT  cosh
' FTANH  CONSTANT  tanh      ' FASINH CONSTANT  asinh
' FACOSH CONSTANT  acosh     ' FATANH CONSTANT  atanh

\ It is advised that you define your own functions
\ in this WORDLIST or the FORTH-WORDLIST by saying, e.g.,
\
\       ftran SET-CURRENT  or  FORTH-WORDLIST SET-CURRENT
\
\ each such function definition.
\ ------------------------------------ end function library

FORTH-WORDLIST   SET-CURRENT            \ definitions to FORTH
GET-ORDER  flib  SWAP 1+  SET-ORDER     \ make library findable

\ ---------------------------------------------- program ends here
\ ---------------------------------------------- program ends here

0 [IF]

                GNU GENERAL PUBLIC LICENSE

This program is variously called ftran.f, ftran.fs, ftran.fth,
etc. etc. depending on the ANS Forth system that runs it.

It is a translation, with simplifications, of an earlier version
that was designed to work with HS/FORTH. As noted in the preamble,
the program allows formula translation a la FORTRAN.

Copyright (C) 1997  Julian V. Noble
                    jvn@virginia.edu

                    Department of Physics
                    University of Virginia
                    Charlottesville, VA 22901
                    USA

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

[Basically, if you modify the program as given herein, you MUST
identify your modifications if you redistribute the program. That
is, you must notify any third party that he is not getting the
original version.   --jvn]

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

For a copy of the GNU General Public License write to the Free
Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

[THEN]
