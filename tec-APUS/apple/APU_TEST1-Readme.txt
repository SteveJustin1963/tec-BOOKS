APU TEST#1

NOTE: The card can be placed into all slots except slot #0

Depending on your choosen slot the card addresses are:
SLOT#1	$C090	= DATA Register;	$C091	= COMMAND REGISTER
SLOT#2	$C0A0	= DATA Register;	$C0A1	= COMMAND REGISTER	
SLOT#3	$C0B0	= DATA Register;	$C0B1	= COMMAND REGISTER
SLOT#4	$C0C0	= DATA Register;	$C0C1	= COMMAND REGISTER
SLOT#5	$C0D0	= DATA Register;	$C0D1	= COMMAND REGISTER
SLOT#6	$C0E0	= DATA Register;	$C0E1	= COMMAND REGISTER
(SLOT#7	$C0F0	= DATA Register;	$C0F1	= COMMAND REGISTER)

START YOUR APPLE USING BASIC
assuming your card is positioned at slot#1

Type:   CALL -151(CR)	to start the monitor
Type:	C091:1A(CR)		will load command code 1A which equals PI into the data register
Type:   C090.C097(CR)	should show the result of 8 bytes as follows, if the card works

		C090- 02 00 C9 00 0F 00 DA 00
		
Please read the CCS Modell 7811 Owners manual for more details
I also recommend to download and read the AM9511A and/or INTEL C8231A datasheets which can
be found at the internet
		
		