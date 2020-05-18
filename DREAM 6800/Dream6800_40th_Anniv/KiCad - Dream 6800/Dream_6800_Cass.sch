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
Sheet 5 7
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
L LM741 U23
U 1 1 5BBB9C00
P 7100 2400
F 0 "U23" H 7250 2550 60  0000 C CNN
F 1 "LM741" H 7250 2650 60  0000 C CNN
F 2 "~" H 7100 2400 60  0000 C CNN
F 3 "~" H 7100 2400 60  0000 C CNN
	1    7100 2400
	-1   0    0    1   
$EndComp
$Comp
L 74LS121 U22
U 1 1 5BBB9CF5
P 5550 2400
F 0 "U22" H 5550 2450 60  0000 C CNN
F 1 "74121" H 5550 2300 60  0000 C CNN
F 2 "~" H 5550 2400 60  0000 C CNN
F 3 "~" H 5550 2400 60  0000 C CNN
	1    5550 2400
	-1   0    0    -1  
$EndComp
$Comp
L 74LS74 U21
U 2 1 5BBB9D04
P 3800 2400
F 0 "U21" H 3800 2400 60  0000 C CNN
F 1 "74LS74" H 3800 2300 60  0000 C CNN
F 2 "~" H 3800 2400 60  0000 C CNN
F 3 "~" H 3800 2400 60  0000 C CNN
	2    3800 2400
	-1   0    0    -1  
$EndComp
$Comp
L C C4
U 1 1 5BBB9D1D
P 5550 1600
F 0 "C4" V 5625 1450 40  0000 L CNN
F 1 "33nF" V 5400 1525 40  0000 L CNN
F 2 "~" H 5588 1450 30  0000 C CNN
F 3 "~" H 5550 1600 60  0000 C CNN
	1    5550 1600
	0    1    -1   0   
$EndComp
$Comp
L DIODE D5
U 1 1 5BBBA352
P 7050 1700
F 0 "D5" H 7050 1875 40  0000 C CNN
F 1 "BAT43" H 7050 1800 40  0000 C CNN
F 2 "~" H 7050 1700 60  0000 C CNN
F 3 "~" H 7050 1700 60  0000 C CNN
	1    7050 1700
	-1   0    0    -1  
$EndComp
$Comp
L R R11
U 1 1 5BBBACEB
P 5550 1350
F 0 "R11" V 5650 1350 40  0000 C CNN
F 1 "10k" V 5557 1351 40  0000 C CNN
F 2 "~" V 5480 1350 30  0000 C CNN
F 3 "~" H 5550 1350 30  0000 C CNN
	1    5550 1350
	0    1    -1   0   
$EndComp
$Comp
L VCC #PWR019
U 1 1 5BBBAD3E
P 4500 1250
F 0 "#PWR019" H 4500 1350 30  0001 C CNN
F 1 "VCC" H 4500 1350 30  0000 C CNN
F 2 "" H 4500 1250 60  0000 C CNN
F 3 "" H 4500 1250 60  0000 C CNN
	1    4500 1250
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5800 1350 5800 1700
Wire Wire Line
	5750 1600 5800 1600
Connection ~ 5800 1600
Wire Wire Line
	5300 1700 5300 1600
Wire Wire Line
	5300 1600 5350 1600
Wire Wire Line
	4400 2600 4900 2600
Wire Wire Line
	6200 2400 6600 2400
NoConn ~ 3200 2200
NoConn ~ 4900 2200
Wire Wire Line
	4400 2200 4600 2200
Wire Wire Line
	4600 2200 4600 3400
Wire Wire Line
	4600 3400 6400 3400
Wire Wire Line
	6400 3400 6400 1700
Connection ~ 6400 2400
$Comp
L GND #PWR020
U 1 1 5BBBB189
P 5400 3150
F 0 "#PWR020" H 5400 3150 30  0001 C CNN
F 1 "GND" H 5400 3080 30  0001 C CNN
F 2 "" H 5400 3150 60  0000 C CNN
F 3 "" H 5400 3150 60  0000 C CNN
	1    5400 3150
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR021
U 1 1 5BBBB196
P 5700 3150
F 0 "#PWR021" H 5700 3150 30  0001 C CNN
F 1 "GND" H 5700 3080 30  0001 C CNN
F 2 "" H 5700 3150 60  0000 C CNN
F 3 "" H 5700 3150 60  0000 C CNN
	1    5700 3150
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5400 3100 5400 3150
Wire Wire Line
	5700 3100 5700 3150
$Comp
L VCC #PWR022
U 1 1 5BBBB1D1
P 3900 1650
F 0 "#PWR022" H 3900 1750 30  0001 C CNN
F 1 "VCC" H 3900 1750 30  0000 C CNN
F 2 "" H 3900 1650 60  0000 C CNN
F 3 "" H 3900 1650 60  0000 C CNN
	1    3900 1650
	-1   0    0    -1  
$EndComp
Wire Wire Line
	3900 1650 3900 1850
Wire Wire Line
	3700 1850 3700 1750
Wire Wire Line
	3700 1750 3900 1750
Connection ~ 3900 1750
$Comp
L R R12
U 1 1 5BBBB3F1
P 7700 2850
F 0 "R12" H 7825 2850 40  0000 C CNN
F 1 "22k" V 7707 2851 40  0000 C CNN
F 2 "~" V 7630 2850 30  0000 C CNN
F 3 "~" H 7700 2850 30  0000 C CNN
	1    7700 2850
	1    0    0    1   
$EndComp
$Comp
L R R13
U 1 1 5BBBB3F7
P 8500 2850
F 0 "R13" H 8625 2850 40  0000 C CNN
F 1 "22k" V 8507 2851 40  0000 C CNN
F 2 "~" V 8430 2850 30  0000 C CNN
F 3 "~" H 8500 2850 30  0000 C CNN
	1    8500 2850
	1    0    0    1   
$EndComp
$Comp
L C C5
U 1 1 5BBBB3FD
P 8100 2850
F 0 "C5" H 8225 2775 40  0000 L CNN
F 1 "10nF" H 8175 2950 40  0000 L CNN
F 2 "~" H 8138 2700 30  0000 C CNN
F 3 "~" H 8100 2850 60  0000 C CNN
	1    8100 2850
	1    0    0    1   
$EndComp
$Comp
L GND #PWR023
U 1 1 5BBBB444
P 7700 3200
F 0 "#PWR023" H 7700 3200 30  0001 C CNN
F 1 "GND" H 7700 3130 30  0001 C CNN
F 2 "" H 7700 3200 60  0000 C CNN
F 3 "" H 7700 3200 60  0000 C CNN
	1    7700 3200
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR024
U 1 1 5BBBB44A
P 8500 3200
F 0 "#PWR024" H 8500 3200 30  0001 C CNN
F 1 "GND" H 8500 3130 30  0001 C CNN
F 2 "" H 8500 3200 60  0000 C CNN
F 3 "" H 8500 3200 60  0000 C CNN
	1    8500 3200
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7700 3100 7700 3200
Wire Wire Line
	7700 1700 7700 2600
Wire Wire Line
	7700 2300 7600 2300
$Comp
L VCC #PWR025
U 1 1 5BBBB4E7
P 7200 1950
F 0 "#PWR025" H 7200 2050 30  0001 C CNN
F 1 "VCC" H 7200 2050 30  0000 C CNN
F 2 "" H 7200 1950 60  0000 C CNN
F 3 "" H 7200 1950 60  0000 C CNN
	1    7200 1950
	0    1    -1   0   
$EndComp
Wire Wire Line
	6400 1700 6850 1700
Wire Wire Line
	7250 1700 7700 1700
Connection ~ 7700 2300
Wire Wire Line
	7150 2775 7150 2850
Wire Wire Line
	7150 2850 7100 2850
Wire Wire Line
	7150 2025 7150 1950
Wire Wire Line
	7150 1950 7200 1950
Text GLabel 7100 2850 0    50   Input ~ 0
-5V
Text GLabel 3000 2600 0    50   Output ~ 0
CASS.IN
$Comp
L R R15
U 1 1 5BBBC136
P 3400 5150
F 0 "R15" H 3525 5150 40  0000 C CNN
F 1 "1k5" V 3400 5150 40  0000 C CNN
F 2 "~" V 3330 5150 30  0000 C CNN
F 3 "~" H 3400 5150 30  0000 C CNN
	1    3400 5150
	-1   0    0    1   
$EndComp
$Comp
L R R14
U 1 1 5BBBC13C
P 3400 4450
F 0 "R14" H 3525 4450 40  0000 C CNN
F 1 "10k" V 3400 4450 40  0000 C CNN
F 2 "~" V 3330 4450 30  0000 C CNN
F 3 "~" H 3400 4450 30  0000 C CNN
	1    3400 4450
	-1   0    0    1   
$EndComp
$Comp
L R R16
U 1 1 5BBBC157
P 4300 4450
F 0 "R16" H 4425 4450 40  0000 C CNN
F 1 "1k5" V 4300 4450 40  0000 C CNN
F 2 "~" V 4230 4450 30  0000 C CNN
F 3 "~" H 4300 4450 30  0000 C CNN
	1    4300 4450
	-1   0    0    1   
$EndComp
$Comp
L R R19
U 1 1 5BBBC15D
P 4900 4450
F 0 "R19" H 5025 4450 40  0000 C CNN
F 1 "10k" V 4900 4450 40  0000 C CNN
F 2 "~" V 4830 4450 30  0000 C CNN
F 3 "~" H 4900 4450 30  0000 C CNN
	1    4900 4450
	-1   0    0    1   
$EndComp
$Comp
L C C6
U 1 1 5BBBC163
P 4600 4800
F 0 "C6" V 4750 4750 40  0000 L CNN
F 1 "1nF" V 4450 4725 40  0000 L CNN
F 2 "~" H 4638 4650 30  0000 C CNN
F 3 "~" H 4600 4800 60  0000 C CNN
	1    4600 4800
	0    -1   -1   0   
$EndComp
$Comp
L C C7
U 1 1 5BBBC175
P 4900 6600
F 0 "C7" H 4750 6500 40  0000 L CNN
F 1 "22nF" H 4700 6700 40  0000 L CNN
F 2 "~" H 4938 6450 30  0000 C CNN
F 3 "~" H 4900 6600 60  0000 C CNN
	1    4900 6600
	-1   0    0    1   
$EndComp
$Comp
L R R18
U 1 1 5BBBC17D
P 4300 6250
F 0 "R18" H 4425 6250 40  0000 C CNN
F 1 "10k" V 4300 6250 40  0000 C CNN
F 2 "~" V 4230 6250 30  0000 C CNN
F 3 "~" H 4300 6250 30  0000 C CNN
	1    4300 6250
	-1   0    0    1   
$EndComp
$Comp
L R R20
U 1 1 5BBBC185
P 5900 6250
F 0 "R20" H 6025 6250 40  0000 C CNN
F 1 "4k7" V 5900 6250 40  0000 C CNN
F 2 "~" V 5830 6250 30  0000 C CNN
F 3 "~" H 5900 6250 30  0000 C CNN
	1    5900 6250
	-1   0    0    1   
$EndComp
$Comp
L C C8
U 1 1 5BBBC18B
P 6100 5400
F 0 "C8" V 6250 5350 40  0000 L CNN
F 1 "10nF" V 5950 5325 40  0000 L CNN
F 2 "~" H 6138 5250 30  0000 C CNN
F 3 "~" H 6100 5400 60  0000 C CNN
	1    6100 5400
	0    -1   -1   0   
$EndComp
$Comp
L R R21
U 1 1 5BBBC192
P 6650 5400
F 0 "R21" V 6750 5400 40  0000 C CNN
F 1 "6k8" V 6657 5401 40  0000 C CNN
F 2 "~" V 6580 5400 30  0000 C CNN
F 3 "~" H 6650 5400 30  0000 C CNN
	1    6650 5400
	0    1    1    0   
$EndComp
$Comp
L R R22
U 1 1 5BBBC198
P 7000 5750
F 0 "R22" H 7125 5750 40  0000 C CNN
F 1 "2k2" V 7007 5751 40  0000 C CNN
F 2 "~" V 6930 5750 30  0000 C CNN
F 3 "~" H 7000 5750 30  0000 C CNN
	1    7000 5750
	1    0    0    -1  
$EndComp
$Comp
L R R17
U 1 1 5BBBC1A3
P 3900 5350
F 0 "R17" H 4025 5350 40  0000 C CNN
F 1 "1k5" V 3905 5350 40  0000 C CNN
F 2 "~" V 3830 5350 30  0000 C CNN
F 3 "~" H 3900 5350 30  0000 C CNN
	1    3900 5350
	1    0    0    -1  
$EndComp
$Comp
L BC557 Q1
U 1 1 5BBBC288
P 3800 4800
F 0 "Q1" H 3800 4651 40  0000 R CNN
F 1 "2N3906" H 3800 4950 40  0000 R CNN
F 2 "TO92" H 3700 4902 29  0000 C CNN
F 3 "~" H 3800 4800 60  0000 C CNN
	1    3800 4800
	1    0    0    -1  
$EndComp
$Comp
L NE566 U24
U 1 1 5BBBC95D
P 5100 5550
F 0 "U24" H 5100 5600 60  0000 C CNN
F 1 "NE566" H 5100 5450 60  0000 C CNN
F 2 "" H 5100 5550 60  0000 C CNN
F 3 "" H 5100 5550 60  0000 C CNN
	1    5100 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	4900 4700 4900 4900
Wire Wire Line
	4800 4800 4900 4800
Connection ~ 4900 4800
Wire Wire Line
	4400 4800 4300 4800
Wire Wire Line
	4300 4700 4300 6000
Connection ~ 4300 4800
Wire Wire Line
	3900 5800 4500 5800
Connection ~ 4300 5800
Wire Wire Line
	3600 4800 3400 4800
Wire Wire Line
	3400 4700 3400 4900
Connection ~ 3400 4800
Wire Wire Line
	3900 5100 3900 5000
Wire Wire Line
	3900 5600 3900 5800
Wire Wire Line
	5900 5400 5700 5400
Wire Wire Line
	6400 5400 6300 5400
Wire Wire Line
	7000 5500 7000 5400
Wire Wire Line
	6900 5400 7900 5400
Wire Wire Line
	5900 6000 5900 5800
Wire Wire Line
	5700 5800 6100 5800
Wire Wire Line
	4900 6400 4900 6300
Wire Wire Line
	5100 1350 5300 1350
Wire Wire Line
	4600 1350 4500 1350
Wire Wire Line
	4500 1350 4500 1250
Wire Wire Line
	3400 4200 3400 4100
Wire Wire Line
	3400 4100 5300 4100
Wire Wire Line
	4900 4100 4900 4200
Wire Wire Line
	4300 4000 4300 4200
Connection ~ 4300 4100
Wire Wire Line
	5300 4100 5300 4900
Connection ~ 4900 4100
$Comp
L VCC #PWR026
U 1 1 5BBBD107
P 4300 4000
F 0 "#PWR026" H 4300 4100 30  0001 C CNN
F 1 "VCC" H 4300 4100 30  0000 C CNN
F 2 "" H 4300 4000 60  0000 C CNN
F 3 "" H 4300 4000 60  0000 C CNN
	1    4300 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4900 6900 4900 6800
Wire Wire Line
	4300 6500 4300 6900
$Comp
L GND #PWR027
U 1 1 5BBBD273
P 7000 6200
F 0 "#PWR027" H 7000 6200 30  0001 C CNN
F 1 "GND" H 7000 6130 30  0001 C CNN
F 2 "" H 7000 6200 60  0000 C CNN
F 3 "" H 7000 6200 60  0000 C CNN
	1    7000 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 6000 7000 6200
Wire Wire Line
	3400 5400 3400 5600
Wire Wire Line
	3400 5600 3000 5600
Connection ~ 5900 5800
Wire Wire Line
	3900 4600 3900 4100
Connection ~ 3900 4100
Connection ~ 7000 5400
Text GLabel 3000 5600 0    50   Input ~ 0
CASS.OUT
Text GLabel 6100 5800 2    50   Output ~ 0
VCO
Wire Wire Line
	5900 6900 5900 6500
Wire Wire Line
	3900 6900 5900 6900
Connection ~ 4900 6900
Wire Wire Line
	5300 6300 5300 6900
Connection ~ 5300 6900
Text GLabel 3900 6900 0    50   Input ~ 0
-5V
Connection ~ 4300 6900
$Comp
L RVAR RV1
U 1 1 5BC0A0FA
P 4850 1350
F 0 "RV1" V 4930 1300 50  0000 C CNN
F 1 "5k" V 4750 1350 50  0000 C CNN
F 2 "~" H 4850 1350 60  0000 C CNN
F 3 "~" H 4850 1350 60  0000 C CNN
	1    4850 1350
	0    1    -1   0   
$EndComp
$Comp
L 180_DIN J2
U 1 1 5BC1AE9D
P 8250 5400
F 0 "J2" H 8275 5800 60  0000 C CNN
F 1 "180_DIN" V 8325 5500 60  0000 C CNN
F 2 "~" H 8250 5400 60  0000 C CNN
F 3 "~" H 8250 5400 60  0000 C CNN
	1    8250 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 5300 7700 5300
Wire Wire Line
	7700 5300 7700 5700
$Comp
L GND #PWR028
U 1 1 5BC1B2BB
P 7700 5700
F 0 "#PWR028" H 7700 5700 30  0001 C CNN
F 1 "GND" H 7700 5630 30  0001 C CNN
F 2 "" H 7700 5700 60  0000 C CNN
F 3 "" H 7700 5700 60  0000 C CNN
	1    7700 5700
	1    0    0    -1  
$EndComp
NoConn ~ 7900 5500
NoConn ~ 7900 5100
Wire Wire Line
	7900 5200 7700 5200
Wire Wire Line
	8500 2500 8500 2600
Wire Wire Line
	7600 2500 8500 2500
Wire Wire Line
	8100 2650 8100 2500
Connection ~ 8100 2500
Wire Wire Line
	8500 3100 8500 3200
Wire Wire Line
	7700 5200 7700 4700
Wire Wire Line
	7700 4700 8100 4700
Wire Wire Line
	8100 4700 8100 3050
Wire Wire Line
	3200 2600 3000 2600
$Comp
L 74LS74 U21
U 1 1 5BC28B99
P 10200 6400
F 0 "U21" H 10200 6400 60  0000 C CNN
F 1 "74LS74" H 10200 6300 60  0000 C CNN
F 2 "~" H 10200 6400 60  0000 C CNN
F 3 "~" H 10200 6400 60  0000 C CNN
	1    10200 6400
	1    0    0    -1  
$EndComp
NoConn ~ 10800 6600
NoConn ~ 10800 6200
$Comp
L GND #PWR029
U 1 1 5BC28BA4
P 9500 6700
F 0 "#PWR029" H 9500 6700 30  0001 C CNN
F 1 "GND" H 9500 6630 30  0001 C CNN
F 2 "" H 9500 6700 60  0000 C CNN
F 3 "" H 9500 6700 60  0000 C CNN
	1    9500 6700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9600 6600 9500 6600
Wire Wire Line
	9500 6200 9500 6700
Wire Wire Line
	9600 6200 9500 6200
Connection ~ 9500 6600
$Comp
L VCC #PWR030
U 1 1 5BC28C58
P 10300 5750
F 0 "#PWR030" H 10300 5850 30  0001 C CNN
F 1 "VCC" H 10300 5850 30  0000 C CNN
F 2 "" H 10300 5750 60  0000 C CNN
F 3 "" H 10300 5750 60  0000 C CNN
	1    10300 5750
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR031
U 1 1 5BC28C5E
P 10100 5750
F 0 "#PWR031" H 10100 5850 30  0001 C CNN
F 1 "VCC" H 10100 5850 30  0000 C CNN
F 2 "" H 10100 5750 60  0000 C CNN
F 3 "" H 10100 5750 60  0000 C CNN
	1    10100 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	10300 5850 10300 5750
Wire Wire Line
	10100 5850 10100 5750
Text Notes 5450 4500 0    50   ~ 0
Adjust R19 for 2400hz VCO
$EndSCHEMATC