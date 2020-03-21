\ FPOUT.F
\
\ Floating Point Output Words
\
\ Version:      1.1
\ Date:         15-Sep-02
\
\ This code is public domain.  Use at your own risk.
\
\ It was tested on a 16-bit forth but should run on most
\ ANS forth systems.
\
\ Main words:
\   (FS.) FS.R FS. (FE.) FE.R FE. (F.) F.R F.
\
\ Caveats:
\ - Does not catch errors from REPRESENT
\ - No rounding for 'digits right of decimal point' mode
\
\ Notes:
\ If your REPRESENT does not return an exponent of +1 in the
\ case of 0.0E it will result in multiple leading zeros being
\ displayed.  This is a bug in your REPRESENT and you should
\ have it fixed!  In the meantime, I have supplied a
\ work-around in the form of an alternate definition for (F1).
\

\ 6 CONSTANT PRECISION    \ uncomment this line if you don't
                        \ already have PRECISION

CREATE FBUF             \ string buffer
20 CHARS ALLOT          \ set this to your max precision

VARIABLE PL#            \ places right of decimal point

\ float to ascii
: (F1)  ( F: r -- ) ( n -- sign c-addr u exp )
  PL# !  FBUF PRECISION  REPRESENT DROP SWAP 1-
  FBUF PRECISION  ROT <# ;

\ float to ascii
\ uncomment this definition if you have a buggy REPRESENT
\ : (F1)  ( F: r -- ) ( n -- sign c-addr u exp )
\  PL# !  FDUP F0= IF  FDROP  FBUF PRECISION [CHAR] 0 FILL
\  1 0 0 0=  ELSE  FBUF PRECISION  REPRESENT  THEN  DROP
\  SWAP 1- FBUF PRECISION  ROT <# ;

\ insert exponent
: (F2)  ( exp -- )
  DUP ABS S>D # #S 2DROP 0< IF [CHAR] - ELSE [CHAR] + THEN
  HOLD [CHAR] E HOLD ;

\ insert string
: (F3)  ( c-addr u -- )
  0 MAX DUP CHARS ROT + SWAP 0 ?DO  -1 CHARS + DUP C@ HOLD
  LOOP DROP ;

\ insert '0's
: (F4)  ( n -- )
  0 MAX 0 ?DO  [CHAR] 0 HOLD  LOOP ;

\ insert sign
: (F5)  ( sign -- )
  SIGN 0. #> ;

: (F6)  ( u1 -- u1 u2 )
  PL# @ 0< IF  DUP  ELSE  PL# @  THEN ;

\ insert fraction string n places right of dec. point
: (F7)  ( c-addr u n -- )
  PL# @ IF
    DUP >R  +
    (F6) OVER - (F4)
    (F6) MIN  R@ - (F3)
    R> (F6) MIN (F4)
    [CHAR] . HOLD
  ELSE
    DROP 2DROP
  THEN ;

\ split string into integer/fraction parts at n and insert
: (F8)  ( c-addr u n -- )
  >R 2DUP R@ MIN  2SWAP R> /STRING  0 (F7) (F3) ;

\ trim trailing '0's
: (F9)  ( c-addr u1 -- c-addr u2 )
  PL# @ 0< IF  BEGIN  2DUP 1- CHARS  +  C@ [CHAR] 0 =  WHILE
  1-  REPEAT  THEN ;

\ These are the main words

\ Convert real number r to a string c-addr u in scientific
\ format with n places to the right of the decimal point.
\ If n < 0 then all significant digits are displayed.

: (FS.)  ( F: r -- ) ( n -- c-addr u )
  (F1) (F2) 1 (F8) (F5) ;

\ Display real number r in scientific format right justified
\ in a field width u with n places to the right of the decimal
\ point.  If n < 0 then all significant digits are displayed.

: FS.R  ( F: r -- ) ( n u -- )
  >R (FS.) R> OVER - SPACES TYPE ;

\ Display real number r in scientific format followed by a
\ space.

: FS.  ( F: r -- )
  -1 0 FS.R SPACE ;

\ Convert real number r to a string c-addr u in engineering
\ format with n places to the right of the decimal point.
\ If n < 0 then all significant digits are displayed.

: (FE.)  ( F: r -- ) ( n -- c-addr u )
  (F1)  S>D 3 FM/MOD  3 * (F2) 1+ (F8) (F5) ;

\ Display real number r in engineering format right justified
\ in a field width u with n places to the right of the decimal
\ point.  If n < 0 then all significant digits are displayed.

: FE.R   ( F: r -- ) ( n u -- )
  >R (FE.) R> OVER - SPACES TYPE ;

\ Display real number r in engineering format followed by
\ a space.

: FE.  ( F: r -- )
  -1 0 FE.R SPACE ;

\ Convert real number r to string c-addr u in floating point
\ format with n places to the right of the decimal point.
\ If n < 0 then all significant digits are displayed.

: (F.)  ( F: r -- ) ( n -- c-addr u )
  (F1) 1+ DUP PRECISION > IF
     0 0 0 (F7)  PRECISION - (F4) (F3)
  ELSE
    DUP 0> IF
      (F8)
    ELSE
      ABS (F7)
      [CHAR] 0 HOLD
    THEN
  THEN
  (F5) (F9) ;

\ Display real number r in floating point format right
\ justified in a field width u with n places to the right of
\ the decimal point.  If n < 0 then all significant digits
\ are displayed.

: F.R   ( F: r -- ) ( n u -- )
  >R (F.) R> OVER - SPACES TYPE ;

\ Display real number r in floating point format followed by
\ a space.

: F.  ( F: r -- )
  -1 0 F.R SPACE ;

\ Some test words

: TEST1  ( -- )
  CR 1.456E-16  FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-8   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-7   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-6   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-5   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-4   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-3   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-2   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E-1   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 0E         FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+1   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+2   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+3   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+4   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+5   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+6   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+7   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+8   FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR 1.456E+16  FDUP 5 20 FS.R  FDUP 5 20 F.R  5 20 FE.R
  CR ;

: TEST2  ( -- )
  CR 1.456E-16  F.
  CR 1.456E-8   F.
  CR 1.456E-7   F.
  CR 1.456E-6   F.
  CR 1.456E-5   F.
  CR 1.456E-4   F.
  CR 1.456E-3   F.
  CR 1.456E-2   F.
  CR 1.456E-1   F.
  CR 0E         F.
  CR 1.456E+1   F.
  CR 1.456E+2   F.
  CR 1.456E+3   F.
  CR 1.456E+4   F.
  CR 1.456E+5   F.
  CR 1.456E+6   F.
  CR 1.456E+7   F.
  CR 1.456E+8   F.
  CR 1.456E+16  F.
  CR ;
