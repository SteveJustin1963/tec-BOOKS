PCBNEW-LibModule-V1  01/11/2018 07:49:11
# encoding utf-8
Units mm
$INDEX
BARREL_JACK
C2V12
RV_Bourns3386H
$EndINDEX
$MODULE BARREL_JACK
Po 0 0 0 15 55564876 00000000 ~~
Li BARREL_JACK
Cd DC Barrel Jack
Kw Power Jack
Sc 0
AR /55562FA0
Op 0 0 0
T0 -1.905 5.715 1.016 1.016 0 0.2032 N V 21 N "CON1"
T1 0 -5.99948 1.016 1.016 0 0.2032 N I 21 N "12v DC In"
DS -4.0005 -4.50088 -4.0005 4.50088 0.381 21
DS -7.50062 -4.50088 -7.50062 4.50088 0.381 21
DS -7.50062 4.50088 7.00024 4.50088 0.381 21
DS 7.00024 4.50088 7.00024 -4.50088 0.381 21
DS 7.00024 -4.50088 -7.50062 -4.50088 0.381 21
$PAD
Sh "1" R 3.50012 3.50012 0 0 0
Dr 1.00076 0 0 O 1.00076 2.99974
At STD N 00E0FFFF
Ne 2 "N-0000031"
Po 6.20014 0
$EndPAD
$PAD
Sh "2" R 3.50012 3.50012 0 0 0
Dr 1.00076 0 0 O 1.00076 2.99974
At STD N 00E0FFFF
Ne 1 "GND"
Po 0.20066 0
$EndPAD
$PAD
Sh "3" R 3.50012 3.50012 0 0 0
Dr 2.99974 0 0 O 2.99974 1.00076
At STD N 00E0FFFF
Ne 1 "GND"
Po 3.2004 4.699
$EndPAD
$EndMODULE BARREL_JACK
$MODULE C2V12
Po 0 0 0 15 5BD8D12E 00000000 ~~
Li C2V12
Cd Condensateur polarise
Kw CP
Sc 0
AR /5BC12967/5BC12F4C
Op 0 0 0
T0 0 3.048 1.27 1.27 0 0.254 N V 21 N "C14"
T1 0 -3.048 1.27 1.27 0 0.254 N V 21 N "1000uF"
DC 0 0 6.35 0 0.3175 21
$PAD
Sh "1" R 1.778 1.778 0 0 0
Dr 1.016 0 0
At STD N 00E0FFFF
Ne 2 "N-00000179"
Po -2.54 0
$EndPAD
$PAD
Sh "2" C 1.778 1.778 0 0 0
Dr 1.016 0 0
At STD N 00E0FFFF
Ne 1 "GND"
Po 2.54 0
$EndPAD
$SHAPE3D
Na "discret/c_vert_c2v10.wrl"
Sc 1 1 1
Of 0 0 0
Ro 0 0 0
$EndSHAPE3D
$EndMODULE C2V12
$MODULE RV_Bourns3386H
Po 0 0 0 15 5BDAAF95 00000000 ~~
Li RV_Bourns3386H
Cd Resistance variable / potentiometre
Kw R
Sc 0
AR /5BBB9A6A/5BC0A0FA
Op A A 0
T0 -3.175 -3.81 1.397 1.27 0 0.2032 N V 21 N "RV1"
T1 3.81 -3.81 1.397 1.27 0 0.2032 N V 21 N "5k"
DS -5.08 2.54 -5.08 -2.54 0.3175 21
DS -5.08 -2.54 5.08 -2.54 0.3175 21
DS 5.08 -2.54 5.08 2.54 0.3175 21
DS 5.08 2.54 -5.08 2.54 0.3175 21
$PAD
Sh "1" C 1.524 1.524 0 0 0
Dr 0.8128 0 0
At STD N 00E0FFFF
Ne 2 "N-00000101"
Po -2.54 1.27
$EndPAD
$PAD
Sh "2" C 1.524 1.524 0 0 0
Dr 0.8128 0 0
At STD N 00E0FFFF
Ne 1 "+5v"
Po 0 -1.27
$EndPAD
$PAD
Sh "3" C 1.524 1.524 0 0 0
Dr 0.8128 0 0
At STD N 00E0FFFF
Ne 0 ""
Po 2.54 1.27
$EndPAD
$SHAPE3D
Na "discret/adjustable_rx2.wrl"
Sc 1 1 1
Of 0 0 0
Ro 0 0 0
$EndSHAPE3D
$EndMODULE RV_Bourns3386H
$EndLIBRARY
