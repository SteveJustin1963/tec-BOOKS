\ fileio.fo           Words to help with ASCII File I/O 
\     (from FSL with FLOAT words removed)

\ This is an ANS Forth program requiring:
\        3. The STRING word CMOVE

\ Words to convert counted strings to numbers
\ atol ( addr count -- d )                ASCII to long
\ atoi ( addr count -- n )                ASCII to int

\ Word to read a whitespace delimited token from a file
\ get-token ( addr fileid -- addr count )

\ Words to read whitespace delimited numbers from a file
\ get-int   ( fileid -- n )                read single int
\ get-long  ( fileid -- d )                read double int

\ Words to convert numbers to counted strings
\ These require the address of a conversion buffer to be given,
\ all but ftoa can convert into PAD if desired.
\ utoa  ( addr u -- addr count )              unsigned int to ASCII
\ itoa  ( addr n -- addr count )              int to ASCII
\ ltoa  ( addr d -- addr count )              long to ASCII
\ ultoa ( addr ud -- addr count )             unsigned long to ASCII


\ Words to write tokens and numbers to a file (no padding)
\ write-float requires the address of a conversion buffer,
\ it must not be PAD.
\ write-token ( addr count fileid -- )
\ write-int   ( n fileid -- )
\ write-uint  ( u fileid -- )
\ write-long  ( d fileid -- )
\ write-ulong ( ud fileid -- )

\  (c) Copyright 1995 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.


CR .( FILEIO-NOFLOAT    V1.3           24 March 1996   EFC )

0 value eol-handler            \ possible user callback
                               \ invoked when and EOL is encountered


: iswhite?  ( c -- t/f )       \ return a true for whitespace chars
        DUP

        \ call eol-handler callback if LF and handler is set
	DUP 10 = eol-handler and if eol-handler execute then

        14 < OVER 8 > AND
        SWAP 32 = OR

;


\ skip to first non-whitespace, stores it at addr
\                               n = -1 if file read error
\                               n = count of whitespace skipped (0 if none)
: skipwhite ( addr fileid -- addr fileid n )

        OVER
        0
        BEGIN
          OVER 
          1 4 PICK READ-FILE
          \ check for file read error
          IF 2DROP DROP -1 EXIT THEN

          \ check to see if there were no more chars
          0= IF 2DROP -1 EXIT THEN
          
          DROP
          OVER
          C@ iswhite?
        WHILE
          1+
        REPEAT

        SWAP DROP
;

\ get whitespace delimited token, stores it at addr
\                               n = -1 if file read error
\                               n = count of token chars if OK
: get-token ( addr fileid -- addr count )

         skipwhite

         0 < IF
                DROP 0
         ELSE
          OVER 1 BEGIN
                   2DUP + 1 4 PICK READ-FILE

                   \ check for file read error
                   IF 2DROP 2DROP -1 EXIT THEN

                   DROP
                   2DUP + C@ iswhite? 0=
           WHILE
             1+
           REPEAT

           SWAP OVER + BL SWAP C!       \ pad with a space at the end

           SWAP DROP
        THEN
;


\ counted string to double int
: atol ( addr count -- d )
     >R
     0. ROT
     R>
     
     >NUMBER
     2DROP
;

\ counted string to single int
: atoi ( addr count -- n )

    atol DROP
;


: move-chars ( dest src count -- dest count )
    >R OVER R@ CMOVE R>
;

: ultoa ( addr ud -- addr count )    \ unsigned long to counted string
    <#  #S #>
    move-chars
;

: utoa ( addr u -- addr count )      \ unsigned int to counted string
    S>D ultoa
;

: ltoa ( addr d -- addr count )      \ (signed) long to counted string
    DUP >R DABS
    <# #S R> SIGN #>
    move-chars
;

: itoa ( addr n -- addr count )       \ (signed) int to counted string
   DUP >R ABS S>D
   <# #S R> SIGN #>
   move-chars
;



: get-int ( fileid -- n )
	PAD SWAP get-token
        DUP 0< ABORT" File read error "
        atoi
;

: get-long ( fileid -- d )
	PAD SWAP get-token
        DUP 0< ABORT" File read error "
        atol
;

: write-token ( addr u fileid -- )
	WRITE-FILE
        ABORT" File write error "
;

: write-int  ( n fileid -- )
        >R PAD SWAP
        itoa R>
        write-token
;

: write-uint  ( u fileid -- )
        >R PAD SWAP
        utoa R>
        write-token
;

: write-long  ( d fileid -- )
        >R PAD ROT ROT
        ltoa R>
        write-token
;

: write-ulong  ( ud fileid -- )
        >R PAD ROT ROT
        ultoa R>
        write-token
;

