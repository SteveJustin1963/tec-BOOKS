PCBNEW-LibModule-V1  30/10/2018 21:32:14
# encoding utf-8
Units mm
$INDEX
Choke_05
Choke_07
Choke_Ax_01
$EndINDEX
$MODULE Choke_05
Po 0 0 0 15 5BD8CD4A 00000000 ~~
Li Choke_05
Sc 0
AR /5BC12967/5BC78A59
Op 0 0 0
T0 0 -4.445 1.27 1.27 0 0.254 N V 21 N "L3"
T1 0 3.81 1.27 1.27 0 0.254 N V 21 N "22uH"
DC 0 0 0 -6.35 0.3048 21
$PAD
Sh "1" C 2.794 2.794 0 0 0
Dr 1.143 0 0
At STD N 00E0FFFF
Ne 2 "N-00000179"
Po -3.81 0
.ThermalWidth 0.762
$EndPAD
$PAD
Sh "2" C 2.794 2.794 0 0 0
Dr 1.143 0 0
At STD N 00E0FFFF
Ne 1 "+5v"
Po 3.81 0
$EndPAD
$EndMODULE Choke_05
$MODULE Choke_07
Po 0 0 0 15 5BD8CDBC 00000000 ~~
Li Choke_07
Sc 0
AR /5BC12967/5BC12F3A
Op 0 0 0
T0 0 -5.08 1.27 1.27 0 0.254 N V 21 N "L2"
T1 0 5.08 1.27 1.27 0 0.254 N V 21 N "120uH"
DC 0 0 0 -8.128 0.3048 21
$PAD
Sh "1" C 3.556 3.556 0 0 0
Dr 1.397 0 0
At STD N 00E0FFFF
Ne 2 "N-00000180"
Po -5.461 0
.ThermalWidth 0.762
$EndPAD
$PAD
Sh "2" C 3.556 3.556 0 0 0
Dr 1.397 0 0
At STD N 00E0FFFF
Ne 1 "N-00000179"
Po 5.461 0
$EndPAD
$EndMODULE Choke_07
$MODULE Choke_Ax_01
Po 0 0 0 15 5BD22602 00000000 ~~
Li Choke_Ax_01
Cd Resitance 4 pas
Kw R
Sc 0
AR /5BB9FB4E/5BBA4187
Op 0 A 0
T0 0 -2.54 1.397 1.27 0 0.2032 N V 21 N "L1"
T1 0 1.905 1.397 1.27 0 0.2032 N I 21 N "10uH"
DA 3.048 0 3.048 -1.016 900 0.3175 21
DA 3.048 0 2.032 0 900 0.3175 21
DA 1.016 0 1.016 -1.016 900 0.3175 21
DA 1.016 0 0 0 900 0.3175 21
DA -1.016 0 -1.016 -1.016 900 0.3175 21
DA -1.016 0 -2.032 0 900 0.3175 21
DA -3.048 0 -3.048 -1.016 900 0.3175 21
DA -3.048 0 -4.064 0 900 0.3175 21
DS -5.08 0 -4.064 0 0.3048 21
DS 5.08 0 4.064 0 0.3048 21
$PAD
Sh "1" C 1.524 1.524 0 0 0
Dr 0.8128 0 0
At STD N 00E0FFFF
Ne 1 "N-0000044"
Po -5.08 0
$EndPAD
$PAD
Sh "2" C 1.524 1.524 0 0 0
Dr 0.8128 0 0
At STD N 00E0FFFF
Ne 2 "N-0000045"
Po 5.08 0
$EndPAD
$SHAPE3D
Na "discret/resistor.wrl"
Sc 0.4 0.4 0.4
Of 0 0 0
Ro 0 0 0
$EndSHAPE3D
$EndMODULE Choke_Ax_01
$EndLIBRARY
