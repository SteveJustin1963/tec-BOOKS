\
\ FPOUT.F  version 3.5
\
\ A Forth floating-point output words package
\
\ Main words:
\
\   Compact   Formatted   String
\   -------   ---------   ------
\   FS.       FS.R        (FS.)     Scientific
\   FE.       FE.R        (FE.)     Engineering
\   F.        F.R         (F.)      Fixed-point
\   G.        G.R         (G.)      General
\
\   FDP ( -- a-addr )
\
\   A variable controlling decimal point display.  If zero
\   then trailing decimal points are not shown. If non-zero
\   (default state) the decimal point is always displayed.
\
\   FECHAR ( -- a-addr )
\
\   A variable containing the output character used to
\   indicate the exponent. Default is 'E'.
\
\   FEDIGITS ( -- a-addr )
\
\   A variable containing the minimum number of digits
\   output for the exponent. Must be 2 or more. Default
\   is 2. Does not affect compact modes.
\
\ Notes:
\
\ Display words that specify the number of places after
\ the decimal point may use the value -1 to force compact
\ mode.  Compact mode displays all significant digits
\ with redundant zeros and signs removed.  FS. FE. F. G.
\ are displayed in compact mode.
\
\ The character string returned by (FS.) (FE.) (F.) (G.)
\ resides in the pictured-numeric output area.
\
\ An ambiguous condition exists if: BASE is not decimal;
\ character string exceeds pictured-numeric output area;
\ PRECISION is set greater than MAX-FLOAT-DIGITS.
\
\ For use with separate or common stack floating-point
\ Forth models.
\
\ This code is PUBLIC DOMAIN.  Use at your own risk.
\
\ *****************************************************
\ This version of FPOUT requires REPRESENT conform to
\ the specification proposed here:
\
\  ftp://ftp.taygeta.com/pub/Forth/Applications/ANS/
\  Represent_30.txt  (2010-12-05)
\
\ If your Forth does not have a compliant REPRESENT
\ then use FPOUT v2.2 instead.
\ *****************************************************
\
\ History:
\
\ v3.1 2006-11-13 es  Demo for REPRESENT proposal.
\ v3.2 2007-06-05 es  Changed default to trailing
\                     decimal point on.
\ v3.3 2007-11-19 es  Add FECHAR FEDIGITS. Fix zero
\                     sign in (F.) F.R
\ v3.4 2008-01-23 es  Updated to REPRESENT spec 2.1
\ v3.5 2010-12-05 es  Updated to REPRESENT spec 3.0
\

CR .( Loading FPOUT 3.5  2010-12-05 ... ) CR

DECIMAL

\ Compile application

CREATE FDP  2 CELLS ALLOT
VARIABLE FECHAR
VARIABLE FEDIGITS

\ ******************  USER OPTIONS  *******************

1 FDP !                 \ trailing decimal point control
2 FEDIGITS !            \ minimum exponent digits
CHAR E FECHAR !         \ output character for exponent

\ *****************************************************

S" MAX-FLOAT-DIGITS" ENVIRONMENT? 0= [IF]
  CR .( MAX-FLOAT-DIGITS not found ) ABORT
[THEN]  ( u )

\ Define PRECISION SET-PRECISION if not present

[UNDEFINED] PRECISION [IF]

( u ) DUP VALUE PRECISION ( -- u )

: SET-PRECISION  ( u -- )
  DUP  1 [ PRECISION 1+ ] LITERAL  WITHIN AND
  ?DUP IF  TO PRECISION  THEN ;

[THEN]

( u ) CONSTANT mp#      \ maximum usable precision

S" REPRESENT-CHARS" ENVIRONMENT? 0= [IF]  mp#  [THEN]

( u ) CONSTANT mc#      \ maximum float chars

CREATE fbuf  mc# CHARS ALLOT

0 VALUE ex#             \ exponent
0 VALUE sn#             \ sign
0 VALUE ef#             \ exponent factor  1=FS. 3=FE.
0 VALUE pl#             \ +n  places right of decimal point
                        \ -1  compact display

\ get exponent, sign, flag2
: (f1)  ( F: r -- r ) ( -- exp sign flag2 )
  FDUP fbuf PRECISION REPRESENT ;

\ apply exponent factor
: (f2)  ( exp -- offset exp2 )
  S>D ef# FM/MOD ef# * ;

\ float to ascii
: (f3)  ( F: r -- ) ( places -- c-addr u flag )
  TO pl#  (f1) NIP AND ( exp & flag2 )
  pl# 0< IF
    DROP PRECISION
  ELSE
    ef# 0> IF  1- (f2) DROP 1+  THEN  pl# +
  THEN  PRECISION MIN  fbuf SWAP REPRESENT >R
  TO sn#  TO ex#  fbuf mc# -TRAILING  R> <# ;

\ insert exponent
: (f4)  ( exp -- )
  DUP  ABS S>D  pl# 0< 0=  DUP >R  IF  FEDIGITS @
  1 DO # LOOP  THEN  #S 2DROP  DUP SIGN  0< 0=
  R> AND IF  [CHAR] + HOLD  THEN  FECHAR @ HOLD ;

\ insert digit and update flag
: (f5)  ( char -- )
  HOLD  1 FDP CELL+ ! ;

\ insert string
: (f6)  ( c-addr u -- )
  0 MAX  BEGIN  DUP  WHILE  1- 2DUP CHARS + C@ (f5)
  REPEAT 2DROP ;

\ insert '0's
: (f7)  ( n -- )
  0 MAX 0 ?DO [CHAR] 0 (f5) LOOP ;

\ insert sign
: (f8)  ( -- )
  sn# SIGN  0 0 #> ;

\ trim trailing '0's
: (f9)  ( c-addr u1 -- c-addr u2 )
  pl# 0< IF
    BEGIN  DUP WHILE  1- 2DUP CHARS +
    C@ [CHAR] 0 -  UNTIL  1+  THEN
  THEN ;

: (fa)  ( n -- n n|pl# )
  pl# 0< IF  DUP  ELSE  pl#  THEN ;

\ insert fraction string n places right of dec. point
: (fb)  ( c-addr u n -- )
  0 FDP CELL+ !
  >R (f9)  R@ +
  (fa) OVER - (f7)     \ trailing 0's
  (fa) MIN  R@ - (f6)  \ fraction
  R> (fa) MIN (f7)     \ leading 0's
  FDP 2@ OR IF
    [CHAR] . HOLD
  THEN ;

\ split string into integer/fraction parts at n and insert
: (fc)  ( c-addr u n -- )
  >R  2DUP R@ MIN 2SWAP R> /STRING  0 (fb) (f6) ;

\ exponent form
: (fd)  ( F: r -- ) ( n factor -- c-addr u )
  TO ef#  (f3) IF  ex# 1- (f2) (f4) 1+ (fc) (f8)  THEN ;

\ display c-addr u right-justified in field width u2
: (fe)  ( c-addr u u2 -- )
  OVER - SPACES TYPE ;

\ These are the main words

\ Convert real number r to a string c-addr u in scientific
\ notation with n places right of the decimal point.

: (FS.)  ( F: r -- ) ( n -- c-addr u )
  1 (fd) ;

\ Display real number r in scientific notation right-
\ justified in a field width u with n places right of the
\ decimal point.

: FS.R  ( F: r -- ) ( n u -- )
  >R (FS.) R> (fe) ;

\ Display real number r in scientific notation followed by
\ a space.

: FS.  ( F: r -- )
  -1 0 FS.R SPACE ;

\ Convert real number r to a string c-addr u in engineering
\ notation with n places right of the decimal point.

: (FE.)  ( F: r -- ) ( n -- c-addr u )
  3 (fd) ;

\ Display real number r in engineering notation right-
\ justified in a field width u with n places right of the
\ decimal point.

: FE.R  ( F: r -- ) ( n u -- )
  >R (FE.) R> (fe) ;

\ Display real number r in engineering notation followed
\ by a space.

: FE.  ( F: r -- )
  -1 0 FE.R SPACE ;

\ Convert real number r to string c-addr u in fixed-point
\ notation with n places right of the decimal point.

: (F.)  ( F: r -- ) ( n -- c-addr u )
  0 TO ef#  (f3) IF
    ex#  DUP mc# > IF
      fbuf 0 ( dummy ) 0 (fb)
      mc# - (f7) (f6)
    ELSE
      DUP 0> IF
        (fc)
      ELSE
        ABS (fb) 1 (f7)
      THEN
    THEN (f8)
  THEN ;

\ Display real number r in fixed-point notation right-
\ justified in a field width u with n places right of the
\ decimal point.

: F.R  ( F: r -- ) ( n u -- )
  >R (F.) R> (fe) ;

\ Display real number r in fixed-point notation followed
\ by a space.

: F.  ( F: r -- )
  -1 0 F.R SPACE ;

\ Convert real number r to string c-addr u with n places
\ right of the decimal point.  Fixed-point is used if the
\ exponent is in the range -4 to 5 otherwise use scientific
\ notation.

: (G.)  ( F: r -- ) ( n -- c-addr u )
  >R  (f1) NIP AND [ -4 1+ ] LITERAL [ 5 2 + ] LITERAL WITHIN
  R> SWAP IF  (F.)  ELSE  (FS.)  THEN ;

\ Display real number r right-justified in a field width u
\ with n places right of the decimal point.  Fixed-point
\ is used if the exponent is in the range -4 to 5 otherwise
\ use scientific notation.

: G.R  ( F: r -- ) ( n u -- )
  >R (G.) R> (fe) ;

\ Display real number r followed by a space.  Fixed-point
\ is used if the exponent is in the range -4 to 5 otherwise
\ use scientific notation.

: G.  ( F: r -- )
  -1 0 G.R SPACE ;

CR  FDP @ [IF]
  CR .( Decimal point always displayed.  Use  0 FDP ! )
  CR .( or  FDP OFF  to disable trailing decimal point. )
[ELSE]
  CR .( Trailing decimal point not displayed.  Use )
  CR .( 1 FDP !  or  FDP ON  for FORTH-94 compliance. )
[THEN]  CR

\ ******************  DEMONSTRATION  ******************

0 [IF]

CR .( Loading demo words... ) CR
CR .( TEST1  formatted, n decimal places )
CR .( TEST2  compact & right-justified )
CR .( TEST3  display FS. )
CR .( TEST4  display F. )
CR .( TEST5  display G. )
CR .( TEST6  display 8087 non-numbers ) CR
CR .( 'n PLACES' sets decimal places for TEST1. )
CR .( SET-PRECISION sets maximum significant )
CR .( digits displayable. )
CR CR

[UNDEFINED] F, [IF]
: F,  ( r -- )  FALIGN HERE 1 FLOATS ALLOT F! ;
[THEN]

CREATE f-array  \ floating-point numbers array

FALIGN HERE
1.23456E-16  F,
1.23456E-11  F,
1.23456E-7   F,
1.23456E-6   F,
1.23456E-5   F,
1.23456E-4   F,
1.23456E-3   F,
1.23456E-2   F,
1.23456E-1   F,
0.E0         F,
1.23456E+0   F,
1.23456E+1   F,
1.23456E+2   F,
1.23456E+3   F,
1.23456E+4   F,
1.23456E+5   F,
1.23456E+6   F,
1.23456E+7   F,
1.23456E+11  F,
1.23456E+16  F,
HERE SWAP -  1 FLOATS /  CONSTANT #numbers

: do-it  ( xt -- )
  #numbers 0 DO
    f-array FALIGNED I FLOATS +
    OVER >R  F@  CR  R> EXECUTE
  LOOP DROP ;

2VARIABLE (dw)
: d.w  ( -- dec.places width )  (dw) 2@ ;
: PLACES ( places -- ) d.w SWAP DROP (dw) 2! ;
: WIDTH  ( width -- )  d.w DROP SWAP (dw) 2! ;

5 PLACES  19 WIDTH

: (t1)  ( r -- )
  FDUP d.w FS.R  FDUP d.w F.R  FDUP d.w G.R  d.w FE.R ;

: TEST1  ( -- )
  CR ." TEST1   right-justified, formatted ("
  d.w DROP 0 .R ."  decimal places)" CR
  ['] (t1) do-it  CR ;

: (t2)  ( r -- )
  FDUP -1 d.w NIP FS.R  FDUP -1 d.w NIP F.R
  FDUP -1 d.w NIP G.R        -1 d.w NIP FE.R ;

: TEST2  ( -- )
  CR ." TEST2   right-justified, compact" CR
  ['] (t2) do-it  CR ;

: TEST3  ( -- )
  CR ." TEST3   FS."
  CR ['] FS. do-it  CR ;

: TEST4  ( -- )
  CR ." TEST4   F."
  CR ['] F. do-it  CR ;

: TEST5  ( -- )
  CR ." TEST5   G."
  CR ['] G. do-it  CR ;

: TEST6  ( -- )
  PRECISION >R  1 SET-PRECISION
  CR ." TEST6   8087 non-numbers  PRECISION = 1" CR
  CR 1.E0 0.E0 F/  FDUP G.
  CR FNEGATE            G.
  CR 0.E0 0.E0 F/  FDUP G.
  CR FNEGATE            G.
  CR
  R> SET-PRECISION ;

[ELSE]

CR .( To compile demonstration words TEST1..TEST6 )
CR .( enable conditional in FPOUT source. ) CR

[THEN]

\ end
