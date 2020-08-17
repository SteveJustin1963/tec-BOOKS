HES 64FORTH                                   29-Nov-02
-------------------------------------------------------

64FORTH is a cartridge program for the Commodore 64.

64FORTH is an implementation of the FORTH programming
language. It is a super-set of fig-FORTH. It uses the
Commodore file-system and has many functions that
access the C64 hardware including sound and graphics.
It occupies 16k of cartridge memory from $8000-BFFF
and comes with a comprehensive manual. 64FORTH was
written by Tom Zimmer and published by HES software in
1983.

Thanks to Tom Zimmer for allowing 64FORTH to be freely
distributed. Tom has advised that while 64FORTH is free
for anyone to use, he is unable to provide any support
or answer queries regarding it.

Thanks also to Jason at http://thisoldcomputer.com/
for providing a dump of the cartridge.

-------------------------------------------------------
Files in this archive include:

64FORTH.TXT   64FORTH manual
64FORTH.ROM   64FORTH rom image
64FORTH.CRT   64FORTH in cartridge file format for use
              with Commodore emulators
64FORTH.PRG   A hacked version of 64FORTH that runs in
              ram (see patch details below). It has an
              integrated loader and may be loaded and
              run like any BASIC program.
64FORTH.ASM   A disassembly of the 64FORTH rom in 6502
              assembly language.

-------------------------------------------------------
Notes:

1. Those without a Commodore 64 can still run 64FORTH by
   using an emulator. A suitable freeware emulator that
   will run on several platforms may be found at:

     http://viceteam.bei.t-online.de/

2. 64FORTH.PRG and 64FORTH.ASM are "unofficial". If they
   don't work or have errors, blame me - not Tom :)

3. 64FORTH.ASM is intended as a basic disassembly only.
   It uses standard 6502 MOS Technology notation and may
   be re-assembled using the public domain MS-DOS A65
   assembler available at:

     http://www.nic.funet.fi/pub/cbm/programming/msdos/

-------------------------------------------------------
64FORTH SOFTLOAD MODIFICATIONS   27/7/85

The following describes an unofficial hack which can be
made to the program to allow 64FORTH to be 'soft-loaded'
i.e. loaded into memory and run like any other program!

1. SWITCH BASIC OUT

   .: 8027 A9 36 85 01   (REPLACES 'NOP'S )

   LDA #$36
   STA $01

2. PREVENT FORTH FROM SWITCHING IN BASIC

   .: A765 36            (.:A765 37 )

3. PREVENT ERASURE OF $8000 - $83FF

   .: 93F5 D4 86         (REPLACES 'ERASE' WITH '2DROP')

4. PREVENT RESET FROM CORRUPTING $A000

   .: 8021 EA EA EA      (DISABLE RAMTAS ROUTINE $FD50 )

5. COMPUTE NEW CHECKSUM

   .: 9389 F2 82

6. ORIGINAL VALUES

   .: 8021 20 50 FD
   .: 8027 EA EA EA EA
   .: 9389 E4 83
   .: 93F5 45 8E
   .: A765 37

-------------------------------------------------------
