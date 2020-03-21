\

\                 Quicksort

\

\  September 8, 1999. version 1.0

\

\  Description:

\

\  The word QUICKSORT sorts a list. It uses the ?quicksort?

\  and ?find? algorithms of C. A. R. Hoare, as well as a

\  ?straight selection? algorithm for small sublists.

\

\  It is assumed that the list elements are referenced by tokens

\  each one cell wide. A token simply may be the order of an

\  element in the list. Typically, however, the tokens are

\  addresses of array elements.

\

\  The stack effect of QUICKSORT is:

\

\        QUICKSORT    (   x1  x2   --           )

\

\  where x1, x2 are the tokens of respectively the first and

\  last elements in the list to be sorted.

\

\  The following seven words reflecting the data must be supplied:

\

\        T+            (       x1   --     x2   )

\        T-            (       x1   --     x2   )

\        T<            (   x1  x2   --   flag   )

\        LESS          (   x1  x2   --   flag   )

\        EXCHANGE      (   x1  x2   --          )

\        TMID          (   x1  x2   --     x3   )

\        LENGTH        (   x1  x2   --      u   )

\

\  The word T+ passes from one token x1 to the token x2

\  referencing the list element following the one corresponding

\  to token x1.

\  Similarly, T- passes from token x1 to token x2 corresponding

\  to the preceding element in the list.

\  The word T< shall leave flag true if and only if the element

\  identified by token x1 strictly precedes in the list the

\  element corresponding to token x2.

\  The word LESS shall leave flag true if and only if the list

\  element represented by token x1 compares to strictly less in

\  the sort order than the element corresponding to x2.

\  The word EXCHANGE is supposed to exchange the list elements

\  corresponding to tokens x1 and x2.

\  The word TMID is expected to compute the token x3 whose order

\  is half (rounding towards zero) the length of the sublist

\  beginning and ending with tokens x1, x2 respectively.

\  The word LENGTH is supposed to compute the number of elements

\  in the sublist beginning and ending with the elements

\  referenced by tokens x1, x2.

\

\  The core routine consists of the three words STRAIGHTSELECTION,

\  SPLIT, QUICKSORT - of which the last is the outer word to be

\  called for sorting - and of the value LOWLIM used by QUICKSORT.

\

\  All of the other words are needed for the test suite only.

\  Execution of RUNTEST should result in the output ?SUCCESS?.

\

\

\  During execution of QUICKSORT, sublists (represented by the tokens

\  of their first and last elements) accumulate on the stack.

\  The number of such sublists does not exceed 1 plus the

\  logarithm to the base 2 of the number of elements of the list

\  to be sorted. Therefore the stack requirements of this

\  conquer and divide algorithm are comparatively small. Indeed,

\  if cell size is n bits, the room for stack needed for the

\  sublists will not exceed 2(n+1) cells.

\  Also note that the algorithm is impracticable for files, for

\  which merging algorithms are appropriate. It is desirable

\  that the entire list resides in RAM, because of the exchange

\  of elements residing near opposite ends of the list.

\

\

\  Reference:

\  N. Wirth: Algorithmen und Datenstrukturen, Teubner

\            Studienbücher, Informatik, Stuttgart 1979.

\

\

\  Requirements:

\

\

\  The core routine requires the Locals and Locals Ext word sets

\  apart from the seven words described above.

\  The other words partly require the Floating Point word set,

\  and partly have environmental dependencies, cf. the comments.

\

\

\

\  (C) Copyright 1999 Marco Thill. Permission is granted by the

\  author to use this software, provided this copyright notice is

\  preserved.

\

\

\

\ WORDS SUPPLIED, CASE OF AN ARRAY OF FLOATING POINT NUMBERS.

\ THIS IS REQUIRING THE FLOATING-POINT WORD SET.

\ NOTE THAT THE ARRAY SHOULD USE LESS THAN HALF OF THE MEMORY

\ ADDRESSABLE, BECAUSE OF THE DIVISIONS USED.

\ IT DOES NOT MATTER WHETHER THE FLOATING POINT STACK IS DIFFERENT

\ FROM THE DATA STACK, OR NOT.

\ THESE SEVEN WORDS CAN OF COURSE BE INSERTED IN-LINE.

\

: T+   FLOAT+  ;

1  FLOATS  CONSTANT  T

: T-   T  -  ;

: T<  U<  ;

: LESS   >R  F@  R>  F@  F< ;

: EXCHANGE

  2DUP  >R  >R

  >R  F@  R>  F@

  R>  F!  R>  F!

;

: TMID   OVER  -  2  /  T  /  T  *  +  ;

: LENGTH   SWAP  -  T  /  1+  ;

\

\

\  *****  CORE ROUTINE  *****

\

\

\ SELECTION ALGORITHM FOR SMALL SUBLISTS. ANS FORTH

\ REQUIRES THE LOCALS AND LOCALS EXT WORD SETS

\ IT IS ASSUMED THAT THE SUBLIST CONTAINS AT LEAST 2 ELEMENTS.

\ THE WORDS T+, T<, LESS AND EXCHANGE ARE NEEDED.

\

: STRAIGHTSELECTION   ( X1 X2 --  )

  OVER  LOCALS|  TSMALL TUPLIM  |    ( S: I )

  BEGIN

     DUP  DUP TO TSMALL   ( I J-1 )

     BEGIN

        T+   ( I J )

        DUP TSMALL LESS IF DUP TO TSMALL THEN

        DUP TUPLIM T< 0=

     UNTIL

     DROP   ( S: I )

     DUP TSMALL EXCHANGE

     T+   ( I -> I+1 )

     DUP TUPLIM T< 0=

  UNTIL

  DROP

;

\ SPLIT. ANS FORTH

\ REQUIRES THE LOCALS AND LOCALS EXT WORD SETS

\ THE WORD SPLIT INCORPORATES THE FIND ALGORITHM

\ AND THE INNER LOOP OF THE QUICKSORT ALGORITHM.

\ IT IS ASSUMED THAT THE SUBLIST CONTAINS AT LEAST 4 ELEMENTS.

\ THE WORDS T+, T-, T<, LESS, EXCHANGE AND TMID ARE NEEDED.

\

: SPLIT   ( X1 X2 -- X3 X4 X5 X6 )

  2DUP TMID DUP  LOCALS|  TMEDIAN TMARK TRIGHT TLEFT  |

  TMEDIAN T+ TRIGHT  TLEFT TMEDIAN T-

  BEGIN

     TMEDIAN TO TMARK  TLEFT TRIGHT

     BEGIN

        BEGIN  TMARK OVER LESS   WHILE   T-   REPEAT

        SWAP

        BEGIN   DUP TMARK  LESS   WHILE   T+   REPEAT

        SWAP

        2DUP SWAP T< 0=  IF

                              2DUP EXCHANGE

                              DUP  TMARK =  IF  OVER TO TMARK       ELSE

                              OVER TMARK =  IF  DUP  TO TMARK  THEN THEN

                              T- SWAP T+ SWAP

                         THEN

        2DUP SWAP T<

     UNTIL

     DUP TMEDIAN  T<  IF  OVER TO TLEFT  THEN

     SWAP

     TMEDIAN SWAP T<  IF  TO TRIGHT  ELSE  DROP  THEN

     TLEFT TRIGHT T< 0=

  UNTIL

;

\ QUICKSORT. ANS FORTH

\ THE OUTER WORD TO BE CALLED FOR SORTING

\ REQUIRES THE LOCALS AND LOCALS EXT WORD SETS

\ THE WORDS T< AND LENGTH ARE NEEDED.

\

16 VALUE LOWLIM   \  LOWLIM SHOULD BE GREATER THAN OR EQUAL TO 5

: QUICKSORT   ( X1 X2 --  )

  1  LOCALS|  #SUBLISTS  |

  BEGIN

     2DUP T<

     IF

        2DUP LENGTH LOWLIM U<

        IF

           STRAIGHTSELECTION

           #SUBLISTS 1- TO #SUBLISTS

        ELSE

           SPLIT

           #SUBLISTS 1+ TO #SUBLISTS

        THEN

     ELSE

           2DROP

           #SUBLISTS 1- TO #SUBLISTS

     THEN

     #SUBLISTS 0=

  UNTIL

;

\ *****  END OF CORE ROUTINE  *****

\

\ TEST SUITE FOR QUICKSORT

\ PSEUDO RANDOM NUMBER GENERATOR.

\ D. KNUTH: THE ART OF COMPUTER PROGRAMMING, SECTION 3.6

\ ENVIRONMENTAL DEPENDENCIES:

\ CELL SIZE: 32 BITS.

\ TWO'S COMPLEMENT ARITHMETIC.

\ RESULT AFTER OVERFLOW SHALL BE THE TRUNCATION TO THE LOWER

\ 32 BITS OF THE TRUE RESULT.

\

-1153374675 CONSTANT MULTIPLIER

: RANDOMIZE  ( N1 -- N2 )

  MULTIPLIER * 1+

;

\ DEFINITION OF THE FLOATING-POINT ARRAY.

\ THIS IS REQUIRING THE FLOATING-POINT WORD SET.

\ IT IS ASSUMED THAT THERE IS ENOUGH ROOM IN DATA SPACE FOR AN ARRAY

\ OF 1024 FLOATING-POINT NUMBERS. THE SPACE NEEDED CAN BE CONTROLLED

\ THROUGH THE CONSTANT MAXINDEX.

\

: FARRAY  FALIGN CREATE 1+ FLOATS ALLOT ;

1023 CONSTANT MAXINDEX

MAXINDEX FARRAY A{          \ ADDRESSABLE FROM  0 TO  MAXINDEX

: }  FLOATS + ;

\

: JUMBLEUP  MAXINDEX 1+  0  DO  RANDOMIZE DUP S>D D>F A{ I } F!  LOOP ;

: CHECK  ( FLAG1 -- FLAG2 )

  MAXINDEX 0  DO  A{ I 1+ }  A{ I } LESS  IF  DROP FALSE  THEN  LOOP ;

: RUNTEST

  HERE ( SEED )

  TRUE

  64 0  DO

             SWAP JUMBLEUP SWAP

             A{ 0 }  A{ MAXINDEX }  QUICKSORT

             CHECK

        LOOP

  IF  ." SUCCESS"  ELSE  ." FAILURE"  THEN

  DROP  ( RANDOMNUMBER )

;
