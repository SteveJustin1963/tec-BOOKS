PCCA Assembler      st.A



                        1  CSEG 
                        2  DSEG 
                        3 y_ RB 2
0000 0100               4 z_ DW 1
0002 0100               5 w_ DW 1
                        6 i_ RB 2
                        7 v_ RB 2
                        8 m_ RB 2
                        9 r_ RB 2
0004 0000              10 p_ DW 0
                       11 n_ RB 2
                       12 mx_ RB 2
                       13 s_ RB 2
                       14 f_ RB 2
                       15 st_ RB 4000
0006 00                16 t_ DB   0
                       17 c_ RB 1
                       18 u_ RB 1
                       19 a_ RB 1
0007 00                20 k_ DB   0
                       21 pr_ RB 2000
                       22  CSEG 
                       23  PUBLIC main_
                       24  PUBLIC fopen_
                       25  DSEG 
0008 726200            26 __22 DB 'rb',0
                       27  CSEG 
                       28  PUBLIC putc_
                       29  PUBLIC exit_
                       30  PUBLIC fgetc_
                       31  PUBLIC fclose_
                       32  PUBLIC atoi_
                       33  PUBLIC getc_
                       34  PUBLIC printf_
                       35  DSEG 
000B 256400            36 __31 DB '%d',0
                       37  CSEG 
                       38 
0000 55                39 main_: PUSH BP
0001 8BEC              40  MOV BP,SP
0003 83EC02            41  SUB SP,2
0006 B80000            42  MOV AX,OFFSET __22
0009 50                43  PUSH AX
000A 8B7606            44  MOV SI,WORD [BP+6]
000D FF7402            45  PUSH WORD [SI+2]
0010 E80000            46  CALL fopen_
0013 83C404            47  ADD SP,4
0016 8946FE            48  MOV WORD [BP-2],AX
0019 3D0000            49  CMP AX,0
001C 7518              50  JNZ _L1
001E B80100            51  MOV AX,1
0021 50                52  PUSH AX
0022 B83F00            53  MOV AX,63
0025 50                54  PUSH AX
0026 E80000            55  CALL putc_
0029 83C404            56  ADD SP,4
002C B80100            57  MOV AX,1
002F 50                58  PUSH AX
PCCA Assembler      st.A



0030 E80000            59  CALL exit_
0033 83C402            60  ADD SP,2
                       61 _L1:
                       62 _L2:
0036 FF76FE            63  PUSH WORD [BP-2]
0039 E80000            64  CALL fgetc_
003C 83C402            65  ADD SP,2
003F A20000            66  MOV BYTE c_,AL
0042 3CFF              67  CMP AL,255
0044 7411              68  JZ _L3
0046 8B360000          69  MOV SI,WORD p_
004A FF060000          70  INC WORD p_
004E A00000            71  MOV AL,BYTE c_
0051 88840000          72  MOV BYTE pr_[SI],AL
0055 EBDF              73  JMP _L2
                       74 _L3:
0057 FF76FE            75  PUSH WORD [BP-2]
005A E80000            76  CALL fclose_
005D 83C402            77  ADD SP,2
0060 A10000            78  MOV AX,WORD p_
0063 A30000            79  MOV WORD mx_,AX
0066 C7060000CF07      80  MOV WORD i_,1999
                       81 _L4:
006C A10000            82  MOV AX,WORD i_
006F FF0E0000          83  DEC WORD i_
0073 3D0000            84  CMP AX,0
0076 740E              85  JZ _L5
0078 8B360000          86  MOV SI,WORD i_
007C D1E6              87  SHL SI,1
007E C78400000000      88  MOV WORD st_[SI],0
0084 EBE6              89  JMP _L4
                       90 _L5:
0086 C70600000000      91  MOV WORD i_,0
                       92 _L6:
008C A10000            93  MOV AX,WORD i_
008F 3B4604            94  CMP AX,WORD [BP+4]
0092 7D2B              95  JGE _L7
0094 833E000001        96  CMP WORD i_,1
0099 7E1E              97  JLE _L9
009B 8B360000          98  MOV SI,WORD i_
009F D1E6              99  SHL SI,1
00A1 037606           100  ADD SI,WORD [BP+6]
00A4 FF34             101  PUSH WORD [SI]
00A6 E80000           102  CALL atoi_
00A9 83C402           103  ADD SP,2
00AC 8B360000         104  MOV SI,WORD i_
00B0 83EE02           105  SUB SI,2
00B3 D1E6             106  SHL SI,1
00B5 89840000         107  MOV WORD st_[SI],AX
                      108 _L9:
                      109 _L8:
00B9 FF060000         110  INC WORD i_
00BD EBCD             111  JMP _L6
                      112 _L7:
00BF C70600000000     113  MOV WORD p_,0
00C5 C70600003C00     114  MOV WORD r_,60
00CB C70600006400     115  MOV WORD s_,100
                      116 _L10:
PCCA Assembler      st.A



00D1 A10000           117  MOV AX,WORD p_
00D4 3B060000         118  CMP AX,WORD mx_
00D8 7E03E90000       119  JG _L11
00DD 8B360000         120  MOV SI,WORD p_
00E1 8A840000         121  MOV AL,BYTE pr_[SI]
00E5 A20000           122  MOV BYTE u_,AL
00E8 803E00007D       123  CMP BYTE u_,125
00ED 7512             124  JNZ _L12
00EF 8B360000         125  MOV SI,WORD r_
00F3 D1E6             126  SHL SI,1
00F5 8BB40000         127  MOV SI,WORD st_[SI]
00F9 89360000         128  MOV WORD p_,SI
00FD FF0E0000         129  DEC WORD r_
                      130 _L12:
0101 803E000041       131  CMP BYTE u_,65
0106 7236             132  JB _L13
0108 803E00005A       133  CMP BYTE u_,90
010D 772F             134  JA _L13
010F FF060000         135  INC WORD r_
0113 8B360000         136  MOV SI,WORD r_
0117 D1E6             137  SHL SI,1
0119 A10000           138  MOV AX,WORD p_
011C 89840000         139  MOV WORD st_[SI],AX
0120 A00000           140  MOV AL,BYTE u_
0123 2C23             141  SUB AL,35
0125 B400             142  MOV AH,0
0127 D1E0             143  SHL AX,1
0129 8BF0             144  MOV SI,AX
012B 8BB40000         145  MOV SI,WORD st_[SI]
012F 89360000         146  MOV WORD p_,SI
0133 8B360000         147  MOV SI,WORD p_
0137 8A840000         148  MOV AL,BYTE pr_[SI]
013B A20000           149  MOV BYTE u_,AL
                      150 _L13:
013E 803E00007B       151  CMP BYTE u_,123
0143 753D             152  JNZ _L14
0145 8B360000         153  MOV SI,WORD p_
0149 83C601           154  ADD SI,1
014C 8A840000         155  MOV AL,BYTE pr_[SI]
0150 2C23             156  SUB AL,35
0152 B400             157  MOV AH,0
0154 A30000           158  MOV WORD f_,AX
0157 A10000           159  MOV AX,WORD p_
015A 050200           160  ADD AX,2
015D 8B360000         161  MOV SI,WORD f_
0161 D1E6             162  SHL SI,1
0163 89840000         163  MOV WORD st_[SI],AX
                      164 _L15:
0167 803E00007D       165  CMP BYTE u_,125
016C 7411             166  JZ _L16
016E FF060000         167  INC WORD p_
0172 8B360000         168  MOV SI,WORD p_
0176 8A840000         169  MOV AL,BYTE pr_[SI]
017A A20000           170  MOV BYTE u_,AL
017D EBE8             171  JMP _L15
                      172 _L16:
017F E90000           173  JMP main_nx_
                      174 _L14:
PCCA Assembler      st.A



0182 803E00003D       175  CMP BYTE u_,61
0187 7403E90000       176  JNZ _L17
018C 8B360000         177  MOV SI,WORD s_
0190 D1E6             178  SHL SI,1
0192 A10000           179  MOV AX,WORD s_
0195 2D0100           180  SUB AX,1
0198 D1E0             181  SHL AX,1
019A 8BF8             182  MOV DI,AX
019C 8BB40000         183  MOV SI,WORD st_[SI]
01A0 3BB50000         184  CMP SI,WORD st_[DI]
01A4 750E             185  JNZ _L18
01A6 8B360000         186  MOV SI,WORD s_
01AA D1E6             187  SHL SI,1
01AC C7840000FFFF     188  MOV WORD st_[SI],-1
01B2 EB0C             189  JMP _L19
                      190 _L18:
01B4 8B360000         191  MOV SI,WORD s_
01B8 D1E6             192  SHL SI,1
01BA C78400000000     193  MOV WORD st_[SI],0
                      194 _L19:
                      195 _L17:
01C0 803E00003E       196  CMP BYTE u_,62
01C5 7534             197  JNZ _L20
01C7 8B360000         198  MOV SI,WORD s_
01CB D1E6             199  SHL SI,1
01CD A10000           200  MOV AX,WORD s_
01D0 2D0100           201  SUB AX,1
01D3 D1E0             202  SHL AX,1
01D5 8BF8             203  MOV DI,AX
01D7 8BB40000         204  MOV SI,WORD st_[SI]
01DB 3BB50000         205  CMP SI,WORD st_[DI]
01DF 7D0E             206  JGE _L21
01E1 8B360000         207  MOV SI,WORD s_
01E5 D1E6             208  SHL SI,1
01E7 C7840000FFFF     209  MOV WORD st_[SI],-1
01ED EB0C             210  JMP _L22
                      211 _L21:
01EF 8B360000         212  MOV SI,WORD s_
01F3 D1E6             213  SHL SI,1
01F5 C78400000000     214  MOV WORD st_[SI],0
                      215 _L22:
                      216 _L20:
01FB 803E00003C       217  CMP BYTE u_,60
0200 7534             218  JNZ _L23
0202 8B360000         219  MOV SI,WORD s_
0206 D1E6             220  SHL SI,1
0208 A10000           221  MOV AX,WORD s_
020B 2D0100           222  SUB AX,1
020E D1E0             223  SHL AX,1
0210 8BF8             224  MOV DI,AX
0212 8BB40000         225  MOV SI,WORD st_[SI]
0216 3BB50000         226  CMP SI,WORD st_[DI]
021A 7E0E             227  JLE _L24
021C 8B360000         228  MOV SI,WORD s_
0220 D1E6             229  SHL SI,1
0222 C7840000FFFF     230  MOV WORD st_[SI],-1
0228 EB0C             231  JMP _L25
                      232 _L24:
PCCA Assembler      st.A



022A 8B360000         233  MOV SI,WORD s_
022E D1E6             234  SHL SI,1
0230 C78400000000     235  MOV WORD st_[SI],0
                      236 _L25:
                      237 _L23:
0236 803E00005B       238  CMP BYTE u_,91
023B 7545             239  JNZ _L26
023D FF060000         240  INC WORD r_
0241 8B360000         241  MOV SI,WORD r_
0245 D1E6             242  SHL SI,1
0247 A10000           243  MOV AX,WORD p_
024A 89840000         244  MOV WORD st_[SI],AX
024E 8B360000         245  MOV SI,WORD s_
0252 D1E6             246  SHL SI,1
0254 83BC000000       247  CMP WORD st_[SI],0
0259 7527             248  JNZ _L27
025B FF060000         249  INC WORD p_
025F 8B360000         250  MOV SI,WORD p_
0263 8A840000         251  MOV AL,BYTE pr_[SI]
0267 A20000           252  MOV BYTE u_,AL
                      253 _L28:
026A 803E00005D       254  CMP BYTE u_,93
026F 7411             255  JZ _L29
0271 FF060000         256  INC WORD p_
0275 8B360000         257  MOV SI,WORD p_
0279 8A840000         258  MOV AL,BYTE pr_[SI]
027D A20000           259  MOV BYTE u_,AL
0280 EBE8             260  JMP _L28
                      261 _L29:
                      262 _L27:
                      263 _L26:
0282 803E000028       264  CMP BYTE u_,40
0287 7403E90000       265  JNZ _L30
028C 8B360000         266  MOV SI,WORD s_
0290 D1E6             267  SHL SI,1
0292 83BC000000       268  CMP WORD st_[SI],0
0297 7403E90000       269  JNZ _L31
029C FF0E0000         270  DEC WORD s_
02A0 FF060000         271  INC WORD p_
02A4 8B360000         272  MOV SI,WORD p_
02A8 8A840000         273  MOV AL,BYTE pr_[SI]
02AC A20000           274  MOV BYTE u_,AL
                      275 _L32:
02AF 803E000029       276  CMP BYTE u_,41
02B4 7503E90000       277  JZ _L33
02B9 FF060000         278  INC WORD p_
02BD 8B360000         279  MOV SI,WORD p_
02C1 8A840000         280  MOV AL,BYTE pr_[SI]
02C5 A20000           281  MOV BYTE u_,AL
02C8 EBE5             282  JMP _L32
                      283 _L33:
02CA EB04             284  JMP _L34
                      285 _L31:
02CC FF0E0000         286  DEC WORD s_
                      287 _L34:
                      288 _L30:
02D0 803E00005F       289  CMP BYTE u_,95
02D5 7517             290  JNZ _L35
PCCA Assembler      st.A



02D7 8B360000         291  MOV SI,WORD s_
02DB D1E6             292  SHL SI,1
02DD 8BB40000         293  MOV SI,WORD st_[SI]
02E1 F7DE             294  NEG SI
02E3 A10000           295  MOV AX,WORD s_
02E6 D1E0             296  SHL AX,1
02E8 8BF8             297  MOV DI,AX
02EA 89B50000         298  MOV WORD st_[DI],SI
                      299 _L35:
02EE 803E000026       300  CMP BYTE u_,38
02F3 751C             301  JNZ _L36
02F5 8B360000         302  MOV SI,WORD s_
02F9 D1E6             303  SHL SI,1
02FB A10000           304  MOV AX,WORD s_
02FE 2D0100           305  SUB AX,1
0301 D1E0             306  SHL AX,1
0303 8BF8             307  MOV DI,AX
0305 8BB40000         308  MOV SI,WORD st_[SI]
0309 21B50000         309  AND WORD st_[DI],SI
030D FF0E0000         310  DEC WORD s_
                      311 _L36:
0311 803E00007C       312  CMP BYTE u_,124
0316 751C             313  JNZ _L37
0318 8B360000         314  MOV SI,WORD s_
031C D1E6             315  SHL SI,1
031E A10000           316  MOV AX,WORD s_
0321 2D0100           317  SUB AX,1
0324 D1E0             318  SHL AX,1
0326 8BF8             319  MOV DI,AX
0328 8BB40000         320  MOV SI,WORD st_[SI]
032C 09B50000         321  OR WORD st_[DI],SI
0330 FF0E0000         322  DEC WORD s_
                      323 _L37:
0334 803E00007E       324  CMP BYTE u_,126
0339 7517             325  JNZ _L38
033B 8B360000         326  MOV SI,WORD s_
033F D1E6             327  SHL SI,1
0341 8BB40000         328  MOV SI,WORD st_[SI]
0345 F7D6             329  NOT SI
0347 A10000           330  MOV AX,WORD s_
034A D1E0             331  SHL AX,1
034C 8BF8             332  MOV DI,AX
034E 89B50000         333  MOV WORD st_[DI],SI
                      334 _L38:
0352 803E00002B       335  CMP BYTE u_,43
0357 752F             336  JNZ _L39
0359 803E000000       337  CMP BYTE k_,0
035E 751E             338  JNZ _L40
0360 8B360000         339  MOV SI,WORD s_
0364 D1E6             340  SHL SI,1
0366 A10000           341  MOV AX,WORD s_
0369 2D0100           342  SUB AX,1
036C D1E0             343  SHL AX,1
036E 8BF8             344  MOV DI,AX
0370 8BB40000         345  MOV SI,WORD st_[SI]
0374 01B50000         346  ADD WORD st_[DI],SI
0378 FF0E0000         347  DEC WORD s_
037C EB0A             348  JMP _L41
PCCA Assembler      st.A



                      349 _L40:
037E 8B360000         350  MOV SI,WORD v_
0382 D1E6             351  SHL SI,1
0384 FF840000         352  INC WORD st_[SI]
                      353 _L41:
                      354 _L39:
0388 803E00002D       355  CMP BYTE u_,45
038D 752F             356  JNZ _L42
038F 803E000000       357  CMP BYTE k_,0
0394 751E             358  JNZ _L43
0396 8B360000         359  MOV SI,WORD s_
039A D1E6             360  SHL SI,1
039C A10000           361  MOV AX,WORD s_
039F 2D0100           362  SUB AX,1
03A2 D1E0             363  SHL AX,1
03A4 8BF8             364  MOV DI,AX
03A6 8BB40000         365  MOV SI,WORD st_[SI]
03AA 29B50000         366  SUB WORD st_[DI],SI
03AE FF0E0000         367  DEC WORD s_
03B2 EB0A             368  JMP _L44
                      369 _L43:
03B4 8B360000         370  MOV SI,WORD v_
03B8 D1E6             371  SHL SI,1
03BA FF8C0000         372  DEC WORD st_[SI]
                      373 _L44:
                      374 _L42:
03BE 803E00002A       375  CMP BYTE u_,42
03C3 7403E90000       376  JNZ _L45
03C8 8B360000         377  MOV SI,WORD s_
03CC 83EE01           378  SUB SI,1
03CF D1E6             379  SHL SI,1
03D1 A10000           380  MOV AX,WORD s_
03D4 D1E0             381  SHL AX,1
03D6 8BF8             382  MOV DI,AX
03D8 8B840000         383  MOV AX,WORD st_[SI]
03DC F7AD0000         384  IMUL WORD st_[DI]
03E0 8B360000         385  MOV SI,WORD s_
03E4 83EE01           386  SUB SI,1
03E7 D1E6             387  SHL SI,1
03E9 89840000         388  MOV WORD st_[SI],AX
03ED FF0E0000         389  DEC WORD s_
                      390 _L45:
03F1 803E00002F       391  CMP BYTE u_,47
03F6 752A             392  JNZ _L46
03F8 8B360000         393  MOV SI,WORD s_
03FC 83EE01           394  SUB SI,1
03FF D1E6             395  SHL SI,1
0401 A10000           396  MOV AX,WORD s_
0404 D1E0             397  SHL AX,1
0406 8BF8             398  MOV DI,AX
0408 8B840000         399  MOV AX,WORD st_[SI]
040C 99               400  CWD
040D F7BD0000         401  IDIV WORD st_[DI]
0411 8B360000         402  MOV SI,WORD s_
0415 83EE01           403  SUB SI,1
0418 D1E6             404  SHL SI,1
041A 89840000         405  MOV WORD st_[SI],AX
041E FF0E0000         406  DEC WORD s_
PCCA Assembler      st.A



                      407 _L46:
0422 803E000025       408  CMP BYTE u_,37
0427 752A             409  JNZ _L47
0429 8B360000         410  MOV SI,WORD s_
042D 83EE01           411  SUB SI,1
0430 D1E6             412  SHL SI,1
0432 A10000           413  MOV AX,WORD s_
0435 D1E0             414  SHL AX,1
0437 8BF8             415  MOV DI,AX
0439 8B840000         416  MOV AX,WORD st_[SI]
043D 99               417  CWD
043E F7BD0000         418  IDIV WORD st_[DI]
0442 8B360000         419  MOV SI,WORD s_
0446 83EE01           420  SUB SI,1
0449 D1E6             421  SHL SI,1
044B 89940000         422  MOV WORD st_[SI],DX
044F FF0E0000         423  DEC WORD s_
                      424 _L47:
0453 803E000023       425  CMP BYTE u_,35
0458 751C             426  JNZ _L48
045A FF060000         427  INC WORD s_
045E 8B360000         428  MOV SI,WORD s_
0462 83EE01           429  SUB SI,1
0465 D1E6             430  SHL SI,1
0467 A10000           431  MOV AX,WORD s_
046A D1E0             432  SHL AX,1
046C 8BF8             433  MOV DI,AX
046E 8BB40000         434  MOV SI,WORD st_[SI]
0472 89B50000         435  MOV WORD st_[DI],SI
                      436 _L48:
0476 803E00005C       437  CMP BYTE u_,92
047B 7504             438  JNZ _L49
047D FF0E0000         439  DEC WORD s_
                      440 _L49:
0481 803E000024       441  CMP BYTE u_,36
0486 7536             442  JNZ _L50
0488 8B360000         443  MOV SI,WORD s_
048C D1E6             444  SHL SI,1
048E 8BB40000         445  MOV SI,WORD st_[SI]
0492 89360000         446  MOV WORD i_,SI
0496 8B360000         447  MOV SI,WORD s_
049A 83EE01           448  SUB SI,1
049D D1E6             449  SHL SI,1
049F A10000           450  MOV AX,WORD s_
04A2 D1E0             451  SHL AX,1
04A4 8BF8             452  MOV DI,AX
04A6 8BB40000         453  MOV SI,WORD st_[SI]
04AA 89B50000         454  MOV WORD st_[DI],SI
04AE 8B360000         455  MOV SI,WORD s_
04B2 83EE01           456  SUB SI,1
04B5 D1E6             457  SHL SI,1
04B7 A10000           458  MOV AX,WORD i_
04BA 89840000         459  MOV WORD st_[SI],AX
                      460 _L50:
04BE 803E000040       461  CMP BYTE u_,64
04C3 751F             462  JNZ _L51
04C5 8B360000         463  MOV SI,WORD s_
04C9 83EE01           464  SUB SI,1
PCCA Assembler      st.A



04CC D1E6             465  SHL SI,1
04CE A10000           466  MOV AX,WORD s_
04D1 050100           467  ADD AX,1
04D4 D1E0             468  SHL AX,1
04D6 8BF8             469  MOV DI,AX
04D8 8BB40000         470  MOV SI,WORD st_[SI]
04DC 89B50000         471  MOV WORD st_[DI],SI
04E0 FF060000         472  INC WORD s_
                      473 _L51:
04E4 803E00005E       474  CMP BYTE u_,94
04E9 7403E90000       475  JNZ _L52
04EE B80000           476  MOV AX,0
04F1 50               477  PUSH AX
04F2 E80000           478  CALL getc_
04F5 83C402           479  ADD SP,2
04F8 A20000           480  MOV BYTE c_,AL
04FB 803E0000FF       481  CMP BYTE c_,255
0500 7407             482  JZ _L54
0502 803E000060       483  CMP BYTE c_,96
0507 750D             484  JNZ _L53
                      485 _L54:
0509 B80000           486  MOV AX,0
050C 50               487  PUSH AX
050D E80000           488  CALL exit_
0510 83C402           489  ADD SP,2
0513 E90000           490  JMP _L55
                      491 _L53:
0516 FF060000         492  INC WORD s_
051A 8B360000         493  MOV SI,WORD s_
051E D1E6             494  SHL SI,1
0520 A00000           495  MOV AL,BYTE c_
0523 B400             496  MOV AH,0
0525 89840000         497  MOV WORD st_[SI],AX
                      498 _L55:
                      499 _L52:
0529 803E00002E       500  CMP BYTE u_,46
052E 7518             501  JNZ _L56
0530 8B360000         502  MOV SI,WORD s_
0534 D1E6             503  SHL SI,1
0536 FFB40000         504  PUSH WORD st_[SI]
053A B80000           505  MOV AX,OFFSET __31
053D 50               506  PUSH AX
053E E80000           507  CALL printf_
0541 83C404           508  ADD SP,4
0544 FF0E0000         509  DEC WORD s_
                      510 _L56:
0548 803E00002C       511  CMP BYTE u_,44
054D 7518             512  JNZ _L57
054F B80100           513  MOV AX,1
0552 50               514  PUSH AX
0553 8B360000         515  MOV SI,WORD s_
0557 D1E6             516  SHL SI,1
0559 FFB40000         517  PUSH WORD st_[SI]
055D E80000           518  CALL putc_
0560 83C404           519  ADD SP,4
0563 FF0E0000         520  DEC WORD s_
                      521 _L57:
0567 C606000000       522  MOV BYTE k_,0
PCCA Assembler      st.A



056C 803E000061       523  CMP BYTE u_,97
0571 7216             524  JB _L58
0573 803E00007A       525  CMP BYTE u_,122
0578 770F             526  JA _L58
057A C606000001       527  MOV BYTE k_,1
057F A00000           528  MOV AL,BYTE u_
0582 2C61             529  SUB AL,97
0584 B400             530  MOV AH,0
0586 A30000           531  MOV WORD v_,AX
                      532 _L58:
0589 803E00003A       533  CMP BYTE u_,58
058E 7519             534  JNZ _L59
0590 8B360000         535  MOV SI,WORD s_
0594 D1E6             536  SHL SI,1
0596 A10000           537  MOV AX,WORD v_
0599 D1E0             538  SHL AX,1
059B 8BF8             539  MOV DI,AX
059D 8BB40000         540  MOV SI,WORD st_[SI]
05A1 89B50000         541  MOV WORD st_[DI],SI
05A5 FF0E0000         542  DEC WORD s_
                      543 _L59:
05A9 803E00003B       544  CMP BYTE u_,59
05AE 7519             545  JNZ _L60
05B0 FF060000         546  INC WORD s_
05B4 8B360000         547  MOV SI,WORD v_
05B8 D1E6             548  SHL SI,1
05BA A10000           549  MOV AX,WORD s_
05BD D1E0             550  SHL AX,1
05BF 8BF8             551  MOV DI,AX
05C1 8BB40000         552  MOV SI,WORD st_[SI]
05C5 89B50000         553  MOV WORD st_[DI],SI
                      554 _L60:
05C9 803E00003F       555  CMP BYTE u_,63
05CE 751F             556  JNZ _L61
05D0 FF060000         557  INC WORD s_
05D4 8B360000         558  MOV SI,WORD v_
05D8 D1E6             559  SHL SI,1
05DA 8BB40000         560  MOV SI,WORD st_[SI]
05DE D1E6             561  SHL SI,1
05E0 A10000           562  MOV AX,WORD s_
05E3 D1E0             563  SHL AX,1
05E5 8BF8             564  MOV DI,AX
05E7 8BB40000         565  MOV SI,WORD st_[SI]
05EB 89B50000         566  MOV WORD st_[DI],SI
                      567 _L61:
05EF 803E000021       568  CMP BYTE u_,33
05F4 751F             569  JNZ _L62
05F6 8B360000         570  MOV SI,WORD s_
05FA D1E6             571  SHL SI,1
05FC A10000           572  MOV AX,WORD v_
05FF D1E0             573  SHL AX,1
0601 8BF8             574  MOV DI,AX
0603 8BBD0000         575  MOV DI,WORD st_[DI]
0607 D1E7             576  SHL DI,1
0609 8BB40000         577  MOV SI,WORD st_[SI]
060D 89B50000         578  MOV WORD st_[DI],SI
0611 FF0E0000         579  DEC WORD s_
                      580 _L62:
PCCA Assembler      st.A



0615 803E00002F       581  CMP BYTE u_,47
061A 7703E90000       582  JBE _L63
061F 803E00003A       583  CMP BYTE u_,58
0624 7203E90000       584  JAE _L63
0629 C70600000000     585  MOV WORD i_,0
                      586 _L64:
062F 803E00002F       587  CMP BYTE u_,47
0634 7703E90000       588  JBE _L65
0639 803E00003A       589  CMP BYTE u_,58
063E 7203E90000       590  JAE _L65
0643 A10000           591  MOV AX,WORD i_
0646 B90A00           592  MOV CX,10
0649 F7E9             593  IMUL CX
064B 8A0E0000         594  MOV CL,BYTE u_
064F B500             595  MOV CH,0
0651 03C1             596  ADD AX,CX
0653 2D3000           597  SUB AX,48
0656 A30000           598  MOV WORD i_,AX
0659 FF060000         599  INC WORD p_
065D 8B360000         600  MOV SI,WORD p_
0661 8A840000         601  MOV AL,BYTE pr_[SI]
0665 A20000           602  MOV BYTE u_,AL
0668 EBC5             603  JMP _L64
                      604 _L65:
066A FF060000         605  INC WORD s_
066E 8B360000         606  MOV SI,WORD s_
0672 D1E6             607  SHL SI,1
0674 A10000           608  MOV AX,WORD i_
0677 89840000         609  MOV WORD st_[SI],AX
067B FF0E0000         610  DEC WORD p_
                      611 _L63:
067F 803E000022       612  CMP BYTE u_,34
0684 7537             613  JNZ _L66
0686 FF060000         614  INC WORD p_
068A 8B360000         615  MOV SI,WORD p_
068E 8A840000         616  MOV AL,BYTE pr_[SI]
0692 A20000           617  MOV BYTE u_,AL
                      618 _L67:
0695 803E000022       619  CMP BYTE u_,34
069A 7421             620  JZ _L68
069C B80100           621  MOV AX,1
069F 50               622  PUSH AX
06A0 A00000           623  MOV AL,BYTE u_
06A3 B400             624  MOV AH,0
06A5 50               625  PUSH AX
06A6 E80000           626  CALL putc_
06A9 83C404           627  ADD SP,4
06AC FF060000         628  INC WORD p_
06B0 8B360000         629  MOV SI,WORD p_
06B4 8A840000         630  MOV AL,BYTE pr_[SI]
06B8 A20000           631  MOV BYTE u_,AL
06BB EBD8             632  JMP _L67
                      633 _L68:
                      634 _L66:
06BD 803E000029       635  CMP BYTE u_,41
06C2 7500             636  JNZ _L69
                      637 _L69:
06C4 803E00005D       638  CMP BYTE u_,93
PCCA Assembler      st.A



06C9 7525             639  JNZ _L70
06CB 8B360000         640  MOV SI,WORD s_
06CF D1E6             641  SHL SI,1
06D1 83BC000000       642  CMP WORD st_[SI],0
06D6 7410             643  JZ _L71
06D8 8B360000         644  MOV SI,WORD r_
06DC D1E6             645  SHL SI,1
06DE 8BB40000         646  MOV SI,WORD st_[SI]
06E2 89360000         647  MOV WORD p_,SI
06E6 EB04             648  JMP _L72
                      649 _L71:
06E8 FF0E0000         650  DEC WORD r_
                      651 _L72:
06EC FF0E0000         652  DEC WORD s_
                      653 _L70:
06F0 803E000027       654  CMP BYTE u_,39
06F5 753A             655  JNZ _L73
06F7 FF060000         656  INC WORD p_
06FB 8B360000         657  MOV SI,WORD p_
06FF 8A840000         658  MOV AL,BYTE pr_[SI]
0703 A20000           659  MOV BYTE u_,AL
                      660 _L74:
0706 803E000027       661  CMP BYTE u_,39
070B 7424             662  JZ _L75
070D FF060000         663  INC WORD s_
0711 8B360000         664  MOV SI,WORD s_
0715 D1E6             665  SHL SI,1
0717 A00000           666  MOV AL,BYTE u_
071A B400             667  MOV AH,0
071C 89840000         668  MOV WORD st_[SI],AX
0720 FF060000         669  INC WORD p_
0724 8B360000         670  MOV SI,WORD p_
0728 8A840000         671  MOV AL,BYTE pr_[SI]
072C A20000           672  MOV BYTE u_,AL
072F EBD5             673  JMP _L74
                      674 _L75:
                      675 _L73:
                      676 main_nx_:
0731 FF060000         677  INC WORD p_
0735 E90000           678  JMP _L10
                      679 _L11:
0738 8BE5             680  MOV SP,BP
073A 5D               681  POP BP
073B C3               682  RET
                      683  END
