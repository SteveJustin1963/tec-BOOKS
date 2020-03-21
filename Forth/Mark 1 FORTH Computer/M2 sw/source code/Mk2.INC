OP_NOP              EQU 0
OP_EN               EQU 1
OP_DI               EQU 2
OP_RD_WORD          EQU 3
OP_RD_BYTE          EQU 4
OP_WR_WORD          EQU 5
OP_WR_BYTE          EQU 6
OP_R2R              EQU 7
OP_TEST_R           EQU 8
OP_TEST_M           EQU 9
OP_IMMED            EQU 10
OP_COND             EQU 11
OP_IOR              EQU 12
OP_IOW              EQU 13
OP_BIS              EQU 14
OP_RESET            EQU 15

                    ; ----------------------------------------------

ALU_A_PLUS_CARRY    EQU 1
ALU_ADD             EQU 2
ALU_ADC             EQU 3
ALU_SUB             EQU 4
ALU_SBB             EQU 5
ALU_ASL             EQU 6
ALU_ROL             EQU 7

ALU_A               EQU 8
ALU_B               EQU 9
ALU_AND             EQU 10
ALU_OR              EQU 11
ALU_NOT_A           EQU 12
ALU_NOT_B           EQU 13
ALU_XOR             EQU 14
ALU_ZERO            EQU 15

                    ; ----------------------------------------------

COND_BEQ            EQU 101b
COND_BNE            EQU 001b

COND_BPL            EQU 110b    ; Note: TEST uses ALU_NOT
COND_BMI            EQU 010b

COND_BCS            EQU 111b
COND_BCC            EQU 011b

                    ; ----------------------------------------------

MB                  MACRO hi, lo:=<0>
                    DB ((hi) SHL 4)+(lo)
                    ENDM

                    ; ----------------------------------------------

RdWord              MACRO rb, ra
                    MB rb, ra
                    MB OP_RD_WORD
                    ENDM

RdByte              MACRO rb, ra
                    MB rb, ra
                    MB OP_RD_BYTE
                    ENDM

WrWord              MACRO rb, ra
                    MB rb, ra
                    MB OP_WR_WORD
                    ENDM

WrByte              MACRO rb, ra
                    MB rb, ra
                    MB OP_WR_BYTE
                    ENDM

R2R                 MACRO alu, rb, ra:=<0>
                    MB rb, ra
                    MB OP_R2R, alu
                    ENDM

TestR               MACRO r
                    MB r
                    MB OP_TEST_R
                    ENDM

TestM               MACRO r
                    MB 0, r
                    MB OP_TEST_M
                    ENDM

Immed               MACRO alu, rb, d
                    MB rb, d AND 15
                    MB OP_IMMED, alu
                    ENDM

Cond                MACRO cond, dest
                    LOCAL $1
                    DB (dest-$1) AND 00111111b
                    MB OP_COND, cond
                    $1:
                    ENDM

IOR                 MACRO rb, ra
                    MB rb, ra
                    MB OP_IOR
                    ENDM
                    
IOW                 MACRO rb, ra
                    MB rb, ra
                    MB OP_IOW
                    ENDM

                    ; ----------------------------------------------

PC                  EQU 7
PSP                 EQU 6
RSP                 EQU 5
IP                  EQU 4
W                   EQU 3

                    ; ----------------------------------------------

$PUSH               MACRO   rb, sp
                    immed   alu_sub, sp, 2
                    wrword  rb, sp
                    ENDM

$PULL               MACRO   rb, sp
                    rdword  rb, sp
                    immed   alu_add, sp, 2
                    ENDM

                    ; ----------------------------------------------
