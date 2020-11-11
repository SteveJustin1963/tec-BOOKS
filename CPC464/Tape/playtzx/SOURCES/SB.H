////////////////////////////////////////////////////////////////////////////////
//
// 			Sound Blaster 8 Bit Mono Direct and DMA Functions
//					 with Auto Initialised DMA Support
//
//                                v1.11
//
//						Copyright (c)1995 Tomaz Kac
//
// 				This Source is WATCOM C specific ( 10.0 + )
//
//					  Some corrections by James McKay
////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <string.h>
#include <dos.h>

#define	word	unsigned short int

word SB_Base;
char SB_Irq;
char SB_Dma;

static volatile int  SB_DMAComplete=0;
static void (interrupt far *SB_OldIrq)();

word P_Read;
word P_Write;
word P_Data;

word SB_sel;

////////////////////////////////////////////////////////////////////////////////
int SB_DSPReset()
{
// Tries to Reset the SB with base address ... returns 1 if successfull
//										   			   0 if not
int c; long dummy;

outp(SB_Base+0x06,0x01);
//delay(5);			// This little command causes the executable to wait
					// in the beginning of the program for over 1 second !
					// therefore I use the next loop instead :)
for (dummy=0; dummy<100000; dummy++) { c+=2; }	// instead of delay
outp(SB_Base+0x06,0x00);
c=100; while (c>0 && inp(SB_Base+0x0a)!=0xaa) c--;
if (c)	return(1);
else	return(0);
}

////////////////////////////////////////////////////////////////////////////////
void SB_SetPorts()
{
// Sets the Port Variables to SB_Base+Offset

P_Read= SB_Base+0x0a;
P_Write=SB_Base+0x0c;
P_Data =SB_Base+0x0e;
}

////////////////////////////////////////////////////////////////////////////////
word SB_DetectBase()
{
// Detects the Base address of the SB ... returns Addres if successfull
//									 			  otherwise returns 0
// Call this routine if SB_Detect() fails !

SB_Base=0x210;
while (SB_Base<0x270 && !SB_DSPReset())	SB_Base+=0x10;
if (SB_Base==0x270) return(0);
SB_SetPorts();
return(SB_Base);
}

////////////////////////////////////////////////////////////////////////////////
int SB_Detect()
{
// Detects the SB using Environment Variable BLASTER
// i.e. BLASTER = A220 I5 D1
// Only A, I, D selectors are used, others are ignored !
// Fills SB_Base, SB_Irq, SB_Dma
// if Detection Failed ( no BLASTER environment, missing selectors or
// Soundblaster could not be reset-ed) then 0 is returned, else 1 is returned
char *blaster;
char *c;
int t;

blaster=(char *) getenv("BLASTER");
if (blaster==NULL) return(0);
if ((c=(char *)strchr(blaster,'A'))==NULL)
	{ if ((c=(char *)strchr(blaster,'a'))==NULL) return(0); }
sscanf(c+1,"%3hx",&t); SB_Base=(word) t;
if ((c=(char *)strchr(blaster,'I'))==NULL) 
	{ if ((c=(char *)strchr(blaster,'i'))==NULL) return(0); }
sscanf(c+1,"%d",&t); SB_Irq=(char) t;
if ((c=(char *)strchr(blaster,'D'))==NULL)
	{ if ((c=(char *)strchr(blaster,'d'))==NULL) return(0); }
sscanf(c+1,"%d",&t); SB_Dma=(char) t;
SB_SetPorts();
if (SB_DSPReset())	return(1);
else 				return(0);
return (1);
}

////////////////////////////////////////////////////////////////////////////////
void SB_Speaker(int t)
{
// Toggles SB Speaker ( Output ) ... if t=0 then it is OFF otherwise ON

while (inp(P_Write)&0x80);
if (t)	outp(P_Write, 0xd1);
else	outp(P_Write, 0xd3);
}
		
////////////////////////////////////////////////////////////////////////////////
char SB_SampleByte()
{
// Samples a Byte from SB Input and returns it as return value

while (inp(P_Write)&0x80);
outp(P_Write, 0x20);
while (!(inp(P_Data)&0x80));
return(inp(P_Read));
}

////////////////////////////////////////////////////////////////////////////////
void SB_PlayByte(char p)
{
// Plays a Byte ( p ) to SB Output

while (inp(P_Write)&0x80);
outp(P_Write, 0x10);
while (inp(P_Write)&0x80);
outp(P_Write, p);
}

////////////////////////////////////////////////////////////////////////////////
void dos_memalloc(short int para, short int *seg, short int *sel);
#pragma  aux dos_memalloc = \
  "push  ecx"               \
  "push  edx"               \
  "mov   ax, 0100h"         \
  "int   31h"               \
  "pop   ebx"               \
  "mov   [ebx], dx"         \
  "pop   ebx"               \
  "mov   [ebx], ax"         \
  parm   [bx] [ecx] [edx]   \
  modify [ax ebx ecx edx];

////////////////////////////////////////////////////////////////////////////////
void dos_memfree(short int sel);
#pragma  aux dos_memfree =  \
  "mov   ax, 0101h"         \
  "int   31h"               \
  parm   [dx]               \
  modify [ax dx];

////////////////////////////////////////////////////////////////////////////////
char *SB_AllocBuffer()
{
// Allocates a buffer of atleast 32767 bytes and returns its pointer
// Buffer is in LOW mem and WHOLE in the same Segment ...
unsigned m;
word seg;

dos_memalloc(0x0fff, (short int *) &seg,(short int *) &SB_sel);
m=(unsigned) (((int) seg)<<4);
if ((m&0xffff)>=0xB000) m=(m+0xffff)&0xffff0000;
return((char *) m);
}

////////////////////////////////////////////////////////////////////////////////
void SB_FreeBuffer()
{
// Frees the Buffer Allocated by SB_AllocBuffer()

dos_memfree(SB_sel);
}

////////////////////////////////////////////////////////////////////////////////
void SB_InitDMA(int PlayRec, char *buf, int len, int mode)
{
// Inits the DMA Controller for Transfer
// PlayRec selects PLAY (1) or RECORD (0)
// buf is pointer to buffer to be send, len is number of bytes to be send
// buf has to be in LOW mem i.e. in 20-bit address space
// mode is toggle for auto init dma mode or normal mode ( auto = 1 )
// Called Internally
word DMAOff;
word DMAPag;
unsigned bufl;

bufl=(int) buf;
DMAPag=(word) (bufl>>16);
DMAOff=(word) (bufl&0xffff);
outp(0x0a, SB_Dma+0x04);
outp(0x0c, 0x00);
if (!PlayRec)	outp(0x0b, 0x44+SB_Dma);	// Record
else if (!mode)	outp(0x0b, 0x48+SB_Dma);	// Play Normal	
	 else		outp(0x0b, 0x58+SB_Dma);	// Play Auto Init
outp(SB_Dma<<1, (char) (DMAOff&0x00ff));
outp(SB_Dma<<1, (char) (DMAOff>>8));
switch (SB_Dma)
	{
	case 0: outp(0x87, (char) (DMAPag&0x00ff)); break;
	case 1: outp(0x83, (char) (DMAPag&0x00ff)); break;
	case 2: outp(0x81, (char) (DMAPag&0x00ff)); break;
	case 3: outp(0x82, (char) (DMAPag&0x00ff)); break;
	}
outp((SB_Dma<<1)+1, (char) ((len-1)&0x00ff));
outp((SB_Dma<<1)+1, (char) ((len-1)>>8));
outp(0x0a, SB_Dma);
}

////////////////////////////////////////////////////////////////////////////////
void SB_InitSBDMA(int PlayRec, int Rate, int len)
{
// Inits SoundBlaster DMA
// PlayRec selects PLAY (1) or RECORD (0)
// Playback or Record starts immediately after this function

while (inp(P_Write)&0x80);
outp(P_Write, 0x40);
while (inp(P_Write)&0x80);
outp(P_Write, (char) (256-(1000000/Rate)));
while (inp(P_Write)&0x80);
if (!PlayRec)	outp(P_Write, 0x24);
else			outp(P_Write, 0x14);
while (inp(P_Write)&0x80);
outp(P_Write, (char) ((len-1)&0x00ff));
while (inp(P_Write)&0x80);
outp(P_Write, (char) ((len-1)>>8));
}

////////////////////////////////////////////////////////////////////////////////
static void interrupt SB_IntHandler()
{
// Interrupt Handler for SB Interrupt ( Sets SB_DMAComplete to 1 when DMA
// Finishes )

SB_DMAComplete=!SB_DMAComplete;
inp(P_Data);
outp(0x20, 0x20);
}

////////////////////////////////////////////////////////////////////////////////
void SB_SetIntHandler()
{
// Sets Our Custom SB_IntHandler() as Interrupt handler for SB DMA finish int.

_disable();
SB_OldIrq=_dos_getvect(0x08+SB_Irq);
_dos_setvect(0x08+SB_Irq, SB_IntHandler);
_enable();
}

////////////////////////////////////////////////////////////////////////////////
void SB_ResetIntHandler()
{
// Sets the Previous Interr. Handler for SB DMA finish int.

_disable();
_dos_setvect(0x08+SB_Irq, SB_OldIrq);
outp(0x21, inp(0x21)|(1<<SB_Irq));
_enable();
}

////////////////////////////////////////////////////////////////////////////////
void SB_PlayDMA(char *buf, int Rate, int Length)
{
// Plays Buffer buf at Rate rate (Hz) for Length bytes through DMA

outp(0x21, inp(0x21)&~(1<<SB_Irq));
while (inp(P_Write)&0x80);
outp(P_Write, 0xd1);
SB_InitDMA(1, buf, Length, 0);
SB_InitSBDMA(1, Rate, Length);
SB_DMAComplete=0;
}

////////////////////////////////////////////////////////////////////////////////
void SB_SampleDMA(char *buf, int Rate, int Length)
{
// Samples to Buffer buf at Rate rate (Hz) for Length bytes through DMA

outp(0x21, inp(0x21)&~(1<<SB_Irq));
SB_InitDMA(0, buf, Length, 0);
SB_InitSBDMA(0, Rate, Length);
SB_DMAComplete=0;
}

////////////////////////////////////////////////////////////////////////////////
void SB_StopDMA()
{
// Stops the DMA Transfer Immediately

while (inp(P_Write)&0x80);
outp(P_Write, 0xd0);
while (inp(P_Write)&0x80);
outp(P_Write, 0xd3);
outp(0x0a, 0x04+SB_Dma);
outp(0x0c, 0x00);
//outp(0x0a, 0x00);  // Causes crash in Win3.1
}

////////////////////////////////////////////////////////////////////////////////
void SB_PlayAIDMA(char *buf, int Rate, int len)
{
// Plays Buffer buf in Auto Init DMA mode at rate Rate (Hz), length is len

outp(0x21, inp(0x21)&~(1<<SB_Irq));
while (inp(P_Write)&0x80);
outp(P_Write, 0xd1);
SB_InitDMA(1, buf, len, 1);

while (inp(P_Write)&0x80);
outp(P_Write, 0x40);
while (inp(P_Write)&0x80);
outp(P_Write, (char) (256-(1000000/Rate)));
while (inp(P_Write)&0x80);
outp(P_Write,0x48);
while (inp(P_Write)&0x80);
outp(P_Write, (char) (((len>>1)-1)&0x00ff));
while (inp(P_Write)&0x80);
outp(P_Write, (char) (((len>>1)-1)>>8));
while (inp(P_Write)&0x80);
if (Rate>22050) outp(P_Write, 0x90);	// High-Speed DMA for Rate> 22050
else			outp(P_Write, 0x1C);	//  Low-SPeed DMA for Rate<=22050
SB_DMAComplete=0;				// This one toggless as the interrupts occurs
								// if 0 then Page Playing = buf
								// if 1 then Page Playing = buf+(len>>1)
}
