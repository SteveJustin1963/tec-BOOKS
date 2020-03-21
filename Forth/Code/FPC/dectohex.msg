
From:  Timothy Trussell                                      Date: 4/20/98
EMail: starjock@ycsi.net
Subj:  Decimal # to Hex string
---------------------------------------------------------------------------

This snippet is for converting a decimal number, in the range 0..65535,
to a string containing it's hexadecimal equivalent, using F-PC FORTH.

------------------------- snip, snip -------------------------------

decimal

\ 1st, create the array that holds the char values of each digit
create AlphaNums  16 allot AlphaNums 16 0 fill

\ Then, stuff the correct char values into the array
" 0123456789ABCDEF" AlphaNums swap cmove

: ConvertToHex                    \ addr number -- addr
  dup 4096 / dup >R 4096 * -      \ addr num-/4096
  dup 256  / dup >R  256 * -      \ addr num-/4096-/256
  dup 16   / dup >R   16 * -      \ addr num-/4096-/256-/16
  R> AlphaNums + C@ 2 pick C!     \  "          "
  R> AlphaNums + C@ 2 pick 1 + C! \  "          "
  R> AlphaNums + C@ 2 pick 2 + C! \  "          "
     AlphaNums + C@ swap   3 + C! \  --
;
----------------------- snip, snip ----------------------------

The example following it is one that I am currently coding, which is
translating a set of Mode X VGA graphics routines for use with FORTH.
The following code allows me to determine where in the dictionary the
routines will be placed, and then to create an include file to the
assembler that simply contains an ORG statement that assembles the code
to the appropriate address in a .COM file.

I am using an external assembler, because the routines are rather
complex, and I want to simply use them - not figure out the logic of
them.  Since I am not including the @110k of source for these VGA
routines, I won't go into greater detail of their operation.

When finished, these routines are removed (FORGET VGAMARKER) and the
rest of the program is loaded.

----------------------- snip, snip ----------------------------

decimal

CR .( Creating VGALIB buffer)
create VGALIB 3620 allot VGALIB 3620 0 fill

: VGAMarker ;                \ where to FORGET to when done

HANDLE VGA_Org_Handle        \ create file handles
HANDLE VGA_ModeX_Handle

create VGA_Name 40 allot VGA_Name 40 0 fill \ create filename arrays
create VGA_Org  40 allot VGA_Org  40 0 fill

\ 1st, create the array that holds the char values of each digit
create AlphaNums  16 allot AlphaNums 16 0 fill

\ Then, stuff the correct char values into the array
" 0123456789ABCDEF" AlphaNums swap cmove

: ConvertToHex                    \ addr number -- addr
  dup 4096 / dup >R 4096 * -      \ addr num-/4096
  dup 256  / dup >R  256 * -      \ addr num-/4096-/256
  dup 16   / dup >R   16 * -      \ addr num-/4096-/256-/16
  R> AlphaNums + C@ 2 pick C!     \  "          "
  R> AlphaNums + C@ 2 pick 1 + C! \  "          "
  R> AlphaNums + C@ 2 pick 2 + C! \  "          "
     AlphaNums + C@ swap   3 + C! \  --
;

\ initialize the strings defined above

: VGA_SetData
  " mx0.a86" VGA_Name 2dup C! 1+ swap cmove
  " modex.com" VGA_ModeX_Handle 2dup C! 1+ swap cmove
  " ORG 0000h" VGA_Org 2dup C! 1+ swap cmove
  13 VGA_Org 10 + C!
  10 VGA_Org 11 + C!
  VGA_Name dup 1+ swap C@ ">$ VGA_Org_Handle $>HANDLE
;

\ Initialize Handle information
VGA_SetData

\ Convert address of VGALIB to a hex string
VGA_Org 5 + VGALIB ConvertToHex

\ open, write and close the data file MX0.A86
: CreateMX0.A86
  VGA_Org_Handle HCREATE drop
  VGA_Org 1+ 12 VGA_Org_Handle HWRITE drop
  VGA_Org_Handle HCLOSE drop
;

CreateMX0.A86                 \ Creating the MX0.A86 file

\ Perform a system call to compile the ModeX library at VGALIBs address

\ This .BAT file calls the A86 assembler, which contains the following
\ command line:

\         a86 -c mx0.a86 mx1.a86 mx2.a86 mx3.a86 TO modex.com

\ The -c tells A86 to ignore upper/lower-case differences

sys modex.bat >nul:

: LoadMODEX.COM         \ loads MODEX.COM into the VGALIB buffer
  VGA_ModeX_Handle HOPEN drop
  VGALIB 256 - 0 VGA_ModeX_Handle movepointer
  VGALIB 3612 VGA_ModeX_Handle HREAD drop
  VGA_ModeX_Handle HCLOSE drop
;

LoadMODEX.COM

forget VGAMarker                \ clear out the work area

\ Now, continue loading the VGA Library access words

----------------------- snip, snip ----------------------------
Again, these routines are coded for use with Tom Zimmers F-PC FORTH.
To use with any other version of FORTH, the file access words would
have to be changed.  It's that simple.



