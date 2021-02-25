PB_Forth - fig-Forth implementation for the Casio PB-1000


Installation instructions
=========================

1. On the PB-1000 type CLEAR ,512 to allocate space for machine code programs

2. Install the PBFTOBIN file conversion utility which can be found in the
 PBFTOBIN directory or downloaded from:

	http://www.lsigame.com/pb-1000/softlib/file/pbf_bin_conv.zip

3. Use the PBFTOBIN utility to transfer the files FORTH.PBF and FORTHDIC.PBF
 from the PC to the PB-1000 via the RS232 port

4. Transfer the text file ERRORS.FOR to the PB-1000

The PB-1000 should now contain following files:

  FORTH.EXE - main program
  FORTHDIC.BIN - dictionary file
  ERRORS.FOR - list of error messages


Disk access
===========

All old-fashioned words dealing with the disks on the block level have been
mercilessly removed:

(ABORT)	(LINE)	+BUF	-->	.LINE	B/BUF	B/SCR	BLOCK	BUFFER	DR0
DR1	EMPTY-BUFFERS	FIRST	FLUSH	INDEX	LIST	OFFSET	PREV	R/W
SCR	TRIAD	UPDATE	?LOADING

The PB_Forth doesn't have its own editor. Source files can be prepared with
any standard text editor, for example with the built-in PB-1000 memo editor,
then loaded with the LOAD operator. Missing file of specified name causes the
error #9 - File not found.

Syntax: LOAD filename

On exit all operators and data added to the dictionary are lost. To preserve
the modified dictionary use the operator SAVE.

Syntax: SAVE


PB_Forth peculiarities and differences from the standard
========================================================

From the Forth programmer's point of view, the dictionary is located in a
virtual address space &H0000..&H5FFF. An address within this range is treated
as relative to the beginning address of the dictionary file, otherwise as
absolute.

Any direct change of DP must be followed by the word RESIZE which adjusts the
size of the dictionary file. This requirement doesn't concern predefined words
influencing DP (like ALLOT) which do this already.


Summary of new and modified words
=================================

USE		- pointer to the directory entry <de> of the dictionary file
-- de

BLK		- pointer to the directory entry <de> of the loaded file or 0
-- de		  when input from the terminal

FILE		- expects the file type <n> and an address of the file name
n a -- de	  <a> preceded by the number of characters,
		  returns the pointer to the directory entry <de> or 0 if the
		  specified file doesn't exist

(LOAD)		- compiled by the operator LOAD, interprets a script from
de --		  a file specified by the pointer to the directory entry <de>

LOAD filename	- interprets a script from a file of a name following the
--		  operator

SAVE		- preserves the modified dictionary file
--

MESSAGE		- similar to fig-Forth, but fetches the error messages from
n --		  the file ERRORS.FOR instead of screens 4..5

WORD		- similar to fig-Forth, but reads data from a file instead of
c --		  a block when BLK <> 0

EXPECT		- the command doesn't terminate after <n> characters have been
a n --		  typed, but requires the EXE key to be pressed

RESIZE		- adjusts the size of the dictionary file after DP change
--

FREE		- returns the size of free memory, DATDI-MEMEN
-- n

NEXT1		- pointer to the main execution loop
-- a

SYSCALL		- pointer to a machine code routine executing a machine code
-- a		  routine pointed to by $23,$24 from the memory bank 0

REAL_ADDR	- pointer to a machine code routine converting virtual address
-- a		  in $2,$3 to a real one in $2,$3 and IZ


Syntax of the CASE statement:

selector
CASE
  value1 OF code_executed_when_selector=value1 ENDOF
  value2 OF code_executed_when_selector=value2 ENDOF
  value3 OF code_executed_when_selector=value3 ENDOF
  code_executed_if_a_match_is_not_found
ENDCASE

Example:

: NUMBER-NAME ( n -- )
  CASE
    0 OF ." ZERO" ENDOF
    1 OF ." ONE" ENDOF
    2 OF ." TWO" ENDOF
    ." OTHER"
  ENDCASE
;


Machine code programming
========================

Example 1
---------

 Definition of the operator PICK which copies the n'th element deep in the
 data stack to the top.
 0 PICK is equivalent to DUP
 1 PICK is equivalent to OVER

HEX
CREATE PICK
AF C, 00 C,             ( PPUW $0 )
9E C, 62 C,             ( GRE US,$2 )
98 C, 60 C,             ( BIUW $0 )
88 C, 42 C,             ( ADW $2,$0 )
91 C, 60 C, 02 C,       ( LDW $0,[$2] )
A7 C, 01 C,             ( PHUW $1 )
37 C, NEXT1 ,           ( JP NEXT1 )
SMUDGE


Example 2
---------

 Definition of the operator BEEP which emits a low tone beep.

HEX
CREATE BEEP
D1 C, 17 C, AAE3 ,	( LDW $23,&HAAE3 ;addres of the ROM subroutine )
77 C, SYSCALL ,		( CAL SYSCALL )
37 C, NEXT1 ,		( JP NEXT1 )
SMUDGE


Example 3
---------

 Definition of the operator CALL0 which creates operators calling machine code
 subroutines from the memory bank 0.

HEX
: CALL0 CREATE SMUDGE , ;CODE
96 C, 42 C,		( PRE IZ,$2 ;real address of the executed word, W )
42 C, 00 C, 02 C,	( LD $0,2 )
A9 C, 57 C,		( LDW $23,[IZ+$0] )
77 C, SYSCALL ,		( CAL SYSCALL )
37 C, NEXT1 ,		( JP NEXT1 )

 Example operators BEEP0, BEEP1, CLS created with CALL0

HEX
AAE3 CALL0 BEEP0	( low tone beep )
AB11 CALL0 BEEP1	( high tone beep )
95CA CALL0 CLS		( clear screen )
