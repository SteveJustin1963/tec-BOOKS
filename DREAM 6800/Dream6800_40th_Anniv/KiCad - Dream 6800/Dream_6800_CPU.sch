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
Sheet 2 7
Title ""
Date "4 jan 2019"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MC6800 U1
U 1 1 5BBA1C09
P 6700 3950
F 0 "U1" H 6700 4000 70  0000 C CNN
F 1 "MC6800" H 6700 3850 70  0000 C CNN
F 2 "" H 6700 3950 60  0000 C CNN
F 3 "" H 6700 3950 60  0000 C CNN
	1    6700 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	7700 2800 8000 2800
Wire Wire Line
	7700 2900 8000 2900
Wire Wire Line
	7700 3000 8000 3000
Wire Wire Line
	7700 3100 8000 3100
Wire Wire Line
	7700 3200 8000 3200
Wire Wire Line
	7700 3300 8000 3300
Wire Wire Line
	7700 3400 8000 3400
Wire Wire Line
	7700 3500 8000 3500
Wire Wire Line
	7700 3600 8000 3600
Wire Wire Line
	7700 3700 8000 3700
Wire Wire Line
	7700 3800 8000 3800
Wire Wire Line
	7700 3900 8000 3900
Wire Wire Line
	7700 4000 8000 4000
Wire Wire Line
	7700 4100 8000 4100
Wire Wire Line
	7700 4200 8000 4200
Wire Wire Line
	7700 4300 8000 4300
Wire Wire Line
	7700 4700 8000 4700
Wire Wire Line
	7700 4800 8000 4800
Wire Wire Line
	7700 4900 8000 4900
Wire Wire Line
	7700 5000 8000 5000
Wire Wire Line
	7700 5100 8000 5100
Wire Wire Line
	7700 5200 8000 5200
Wire Wire Line
	7700 5300 8000 5300
Wire Wire Line
	7700 5400 8000 5400
Text GLabel 8000 2800 2    50   3State ~ 0
A0
Text GLabel 8000 2900 2    50   3State ~ 0
A1
Text GLabel 8000 3000 2    50   3State ~ 0
A2
Text GLabel 8000 3100 2    50   3State ~ 0
A3
Text GLabel 8000 3200 2    50   3State ~ 0
A4
Text GLabel 8000 3300 2    50   3State ~ 0
A5
Text GLabel 8000 3400 2    50   3State ~ 0
A6
Text GLabel 8000 3500 2    50   3State ~ 0
A7
Text GLabel 8000 3600 2    50   3State ~ 0
A8
Text GLabel 8000 3700 2    50   3State ~ 0
A9
Text GLabel 8000 3800 2    50   3State ~ 0
A10
Text GLabel 8000 3900 2    50   3State ~ 0
A11
Text GLabel 8000 4000 2    50   3State ~ 0
A12
Text GLabel 8000 4100 2    50   3State ~ 0
A13
Text GLabel 8000 4200 2    50   3State ~ 0
A14
Text GLabel 8000 4300 2    50   3State ~ 0
A15
Text GLabel 8000 4700 2    50   BiDi ~ 0
D0
Text GLabel 8000 4800 2    50   BiDi ~ 0
D1
Text GLabel 8000 4900 2    50   BiDi ~ 0
D2
Text GLabel 8000 5000 2    50   BiDi ~ 0
D3
Text GLabel 8000 5100 2    50   BiDi ~ 0
D4
Text GLabel 8000 5200 2    50   BiDi ~ 0
D5
Text GLabel 8000 5300 2    50   BiDi ~ 0
D6
Text GLabel 8000 5400 2    50   BiDi ~ 0
D7
$Comp
L MC6875 U8
U 1 1 5BBA3D9C
P 4250 2500
F 0 "U8" H 4250 2500 70  0000 C CNN
F 1 "MC6875" H 4250 2350 70  0000 C CNN
F 2 "" H 4100 3300 60  0000 C CNN
F 3 "" H 4100 3300 60  0000 C CNN
	1    4250 2500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 5BBA407D
P 3300 3300
F 0 "#PWR03" H 3300 3300 30  0001 C CNN
F 1 "GND" H 3300 3230 30  0001 C CNN
F 2 "" H 3300 3300 60  0000 C CNN
F 3 "" H 3300 3300 60  0000 C CNN
	1    3300 3300
	1    0    0    -1  
$EndComp
$Comp
L CRYSTAL X1
U 1 1 5BBA40CC
P 2800 2850
F 0 "X1" V 2850 3100 50  0000 C CNN
F 1 "4Mhz" V 2750 3100 50  0000 C CNN
F 2 "~" H 2800 2850 60  0000 C CNN
F 3 "~" H 2800 2850 60  0000 C CNN
	1    2800 2850
	0    -1   -1   0   
$EndComp
$Comp
L C C1
U 1 1 5BBA416E
P 3300 2050
F 0 "C1" H 3350 2150 40  0000 L CNN
F 1 "150pF" H 3350 1950 40  0000 L CNN
F 2 "~" H 3338 1900 30  0000 C CNN
F 3 "~" H 3300 2050 60  0000 C CNN
	1    3300 2050
	1    0    0    -1  
$EndComp
$Comp
L INDUCTOR_SMALL L1
U 1 1 5BBA4187
P 2800 2050
F 0 "L1" V 2850 2250 50  0000 C CNN
F 1 "10uH" V 2750 2250 50  0000 C CNN
F 2 "~" H 2800 2050 60  0000 C CNN
F 3 "~" H 2800 2050 60  0000 C CNN
	1    2800 2050
	0    -1   -1   0   
$EndComp
$Comp
L R R1
U 1 1 5BBA4196
P 3050 2050
F 0 "R1" H 2950 2050 40  0000 C CNN
F 1 "1k" V 3057 2051 40  0000 C CNN
F 2 "~" V 2980 2050 30  0000 C CNN
F 3 "~" H 3050 2050 30  0000 C CNN
	1    3050 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 3200 3300 3200
Wire Wire Line
	3300 3200 3300 3300
Wire Wire Line
	2800 1850 2800 1700
Wire Wire Line
	2800 1700 3400 1700
Wire Wire Line
	3050 1800 3050 1700
Connection ~ 3050 1700
Wire Wire Line
	3300 1850 3300 1700
Connection ~ 3300 1700
Wire Wire Line
	2800 2250 2800 2550
Wire Wire Line
	2800 2400 3400 2400
Connection ~ 2800 2400
Wire Wire Line
	3050 2300 3050 2400
Connection ~ 3050 2400
Wire Wire Line
	3300 2250 3300 2400
Connection ~ 3300 2400
$Comp
L GND #PWR04
U 1 1 5BBA46C4
P 2800 3300
F 0 "#PWR04" H 2800 3300 30  0001 C CNN
F 1 "GND" H 2800 3230 30  0001 C CNN
F 2 "" H 2800 3300 60  0000 C CNN
F 3 "" H 2800 3300 60  0000 C CNN
	1    2800 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 3150 2800 3300
$Comp
L GND #PWR05
U 1 1 5BBA478B
P 5600 5500
F 0 "#PWR05" H 5600 5500 30  0001 C CNN
F 1 "GND" H 5600 5430 30  0001 C CNN
F 2 "" H 5600 5500 60  0000 C CNN
F 3 "" H 5600 5500 60  0000 C CNN
	1    5600 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 5200 5600 5200
Wire Wire Line
	5600 5200 5600 5500
Wire Wire Line
	5700 5300 5600 5300
Connection ~ 5600 5300
Wire Wire Line
	5700 5400 5600 5400
Connection ~ 5600 5400
$Comp
L CP C2
U 1 1 5BBA4946
P 4250 4200
F 0 "C2" H 4325 4325 40  0000 L CNN
F 1 "2.2uF" H 4325 4075 40  0000 L CNN
F 2 "~" H 4350 4050 30  0000 C CNN
F 3 "~" H 4250 4200 300 0000 C CNN
	1    4250 4200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 5BBA495D
P 4250 4600
F 0 "#PWR06" H 4250 4600 30  0001 C CNN
F 1 "GND" H 4250 4530 30  0001 C CNN
F 2 "" H 4250 4600 60  0000 C CNN
F 3 "" H 4250 4600 60  0000 C CNN
	1    4250 4600
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 5BBA4963
P 3850 3800
F 0 "R2" V 3750 3800 40  0000 C CNN
F 1 "100R" V 3850 3800 40  0000 C CNN
F 2 "~" V 3780 3800 30  0000 C CNN
F 3 "~" H 3850 3800 30  0000 C CNN
	1    3850 3800
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4250 4400 4250 4600
Wire Wire Line
	4250 4000 4250 3600
Wire Wire Line
	4100 3800 4250 3800
Connection ~ 4250 3800
Wire Wire Line
	3600 3800 3400 3800
Text GLabel 3400 3800 0    50   Input ~ 0
EXT-RST
Wire Wire Line
	5100 2300 5400 2300
Wire Wire Line
	5100 2200 5400 2200
NoConn ~ 5100 1900
NoConn ~ 5100 2100
$Comp
L VCC #PWR07
U 1 1 5BBA37E1
P 5600 4100
F 0 "#PWR07" H 5600 4200 30  0001 C CNN
F 1 "VCC" H 5600 4200 30  0000 C CNN
F 2 "" H 5600 4100 60  0000 C CNN
F 3 "" H 5600 4100 60  0000 C CNN
	1    5600 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 4200 5600 4200
Wire Wire Line
	5600 4200 5600 4100
Wire Wire Line
	5700 4400 5400 4400
Wire Wire Line
	5700 4500 5400 4500
Wire Wire Line
	5700 4600 5400 4600
Wire Wire Line
	5700 4800 5400 4800
Wire Wire Line
	5700 4900 5400 4900
Text GLabel 5400 2200 2    50   Output ~ 0
2FO
Text GLabel 5400 2300 2    50   Output ~ 0
02
NoConn ~ 5100 2400
$Comp
L VCC #PWR08
U 1 1 5BBA396F
P 5200 1600
F 0 "#PWR08" H 5200 1700 30  0001 C CNN
F 1 "VCC" H 5200 1700 30  0000 C CNN
F 2 "" H 5200 1600 60  0000 C CNN
F 3 "" H 5200 1600 60  0000 C CNN
	1    5200 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5100 1800 5200 1800
Wire Wire Line
	5200 1800 5200 1600
Wire Wire Line
	5100 1700 5200 1700
Connection ~ 5200 1700
Text GLabel 5400 4400 0    50   Input ~ 0
IRQ*
Text GLabel 5400 4500 0    50   Output ~ 0
R/W*
Text GLabel 5400 4600 0    50   Output ~ 0
VMA
Text GLabel 5400 4800 0    50   Output ~ 0
BA
Text GLabel 5400 4900 0    50   Input ~ 0
HALT*
Wire Wire Line
	5700 3200 5100 3200
Wire Wire Line
	5700 3000 5100 3000
Wire Wire Line
	5700 2800 5100 2800
Wire Wire Line
	5700 3400 5500 3400
Wire Wire Line
	5500 3400 5500 3200
Connection ~ 5500 3200
Wire Wire Line
	5300 2800 5300 2500
Wire Wire Line
	5300 2500 5400 2500
Connection ~ 5300 2800
Text GLabel 5400 2500 2    50   Output ~ 0
RST*
$EndSCHEMATC
