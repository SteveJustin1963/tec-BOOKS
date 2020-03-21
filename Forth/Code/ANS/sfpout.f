\ SFPOUT.F
\
\ Simple Floating Point Output
\
\ Main words:
\
\ (F.)  (FS.)  (FE.)  F.R  FS.R  FE.R  F.  FS.  FE.
\ FDP  PLACES
\
\ This package should function correctly on any Forth
\ system with the following limitations:
\
\ - Don't attempt to output non-numbers such as NANs
\   or INFs as it will enter an infinite loop.
\ - Floating-point strings are limited to the size of
\   the system's pictured numeric output buffer.
\
\ History:
\ 131029  Fix (F.) to use FDP. Add F. FS. FE. PLACES

FORTH DEFINITIONS DECIMAL

\ Floating-point pictured numeric output operators
: <#. ( F: r1 -- r2 )  FROUND <# ;
: #. ( F: r1 -- r2 )  10.E F/ FDUP FLOOR FSWAP FOVER F-
  10.E F* FROUND F>D D>S  [CHAR] 0 + HOLD ;
: #S. ( F: r1 -- r2 )  BEGIN #. FDUP F0= UNTIL ;
: #>. ( F: r -- ) ( c-addr u )  FDROP 0 0 #> ;
: SIGN. ( flag -- )  IF [CHAR] - HOLD THEN ;

\ Variable controlling trailing decimal point display.
\ Default (ON) is to always display decimal point.
VARIABLE FDP  1 FDP !

: 10^n ( r1 n -- r2 )  0 ?DO 10.E F* LOOP ;
: #.n ( r1 n -- r2 )  0 ?DO #. LOOP ;

VARIABLE rscale  1 rscale !
FVARIABLE rstep  10.E rstep F!
VARIABLE fdpl  4 fdpl !

\ Normalize to range 1.0 <= r < STEPSIZE
: fnorm ( r1 -- |r2| sign exp )
  FDUP F0<  0 2>R  FABS
  FDUP F0= 0= IF
    BEGIN  FDUP  rstep F@ F< 0=
    WHILE  rstep F@ F/  R> rscale @ + >R  REPEAT
    BEGIN  FDUP 1.0E F<
    WHILE  rstep F@ F*  R> rscale @ - >R  REPEAT
  THEN  2R> ;

\ Convert fixed-point
: fcvt ( r n -- )
  >R  FDUP F0< ( sign)  R> 2>R
  FABS  FDP @ IF  ( always output decimal point )
    R> #.n  [CHAR] . HOLD
  ELSE  ( conditionally output decimal point )
    R@ #.n  R> IF  [CHAR] . HOLD  THEN
  THEN  #S.  R> SIGN.  #>. ;

\ Convert real number r to string c-addr u in exponential
\ notation with n places right of the decimal point.
: (e.) ( r n scale step -- c-addr u )
  rstep F!  rscale !  0 MAX >R  fnorm
  R> 2>R  IF FNEGATE THEN  1.E R@ 10^n
  FSWAP FOVER F*  FROUND ( make integer)
  FDUP FABS FROT F/ rstep F@ F< 0= IF ( overflow)
  rstep F@ F/  R> R> rscale @ + >R >R  THEN
  <#.  R>  R> S>D TUCK DABS # #S  2DROP
  0< IF [CHAR] - ELSE [CHAR] + THEN  HOLD
  [CHAR] E HOLD  fcvt ;

\ Convert real number r to string c-addr u in scientific
\ notation with n places right of the decimal point.
: (FS.) ( r n -- c-addr u )  1 10.E (e.) ;

\ Display real number r in scientific notation right-
\ justified in a field width u with n places right of
\ the decimal point.
: FS.R ( r n u -- )  >R (FS.) R> OVER - SPACES TYPE ;

\ Convert real number r to string c-addr u in engineering
\ notation with n places right of the decimal point.
: (FE.) ( r n -- c-addr u )  3 1000.E (e.) ;

\ Display real number r in engineering notation right-
\ justified in a field width u with n places right of
\ the decimal point.
: FE.R ( r n u -- )  >R (FE.) R> OVER - SPACES TYPE ;

\ Convert real number r to string c-addr u in fixed-point
\ notation with n places right of the decimal point.
: (F.) ( r n -- c-addr u )
  0 MAX  DUP >R  10^n  <#. ( round)  R> fcvt ;

\ Display real number r in fixed-point notation right-
\ justified in a field width u with n places right of
\ the decimal point.
: F.R ( r n u -- )  >R (F.) R> OVER - SPACES TYPE ;

\ Set decimal places control for F. FS. FE.
: PLACES ( n -- )  fdpl ! ;

: F.  ( r -- )  fdpl @ 0 F.R SPACE ;
: FS. ( r -- )  fdpl @ 0 FS.R SPACE ;
: FE. ( r -- )  fdpl @ 0 FE.R SPACE ;

[DEFINED] DXFORTH [IF] behead 10^n (e.) [THEN]

\ end
