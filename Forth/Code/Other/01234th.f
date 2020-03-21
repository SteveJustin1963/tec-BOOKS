\ 0123 Forth
\ beginning programs in ANS Forth


\ greet the computer, and be greeted in turn

: I'M  ( 'ccc<char>' -- )  
   0 PARSE  CR ." Hello, " TYPE  CR ;


\ miscellaneous tools 

: CHAR-  ( a1 -- a2 )
   1 CHARS - ;

: CHAR/  ( n1 -- n2 )
   1 CHARS / ;

: -ROT  ( x y z -- z x y )
   ROT ROT ;

: UNDER+  ( x y z -- x+z y )
   ROT + SWAP ;

: INCR  ( a -- )
   1 SWAP +! ;

: BETWEEN  ( n1 n2 n3 -- f )
   1+ WITHIN ;

\ upper- lower-case conversions
: UPPERCASE  ( c -- C )
   DUP [CHAR] a [CHAR] z BETWEEN  BL AND XOR ;

: lowercase  ( C -- c )
   DUP [CHAR] A [CHAR] Z BETWEEN  BL AND XOR ;   

\ keyboard input
: BIGKEY  ( -- C )
   KEY UPPERCASE ;

: littlekey  ( -- c )
   KEY lowercase ;

: STRING  ( - pad u )
   PAD DUP 84 ACCEPT  -TRAILING ;

: DOUBLE  ( -- d f )
   0.  STRING >NUMBER  NIP 0= ;

: INTEGER  ( -- n )
   DOUBLE DROP  D>S ;

\ convert a number to its ASCII representation
\ after Moore
: >DIGIT  ( n -- c )
   DUP 9 >  7 AND +  [CHAR] 0 + ;

\ display the following character
\ a compile-only word
: .CHAR  ( '<spaces>name' -- )
   POSTPONE [CHAR]  POSTPONE EMIT ; IMMEDIATE

\ square of n
: SQUARED  ( n -- n*n )  
   DUP * ;

\ square root after Wil Baden
\ see C. H. Ting, The First Course
: SQRT   ( n1 -- n2 )
   0 TUCK  DO  1+  DUP 2* 1+  +LOOP ;

\ random number generator from Brodie
\ Starting Forth
VARIABLE RND   HERE RND !
: RANDOM  ( -- u )
   RND @  31421 *  6927 +  DUP RND ! ;
: CHOOSE  ( u - 0...u-1)
   RANDOM UM*  NIP ;

\ character array
: CLIST
   CREATE  ( u -- )  CHARS ALLOT
   DOES>  ( u -- addr )  SWAP  CHARS + ;


\ size of an address unit, cell, character

\ display the number of bits in an address unit
\ see ANS Forth document for other query strings
: BITS-IN-ADDRESS  ( -- )
   S" ADDRESS-UNITS-BITS" ENVIRONMENT?

   IF  U.  ELSE  ." Query not answered."  THEN ;

\ show the number of address units in a cell
: ADDRESSES-IN-CELL  ( -- )  
   0 CELL+  U. ;

\ show the number of address units in a character
: ADDRESSES-IN-CHAR  ( -- )  
   0 CHAR+  U. ;

\ highest on-bit in x
: HI-BIT  ( x -- u )
   0 SWAP
   BEGIN DUP WHILE  1 RSHIFT  1 UNDER+  REPEAT
   DROP ;

\ display the number of bits in a cell
: BITS-IN-CELL  ( -- )  
   TRUE HI-BIT  U. ;

\ display the number of bits in a character
: BITS-IN-CHAR  ( -- )
   TRUE HERE C!  HERE C@  HI-BIT  U. ;


\ fahrenheit-centigrade conversion

: F>C  ( fahrenheit -- centigrade )
   32 -  5 9 */ ;

: C>F  ( centigrade -- fahrenheit )
   9 5 */  32 + ;

: FAHRENHEIT  ( fahrenheit -- )
   ." is "  F>C .  ." CENTIGRADE. " ;

: CENTIGRADE  ( centigrade -- )
   ." is "  C>F .  ." FAHRENHEIT. " ;


\ sum of the squares between two limits
\ after Moore and Leach
\ FORTH - A Language for Interactive Computing
\ (Mohasco Industries, Inc., 1970)

: SUM-OF-SQUARES  ( from to -- sum_of_squares )
   1+  0 SWAP ROT  DO I SQUARED + LOOP ;


\ greatest common divisor
\ Euclid's algorithm

: UMOD  ( u1 u2 - remainder)
   0 SWAP  UM/MOD  DROP ;

: GCD  ( u1 u2 -- gcd )
   BEGIN  ?DUP WHILE  TUCK UMOD  REPEAT ;

: GCD-RECURSIVE  ( u1 u2 - gcd )
   ?DUP IF  TUCK UMOD  RECURSE  THEN ;


\ game of craps

: WIN  ( -- )  
   ." Win " ;
: LOSE  ( -- )  
   ." Lose " ;

\ roll two dice
\ ROLL and THROW already have meanings in Forth
\ you can redefine any word but it's generally
\ better not to
: SHOOT  ( -- 2...12 )
   6 CHOOSE 1+  6 CHOOSE 1+  +  DUP U. ;

: NATURAL  ( u - flag )
   DUP  7 =  SWAP  11 =  OR ;

\ three versions of a losing first throw
\ which do you prefer and why?

: CRAP  ( u - flag )
   DUP    2 =
   OVER   3 = OR
   SWAP  12 = OR ;

: CRAP  ( u - flag )
   DUP  4 U<  SWAP  12 =  OR ;

: CRAP  ( u - flag )
   4 12 WITHIN  0= ;

\ shoot for the point
: POINT  ( u -- )
   BEGIN  SHOOT
      2DUP = IF  DROP WIN  ELSE
         7 = IF  LOSE      ELSE
                 FALSE
             THEN THEN
   UNTIL ;

: CRAPS  ( -- )
   SHOOT               
   DUP NATURAL IF WIN    ELSE
   DUP CRAP    IF LOSE   ELSE
   DUP            POINT
               THEN THEN 
   DROP ;


\ count words in a text file

128 CONSTANT MAXCHARS  \ max characters in a line
MAXCHARS 2 +  CONSTANT MAXREAD
CREATE LINEPAD  MAXREAD CHARS ALLOT

\ file words
0 VALUE FILE-ID
: GET-FILE  ( -- )
   CR  ." Filename:" STRING 
   R/O OPEN-FILE
   ABORT" OPEN-FILE problem"  TO FILE-ID ;
: LINE  ( -- a u flag )  
   LINEPAD MAXREAD 
   OVER SWAP FILE-ID READ-LINE
   ABORT" READ-LINE problem" ;
: DONE  ( -- )
   FILE-ID CLOSE-FILE
   ABORT" CLOSE-FILE problem" ;

\ word-counting words
\ eliminate characters to previous blank
: -WORD  ( a u1 -- a u2 )
   2DUP CHARS + SWAP
   0 ?DO
        CHAR-  DUP C@
        BL = IF LEAVE THEN
      LOOP
      OVER -  CHAR/ ;

\ count the words in a line
\ the count is kept on the return stack
: #WORDS  ( a u -- n )
   0 >R  -TRAILING
   BEGIN  DUP WHILE 
      -WORD -TRAILING  R> 1+ >R
   REPEAT
   2DROP  R> ;

\ count the words in a file
: COUNT-WORDS  ( -- u )
   0 BEGIN  
   LINE WHILE  
     #WORDS +  
   REPEAT  2DROP ;

\ display the number of words in the file
: .COUNT   ( u -- )
   CR  U. ." words " ;

: WC  ( -- )
   GET-FILE COUNT-WORDS .COUNT  DONE ;


\ prime numbers
\ after Wirth, Programming in Modula-2,
\ 2nd ed., p. 41

200 CONSTANT #PRIMES  \ # of primes to compute
  3 CONSTANT #KNOWN   \ I know the first 3: 2 3 5 
VARIABLE NOW          \ a counter

\ first so many primes are used to determine if
\ a number is prime only these primes are stored
\ the rest are just displayed
#PRIMES SQRT CONSTANT YOUNG  \ so Wirth
CREATE YOUTH  YOUNG CELLS ALLOT  
HERE CONSTANT OLD  \ don't care about middle age

\ display words
: TITLE  ( -- )   
   CR ." The first " #PRIMES U.
      ." prime numbers are:"
   CR ;
: .PRIME  ( u)  
   8 U.R ;

\ display the first 3 primes
: .KNOWN  ( -- )   
   2 .PRIME  3 .PRIME  5 .PRIME ; 

\ determine if a number is prime
: PRIME  ( u -- u remainder )  
   YOUTH 
   BEGIN  
      2DUP @  TUCK /MOD  ROT >  OVER
   AND WHILE     
      DROP CELL+  
   REPEAT   NIP ; 

\ display prime number and increase counter
: SAY  ( u -- )
   .PRIME  NOW INCR ;

\ if a young prime, store it in the array
\ and update pointer
: ?YOUNG  ( a1 u -- a2 u )
   OVER  OLD
   U< IF  SWAP 2DUP !  CELL+ SWAP  THEN ;

\ if it's prime, do some work
: PRIME?  ( a1 u -- a2 u )    
   PRIME IF  DUP SAY  ?YOUNG  THEN ;

\ skip multiples of 2 and 3 by alternately adding
\ 2 or 4 to the previous candidate for prime 
: 2~4  ( 2|4 -- 4|2 )  
   6 XOR ;
: NEXT-CANDIDATE  ( a1 u 2|4 -- a2 u+2|u+4 4|2 )
   DUP >R  +  
   PRIME?   
   R> 2~4 ;

: PRIMES  ( -- )
   TITLE .KNOWN  #KNOWN NOW !  
   5 YOUTH !  YOUTH CELL+  \ skip 2 and 3  
   5 2                     \ first candidate is 7 
   BEGIN  NEXT-CANDIDATE  NOW @ #PRIMES = UNTIL 
   CR  2DROP DROP ;


\ ANSified Sieve of Eratosthenes

8192 CONSTANT SIZE  \ test this many odd numbers
CREATE FLAGS SIZE CHARS ALLOT  \ odd numbers
HERE CONSTANT END-FLAGS  \ address after the list
: ODD  ( u -- n)  \ number n of flag u
   2* 3 + ;

0 VALUE SIFT  \ to sift or not to sift

\ calculate offset of prime**2
: NEXT-SQUARE  ( u1 -- u2 )
   DUP SQUARED 2*  SWAP 6 * +  3 + ;

\ reset flags of multiples of a prime
: RESET-FLAGS
   ( increment end-address start-address -- )
   DO  0 I C!  \ reset flag of an odd multiple
       DUP     \ duplicate the loop increment
   +LOOP  DROP ;

: SIEVE   ( -- )
   FLAGS SIZE 1 FILL  \ assume numbers are prime
   TRUE TO SIFT  \ yes to sifting
   0  \ 0 the count of primes
   FLAGS  \ start with first flag
   SIZE 0 DO  \ outer loop
      COUNT IF  \ prime? ; address now next flag 
      1 UNDER+  \ add 1 to the count of primes
         SIFT IF        
            I NEXT-SQUARE DUP SIZE
               U< IF  \ next square in array?
                 I ODD CHARS  \ loop increment 
                 END-FLAGS  \ loop end
                 ROT CHARS FLAGS +  \ loop start
                 RESET-FLAGS  \ inner loop
               ELSE   
                 DROP  FALSE TO SIFT
               THEN
         THEN
    THEN
   LOOP
   DROP U. ." Primes" ;

\ test
: .PRIMES  ( -- )
   CR  
   0
   FLAGS SIZE 0 DO
     COUNT
     IF  I ODD .PRIME  1 UNDER+  THEN
   LOOP
   DROP
   CR  U. ." prime numbers displayed. " ; 
: SIEVE-TEST  ( -- )
   SIEVE .PRIMES ;
       

\ powers of 2 after Wirth
\ Programming in Modula-2, 2nd ed., pp. 37-39

32 CONSTANT #EXPONENTS
11 CONSTANT +DIGITS          
#EXPONENTS CONSTANT -DIGITS
VARIABLE +PLACE

+DIGITS CLIST +DIGIT
-DIGITS CLIST -DIGIT

\ positive power is calculated, then displayed
: +POWER  ( -- )
   0  \ carry
   +PLACE @ 0 DO 
      I +DIGIT DUP C@ 2*  ROT +
      DUP 9 > IF  10 -  1  ELSE  0  THEN
      SWAP ROT C!
   LOOP
   IF  1 +PLACE @ +DIGIT C!  +PLACE INCR  THEN ;
: .+POWER  ( -- )
   +PLACE @  +DIGITS OVER -  1-  SPACES
   DUP +DIGIT SWAP
   0 DO  CHAR-  DUP C@  0 U.R  LOOP  DROP ;

\ negative power is displayed as it is calculated
: -POWER ( u -- ) 
   ." 0."
   1-  \ divide u-1 times for the 1st u-1 digits
   0   \ remainder
   OVER 0 ?DO
      10 *  I -DIGIT C@ +
      2 /MOD  \ quotient is next digit
      DUP I -DIGIT C!  0 U.R
   LOOP DROP
   5 SWAP -DIGIT C!  5 0 U.R  \ last digit always 5
   ;

: POWERS-OF-2  ( -- )
   1 0 +DIGIT C!  1 +PLACE !
   #EXPONENTS 1+ 1 DO
      CR
      +POWER .+POWER
      I 4 U.R  2 SPACES
      I -POWER
   LOOP ;

: P2   ( -- )
   POWERS-OF-2 ;


\ fractions after Wirth
\ Programming in Modula-2, 2nd ed., pp. 40-41

\ data structures
DECIMAL
32 CONSTANT MAXDIVISOR
0 VALUE DIVISOR  \ will go from 2 to maxdivisor
MAXDIVISOR CLIST  DIGIT  \ digits in the fraction
MAXDIVISOR CLIST  INDEX  \ index of remainders

\ display words
: .DIVISOR  ( -- )
   CR  DIVISOR 4 U.R  2 SPACES ;
: .FRACTION
   ( #digits index[repeated-remainder] -- )
   1-  \ number of digits to repeating period
   ." 0."  \ integer part
   1 DIGIT OVER TYPE  \ digits before repeats
   .CHAR '  \ period marker
   DUP 1+ DIGIT -ROT - TYPE  \ repeating period
   SPACE ;

: FRACTIONS  ( -- )
   MAXDIVISOR 1+ 2 DO 
      I TO DIVISOR
      .DIVISOR
      0 INDEX DIVISOR 0 FILL \ for new divisor
      0 1  \ #digits, remainder  
      BEGIN
         1 UNDER+  \ increment #digits 
         2DUP INDEX C!  \ #digits in
                        \ index(remainder)
         10 *  DIVISOR
         /MOD  \ compute next digit, remainder
         >DIGIT
         ROT TUCK DIGIT C!  \ store ASCII version
         SWAP DUP INDEX C@  \ index(remainder)
      ?DUP UNTIL  \ done if
                  \ remainder occurred before
      NIP  \ discard remainder
      .FRACTION
   LOOP ;


\ GUESS after Kemeny & Kurtz
\ Back to BASIC, pp. 114-119

\ range of numbers to guess from  
  1 CONSTANT LOWEST
100 CONSTANT HIGHEST

: INSTRUCTIONS  ( -- )
   PAGE
   ." You and the machine take turns."  CR
   ." One player chooses an integer from "
      LOWEST .
   ." to "  HIGHEST .  ." ."  CR
   ." The other player must guess the number."  CR
   ." After each guess a hint is given:"  CR
   ." 'Smaller' , 'Larger' , or 'Correct' ."  CR
   ." The player needing fewer guesses wins."  CR
   ;

: SEED   ( -- )
   TIME&DATE  + + + + +
   0 DO  RANDOM DROP  LOOP ;
: RANDOM-INTEGER  ( n1 n2 -- n1...n2 )
   1+  OVER -  CHOOSE  + ;

\ game variables
VARIABLE YOUR-GUESSES
VARIABLE MACHINE'S-GUESSES
VARIABLE YOUR-WINS
VARIABLE MACHINE'S-WINS
VARIABLE TIES

: ZERO  ( a -- )
   0 SWAP ! ;

: START-EVEN  ( -- )
   YOUR-WINS ZERO
   MACHINE'S-WINS ZERO
   TIES ZERO ;

\ your turn
: MACHINE-CHOOSES  ( -- n )
   LOWEST HIGHEST RANDOM-INTEGER  
   CR  ." A number has been chosen."  CR ;
: YOU  ( -- )
   MACHINE-CHOOSES
   YOUR-GUESSES ZERO
   BEGIN
      ." Your guess: " INTEGER CR
      YOUR-GUESSES INCR
      OVER -  
   DUP WHILE
      0< IF  ." Larger."
            ELSE  ." Smaller." THEN  CR
   REPEAT  2DROP
   ." Correct!" CR
   ." You needed " YOUR-GUESSES ?  ." guesses."
   CR ;

\ the machine's turn
VARIABLE LOW
VARIABLE HIGH
VARIABLE CORRECT

: MODERATE  ( n1 n2 -- n3 )
   2*  +  3 / ;
: MACHINE'S-GUESS  ( -- n )
   LOW @  HIGH @  
   2DUP SWAP MODERATE  -ROT MODERATE
   RANDOM-INTEGER 
   DUP ." The machine guesses "  .  CR 
   MACHINE'S-GUESSES INCR ;
: YOUR-ANSWER  ( machine's-guess -- )  
   BEGIN
      ." Hint ( Larger, Smaller, Correct ) "
      BIGKEY         
      DUP [CHAR] L =
         IF ." Larger"   SWAP 1+ LOW !
      ELSE DUP [CHAR] S =                  
         IF ." Smaller"  SWAP 1- HIGH !
      ELSE DUP [CHAR] C =
         IF ." Correct"  NIP  TRUE CORRECT !
      ELSE FALSE AND
         CR  ." Please answer S , L , or C ."
         THEN THEN THEN  CR
    UNTIL ;
: IMPOSSIBLE  ( -- f )
   LOW @  HIGH @  >
   DUP IF  ." That cannot be."  CR
           MACHINE'S-GUESSES ZERO
       THEN ;
: MACHINE'S-GUESSING  ( -- )
   LOWEST LOW !  HIGHEST HIGH !  FALSE CORRECT !
   BEGIN
      MACHINE'S-GUESS
      YOUR-ANSWER
   CORRECT @  IMPOSSIBLE OR  UNTIL ;

\ wait for a key press
: WAIT  ( -- )
   KEY DROP ;

: MACHINE  ( -- )
   ." Your turn to think of a number."  CR
   ." Press a key when ready..."  WAIT  CR
   MACHINE'S-GUESSES ZERO
   MACHINE'S-GUESSING
   MACHINE'S-GUESSES @
   ?DUP IF ." The machine needed " . ." guesses."
        ELSE  ." You cheated."
        THEN  
   CR ;

\ who won
: YOU-OR-IT  ( -- )
   YOUR-GUESSES @  MACHINE'S-GUESSES @ -
   DUP 0<
       IF ." You won."
          YOUR-WINS INCR
   ELSE  DUP
       IF ." The machine won."
          MACHINE'S-WINS INCR
   ELSE
       ." It's a tie."
          TIES INCR
       THEN THEN  CR
   DROP ;

: ENOUGH  ( -- )
   ." Another game (y/n)?" 
   BIGKEY CR  [CHAR] Y <> ;

: RESULTS  ( -- )
   ."          Your score: "  YOUR-WINS ?  CR
   ." The machine's score: "  MACHINE'S-WINS ?  CR
   ."                Ties: "  TIES ?  CR ;
   
\ the game
: GUESS  ( -- )
   SEED INSTRUCTIONS START-EVEN
   BEGIN  
      YOU  
      MACHINE  
      YOU-OR-IT  
   ENOUGH UNTIL 
   RESULTS ;


\ Permute after Wirth
\ Programming in Modula 2, 2nd ed., pp. 54-55
\ uses pad instead of a named array of characters

0 VALUE #LETTERS

: LETTERS  ( a 'ccc<char>' -- a u )
   BL PARSE TO #LETTERS  CR
   OVER #LETTERS CMOVE 
   #LETTERS ;

: .LETTERS  ( a -- )  
    #LETTERS TYPE  SPACE ;

: CPAIR  ( a n1 n2 -- a1 a2 )
   CHARS >R
   OVER CHARS +
   SWAP R> + ;

: CTRADE  ( a1 a2 -- )
   2DUP C@  -ROT C@  SWAP C!  SWAP C! ;

: (PERMUTE)  ( a n -- )
   1- ?DUP IF 
      2DUP RECURSE
      DUP 0 DO
         2DUP I CPAIR CTRADE
         2DUP RECURSE   
         2DUP I CPAIR CTRADE
      LOOP 2DROP
   ELSE  .LETTERS  THEN ;

: PERMUTE  ( 'ccc<char> -- )
   PAD LETTERS (PERMUTE) ;


\ postfix after Wirth
\ Programming in Modula 2, 2nd ed., pp. 56-57

\ windows96--not!!
: QUICK-AND-DIRTY-WINDOW  
   CREATE  ( left top right bottom -- )
      ,  ,  2DUP  ,  ,  ,  , ;

 0  0  25  20 QUICK-AND-DIRTY-WINDOW 0WINDOW
30  0  55  20 QUICK-AND-DIRTY-WINDOW 1WINDOW

: LEFT-TOP  ( a -- col row )  
   CELL+ CELL+ 2@ ;
: TOP  ( a -- row )
   LEFT-TOP  NIP ;
: LEFT  ( a - col )
   LEFT-TOP  DROP ;
: RIGHT-BOTTOM  ( a -- col row )  
   2@ ;
: BOTTOM  ( a -- row )
   RIGHT-BOTTOM  NIP ;
: RIGHT  ( a -- col )
   RIGHT-BOTTOM  DROP ;
: XY  ( a1 -- a2)
   4 CELLS + ;

0 VALUE WIDE
 
: WPAGE  ( a -- )
   >R
   R@ LEFT-TOP AT-XY
   R@ RIGHT R@ LEFT - 1+ TO WIDE
   R@ LEFT-TOP  R@ BOTTOM 1+ SWAP   
      DO  DUP I AT-XY  WIDE SPACES  LOOP  DROP
   R@ LEFT-TOP 2DUP 
   R@ XY 2!  AT-XY
   R> DROP ;

: WCR  ( a -- )
   >R
   R@ LEFT 
   R@ XY 2@ NIP 1+  R@ BOTTOM MIN  2DUP AT-XY 
   R@ XY 2! 
   R> DROP ;

: WEMIT  ( c a -- )
   >R
   R@ XY 2@ AT-XY EMIT
   R@ XY 2@ SWAP 1+  R@ RIGHT MIN SWAP 
   R@ XY 2!
   R> DROP ;

\ implementation dependent?
13 CONSTANT InputReturnKey  

0 VALUE 'EXPRESSION  \ expression defined below

: FACTOR  ( c1 -- c2 )
   DUP [CHAR] ( = IF
      0WINDOW WEMIT
      littlekey 'EXPRESSION EXECUTE
      BEGIN 
      DUP [CHAR] ) <> WHILE
         DROP littlekey 
      REPEAT
   ELSE DUP [CHAR] [ = IF
      0WINDOW WEMIT
      littlekey 'EXPRESSION EXECUTE
      BEGIN
      DUP [CHAR] ] <> WHILE
          DROP littlekey 
      REPEAT
   ELSE
      BEGIN
      DUP [CHAR] a < OVER [CHAR] z > OR WHILE
         DROP littlekey 
      REPEAT   
      DUP 1WINDOW WEMIT
   THEN THEN
   0WINDOW WEMIT
   littlekey ;

: TERM  ( c1 -- c2 )
   FACTOR 
   BEGIN  
   DUP [CHAR] * =  OVER [CHAR] / =  OR WHILE 
      DUP >R 0WINDOW WEMIT
      littlekey FACTOR 
      R> 1WINDOW WEMIT
   REPEAT ;

: EXPRESSION  ( c1 -- c2 )
   TERM
   BEGIN 
   DUP [CHAR] + =  OVER [CHAR] - =  OR WHILE
      DUP >R 0WINDOW WEMIT
      littlekey TERM
      R> 1WINDOW WEMIT
   REPEAT ;

' EXPRESSION TO 'EXPRESSION

: POSTFIX  ( -- )
   0WINDOW WPAGE
   1WINDOW WPAGE
   BEGIN
      [CHAR] > 0WINDOW WEMIT
      littlekey
   DUP InputReturnKey <> WHILE
      EXPRESSION 
      0WINDOW WCR  1WINDOW WCR
      DROP
   REPEAT
   DROP
   ;


\ Queens after Wirth
\ Programming in Modula 2, 2nd ed., pp. 57-59

\ Wirth uses screen painting 
80 CONSTANT SCREEN-COLUMNS
25 CONSTANT SCREEN-ROWS
0 VALUE LEFT  \ screen location
0 VALUE TOP   \ screen location

\ maximum number of columns/rows
SCREEN-COLUMNS SCREEN-ROWS MIN 1- 2/ CONSTANT NMAX
0 VALUE N     \ actual number of columns/rows

VARIABLE ANSWERS  \ number of "solutions"

\ pause half a second
: PAUSE  ( -- )
   500 MS ;

: PEACE  ( -- )
   ANSWERS INCR
   0 0 AT-XY  
   N . ." QUEENS  "  ANSWERS ?  ." ANSWERS"
   PAUSE ;

: DASHES  ( n -- )   
   0 DO  ." +---"  LOOP  .CHAR + ;

: GAPS  ( n -- )   
   0 DO  .CHAR |  3 SPACES  LOOP  .CHAR |  ;

: .BOARD  ( -- )       
   PAGE     
   N 0 DO  LEFT TOP I 2* +    
           2DUP AT-XY  N DASHES  1+ AT-XY  N GAPS
       LOOP   
           LEFT TOP N 2* + AT-XY  N DASHES 
   PEACE ;

: AT-BOARD  ( col row  -- ) 
   2* 1+   TOP +   >R
   4 * 2 + LEFT +  R>
   AT-XY ;

\ Wirth uses Boolean arrays

NMAX CLIST ROW

: /DIAGONALS  \ lower left to upper right
   CREATE  ( u -- )  CHARS ALLOT
   DOES>  ( col row -- a )
      >R  + CHARS  R> + ;
NMAX 2* 1- /DIAGONALS /DIAGONAL

: \DIAGONALS  \ upper left to lower right
   CREATE  ( u -- )  CHARS ALLOT
   DOES>  ( col row -- a )
      >R  -  N 1- + CHARS  R> + ;
NMAX 2* 1- \DIAGONALS \DIAGONAL

0 VALUE SAFE?

: >ARRAYS  ( col row -- )
   DUP  ROW       SAFE? SWAP C!
   2DUP /DIAGONAL SAFE? SWAP C! 
        \DIAGONAL SAFE? SWAP C! ;

: PUT  ( col row -- )
   FALSE TO SAFE?  \ a queen creates danger
   2DUP >ARRAYS  AT-BOARD .CHAR Q ;

: PUNT  ( col row -- )
   TRUE TO SAFE?   \ removing her lessens danger
   2DUP >ARRAYS  AT-BOARD SPACE ;

: -QUEENS  ( -- )    
   TRUE TO SAFE?
     0    ROW       N        SAFE? FILL
   0 0    /DIAGONAL N 2* 1-  SAFE? FILL
   0 N 1- \DIAGONAL N 2* 1-  SAFE? FILL ;

: BOARD  ( -- )
   -QUEENS .BOARD ;

: SAFE  ( col row -- flag)
   DUP  ROW C@        >R
   2DUP /DIAGONAL C@  >R
        \DIAGONAL C@  R> R>  AND AND ;

: TRY-COLUMN  ( col -- )          
   N 0 DO
      I             ( col row )
      2DUP SAFE IF
         2DUP PUT   \ install queen
         OVER IF  OVER 1- RECURSE
              ELSE  PEACE  THEN
         2DUP PUNT  \ remove queen
      THEN  DROP    
   LOOP  DROP ;

\ starting values
: VALUES  ( n -- )
   1 MAX  NMAX MIN  TO N
   SCREEN-COLUMNS 1-  2/  N 2* -  TO LEFT
   SCREEN-ROWS    1-  2/  N -     TO TOP 
   -1 ANSWERS ! ;

: (QUEENS)  ( n -- )
   VALUES  BOARD  N 1- TRY-COLUMN ;
   
: 8QUEENS  ( -- )
   8 (QUEENS) ;

: QUEENS  ( -- )
   NMAX 0 DO  I 1+ (QUEENS)  LOOP ;


\ Some floating-point programs

\ miscellaneous floating-point tools

: -FROT  ( r1 r2 r3 -- r3 r1 r2 )
    FROT FROT ;
: FTUCK  ( r1 r2 -- r2 r1 r2 )
   FSWAP FOVER ;
: FSWOOP  ( r1 r2 -- r2 r1 r1 )
   FSWAP FDUP ;
: FSPIN  ( r1 r2 r3 -- r3 r2 r1 )
   FSWAP FROT ;
: FSQUARED  ( r -- r**2 )
   FDUP F* ;
: FHALVED  ( r -- r/2 )
   .5E F* ;
: FLOAT  ( -- r )
   STRING >FLOAT 0=
   ABORT" Not a floating point number" ;


\ pi after Kemeny and Kurtz
\ Back to Basic, pp. 107-110.

: MUCH-LIKE-PI  ( -- f )
   2.0E                        \ a = 2 
   1.0E  2.0E FSQRT  F/        \ h = 1/sqrt(2)
   12 0 DO
      FTUCK  F/                \ a = a/h
      FTUCK  CR F.             \ display a
      1.0E F+  2.0E F/  FSQRT  \ h = sqrt((1+h)/2)
   LOOP  FDROP ;

MUCH-LIKE-PI FCONSTANT PI


\ power after Wirth
\ Programming in Modula 2, 2nd ed., p. 22.
\ note that the ANS Forth floating-point extension
\ words include F**  ( r1 r2 -- r1**r2 )

: (POWER)  ( x i -- x**i )  \ x float, i cardinal
   >R  1.0E FSWAP  R> ( z x i )
   BEGIN  DUP WHILE  \ while i > 0
      2 /MOD >R  \ push i=i/2
      IF  FTUCK F*  FSWAP  THEN  \ if i odd z=z*x
      FSQUARED  \ x=x*x
      R>  \ pop i
   REPEAT 
   DROP  \ drop i=0
   FDROP ;  \ drop x, leaving z=x**i

: POWER  ( -- )
   BEGIN
      ."  x = " FLOAT
   FDUP F0= 0= WHILE
      ."  i = " INTEGER  0 MAX
      (POWER)
      ."  x**i = " F.  CR
   REPEAT   
   FDROP ;


\ log2 after Wirth
\ Programming in Modula 2, 2nd ed., p. 22.

1E-7 FCONSTANT TINY

: (LOG2)  ( 1.0<=r1<2.0 -- r2 )
   0E FSWAP 1.0E     ( sum a b )    
   BEGIN
      FHALVED        ( sum a b=b/2 ) 
      FSWAP          ( sum b a )
      FSQUARED       ( sum b a=a**2 )
      FDUP           ( sum b a a )
      2.0E F< 0= IF  ( sum b a f )
         FHALVED     ( sum b a=a/2 )
         -FROT       ( a sum b )
         FTUCK       ( a b sum b )     
         F+          ( a b sum=sum+b )
         FSPIN       ( sum b a )
      THEN
      FSWOOP         ( sum a b b )
      TINY F< UNTIL  ( sum a b ) 
      FDROP FDROP ;     

: LOG2 ( -- ) 
   BEGIN
      ."  x = " FLOAT 
   FDUP 1.0E F< 0= >R  FDUP 2.0E F<  R> AND  WHILE
   (LOG2)  
      ." log2 = " F.  CR
   REPEAT 
   FDROP ;

\ 28AUG96 + 05MAR97 +
 
\ Copyright 1996 Leo Wong
\ hello@albany.net
\ http://www.albany.net/~hello/

