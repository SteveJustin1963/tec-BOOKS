\ FPOUT.F   version 2.0
\
\ A Floating Point Output Words package for ANS FORTH-94
\ compliant systems.
\
\ This code is public domain.  Use at your own risk.
\
\ Main words:
\
\  Compact   Formatted   String
\  -------   ---------   ------
\  FS.       FS.R        (FS.)     Scientific
\  FE.       FE.R        (FE.)     Engineering
\  F.        F.R         (F.)      Fixed-point
\  G.        G.R         (G.)      General
\
\  FDP ( -- a-addr )
\
\    A variable controlling decimal point display.  If zero
\    (default state) trailing decimal points are not shown.
\    If non-zero the decimal point is always displayed.
\
\ Notes:
\
\ 1. An ambiguous condition exists if the value of BASE is
\    not (decimal) ten or if the character string
\    representation exceeds the size of the pictured numeric
\    output string buffer.
\
\ 2. Works on either separate floating-point stack or common
\    stack forth models.
\
\ 3. Opinions vary as to the correct display for F. FS. FE.
\    One useful interpretation of the Forth-94 Standard has
\    been chosen here.  See also note 9.
\
\ 4. Display words that specify the number of places after
\    the decimal point may use the value -1 to force compact
\    mode.  Compact mode displays all significant digits
\    with redundant zeros and signs removed.  FS. F. FE. G.
\    are displayed in compact mode.
\
\ 5. Ideally all but the main words and user options should
\    be headerless or else placed in a hidden vocabulary.
\    Code size may be reduced by eliminating features not
\    needed e.g. if REPRESENT always returns flag2=true or
\    if CHARS is a no-operation.  Those without VALUE TO
\    can use VARIABLE etc if appropriate changes are made.
\
\ 6. If your REPRESENT does not return an exponent of +1
\    in the case of 0.0E it will result in multiple leading
\    zeros being displayed.  This is a bug** and you should
\    have it fixed!  In the meantime, a work-around in the
\    form of an alternate (F3) is supplied.
\
\ 7. If your REPRESENT does not blank fill the remainder
\    of the buffer when NAN or other graphic string is
\    returned then unspecified trailing characters will be
\    displayed.  Again, this is a bug** in your REPRESENT.
\    Unfortunately no work-around is possible.
\
\ 8. Manual rounding is used in instances when REPRESENT
\    can't e.g. when the whole significand is rounded up.
\
\ 9. FORTH-94 requires F. FS. to always display a decimal
\    point.  FPOUT variable FDP controls this feature.
\
\ ** FORTH-94 is silent on this point.
\
\ History:
\
\ v1.1  15-Sep-02  es   First release
\ v1.2  14-Jan-05  es   Display decimal point if places = 0.
\                       Added (G.) G.
\ v1.3  16-Jan-05  es   Implemented compact display
\ v1.4  20-Jan-05  es   Handle NAN INF etc
\ v1.5  30-Jan-05  es   Implemented rounding. Changed (G.)
\                       G. upper limit.
\ v1.6  01-Feb-05  es   Changed (G.) to use decimal places
\                       parameter. Added G.R
\ v1.7  21-Feb-05  es   Fixed rounding error which occurred
\                       under certain conditions.
\ v1.8  23-Jul-05  es   Rounder fixed & changed to IEEE.
\                       Negative zero support.
\ v1.9  10-Nov-05  es   Fix engineering fn's for precision
\                       less than 3. Compatible with IEEE
\                       or arithmetic rounding. Add decimal
\                       point control.
\ v2.0  04-Sep-06  es   Fix decade overflow in F.R modes
\                       when using zero decimal places.

CR .( Loading FPOUT v2.0  4-Sep-06 ... ) CR

DECIMAL

CREATE FDP  2 CELLS ALLOT  \ decimal point display control

\ User options

0 FDP !                    \ default is off

\ End of user options


\ 6 VALUE PRECISION       \ uncomment this line if you don't
                        \ already have PRECISION

20 VALUE MP#            \ set this equal to or greater than
                        \ your maximum PRECISION

CREATE FBUF  MP# CHARS ALLOT

0 VALUE EX#             \ exponent
0 VALUE SN#             \ sign
0 VALUE EF#             \ exponent factor  1=FS. 3=FE.
0 VALUE PL#             \ +n  places right of decimal point
                        \ -1  compact display

\ trim trailing '0's
: (F0)  ( c-addr u1 -- c-addr u2 )
  BEGIN  DUP WHILE  1- 2DUP CHARS +
  C@ [CHAR] 0 -  UNTIL  1+  THEN ;

\ get exponent, sign, flag2
: (F1)  ( F: r -- r ) ( -- exp sign flag2 )
  FDUP FBUF PRECISION REPRESENT ;

\ apply exponent factor
: (F2)  ( exp -- offset exp2 )
  S>D EF# FM/MOD EF# * ;

CR .( Testing your REPRESENT characteristics... ) CR

\ Test if enhanced REPRESENT is present. See:
\ ftp.taygeta.com/pub/Forth/Applications/ANS/Represent_11.txt
\ If found the usual work-arounds are bypassed and simpler
\ code is installed.  Note: this test involves checking
\ REPRESENT outside Forth-94 limits which may cause some
\ systems to crash.

0 [IF]  \ enhanced REPRESENT test

CR .( Should it hang or crash at this point, you will )
CR .( need to disable the enhanced REPRESENT test. ) CR

CHAR X  PAD C!  \ any non-digit char

-9.0E0 PAD 0 REPRESENT ( sign & flag2 ) AND
SWAP 2 = ( exp ) AND
PAD C@  CHAR 1  = ( rounded digit ) AND

[ELSE]

CR .( Enhanced REPRESENT test disabled.  See FPOUT )
CR .( source for details. ) CR

0

[THEN]

[IF]  ( best case )

CR .( Enhanced REPRESENT found.  Skipping work-arounds... )
CR

\ float to ascii
: (F3)  ( F: r -- ) ( places -- c-addr u flag )
  TO PL#  (F1) NIP AND ( exp & flag2 )
  PL# 0< IF
    DROP PRECISION
  ELSE
    EF# 0> IF  1- (F2) DROP 1+  THEN  PL# +
  THEN  0 MAX  PRECISION MIN  >R  FBUF
  DUP MP# [CHAR] 0 FILL
  R@ REPRESENT >R  TO SN#  TO EX#
  R>  FBUF R>  1 MAX  -TRAILING  ROT <# ;

[ELSE]  ( most implementations )

CR .( Installing work-arounds... ) CR

0 VALUE  BS#            \ buffer size
0 VALUE  NZ#            \ negative zero flag

0.5E0 FROUND F0= TO BS#  \ determine rounding method

-0.E0 PAD 50 REPRESENT DROP

[IF]  ( system responds to negative zero )
  1 TO NZ#
[THEN]

1 = [IF] ( exponent correct )

\ float to ascii
: (F3)  ( F: r -- ) ( places -- c-addr u flag )
  TO PL#  (F1) SWAP ( r exp flag2 sgn )
  \ save sign for negative zero systems
  [ NZ# ] [IF]  TO NZ#  [ELSE]  DROP  [THEN]
  AND ( exp & flag2 )  PL# 0< IF
    DROP PRECISION
  ELSE
    EF# 0> IF  1- (F2) DROP 1+  THEN  PL# +
  THEN
  DUP ( size ) 0= >R  1 MAX  PRECISION MIN  TO BS#
  FBUF  R@ IF  PRECISION  ELSE  BS#  THEN
  OVER MP# [CHAR] 0 FILL
  REPRESENT DUP  R> AND IF ( flag2 & size=0 )
    >R  FBUF C@  [ BS# ] [IF] DUP  [THEN]
    [CHAR] 5 <   [ BS# ] [IF] SWAP
    [CHAR] 5 =
    FBUF PRECISION  1 /STRING (F0) NIP 0=  AND
    OR ( exactly 5 or less ) [THEN]
    IF    2DROP  1 NZ#  [CHAR] 0
    ELSE  SWAP 1+ SWAP  [CHAR] 1
    THEN  FBUF  DUP MP# [CHAR] 0 FILL  C!
    R>
  THEN
  >R  TO SN#  TO EX#  FBUF BS#  -TRAILING  R> <# ;

[ELSE]  ( wrong exponent! )

CR .( WARNING: your REPRESENT does not return exponent )
CR .( of +1 for 0.0E.  Compensating... ) CR

\ use this definition if you have a buggy REPRESENT
\ float to ascii
: (F3)  ( F: r -- ) ( places -- c-addr u flag )
  TO PL#  (F1) SWAP ( r exp flag2 sgn )
  \ save sign for negative zero systems
  [ NZ# ] [IF]  TO NZ#  [ELSE]  DROP  [THEN]
  FBUF C@ [CHAR] 0 = IF ( r=0 )
    >R  DROP FDROP  1 NZ#  R> ( exp sgn flag2 )
  ELSE
    AND ( exp & flag2 )  PL# 0< IF
      DROP PRECISION
    ELSE
      EF# 0> IF  1- (F2) DROP 1+  THEN  PL# +
    THEN
    DUP ( size ) 0= >R  1 MAX  PRECISION MIN  TO BS#
    FBUF  R@ IF  PRECISION  ELSE  BS#  THEN
    OVER MP# [CHAR] 0 FILL
    REPRESENT DUP  R> AND IF ( flag2 & size=0 )
      >R  FBUF C@  [ BS# ] [IF] DUP  [THEN]
      [CHAR] 5 <   [ BS# ] [IF] SWAP
      [CHAR] 5 =
      FBUF PRECISION  1 /STRING (F0) NIP 0=  AND
      OR ( exactly 5 or less ) [THEN]
      IF    2DROP  1 NZ#  [CHAR] 0
      ELSE  SWAP 1+ SWAP  [CHAR] 1
      THEN  FBUF  DUP MP# [CHAR] 0 FILL  C!
      R>
    THEN
  THEN
  >R  TO SN#  TO EX#  FBUF BS#  -TRAILING  R> <# ;

[THEN]

[THEN]

\ insert exponent (uncomment the # if you wish to maintain
\ alignment for exponents > 99 )
: (F4)  ( exp -- )
  PL# 0< >R  DUP ABS S>D  R@ 0= IF # ( # ) THEN
  #S 2DROP  DUP SIGN  0< R> OR 0= IF [CHAR] + HOLD THEN
  [CHAR] E HOLD ;

\ insert digit and update flag
: (F5)  ( char -- )
  HOLD  1 FDP CELL+ ! ;

\ insert string
: (F6)  ( c-addr u -- )
  0 MAX  BEGIN  DUP  WHILE  1- 2DUP CHARS + C@ (F5)
  REPEAT 2DROP ;

\ insert '0's
: (F7)  ( n -- )
  0 MAX 0 ?DO [CHAR] 0 (F5) LOOP ;

\ insert sign
: (F8)  ( -- )
  SN# SIGN  0 0 #> ;

\ trim trailing '0's
: (F9)  ( c-addr u1 -- c-addr u2 )
  PL# 0< IF  (F0)  THEN ;

: (FA)  ( n -- n n|pl# )
  PL# 0< IF  DUP  ELSE  PL#  THEN ;

\ insert fraction string n places right of dec. point
: (FB)  ( c-addr u n -- )
  0 FDP CELL+ !
  >R (F9)  R@ +
  (FA) OVER - (F7)     \ trailing 0's
  (FA) MIN  R@ - (F6)  \ fraction
  R> (FA) MIN (F7)     \ leading 0's
  FDP 2@ OR IF
    [CHAR] . HOLD
  THEN ;

\ split string into integer/fraction parts at n and insert
: (FC)  ( c-addr u n -- )
  >R  EF# MAX  2DUP R@ MIN 2SWAP R> /STRING  0 (FB) (F6) ;

\ exponent form
: (FD)  ( F: r -- ) ( n factor -- c-addr u )
  TO EF# (F3) IF  EX# 1- (F2) (F4) 1+ (FC) (F8)  THEN ;

\ display c-addr u right-justified in field width u2
: (FE)  ( c-addr u u2 -- )
  OVER - SPACES TYPE ;

\ These are the main words

\ Convert real number r to a string c-addr u in scientific
\ notation with n places right of the decimal point.

: (FS.)  ( F: r -- ) ( n -- c-addr u )
  1 (FD) ;

\ Display real number r in scientific notation right-
\ justified in a field width u with n places right of the
\ decimal point.

: FS.R  ( F: r -- ) ( n u -- )
  >R (FS.) R> (FE) ;

\ Display real number r in scientific notation followed by
\ a space.

: FS.  ( F: r -- )
  -1 0 FS.R SPACE ;

\ Convert real number r to a string c-addr u in engineering
\ notation with n places right of the decimal point.

: (FE.)  ( F: r -- ) ( n -- c-addr u )
  3 (FD) ;

\ Display real number r in engineering notation right-
\ justified in a field width u with n places right of the
\ decimal point.

: FE.R  ( F: r -- ) ( n u -- )
  >R (FE.) R> (FE) ;

\ Display real number r in engineering notation followed
\ by a space.

: FE.  ( F: r -- )
  -1 0 FE.R SPACE ;

\ Convert real number r to string c-addr u in fixed-point
\ notation with n places right of the decimal point.

: (F.)  ( F: r -- ) ( n -- c-addr u )
  0 TO EF#  (F3) IF
    DROP MP#  EX#  DUP MP# > IF
      FBUF 0 ( dummy ) 0 (FB)
      MP# - (F7) (F6)
    ELSE
      DUP 0> IF
        (FC)
      ELSE
        ABS (FB) 1 (F7)
      THEN
    THEN (F8)
  THEN ;

\ Display real number r in fixed-point notation right-
\ justified in a field width u with n places right of the
\ decimal point.

: F.R  ( F: r -- ) ( n u -- )
  >R (F.) R> (FE) ;

\ Display real number r in fixed-point notation followed
\ by a space.

: F.  ( F: r -- )
  -1 0 F.R SPACE ;

\ Convert real number r to string c-addr u with n places
\ right of the decimal point.  Fixed-point is used if the
\ exponent is in the range -4 to 5 otherwise use scientific
\ notation.

: (G.)  ( F: r -- ) ( n -- c-addr u )
  >R  (F1) NIP AND [ -4 1+ ] LITERAL [ 5 2 + ] LITERAL WITHIN
  R> SWAP IF  (F.)  ELSE  (FS.)  THEN ;

\ Display real number r right-justified in a field width u
\ with n places right of the decimal point.  Fixed-point
\ is used if the exponent is in the range -4 to 5 otherwise
\ use scientific notation.

: G.R  ( F: r -- ) ( n u -- )
  >R (G.) R> (FE) ;

\ Display real number r followed by a space.  Fixed-point
\ is used if the exponent is in the range -4 to 5 otherwise
\ use scientific notation.

: G.  ( F: r -- )
  -1 0 G.R SPACE ;

CR  FDP @ [IF]
  CR .( Decimal point always displayed.  Use  FDP OFF )
  CR .( or  0 FDP !  to restore default mode. )
[ELSE]
  CR .( Default is trailing decimal point off.  Use )
  CR .( FDP ON  or  1 FDP !  for FORTH-94 compliance. )
[THEN]  CR

0 [IF]  \ compile demo

CR .( Loading demo words... ) CR
CR .( TEST1  formatted, n decimal places )
CR .( TEST2  compact & right-justified )
CR .( TEST3  display FS. )
CR .( TEST4  display F. )
CR .( TEST5  display G. ) CR
CR .( 'n PLACES' sets decimal places for TEST1. )
CR .( SET-PRECISION [if you have it] sets maximum )
CR .( significant digits displayable. )
CR CR

2VARIABLE (dw)
: d.w  ( -- dec.places width )  (dw) 2@ ;
: PLACES ( places -- ) d.w SWAP DROP (dw) 2! ;
: WIDTH  ( width -- )  d.w DROP SWAP (dw) 2! ;

5 PLACES  19 WIDTH

: T1  ( r -- )
  FDUP d.w FS.R  FDUP d.w F.R  FDUP d.w G.R  d.w FE.R ;

: TEST1  ( -- )
  CR ." TEST1 ... right-justified, formatted ("
  d.w DROP 0 .R ."  decimal places)" CR
  CR 1.23456E-16  T1
  CR 1.23456E-11  T1
  CR 1.23456E-7   T1
  CR 1.23456E-6   T1
  CR 1.23456E-5   T1
  CR 1.23456E-4   T1
  CR 1.23456E-3   T1
  CR 1.23456E-2   T1
  CR 1.23456E-1   T1
  CR 0.E0         T1
  CR 1.23456E+0   T1
  CR 1.23456E+1   T1
  CR 1.23456E+2   T1
  CR 1.23456E+3   T1
  CR 1.23456E+4   T1
  CR 1.23456E+5   T1
  CR 1.23456E+6   T1
  CR 1.23456E+7   T1
  CR 1.23456E+11  T1
  CR 1.23456E+16  T1
  CR ;

: T2  ( r -- )
  FDUP -1 d.w NIP FS.R  FDUP -1 d.w NIP F.R
  FDUP -1 d.w NIP G.R        -1 d.w NIP FE.R ;

: TEST2  ( -- )
  CR ." TEST2 ... right-justified, compact" CR
  CR 1.23456E-16  T2
  CR 1.23456E-11  T2
  CR 1.23456E-7   T2
  CR 1.23456E-6   T2
  CR 1.23456E-5   T2
  CR 1.23456E-4   T2
  CR 1.23456E-3   T2
  CR 1.23456E-2   T2
  CR 1.23456E-1   T2
  CR 0.E0         T2
  CR 1.23456E+0   T2
  CR 1.23456E+1   T2
  CR 1.23456E+2   T2
  CR 1.23456E+3   T2
  CR 1.23456E+4   T2
  CR 1.23456E+5   T2
  CR 1.23456E+6   T2
  CR 1.23456E+7   T2
  CR 1.23456E+11  T2
  CR 1.23456E+16  T2
  CR ;

: TEST3  ( -- )
  CR ." TEST3 ... FS." CR
  CR 1.23456E-16  FS.
  CR 1.23456E-11  FS.
  CR 1.23456E-7   FS.
  CR 1.23456E-6   FS.
  CR 1.23456E-5   FS.
  CR 1.23456E-4   FS.
  CR 1.23456E-3   FS.
  CR 1.23456E-2   FS.
  CR 1.23456E-1   FS.
  CR 0.E0         FS.
  CR 1.23456E+0   FS.
  CR 1.23456E+1   FS.
  CR 1.23456E+2   FS.
  CR 1.23456E+3   FS.
  CR 1.23456E+4   FS.
  CR 1.23456E+5   FS.
  CR 1.23456E+6   FS.
  CR 1.23456E+7   FS.
  CR 1.23456E+11  FS.
  CR 1.23456E+16  FS.
  CR ;

: TEST4  ( -- )
  CR ." TEST4 ... F." CR
  CR 1.23456E-16  F.
  CR 1.23456E-11  F.
  CR 1.23456E-7   F.
  CR 1.23456E-6   F.
  CR 1.23456E-5   F.
  CR 1.23456E-4   F.
  CR 1.23456E-3   F.
  CR 1.23456E-2   F.
  CR 1.23456E-1   F.
  CR 0.E0         F.
  CR 1.23456E+0   F.
  CR 1.23456E+1   F.
  CR 1.23456E+2   F.
  CR 1.23456E+3   F.
  CR 1.23456E+4   F.
  CR 1.23456E+5   F.
  CR 1.23456E+6   F.
  CR 1.23456E+7   F.
  CR 1.23456E+11  F.
  CR 1.23456E+16  F.
  CR ;

: TEST5  ( -- )
  CR ." TEST5 ... G." CR
  CR 1.23456E-16  G.
  CR 1.23456E-11  G.
  CR 1.23456E-7   G.
  CR 1.23456E-6   G.
  CR 1.23456E-5   G.
  CR 1.23456E-4   G.
  CR 1.23456E-3   G.
  CR 1.23456E-2   G.
  CR 1.23456E-1   G.
  CR 0.E0         G.
  CR 1.23456E+0   G.
  CR 1.23456E+1   G.
  CR 1.23456E+2   G.
  CR 1.23456E+3   G.
  CR 1.23456E+4   G.
  CR 1.23456E+5   G.
  CR 1.23456E+6   G.
  CR 1.23456E+7   G.
  CR 1.23456E+11  G.
  CR 1.23456E+16  G.
  CR ;

[ELSE]

CR .( To compile demo words TEST1..TEST5 enable )
CR .( conditional in FPOUT source. ) CR

[THEN]

\ end
