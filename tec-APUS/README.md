
## tec-APUS, 

Serial + Maths+ Firth of Forth in mind. 

This addon has 2 parts, async serial using the MC6850, amx rate of 1.0 Mbps.
We only need a fraction of that, with a clock of 7.3728 Mhz, which is a special baud rated freq, then by dividing down with reg settings divisor; ie /64 = 115,200 baud or /16 =  460,800 baud. We set up the control registers and then can tx and rx, with INT control as needed, ie rx buffer > INT.

The second part adds a maths calculator using the AM9511. We setup the control registers then send maths commands and data, it executes with the result placed on its internals  stack signaling with INT call.

The circuit is still work in progress at   https://easyeda.com/editor#id=f38afcc535a449c0b98ccadf3163fde4
The pcb can be connected 2 ways; the expansion socket with ribbon or a 2x22 socket.

## MC6850
The MC6850 is selected via M1, A7,A1,A0  on IO ports 82, 83.

The test code is files are 
-mycomputer.emu
-simple-echo.z80

You can compile it in asm80.com, place your test message in the code and set the memory range to Download as a BIN file, main.z80.bin will download. Also setup ORG value depending on how or where you load the code or which monitor is used. If using Bens https://github.com/SteveJustin1963/tec-EMU-BG there is not monitor and org = 0000h. 
The EMU board goes in the ROM socket, code is uploaded via USB cable from the pc. When the USB end goes into pc, it will activate PnP and windows will auto install drivers for EMU that Bens app is a .bat DOS file when runs calls a python script to load the code. run C:\cmd and C:\mode.

Also note when you activate “Download BIN” function in the asm80.com IDE, you need to trim the bin file down default is 64k using ;
eg
- .binfrom 0000h 
- .binto 0130h

You also need a special USB to TTL cable; it has a TTL to USB bridging chip ie the FT232R or PL2303TA and emulates a virtual com port. When the USB end goes into pc, It will activate PnP and windows will auto install drivers and create a virtual com port. Or use a TTL to RS-232 converter such the MAX232 chip on pcb. Then connect to TTL on tec-APUS and run a com cable to the com port on the pc. Bugt newer pcs and laptops don't always have com ports.
Then run a terminal app to generate ascii text such as 
-https://www.putty.org/    
-https://www.chiark.greenend.org.uk/~sgtatham/putty/ 

On the USB to TTL cable, the TTL end presents Red=+5V, Black=GND, White=RXD, Green=TXD, but RTS, CTS, DSR are not there on a cheap cables, from the chip inside the lines are not presented and are not needed for the PCB. Some current limit resistors are on the tx and rx lines for protection. You can do loopback test on the cable, so short out TX to RX (white green), typing anything.. It should echo back.

## AM9511
See the code file 9511.asm, still work in progress.

## Firth of Forth
Firth still wont fit in a 4k ROM mod but is not far off. When it does, Firth can be compiled with 82, 83 control ports and testing can begin.

## Journal
More info in https://github.com/SteveJustin1963/tec-APUS/wiki





