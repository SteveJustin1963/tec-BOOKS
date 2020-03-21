

: ENUM ( -- )  CREATE 0 ,    DOES> ( -- n )  DUP @ CONSTANT  1 SWAP +! ;

((
   An example of use is:

        ENUM COLOR
        COLOR RED
        COLOR BLUE
        COLOR GREEN

ENUM defines a new enumerate called COLOR.  COLOR can then be used to define
unique CONSTANTs for each color.  In the example, RED will return a value of
zero, BLUE will return 1, and GREEN will return 2.
))

