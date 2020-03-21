

                               FORTH Snippets

------------------------------------------------------------------------------

    Received this on the FORTH LANGUAGE conference on RIME a while back

------------------------------------------------------------------------------
A discussion about defining words produced the following definition to
do enumeration (if you don't understand this, come to a meeting and
learn!):

: ENUM ( -- )  CREATE 0 ,    DOES> ( -- n )  DUP @ CONSTANT  1 SWAP +! ;

The purpose is to allow the creation of a sequence of constants, which is
directly analogous to the C/C++ construct 'enum', and the equivalent TYPE
structure created in Pascal.

In Pascal, you would use:

                TYPE
                  Color = (Red,Blue,Green);

In C, you would use:

                enum Color {Red,Blue,Green};

In FORTH, using the word defined above, you would use:

                ENUM COLOR
                COLOR Red
                COLOR Blue
                COLOR Green

ENUM defines a new enumerate called COLOR.  COLOR can then be used to define
unique CONSTANTs for each color.  In the example, RED will return a value of
zero, BLUE will return 1, and GREEN will return 2.

