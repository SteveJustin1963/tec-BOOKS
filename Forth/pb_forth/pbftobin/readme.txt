
The latest version of this program along with the source can be downloaded
from:

http://www.lsigame.com/pb-1000/softlib/file/pbf_bin_conv.zip



*********************************************************************
*           PBF to binary data converter for PB-1000/C              *
*         (C)2007 Miyura (miyura321@ybb.ne.jp) and Blue             *
*********************************************************************

This document describes PBF-binary file converter for the PB-1000/C.

1.Functions
  This program converts a PBF text format file into a binary data file
  via RS-232C interface. This program is useful and fast compared to
  the previous version due to programming in machine language completely.

2.System Requirements
* Minimum
  PB-1000/C
  RS-232C interface (FA-7 or MD-100)
  Data transfer program (via RS232C)
* Recommended
  Expanded 32KB RAM (RP-32)

3.Contents of attached files
  This file				readme.txt
  BASIC file to make execute file	pbftobin.bas   (for PB-1000)

4.How to install the program
  Input LOAD "COM0: in BASIC mode and send "pbftobin.bas" file from
  PC to the PB-1000 via RS-232C I/F.
  When the transfer is completed, push [BRK] key. And then you can find
  a BASIC file with no name. Enter an appropriate name for this file.

  Set over 378 bytes execute file loading area and execute the BASIC file.
  After a while, the execute file named "PBFTOBIN.EXE" will be created.

5.How to execute the program
  Execute "PBFTOBIN.EXE" in MENU mode.

  Send a PBF text file from PC to PB-1000 after "loading pbf." is displayed.
  When the data transfer starts, you can see the rotation of the arrow graphic.
  After transfer and conversion are successfully completed, it returns to
  MENU mode and the cursor is set to the position according to the generated
  binary file. The file with the same name is overwritten with new information.

  If the memory is not sufficient or the PBF file format is invalid, an error
  occurs and the binary file is not generated.

  The program refers to the work RSFG(&H6C00) for the RS232C parameter.
  Therefore, you should be set the work area to an appropriate value. 
  It can be confirmed and modified in MENU mode.(e.g. [load]-->[RS232C])

6.Copyrights and disclaims
  This program is a freeware, however copyright subsists in all programs.
  I disclaim any guarantee against losses caused by use of the programs.
