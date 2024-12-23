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
Sheet 7 7
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
L LT1054 U27
U 1 1 5BC129A4
P 7000 4900
F 0 "U27" H 7000 5350 60  0000 C CNN
F 1 "LT1054" H 7000 4950 60  0000 C CNN
F 2 "" H 7000 4900 60  0000 C CNN
F 3 "" H 7000 4900 60  0000 C CNN
	1    7000 4900
	1    0    0    -1  
$EndComp
$Comp
L CP C16
U 1 1 5BC129AA
P 6200 4900
F 0 "C16" H 6275 5000 40  0000 L CNN
F 1 "100uF" H 6250 4775 40  0000 L CNN
F 2 "~" H 6300 4750 30  0000 C CNN
F 3 "~" H 6200 4900 300 0000 C CNN
	1    6200 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 4600 6200 4600
Wire Wire Line
	6200 4600 6200 4700
Wire Wire Line
	6400 5200 6200 5200
Wire Wire Line
	6200 5200 6200 5100
$Comp
L CP C17
U 1 1 5BC129B4
P 7700 5700
F 0 "C17" H 7775 5800 40  0000 L CNN
F 1 "100uF" H 7750 5575 40  0000 L CNN
F 2 "~" H 7800 5550 30  0000 C CNN
F 3 "~" H 7700 5700 300 0000 C CNN
	1    7700 5700
	1    0    0    1   
$EndComp
Wire Wire Line
	7600 5400 8000 5400
Wire Wire Line
	7700 5500 7700 5400
Connection ~ 7700 5400
NoConn ~ 6400 5400
$Comp
L GND #PWR046
U 1 1 5BC129BE
P 7000 6000
F 0 "#PWR046" H 7000 6000 30  0001 C CNN
F 1 "GND" H 7000 5930 30  0001 C CNN
F 2 "" H 7000 6000 60  0000 C CNN
F 3 "" H 7000 6000 60  0000 C CNN
	1    7000 6000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 4600 7600 4600
NoConn ~ 7600 5000
NoConn ~ 7600 5200
$Comp
L LM2576-5.0 U26
U 1 1 5BC129DD
P 5700 3000
F 0 "U26" H 5650 3450 60  0000 C CNN
F 1 "LM2576-5.0" H 5650 3150 60  0000 C CNN
F 2 "~" H 5700 3000 60  0000 C CNN
F 3 "~" H 5700 3000 60  0000 C CNN
	1    5700 3000
	1    0    0    -1  
$EndComp
$Comp
L CP C13
U 1 1 5BC12D97
P 4900 3300
F 0 "C13" H 4700 3400 40  0000 L CNN
F 1 "100uF" H 4650 3175 40  0000 L CNN
F 2 "~" H 5000 3150 30  0000 C CNN
F 3 "~" H 4900 3300 300 0000 C CNN
	1    4900 3300
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR047
U 1 1 5BC12DB1
P 5400 3600
F 0 "#PWR047" H 5400 3600 30  0001 C CNN
F 1 "GND" H 5400 3530 30  0001 C CNN
F 2 "" H 5400 3600 60  0000 C CNN
F 3 "" H 5400 3600 60  0000 C CNN
	1    5400 3600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR048
U 1 1 5BC12DBD
P 4900 3600
F 0 "#PWR048" H 4900 3600 30  0001 C CNN
F 1 "GND" H 4900 3530 30  0001 C CNN
F 2 "" H 4900 3600 60  0000 C CNN
F 3 "" H 4900 3600 60  0000 C CNN
	1    4900 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	4900 3500 4900 3600
$Comp
L DIODE D7
U 1 1 5BC12F2B
P 6400 3500
F 0 "D7" V 6500 3600 40  0000 C CNN
F 1 "MBR350" V 6300 3650 40  0000 C CNN
F 2 "~" H 6400 3500 60  0000 C CNN
F 3 "~" H 6400 3500 60  0000 C CNN
	1    6400 3500
	0    -1   -1   0   
$EndComp
$Comp
L INDUCTOR_SMALL L2
U 1 1 5BC12F3A
P 6700 3200
F 0 "L2" H 6700 3300 50  0000 C CNN
F 1 "120uH" H 6725 3150 50  0000 C CNN
F 2 "~" H 6750 3200 60  0000 C CNN
F 3 "~" H 6750 3200 60  0000 C CNN
	1    6700 3200
	1    0    0    -1  
$EndComp
$Comp
L CP C14
U 1 1 5BC12F4C
P 7000 3500
F 0 "C14" H 6800 3600 40  0000 L CNN
F 1 "1500uF" H 6750 3375 40  0000 L CNN
F 2 "~" H 7100 3350 30  0000 C CNN
F 3 "~" H 7000 3500 300 0000 C CNN
	1    7000 3500
	1    0    0    -1  
$EndComp
$Comp
L CP C15
U 1 1 5BC12F52
P 7600 3500
F 0 "C15" H 7400 3600 40  0000 L CNN
F 1 "22uF" H 7405 3380 40  0000 L CNN
F 2 "~" H 7700 3350 30  0000 C CNN
F 3 "~" H 7600 3500 300 0000 C CNN
	1    7600 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	7700 5900 7700 6000
$Comp
L GND #PWR049
U 1 1 5BC12FAA
P 7700 6000
F 0 "#PWR049" H 7700 6000 30  0001 C CNN
F 1 "GND" H 7700 5930 30  0001 C CNN
F 2 "" H 7700 6000 60  0000 C CNN
F 3 "" H 7700 6000 60  0000 C CNN
	1    7700 6000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 5700 7000 6000
$Comp
L GND #PWR050
U 1 1 5BC12FDA
P 5700 3600
F 0 "#PWR050" H 5700 3600 30  0001 C CNN
F 1 "GND" H 5700 3530 30  0001 C CNN
F 2 "" H 5700 3600 60  0000 C CNN
F 3 "" H 5700 3600 60  0000 C CNN
	1    5700 3600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR051
U 1 1 5BC12FE0
P 6400 3900
F 0 "#PWR051" H 6400 3900 30  0001 C CNN
F 1 "GND" H 6400 3830 30  0001 C CNN
F 2 "" H 6400 3900 60  0000 C CNN
F 3 "" H 6400 3900 60  0000 C CNN
	1    6400 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 3500 5700 3600
Wire Wire Line
	5400 3500 5400 3600
Wire Wire Line
	6300 3200 6500 3200
Wire Wire Line
	6400 3300 6400 3200
Connection ~ 6400 3200
Wire Wire Line
	7000 2700 6300 2700
Text GLabel 8000 5400 2    60   Output ~ 0
-5V
Text GLabel 8200 3200 2    60   Output ~ 0
+5v
$Comp
L VCC #PWR052
U 1 1 5BC13906
P 7900 3000
F 0 "#PWR052" H 7900 3100 30  0001 C CNN
F 1 "VCC" H 7900 3100 30  0000 C CNN
F 2 "" H 7900 3000 60  0000 C CNN
F 3 "" H 7900 3000 60  0000 C CNN
	1    7900 3000
	1    0    0    -1  
$EndComp
$Comp
L DIODE D6
U 1 1 5BC1AD39
P 4200 2950
F 0 "D6" H 4200 3050 40  0000 C CNN
F 1 "1N5402" H 4200 2850 40  0000 C CNN
F 2 "~" H 4200 2950 60  0000 C CNN
F 3 "~" H 4200 2950 60  0000 C CNN
	1    4200 2950
	1    0    0    -1  
$EndComp
$Comp
L BARREL_JACK CON1
U 1 1 5BC3D0E3
P 3400 3050
F 0 "CON1" H 3400 3300 60  0000 C CNN
F 1 "12v DC" H 3400 2850 60  0000 C CNN
F 2 "" H 3400 3050 60  0000 C CNN
F 3 "" H 3400 3050 60  0000 C CNN
	1    3400 3050
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR053
U 1 1 5BC3C86C
P 3800 3450
F 0 "#PWR053" H 3800 3450 30  0001 C CNN
F 1 "GND" H 3800 3380 30  0001 C CNN
F 2 "" H 3800 3450 60  0000 C CNN
F 3 "" H 3800 3450 60  0000 C CNN
	1    3800 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 2950 3700 2950
Wire Wire Line
	3700 3150 3800 3150
Wire Wire Line
	3800 3050 3800 3450
Wire Wire Line
	3700 3050 3800 3050
Connection ~ 3800 3150
Text GLabel 8200 2000 2    60   Output ~ 0
+12v
Wire Wire Line
	7600 3700 7600 3800
Wire Wire Line
	7600 3800 6400 3800
Wire Wire Line
	6400 3700 6400 3900
Connection ~ 6400 3800
Wire Wire Line
	7000 3700 7000 3800
Connection ~ 7000 3800
Wire Wire Line
	7900 4600 7900 3000
Wire Wire Line
	6900 3200 8200 3200
Connection ~ 7900 3200
Wire Wire Line
	7600 3300 7600 3200
Connection ~ 7600 3200
Wire Wire Line
	7000 2700 7000 3300
Connection ~ 7000 3200
$Comp
L DIODE D8
U 1 1 5BFEDBAD
P 4200 2000
F 0 "D8" H 4200 2100 40  0000 C CNN
F 1 "1N4002" H 4200 1900 40  0000 C CNN
F 2 "~" H 4200 2000 60  0000 C CNN
F 3 "~" H 4200 2000 60  0000 C CNN
	1    4200 2000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5000 2950 4400 2950
Wire Wire Line
	4900 3100 4900 2950
Connection ~ 4900 2950
Wire Wire Line
	8200 2000 4400 2000
Wire Wire Line
	3800 2950 3800 2000
Wire Wire Line
	3800 2000 4000 2000
Connection ~ 3800 2950
$EndSCHEMATC
