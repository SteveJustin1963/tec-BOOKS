EESchema Schematic File Version 2
LIBS:Dream_6800
LIBS:180_din
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:Dream_6800-cache
EELAYER 27 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 7
Title ""
Date "4 jan 2019"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	8300 4000 5400 4000
Wire Wire Line
	8300 4100 5400 4100
$Comp
L 74LS40 U20
U 1 1 5BBB4BDA
P 6400 3300
F 0 "U20" H 6400 3400 60  0000 C CNN
F 1 "7440" H 6400 3200 60  0000 C CNN
F 2 "~" H 6400 3300 60  0000 C CNN
F 3 "~" H 6400 3300 60  0000 C CNN
	1    6400 3300
	-1   0    0    1   
$EndComp
Wire Wire Line
	6900 3450 7000 3450
Wire Wire Line
	6900 3350 7100 3350
Wire Wire Line
	6900 3250 7200 3250
Wire Wire Line
	6900 3150 7300 3150
Wire Wire Line
	5900 3300 5400 3300
Wire Wire Line
	3400 4700 3100 4700
Wire Wire Line
	3400 4600 3100 4600
Wire Wire Line
	3400 4500 3100 4500
Wire Wire Line
	3400 4400 3100 4400
Wire Wire Line
	3400 4300 3100 4300
Wire Wire Line
	3400 4200 3100 4200
Wire Wire Line
	3400 4100 3100 4100
Wire Wire Line
	3400 4000 3100 4000
$Comp
L 74LS40 U20
U 2 1 5BBB5314
P 6700 2300
F 0 "U20" H 6700 2400 60  0000 C CNN
F 1 "7440" H 6700 2200 60  0000 C CNN
F 2 "~" H 6700 2300 60  0000 C CNN
F 3 "~" H 6700 2300 60  0000 C CNN
	2    6700 2300
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 5BBB7586
P 3200 2250
F 0 "R5" H 3300 2250 40  0000 C CNN
F 1 "2k2" V 3207 2251 40  0000 C CNN
F 2 "~" V 3130 2250 30  0000 C CNN
F 3 "~" H 3200 2250 30  0000 C CNN
	1    3200 2250
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR011
U 1 1 5BBB759F
P 3200 1900
F 0 "#PWR011" H 3200 2000 30  0001 C CNN
F 1 "VCC" H 3200 2000 30  0000 C CNN
F 2 "" H 3200 1900 60  0000 C CNN
F 3 "" H 3200 1900 60  0000 C CNN
	1    3200 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 2700 3400 2700
Wire Wire Line
	3200 2500 3200 2700
Wire Wire Line
	3400 2600 3200 2600
Connection ~ 3200 2600
Wire Wire Line
	3200 2000 3200 1900
Connection ~ 3200 2700
Wire Wire Line
	3400 2900 3100 2900
Wire Wire Line
	3400 3000 3100 3000
Wire Wire Line
	3400 3100 3100 3100
Wire Wire Line
	3400 3300 3100 3300
Wire Wire Line
	3400 3400 3100 3400
Wire Wire Line
	3400 3500 3100 3500
Wire Wire Line
	3400 3600 3100 3600
Wire Wire Line
	3400 3700 3100 3700
Text GLabel 3100 2900 0    50   Input ~ 0
R/W*
Text GLabel 3100 2700 0    50   Output ~ 0
IRQ*
Text GLabel 3100 4000 0    50   BiDi ~ 0
D0
Text GLabel 3100 4100 0    50   BiDi ~ 0
D1
Text GLabel 3100 4200 0    50   BiDi ~ 0
D2
Text GLabel 3100 4300 0    50   BiDi ~ 0
D3
Text GLabel 3100 4400 0    50   BiDi ~ 0
D4
Text GLabel 3100 4500 0    50   BiDi ~ 0
D5
Text GLabel 3100 4600 0    50   BiDi ~ 0
D6
Text GLabel 3100 4700 0    50   BiDi ~ 0
D7
Text GLabel 3100 3100 0    50   Input ~ 0
RST*
Text GLabel 3100 3000 0    50   Input ~ 0
02
Text GLabel 3100 3300 0    50   3State ~ 0
A0
Text GLabel 3100 3400 0    50   3State ~ 0
A1
Text GLabel 3100 3700 0    50   3State ~ 0
A14
Text GLabel 3100 3500 0    50   Input ~ 0
VMA.A15
Text GLabel 3100 3600 0    50   3State ~ 0
A4
Wire Wire Line
	4100 2000 4100 1400
Wire Wire Line
	4100 1400 3100 1400
Wire Wire Line
	4300 1300 4300 2000
Wire Wire Line
	3100 1300 4400 1300
$Comp
L R R4
U 1 1 5BBB86A5
P 4650 1300
F 0 "R4" V 4750 1300 40  0000 C CNN
F 1 "2k2" V 4657 1301 40  0000 C CNN
F 2 "~" V 4580 1300 30  0000 C CNN
F 3 "~" H 4650 1300 30  0000 C CNN
	1    4650 1300
	0    -1   -1   0   
$EndComp
$Comp
L VCC #PWR012
U 1 1 5BBB86AB
P 5000 1300
F 0 "#PWR012" H 5000 1400 30  0001 C CNN
F 1 "VCC" H 5000 1400 30  0000 C CNN
F 2 "" H 5000 1300 60  0000 C CNN
F 3 "" H 5000 1300 60  0000 C CNN
	1    5000 1300
	1    0    0    -1  
$EndComp
Connection ~ 4300 1300
Wire Wire Line
	5800 2450 6200 2450
Wire Wire Line
	5800 2450 5800 3100
Wire Wire Line
	5800 3100 5400 3100
Wire Wire Line
	6200 2350 6100 2350
Wire Wire Line
	6100 2350 6100 2450
Connection ~ 6100 2450
$Comp
L R R6
U 1 1 5BBB88BE
P 7750 2300
F 0 "R6" V 7830 2300 40  0000 C CNN
F 1 "47" V 7757 2301 40  0000 C CNN
F 2 "~" V 7680 2300 30  0000 C CNN
F 3 "~" H 7750 2300 30  0000 C CNN
	1    7750 2300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7500 2300 7200 2300
$Comp
L VCC #PWR013
U 1 1 5BBB8972
P 8200 2000
F 0 "#PWR013" H 8200 2100 30  0001 C CNN
F 1 "VCC" H 8200 2100 30  0000 C CNN
F 2 "" H 8200 2000 60  0000 C CNN
F 3 "" H 8200 2000 60  0000 C CNN
	1    8200 2000
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 2300 8000 2300
Wire Wire Line
	8300 2100 8200 2100
Wire Wire Line
	8200 2100 8200 2000
Text GLabel 3100 1300 0    50   Output ~ 0
DMA.ENAB
Text GLabel 3100 1400 0    50   Input ~ 0
RTC
Wire Wire Line
	4500 2000 4500 1500
Wire Wire Line
	4500 1500 6700 1500
Wire Wire Line
	4700 2000 4700 1600
Wire Wire Line
	4700 1600 6700 1600
Wire Wire Line
	6200 2250 5800 2250
Wire Wire Line
	5800 2250 5800 1800
Wire Wire Line
	5800 1800 4300 1800
Connection ~ 4300 1800
Wire Wire Line
	6200 2150 6000 2150
Wire Wire Line
	6000 2150 6000 1800
Wire Wire Line
	6000 1800 6700 1800
Text GLabel 6700 1500 2    50   Input ~ 0
CASS.IN
Text GLabel 6700 1600 2    50   Output ~ 0
CASS.OUT
Text GLabel 6700 1800 2    50   Input ~ 0
VCO
$Comp
L 74LS08 U12
U 4 1 5BBB8FC7
P 6300 5700
F 0 "U12" H 6300 5750 60  0000 C CNN
F 1 "74LS08" H 6300 5650 60  0000 C CNN
F 2 "~" H 6300 5700 60  0000 C CNN
F 3 "~" H 6300 5700 60  0000 C CNN
	4    6300 5700
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR014
U 1 1 5BBB9477
P 8100 6200
F 0 "#PWR014" H 8100 6200 30  0001 C CNN
F 1 "GND" H 8100 6130 30  0001 C CNN
F 2 "" H 8100 6200 60  0000 C CNN
F 3 "" H 8100 6200 60  0000 C CNN
	1    8100 6200
	1    0    0    -1  
$EndComp
$Comp
L R R8
U 1 1 5BBB9484
P 7250 5600
F 0 "R8" V 7330 5600 40  0000 C CNN
F 1 "470" V 7257 5601 40  0000 C CNN
F 2 "~" V 7180 5600 30  0000 C CNN
F 3 "~" H 7250 5600 30  0000 C CNN
	1    7250 5600
	0    -1   -1   0   
$EndComp
$Comp
L R R10
U 1 1 5BBB9494
P 7950 5600
F 0 "R10" V 8030 5600 40  0000 C CNN
F 1 "220" V 7957 5601 40  0000 C CNN
F 2 "~" V 7880 5600 30  0000 C CNN
F 3 "~" H 7950 5600 30  0000 C CNN
	1    7950 5600
	0    -1   -1   0   
$EndComp
$Comp
L R R9
U 1 1 5BBB949A
P 7950 5400
F 0 "R9" V 8030 5400 40  0000 C CNN
F 1 "2k2" V 7957 5401 40  0000 C CNN
F 2 "~" V 7880 5400 30  0000 C CNN
F 3 "~" H 7950 5400 30  0000 C CNN
	1    7950 5400
	0    -1   -1   0   
$EndComp
$Comp
L R R7
U 1 1 5BBB94A0
P 6300 6100
F 0 "R7" V 6380 6100 40  0000 C CNN
F 1 "4k7" V 6307 6101 40  0000 C CNN
F 2 "~" V 6230 6100 30  0000 C CNN
F 3 "~" H 6300 6100 30  0000 C CNN
	1    6300 6100
	0    -1   -1   0   
$EndComp
$Comp
L CP C3
U 1 1 5BBB94A8
P 7600 5900
F 0 "C3" H 7650 6000 40  0000 L CNN
F 1 "10uF" H 7675 5775 40  0000 L CNN
F 2 "~" H 7700 5750 30  0000 C CNN
F 3 "~" H 7600 5900 300 0000 C CNN
	1    7600 5900
	1    0    0    -1  
$EndComp
Wire Wire Line
	5400 3800 8300 3800
$Comp
L GND #PWR015
U 1 1 5BBB990D
P 7600 6200
F 0 "#PWR015" H 7600 6200 30  0001 C CNN
F 1 "GND" H 7600 6130 30  0001 C CNN
F 2 "" H 7600 6200 60  0000 C CNN
F 3 "" H 7600 6200 60  0000 C CNN
	1    7600 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6800 5600 7000 5600
Wire Wire Line
	7500 5600 7700 5600
Wire Wire Line
	7600 5400 7600 5700
Connection ~ 7600 5600
Wire Wire Line
	7700 5400 7600 5400
Wire Wire Line
	7600 6100 7600 6200
Wire Wire Line
	6800 5800 6900 5800
Wire Wire Line
	6900 5600 6900 6100
Connection ~ 6900 5600
Wire Wire Line
	5700 4700 5400 4700
Wire Wire Line
	8300 6400 3100 6400
Wire Wire Line
	6900 6100 6550 6100
Connection ~ 6900 5800
Wire Wire Line
	5700 6100 6050 6100
$Comp
L VCC #PWR016
U 1 1 5BBBA206
P 8300 5300
F 0 "#PWR016" H 8300 5400 30  0001 C CNN
F 1 "VCC" H 8300 5400 30  0000 C CNN
F 2 "" H 8300 5300 60  0000 C CNN
F 3 "" H 8300 5300 60  0000 C CNN
	1    8300 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	8200 5600 8300 5600
Wire Wire Line
	4900 1300 5000 1300
Text GLabel 3100 6400 0    50   Output ~ 0
EXT-RST
Wire Wire Line
	5700 4700 5700 6100
Wire Wire Line
	5800 5700 5700 5700
Connection ~ 5700 5700
Wire Wire Line
	5400 4200 8300 4200
Wire Wire Line
	7300 3150 7300 4200
Connection ~ 7300 4200
Wire Wire Line
	5400 4300 8300 4300
Wire Wire Line
	7200 3250 7200 4300
Connection ~ 7200 4300
Wire Wire Line
	5400 4400 8300 4400
Wire Wire Line
	7100 3350 7100 4400
Connection ~ 7100 4400
Wire Wire Line
	5400 4500 8300 4500
Wire Wire Line
	7000 3450 7000 4500
Connection ~ 7000 4500
Wire Wire Line
	5400 3900 8300 3900
$Comp
L CONN_8 P4
U 1 1 5BC37AAD
P 8650 4150
F 0 "P4" H 8650 4600 60  0000 C CNN
F 1 "Key Matrix" V 8650 4150 60  0000 C CNN
F 2 "" H 8650 4150 60  0000 C CNN
F 3 "" H 8650 4150 60  0000 C CNN
	1    8650 4150
	1    0    0    -1  
$EndComp
$Comp
L CONN_3 P5
U 1 1 5BC38625
P 8650 5900
F 0 "P5" H 8650 6100 60  0000 C CNN
F 1 "Keys" V 8650 5900 60  0000 C CNN
F 2 "" H 8650 5900 60  0000 C CNN
F 3 "" H 8650 5900 60  0000 C CNN
	1    8650 5900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 5600 8300 5800
Wire Wire Line
	8300 6400 8300 6000
Wire Wire Line
	8300 5900 8100 5900
Wire Wire Line
	8100 5900 8100 6200
Wire Wire Line
	8200 5400 8300 5400
Wire Wire Line
	8300 5400 8300 5300
$Comp
L MC6820 U9
U 1 1 5BBB2C84
P 4400 3550
F 0 "U9" H 4400 3600 70  0000 C CNN
F 1 "MC6820" H 4400 3450 70  0000 C CNN
F 2 "" H 4400 3550 60  0000 C CNN
F 3 "" H 4400 3550 60  0000 C CNN
	1    4400 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	5400 2600 5500 2600
Wire Wire Line
	5400 2700 5500 2700
Wire Wire Line
	5400 2800 5500 2800
Wire Wire Line
	5400 2900 5500 2900
Wire Wire Line
	5400 3000 5500 3000
$Comp
L CONN_8 P3
U 1 1 5BC4D870
P 8650 3050
F 0 "P3" H 8650 3500 60  0000 C CNN
F 1 "I/O Pins" V 8650 3050 60  0000 C CNN
F 2 "" H 8650 3050 60  0000 C CNN
F 3 "" H 8650 3050 60  0000 C CNN
	1    8650 3050
	1    0    0    -1  
$EndComp
Text Label 5500 2600 0    60   ~ 0
PB1
Text Label 5500 2700 0    60   ~ 0
PB2
Text Label 5500 2800 0    60   ~ 0
PB3
Text Label 5500 2900 0    60   ~ 0
PB4
Text Label 5500 3000 0    60   ~ 0
PB5
Wire Wire Line
	8300 2700 8200 2700
Wire Wire Line
	8300 2800 8200 2800
Wire Wire Line
	8300 3000 8100 3000
Wire Wire Line
	8300 3100 8100 3100
Wire Wire Line
	8300 3300 8100 3300
$Comp
L GND #PWR017
U 1 1 5BC4DB22
P 8200 3500
F 0 "#PWR017" H 8200 3500 30  0001 C CNN
F 1 "GND" H 8200 3430 30  0001 C CNN
F 2 "" H 8200 3500 60  0000 C CNN
F 3 "" H 8200 3500 60  0000 C CNN
	1    8200 3500
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR018
U 1 1 5BC4DB28
P 7600 2700
F 0 "#PWR018" H 7600 2800 30  0001 C CNN
F 1 "VCC" H 7600 2800 30  0000 C CNN
F 2 "" H 7600 2700 60  0000 C CNN
F 3 "" H 7600 2700 60  0000 C CNN
	1    7600 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 3400 8100 3400
Text Label 8100 3400 2    60   ~ 0
PB1
Text Label 8100 3300 2    60   ~ 0
PB2
Text Label 8100 3200 2    60   ~ 0
PB3
Text Label 8100 3100 2    60   ~ 0
PB4
Text Label 8100 3000 2    60   ~ 0
PB5
$Comp
L R R31
U 1 1 5BC4E381
P 7950 2700
F 0 "R31" V 8030 2700 40  0000 C CNN
F 1 "10" V 7957 2701 40  0000 C CNN
F 2 "~" V 7880 2700 30  0000 C CNN
F 3 "~" H 7950 2700 30  0000 C CNN
	1    7950 2700
	0    1    1    0   
$EndComp
Wire Wire Line
	8300 3200 8100 3200
NoConn ~ 8300 2900
Wire Wire Line
	8200 2800 8200 3500
Wire Wire Line
	7700 2700 7600 2700
$Comp
L CONN_3 P2
U 1 1 5BCA0872
P 8650 2200
F 0 "P2" H 8650 2400 60  0000 C CNN
F 1 "Spkr" V 8650 2200 60  0000 C CNN
F 2 "" H 8650 2200 60  0000 C CNN
F 3 "" H 8650 2200 60  0000 C CNN
	1    8650 2200
	1    0    0    -1  
$EndComp
NoConn ~ 8300 2200
$EndSCHEMATC
