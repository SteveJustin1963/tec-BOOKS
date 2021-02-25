; Main program

; $25,$26 - real starting address of the dictionary
; $27,$28 - real ending address of the dictionary
; USP - data stack
; SSP - return stack
; IX - real instruction pointer, IP
; $2,$3 - real address of the executed word, W

	ORG	&H7000
	START	MAIN

PUSH1:		PHUW	$3
NEXT1:		LDIW	$2,(IX+$31)
; here could be only JP ($2) if the dictionary would be located at fixed
; address :(
NEXT2:		ADW	$2,$25
		LDW	$0,($2)
		ADW	$0,$25
		JP	$0

; IZ <- real address of the USER_AREA
USER1:		PRE	IZ,$25
		LD	$0,&H26	;ORIGIN_ADDR + offset of the USER_AREA_PTR
		LDW	$2,(IZ+$0)
; IZ <- real address of a virtual/real address in $2,$3
REAL_ADDR:	SBC	$3,&H60
		JR	NC,REAL_ADDR_2
		ADW	$2,$25
REAL_ADDR_2:	PRE	IZ,$2
		RTN

; from the page 1 calls the procedure $23,$24 in the page 0
SYSCALL:	LDW	$21,SYSCALL_1-1
		PHSW	$22
		GRE	IX,$21
SYSJUMP:	PST	UA,&H50
		JP	$23
SYSCALL_1:	PRE	IX,$21
		PST	UA,&H51
		RTN

; BREAK and error handle routine
BRK1:		PST	UA,&H51
		LD	$0,&H2A		;ORIGIN_ADDR + offset of the QUIT_PFA_PTR
BRK2:		PRE	IZ,$25
		LDW	$0,(IZ+$0)	;PFA field
		ADW	$0,$25		;virtual->real address conversion
		PRE	IX,$0,JR NEXT1	;initial IP value

; starting code, run only once and not further used, could be overwritten
MAIN:		LDW	$2,DIC_NAME
		CAL	&H9040		;copy 11 bytes from $2,$3 to WORK1
		LD	$4,&H0D		;binary file
		CAL	&HE818		;FNSCH, search for file name in WORK1
		RTN	C		;exit if not found
		LDW	$2,BRK1
		CAL	&H90C3		;BRSTR, jump address for BREAK
		PRE	IZ,&H6F51
		SBW	$0,$0
		STM	$31,(IZ+$31),3	;input mode
		PST	UA,&H51
		PRE	IZ,$6		;directory entry for the dictionary file
		LDM	$25,(IZ+$30),4	;addresses of the dictionary file
		CAL	USER1
		LD	$0,&H28		;offset of the user variable USE
		STW	$6,(IZ+$0)	;directory entry for the dictionary file
		LD	$0,&H28,JR BRK2	;ORIGIN_ADDR + offset of the COLD_PFA_PTR

DIC_NAME:	DB	"FORTHDICBIN"
