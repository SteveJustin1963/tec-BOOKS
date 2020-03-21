FALSE [IF]

******** ANS-compatible FORmula TRANslator ********
filenames:
  ftran.f, ftran.fs   v. 1.10  November 12th, 1998 - 16:03

---------------------------------------------------
    (C) Copyright 1998  Julian V. Noble.
      Permission is granted by the author to      
      use this software for any application pro-  
      vided this copyright notice is preserved,
      as per GNU Public License agreement.
---------------------------------------------------

----------------------------------------------------------------
Usage examples:
^^^^^^^^^^^^^^
  Convert formula to Forth on the screen:                      
  f." a=b*c-3.17e-5/tanh(w)+abs(x)"
      b F@ c F@ F* 31.7000E-6 w F@ FTANH F/ F-
      x F@ FABS F+ a F!  ok

  Compile formula(s) into Forth word:
      fvariable x  ok
      fvariable w  ok
      fvariable c  ok
      fvariable b  ok
      fvariable a  ok
      : test  f" a=b*c-3.17e-5/tanh(w)+abs(x)"
      ;  ok
      see test
      : TEST          B F@ C F@ F* flit 3.17000E-5 W F@ FTANH
                      F/ F- X F@ FABS F+ A F! ;  ok

**A word can contain more than one formula, as in
        : test4  f" a=b*c+sin(w)"  rot dup  *
                 f" x=-3.75e6/a"  ;  ok
see test1
        : TEST1         B F@ C F@ F* W F@ FSIN F+ A F! ROT DUP
                        * flit -3.75000E6 A F@ F/ X F! ;  ok

Added functionality since first release:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
**Arrays in "Scientific FORTH" notation:
      : }   ( adr n -- adr[n])  FLOATS  +  ;  ok
      fvariable v{  ok
      : test2    f" a=v{i}"
      ;  ok
      see test2
      : TEST2         V{ I } A F! ;  ok

      : test3    f" a=b*c+v{i_j_+}"
      ;  ok
      see test3
      : TEST3         B F@ C F@ F* V{ I J + } F+ A F! ;  ok

  As illustrated above, the space between curly braces {}
  can contain a Forth index or expression. You MUST separ-
  ate the Forth words with underscores _ rather than the
  usual blank spaces, since all blank spaces are removed
  from the formula BEFORE it is parsed.

  The parser also recognizes multidimensional arrays:

    f." a{{ j_i }}= b + m{{ i_j}}"
    b F@ m{{ i j }} F@ F+ a{{ j i }} F!  ok


**Formulas can now extend over more than one line, e.g.

      : test4    f" a=b*c
                    -x/cosh(w)"  ;  ok
      see test4
      : TEST4         B F@ C F@ F* X F@ W F@ FCOSH F/ F- A F!
                      ;  ok

***Bug fix--multiline input did not work properly when the source
   was a file rather than the keyboard. This is now repaired.
---------------------------------------------------------------

----------------------------------------
Environmental dependencies:
      ANS FLOAT and FLOAT EXT wordsets
      ANS TOOLS EXT wordsets
----------------------------------------

----------------------------------------
Non STANDARD, but common words:
    OFF (alias 0!)  store 0  to a cell
    ON              store -1 to a cell
    NOOP  "no operation"    : NOOP   ;
    PERFORM == @ EXECUTE
    CAPS-FIND     (Win32Forth 3.5)
    .NAME         (WinForth & GForth)
----------------------------------------

Compiler documentation:
----------------------------- Backus-Naur Rules for mini FORTRAN
NOTATION:
|               -> "or",
+               -> "unlimited repetitions"
Q               -> "empty set"
&               -> + | -
%               -> * | /

NUMBERS:
fp#           -> {-|Q}{digit.digit+ | .digit digit+} exponent
exponent      -> {dDeE {&|Q} digit {digit|Q} {digit|Q} | Q}

FORMULAS:
assignment    -> id = expression
id            -> letter {letter|digit}+
arglist       -> ( expression {,expression}+ )
function      -> id arglist
expression    -> term | expression & term
term          -> factor | term % factor
factor        -> id | fp# | ( expression )
                   | factor ^ factor | function
------------------------------------------ end Backus-Naur Rules

[THEN]

\ program begins here

FORTH-WORDLIST  SET-CURRENT     \ a precaution
marker -ftran                   \ say -ftran to remove all ANS-ly

\ some string handling words
: text    WORD   PAD  OVER C@  1+  CMOVE  PAD  ;
: $"      [CHAR] "  text  ;                 \ use as $" abcd"

\ conditional definition of common non-STANDARD words
CR  .( Are you using GForth? )
KEY  DUP  CHAR Y =  SWAP  CHAR y =  OR  [IF]
    : .NAME   LOOK  DROP  .NAME  ; [THEN]

$" 3DROP"  FIND NIP  0= [IF]
    : 3DROP   POSTPONE 2DROP  POSTPONE DROP ; IMMEDIATE [THEN]

$" -ROT" FIND  NIP  0= [IF]
    : -ROT  POSTPONE ROT  POSTPONE ROT  ; IMMEDIATE     [THEN]

$" NOOP" FIND  NIP  0= [IF]
    : NOOP   ;   [THEN]

$" PERFORM" FIND  NIP  0=  [IF]
    : PERFORM   @ EXECUTE ;  [THEN]

$" OFF" FIND  NIP  0=  [IF]
    : OFF  ( adr --)  0 SWAP ! ;  [THEN]

$" ON" FIND  NIP  0=  [IF]
    : ON  ( adr --)  -1 SWAP ! ;  [THEN]

$" CAPS-FIND" FIND  NIP  0=  [IF]

    : lcase?        ( char -- flag=true if lower case)
        DUP   [CHAR] a  MAX     ( char max[a,c])
        SWAP  [CHAR] z  MIN     ( max[a,c] min[a,z])
        =   ;

    : ucase   ( c-adr u --)  OVER  +  SWAP
        DO  I C@  DUP  lcase?  32 AND  -  I  C!  LOOP   ;
    \ assumes ASCII character coding
    : CAPS-FIND  DUP COUNT ucase FIND ;
[THEN]
\ end conditional definition of non-STANDARD words

\ conditional definition of logical step:
TRUE -1 =  [IF]
    : ?step   POSTPONE  -  ;  IMMEDIATE
[ELSE]
    : ?step   1 LITERAL   POSTPONE  AND  POSTPONE  +  ;  IMMEDIATE
[THEN]

\ end of conditional definition


\ more string handling words
: $!      ( src dest -- )   OVER  C@  1+  CMOVE  ;
: $+  ( $1 $2 --)       \ string concatenation: $1 <- $1 + $2
      OVER  COUNT       ( $1 $2 $1+1 n1 )
      DUP  >R  +        ( $1 $2 dst )
      OVER  COUNT       ( $1 $2 dst src n2)
      ROT SWAP CMOVE    ( $1 $2)    \ move chars
      C@  R>  +  SWAP C!   ;        \ adjust length

CREATE new_pad 256 ALLOT

: last_char   COUNT + 1-  C@   ;

: get_line"             \ input line terminated by CR or "
    BEGIN   BL WORD             ( adr)
            new_pad  OVER  $+   ( adr)
            DUP C@   0=         ( adr f)
            SWAP  last_char  [CHAR] " =  OR
    UNTIL   ;

: aword"   ( -- adr)    \ multi line input
    new_pad OFF         \ initialize buffer
    BEGIN   get_line"
        new_pad  last_char
        [CHAR] " <>     \ not " ?
    WHILE  REFILL DROP  \ reset input buffer, move cursor
    REPEAT
    new_pad  DUP  C@  1-  OVER  C!    \ clean up, leave adr
;
\ end string handling words


\ vectoring: for fwd recursion, or using function names as arguments

: use(      '       \ state-smart ' for syntactic sugar
    STATE @  IF  POSTPONE LITERAL  THEN  ;  IMMEDIATE

' NOOP  CONSTANT  'noop
: v:   CREATE  'noop  ,  DOES> PERFORM  ;   \ create dummy def'n
: 'dfa   ' >BODY  ;                         ( -- data field address)
: defines    'dfa   STATE @
             IF   POSTPONE  LITERAL    POSTPONE  !
             ELSE   !   THEN  ;  IMMEDIATE
\ end vectoring


\ code to create state machines from tabular representations

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

\ set fsm's state, as in:  0 >state fsm-name
: >state   POSTPONE defines  ; IMMEDIATE   ( state "fsm-name" --)

: state: ( "fsm-name" -- state) \ get fsm's state
    'dfa                  \ get dfa
    POSTPONE LITERAL  POSTPONE @   ;   IMMEDIATE

0 CONSTANT >0   3 CONSTANT >3   6 CONSTANT >6    \ these indicate state
1 CONSTANT >1   4 CONSTANT >4   7 CONSTANT >7    \ transitions in tabular
2 CONSTANT >2   5 CONSTANT >5                    \ representations
\ end fsm code

WORDLIST  CONSTANT  ftran               \ create separate wordlist
ftran SET-CURRENT                       \ for FOR...TRAN... def'ns
GET-ORDER  ftran  SWAP 1+  SET-ORDER    \ make ftran findable

\ string stack
16 CONSTANT  max_depth

CREATE $stack   max_depth  3 *  CELLS  CELL+  ALLOT
\ 3 cells wide, cell at base_adr holds $ptr

HERE  $stack -  1 CELLS -  CONSTANT  $max  \ max depth (cells)

: $init   -3 CELLS  $stack  !  ;   $init

: $ptr    ( -- adr offset)    $stack DUP  @  ;

: $lbound ( offset)    0<  ABORT" empty $stack!" ;

: ($pop)  ( adr offset -- end beg op)
          DUP   $lbound                       \ bounds check
          + CELL+                             ( adr[TO$])
          DUP >R   CELL+  2@  R>  @   ;       ( end beg op)

: $pop    ( -- end beg op)
          $ptr                                ( adr offset)
          ($pop)                              ( end beg op)
          -3 CELLS $stack +!  ;               \ dec $ptr

: $ubound ( offset)    $max > ABORT" $stack too deep!"  ;

: $push   ( end beg op -- )
          3 CELLS  $stack  +!                 \ inc $ptr
          $ptr                                ( end beg op adr offset)
          DUP  $ubound                        \ bounds check
          + CELL+  DUP >R                     ( end beg op adr[TO$])
          !   R>  CELL+  2!  ;

: $ends   ( $adr -- end beg)    \ convert $adr to ends
    COUNT  DUP  0>              ( beg n f)
    -1 AND +                    ( beg  n-1|0)
    OVER  +  SWAP ;             ( end beg)

: ends->count   ( end beg -- c-adr u)  TUCK  -  1+ ;

: make$     ( end beg -- $adr)  \ convert text to $ @ PAD
    ends->count  PAD 1+  SWAP   DUP >R  CMOVE
    R>  PAD  C!    PAD  ;

: expr.   ( end beg --)         \ emit expression
    ends->count   TYPE  SPACE ;


CREATE bl$ 1 C, BL C,
bl$   $ends   2CONSTANT  0null


\ data structures
v: term           \ dummy names for vectored recursion
v: factor

v: (.op)          \ re-vectorable names for compilation
v: .fp#
v: (do_id)



\ end data structures

\ Automatic conversion tables
: table:   ( #bytes -- )
    CREATE   HERE  OVER  ALLOT   SWAP  0 FILL
    DOES>  +  C@  ;

: install      ( col# adr char.n char.1 -- )   \ fast fill
    SWAP 1+ SWAP   DO  2DUP I +  C!  LOOP  2DROP ;
\ end automatic conversion tables


128 table: [token]        \ convert ASCII char to token
 1 'dfa [token]    CHAR Z  CHAR A  install
 1 'dfa [token]    CHAR z  CHAR a  install
 2 'dfa [token]    CHAR E  CHAR D  install
 2 'dfa [token]    CHAR e  CHAR d  install
 3 'dfa [token]    CHAR .  +  C!
 4 'dfa [token]    CHAR 9  CHAR 0  install
 5 'dfa [token]    CHAR (  +  C!
 6 'dfa [token]    CHAR {  +  C!
 7 'dfa [token]    CHAR )  +  C!
 8 'dfa [token]    CHAR }  +  C!
 9 'dfa [token]    CHAR +  +  C!
10 'dfa [token]    CHAR -  +  C!
11 'dfa [token]    CHAR *  +  C!
12 'dfa [token]    CHAR /  +  C!
13 'dfa [token]    CHAR ^  +  C!
14 'dfa [token]    CHAR ,  +  C!
\ "other" -> 0

: skip+     ( adr -- adr|adr+1)     \ skip + sign
    DUP C@  [CHAR] +  =  ?step  ;

: skip-     ( adr -- adr|adr+1)     \ skip - sign
    DUP C@  [CHAR] -  =  ?step  ;

: >digits   ( adr -- adr')          \ skip digits rightward
    BEGIN  DUP C@  [token] 4 =  WHILE  1+  REPEAT  ;

: skip_dp   ( adr -- adr|adr+1)     \ skip decimal point
    DUP C@  [token]  3 =  ?step  ;

: skip#    ( adr -- adr')           \ skip past a fp#
    >digits  skip_dp  >digits       \ skip mantissa
    DUP C@  [token]  2 =            \ d,D,e or E ?
    IF  1+  ELSE  EXIT  THEN
    skip+  skip-  >digits  ;        \ skip exponent


VARIABLE  ()level                    \ place to hold parens count
: inc()   1  ()level  +!   1+ ;
: dec()  -1  ()level  +!   1+ ;
: >0?     ()level @  0=  IF  0  ELSE  1  THEN  ;

: ()err   TRUE  ABORT" Unbalanced () !" ; \ error message

6 wide fsm: (expr)
\ input:  | other  |   +      |    -     |  ( or {   |  ) or }   | . or digit |
\ state: ----------------------------------------------------------------------
 ( 0 )   || 1+ >0 || noop >3 || noop >4 || inc() >1 || ()err >6  || skip# >0
 ( 1 )   || 1+ >1 || 1+   >1 || 1+   >1 || inc() >1 || dec() >0? || 1+    >1
;fsm

: init_expr   ()level OFF
              2DUP  skip+  skip-
              0 >state (expr)   ;

16 table: [expr]
\ col   base adr        offset
    1   'dfa  [expr]    CHAR +    [token]     + C!
    2   'dfa  [expr]    CHAR -    [token]     + C!
    3   'dfa  [expr]    CHAR (    [token]     + C!
    3   'dfa  [expr]    CHAR {    [token]     + C!
    4   'dfa  [expr]    CHAR )    [token]     + C!
    4   'dfa  [expr]    CHAR }    [token]     + C!
    5   'dfa  [expr]    CHAR .    [token]     + C!
    5   'dfa  [expr]    CHAR 9    [token]     + C!

\ revised May 27th, 1998 - 23:00

: do_expr   ( end beg -- end beg ptr state )   \ locate term
    init_expr                       ( end beg end beg|beg+1)
    BEGIN
        DUP C@  [token]  [expr]     \ char -> col# 0-4
        (expr)                      ( end beg end beg')
        2DUP <                      \ past end of string?
          IF 5 >state (expr) THEN   \ set state to terminal
        state: (expr)  2 >          \ terminal state?
                                    \   3=)+(
                                    \   4=)-(
                                    \   5=not found
    UNTIL  NIP   ()level @  0=      \ test for balanced ()
    IF  state: (expr)   ELSE  ()err  THEN
 ;

' .NAME  defines (.op)

: &arrange   ( end beg ptr -- ptr-1 beg end ptr+1)
    TUCK  1-  SWAP  2SWAP  1+  ;

: .op   ( xt --)             \ emit an operator
    DUP  'noop =   IF   DROP   ELSE  (.op)    THEN  ;

: expr  ( --)   \ expr -> term | term & expr
    $pop  >R  ( end beg)                \ defer operator
    do_expr     ( end beg ptr state)    \ run fsm
    CASE  ( +)  3 OF  &arrange
                      ['] F+  $push   'noop $push
                      term  recurse   ENDOF
          ( -)  4 OF  &arrange
                      ['] F-  $push   'noop $push
                      term  recurse   ENDOF
          (  )  5 OF  DROP  skip+     'noop $push
                      term            ENDOF
    ENDCASE
    R>   .op                            \ emit operator
;
\ repaired and tested May 28th, 1998 - 11:23

\ assignment:  id = expression

: find_char  ( end beg c -- ptr|0)  \ find first instance of c
    >R   1-
    BEGIN   1+  DUP C@   R@ =   >R   2DUP <   R>  OR
    UNTIL   TUCK   >=   AND    R> DROP  ;

: trailing_op_err  ( end --)
    C@  [token]  9 15 WITHIN   ABORT" Missing final operand!"  ;

: op_op_err    TRUE ABORT" Can't have repeated operators!"  ;

2 wide fsm: (op_op)
\ input:  |   other   |    +-*/^   |
\ state:  --------------------------
  ( 0)   || 1+  >0   ||  1+  >1
  ( 1)   || 1+  >0   || op_op_err >6
;fsm

: ~op_op    ( end beg --)   \ check for duplicate operators
    BEGIN   DUP C@  [token]  9 14 WITHIN  ABS (op_op)
    2DUP <  UNTIL  2DROP  ;

: assign      ( $adr --) $init  \ clear $stack
    $ends                       ( end beg)
    OVER   trailing_op_err      \ can't have trailing op
    2DUP  ~op_op                \ can't have double ops
    2DUP  [CHAR] =  find_char   \ look for =  ( end beg ptr|0)
    ?DUP  IF    &arrange  2SWAP
               ['] F!  $push
               'noop   $push  expr  factor
          ELSE  'noop   $push  expr   THEN  ;

\ : >0?     ()level @  0=  IF  0  ELSE  1  THEN  ;

6 wide fsm: ((term))
\ input:  | other  |     (     |     )      |    *     |   /      |   ^   |
\ state:  -----------------------------------------------------------------
 ( 0 )   || 1+ >0 || inc() >1 || ()err >6  || noop >3 || noop >4 || noop >6
 ( 1 )   || 1+ >1 || inc() >1 || dec() >0? || 1+   >1 || 1+   >1 || 1+   >1
;fsm


v: [remap]

16 table: [term]
 1  'dfa [term]  6   5 install     \ ( or {
 2  'dfa [term]  8   7 install     \ ) or }
 3  'dfa [term]  11  + C!          \ *
 4  'dfa [term]  12  + C!          \ /

: do_term   ( end beg -- end beg ptr state)
    ()level OFF   0 >state ((term))
    2DUP                            ( end beg end beg)
    BEGIN
        DUP C@  [token]  [remap]    \ char -> col# 0-5
        ((term))                    ( end end beg beg')
        2DUP <                      \ past end of string?
          IF 5 >state ((term)) THEN \ state -> "not found"
        state: ((term)) 2 >         \ terminal state?
                                    \   3=)*(
                                    \   4=)/(
                                    \   5=not found
    UNTIL  NIP   state: ((term))
 ;


: leading-?     ( adr -- f)
    DUP C@ [CHAR] -  =   SWAP 1+ C@  [token] 4 <>  AND  ;

: %arrange   ( end beg ptr op)  ( "a%b" -- $: b op a noop)
    >R  &arrange   R> $push   'noop $push  ;

\ term -> factor | term % factor
: (term)      ( --)
    $pop  0null ROT $push  ( end beg)   \ defer operator
    DUP   leading-?
    IF   1+ ['] FNEGATE  ELSE  'noop  THEN  >R
    ['] [term]  defines [remap]
    do_term   ( end beg ptr state)
    CASE   ( *)  3 OF   ['] F*  %arrange
                        factor term         ENDOF
           ( /)  4 OF   ['] F/  %arrange
                        factor term         ENDOF
           (  )  5 OF   DROP  'noop $push
                        factor              ENDOF
    ENDCASE
    R> .op  factor      \ emit deferred ops
;

' (term)  defines term      \ resolve forward reference

\ id -> letter {letter|digit}+    unlimited chars

16 table: [id]
1 'dfa  [id]  2 1 install
2 'dfa  [id]  4 +  C!

: id?   ( end beg -- f)
    DUP C@  [token] [id] 1 =  DUP >R   ?step
    \ skip initial letter, save flag
    BEGIN  DUP C@  [token] [id] 0>
    WHILE  1+  REPEAT               \ skip dig or let
    <  R> AND   ;

: F@?   ( op -- op)  DUP  ['] F!  <>  IF  ['] F@  .op  THEN  ;

: .id   ( op end beg)   (do_id)  F@?  ;

: compile_id  ( beg end --)
    make$  CAPS-FIND            ( xt|adr f)
    0=  IF  COUNT TYPE  ."  Not found" ABORT  THEN
    COMPILE,  ;

: fp#?   ends->count  >FLOAT  ;

: (expr)?    ( end beg -- flag)     \ "enclosed" ?
    C@  [CHAR] ( =   SWAP
    C@  [CHAR] ) =   AND  ;

: -()    ( op end beg -- end-1 beg+1) \ remove parens
    1+  SWAP  1-  SWAP   ;

: expose   -()     ROT  $push  ;

16 table: [f1^f2]
 1 'dfa   [f1^f2]   6  5 install     \ ( or {
 2 'dfa   [f1^f2]   8  7 install     \ ) or }
 0 'dfa   [f1^f2]  11  + C!          \ *
 0 'dfa   [f1^f2]  12  + C!          \ /
 5 'dfa   [f1^f2]  13  + C!          \ ^

'dfa [f1^f2]  13  +  CONSTANT  '^
'dfa [f1^f2]  14  +  CONSTANT  ',


: f1^f2?     ( end beg -- end beg ptr f)
    [']  [f1^f2]  defines  [remap]
    do_term  ( end beg ptr state)  6 =  ;

: f^2  FDUP  F*  ;
: f^3  FDUP  FDUP  F* F*  ;
: f^4  f^2  f^2  ;

CREATE do^   'noop ,  'noop ,  ' f^2 ,  ' f^3  , ' f^4 ,

: int<5?   ( end beg -- n TRUE | n FALSE)
    ends->count  0.0  2SWAP  >NUMBER
    0=  IF   2DROP  DUP  5 <
        ELSE 2DROP  FALSE  THEN ;

: f1^f2!     ( end beg ptr --)
    &arrange    ( ptr-1 beg end ptr+1)
    2DUP  int<5?   IF   NIP NIP CELLS do^ + @  0null ROT
                   ELSE DROP ['] F**   THEN
    $push   'noop $push    factor   factor  ;

: id{}?   ( end beg -- ptr|0)
    2DUP  [CHAR] {  find_char       ( end beg ptr|0)
    DUP   IF  DUP >R 1- SWAP        ( end ptr-1 beg)
              id?  >R               \ suspenders & belt
              C@  [CHAR] } =        \ last char = }
              R>  AND  R>  AND      ( ptr|0)
          ELSE  NIP NIP   THEN  ;   ( 0)

CREATE  temp  32 ALLOT


CREATE }$ 1 C, CHAR } C,

: thru{   ( ptr -- ptr' n)
    DUP  BEGIN  DUP  C@   [CHAR] { =  WHILE  1+
         REPEAT             ( ptr ptr'+1)
    1-  TUCK  SWAP -  1+  ;

v: (.id{})

: .id{}       ( op c-adr u)  (.id{})  F@?  ;

: id{}!   ( end beg ptr --)
    thru{ ( end beg ptr' n)  >R     \ save n
    TUCK SWAP                       ( end ptr ptr beg)
    make$  bl$ $+ PAD temp $!       ( end ptr)
    1+ SWAP  R@ - SWAP  make$
    COUNT  OVER + SWAP
    DO  I C@  [CHAR] _ =
        IF  BL I C!  THEN
    LOOP                            \ change _ to blank
    PAD  bl$  $+  R> 0  DO PAD }$  $+  LOOP  PAD BL$  $+
    temp  PAD  $+
    temp  COUNT  .id{}
;

: fn?   ( end beg -- ptr|0)         \ fn -> id arglist
    2DUP                            ( end beg end beg)
    [CHAR] (   find_char            \ find first "("
    ( end beg ptr|0)   ?DUP
    IF  ROT OVER                    ( beg ptr end ptr)
        (expr)?  >R  TUCK 1- SWAP   ( ptr ptr-1 beg)
        id?   R>  AND  AND
    ELSE  2DROP  0  THEN ;

: find),(    ( end beg -- end beg ptr|0)
    5 ', C!   0 '^  C!              \ remap [f1^f2]
    f1^f2?   AND
    0 ', C!   5 '^  C!  ;

: list!       ( --)
    $pop                            ( end beg op)
    >R                              \ save op
    find),(                         \ -> )comma(
    ?DUP  IF  'noop  %arrange  expr  RECURSE
          ELSE  'noop  $push  expr  THEN
    R>  .op  ;                      \ emit saved op

CREATE  F$  1 C, CHAR F C,

: fn!   ( end beg ptr --)       \ ptr points to (
    TUCK  1-  SWAP              ( end ptr ptr-1 beg)
    make$                       ( end ptr $adr)
    F$ temp $!  temp SWAP  $+   \ name->Fname
    temp CAPS-FIND  ?DUP        \ look up Fname
    0=  IF  DROP  PAD CAPS-FIND \ else look up name
        THEN                    ( end ptr xt f)
    0=  ABORT" Function not defined!"
    -ROT   expose   ;           \ remove parens, arrange
    ( $: arglist 'fn)


\ factor -> id | fp# | (expr) | factor^factor |
\           id{ Forth_int_expr } | function
: (factor)    
    $pop  -ROT      ( op end beg)
    2DUP  0null D=  IF  2DROP  .op      EXIT  THEN
    2DUP  id?       IF  .id    .op      EXIT  THEN
    2DUP  fp#?      IF  .fp# 2DROP .op  EXIT  THEN
    f1^f2?          IF  f1^f2!  .op     EXIT  THEN   DROP
    2DUP  (expr)?   IF  expose  expr    EXIT  THEN
    2DUP id{}? ?DUP IF  id{}!   .op     EXIT  THEN
    2DUP fn?   ?DUP IF  fn!  list!   .op      THEN
;


' (factor) defines factor

FORTH-WORDLIST   SET-CURRENT            \ definitions to FORTH

: f."   ( formula --)           \ for testing
    ['] .NAME  defines (.op)    \ revector operators
    ['] FE.    defines .fp#
    ['] expr.  defines (do_id)
    ['] TYPE   defines (.id{})
    aword"  CR  assign  ;

: f"    ( formula --)            \ for compiling
    state @  0= ABORT" Compile only!"
    ['] COMPILE,   defines (.op) \ revector operators
    ['] FLITERAL   defines .fp#
    ['] compile_id defines (do_id)
    ['] EVALUATE   defines (.id{})
    aword" assign   ; IMMEDIATE

GET-ORDER  NIP  1-  SET-ORDER           \ hide ftran definitions

\ ---------------------------------------------- program ends here


