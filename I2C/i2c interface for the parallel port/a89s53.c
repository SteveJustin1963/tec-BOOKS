/*
	a89s53.c
	a simple atmel 89s53 prommer for the parallel port
	
	(c) 02.09.2000 Franz Ackermann ackermann@unix.cslab.tuwien.ac.at

	the atmel 89s53 offers programming of its 12k byte eeprom via a
	simple serial interface.

	to reused the hardware of my 93c66 prommer, I use the same
	pins on the parallel port. the protocol is basically the
	same too, the connectiors are just called differently.

	for pinout and hardware requiremets on the controller side
	(powersupply, clock) see the documentation at atmels website.
	I just need to express that I am bewilderd by names like MOSI
	and MISO. master out, slave in, dont make me happy:

	RST	this line needs to go up to enable serial programming
	SCK	clock. a transition from logic 0 to 1 triggers.
	MOSI	input line
	MISO	output line


	to program the chip RST has to go to high (1). this is is done
	by setting bit 0 of the parallel port to 1.

	sck impulse is initiated by the transition from 0 to 1.
	this is done by switching bit 1 of parallel port.

	MOSI is the imput signal, its provided by bit 2 of parallel port

	MISO is read via the paper emty line of the parallel port. therefore
	even old unidirectional interfaces should work.


	RST connects to pin 2
	SCK connects to pin 3
	MOSI connects to pin 4
	MISO connects to pin 12

	even on the (pc-)master side, the code refers to data_out
	as a data out from the microcontroller

*/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#ifdef __GNUC__
#include <sys/io.h>
#define outp(a1, a2)   outb(a2, a1)
#define inp(id)   inb(id)
#endif


int parbase=0x378,parcont;
int reading=-1;
int erasing=0;
int programming=1;
char binfile[1024];
int filemode=0;
int writelock=0;
int lock1,lock2,lock3;
int addr=-1,len=-1;
int verbosemode=0;

/* definition of parallel port signals */

#define C_DO_1 0x20
#define C_DO_0 0x0

#define C_CS_1 0x1
#define C_CS_0 0x0

#define C_SK_1 0x2
#define C_SK_0 0x0

#define C_DI_1 0x4
#define C_DI_0 0x0

/* timeout while waitint for completion */
#define twp 30000
/* len of clock intervall in port accesses */
#define SYNC_LEN 	(12*2)
/* when the 0 to 1 switch takes place */
#define SYNC_HALF   (6*2)
/* time for eventual reading */
#define SYNC_75     (10*2)

#define SYNC_LONGER (SYNC_LEN*5)

int basetick;

void sendoutbit(unsigned char value)
{
	int i;
	unsigned char w;
	unsigned char indummy=0;
//	w=random()%2;
//	w=w*C_SK_1;
	for (i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|value;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}	
}

unsigned char receivebit()
{
	int i;
	unsigned char w;
	unsigned char indummy=0;

	unsigned char d=0;

	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);

		if(basetick%SYNC_LEN==SYNC_75) {
			if(indummy&C_DO_1) d=1; else d=0;
			if(verbosemode) fprintf(stderr,"[%d]",d);
		}
	}
	return d;
}

void off()
{
	char w;
	outp(parbase,0);
	w=inp(parcont);
	w=w & ~C_DO_1;
	outp(parcont,0);
}

void enableprogramming()
{
	/* byte 1: 1010 1100 */

	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_1);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	/* byte 2: 0101 0011 */

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_1);

	/* byte 3: dont care, use 0 */

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

}


void eraseall()
{
	/* byte 1: 1010 1100 */

	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_1);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	/* byte 2: xxxx x011 */

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	/* byte 3: dont care, use 0 */

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

}

void writelockbits()
{
	/* byte 1: 1010 1100 */

	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_1);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	/* byte 2: 123x x111 */

	if (lock1) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (lock2) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (lock3) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_1);
	sendoutbit(C_DI_1);

	/* byte 3: dont care, use 0 */

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);
	sendoutbit(C_DI_0);

}

char readbyte(unsigned int pos)
{
	int i;
	unsigned char value=0;

	if (pos & (1<<12)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<11)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<10)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<< 9)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);

	if (pos & (1<< 8)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<13)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);

	sendoutbit(C_DI_0);
	sendoutbit(C_DI_1);

	if (pos & (1<<7)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<6)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<5)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<4)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);

	if (pos & (1<<3)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<2)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<1)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
//	if (pos & (1<<0)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	sendoutbit(C_DI_1*(random()%2));
	/* now read data */

	for (i=7;i>=0;i--) {
		if(receivebit()) value=value|(1<<i);
	}	

	return value;
}

void writebyte(unsigned int pos,unsigned char value)
{
	int i;

	if (pos & (1<<12)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<11)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<10)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<< 9)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);

	if (pos & (1<< 8)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<13)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);

	sendoutbit(C_DI_1);
	sendoutbit(C_DI_0);

	if (pos & (1<<7)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<6)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<5)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<4)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);

	if (pos & (1<<3)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<2)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<1)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	if (pos & (1<<0)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);

	/* now write data */

	for (i=7;i>=0;i--) {
		if (value &(1<<i)) sendoutbit(C_DI_1); else sendoutbit(C_DI_0);
	}	

}



void readdata ()
{
	FILE *outfile;
	int i;
	unsigned char w;

	enableprogramming();
	
	if (filemode) outfile=fopen(binfile,"wb");

	for(i=0;i<len;i++) {
		w=readbyte(addr+i);
		if(filemode) fputc(w,outfile);
		else fprintf(stdout,"%5x %2x\n",addr+i,w);
	}
	if (filemode) fclose(outfile);

}



void writedata (char **argv,int index)
{
	FILE *infile;
	int i;
	unsigned char w;

	enableprogramming();
	
	if (filemode) infile=fopen(binfile,"rb");

	for(i=0;i<len;i++) {
		if(filemode) w=fgetc(infile); else w=atoi(argv[index+i]);
		writebyte(addr+i,w);
	}
	if (filemode) fclose(infile);

}


void printusage()
{
	fprintf(stderr,"\nUsage:\n");
	fprintf(stderr,"89c53 -r pos     	 Read from pos\n");
	fprintf(stderr,"89c53 -w pos,byte    	 Write to pos\n");
	fprintf(stderr,"89c53 -s pos,len,file    Save len bytes from pos to file\n");
	fprintf(stderr,"89c53 -l pos,len,file    Load len from file to pos\n");
	fprintf(stderr,"89c53 -p     	         enable Programming\n");
	fprintf(stderr,"89c53 -e     	         Erase chip\n");
	fprintf(stderr,"89c53 -k b1,b2,b3    	 locK bits b1 b2 b3\n");
	fprintf(stderr,"89c53 -i ioport          parallel base ioport\n");
	exit(1);
}


int main (int argc, char **argv)
{
#ifdef __GNUC__
	int c;
	extern int optind;
	extern char *optarg;
#endif
	int specials=0;

	fprintf(stderr,"compiled for iobase: %x\n",parbase);

#ifdef __GNUC__
	while ((c = getopt(argc, argv, "va:c:f:rwk:epi:")) != EOF)
		switch (c) {
			case 'v': verbosemode=1; break;
			case 'a':
						if (!sscanf(optarg,"%d",&addr)) printusage();
				fprintf(stderr,"address: %d\n",addr);
				break;
			case 'c':
								if (!sscanf(optarg,"%d",&len)) printusage();
								fprintf(stderr,"count: %d\n",len);
								break;
						case 'f':
				strcpy(binfile,optarg);
				filemode=1;
								fprintf(stderr,"filename: %s\n",binfile);
								break;
			case 'r':
				if (reading!=-1) {
					fprintf(stderr,"read and write dont mix to well.\n");
					printusage();
				}
				reading=1;
				break;
						case 'w':
				if (reading!=-1) {
										fprintf(stderr,"read and write dont mix to well.\n");
										printusage();
								}
								reading=0;
								break;
						case 'e':
								erasing=1;
				specials++;
								break;
						case 'p':
								programming=1;
				specials++;
								break;
						case 'i':
								if (!sscanf(optarg,"%x",&parbase)) printusage();
								fprintf(stderr,"iobase: %x\n",parbase);
								break;
						case 'k':
				if (3!=sscanf(optarg,"%d,%d,%d",&lock1,&lock2,&lock3)) printusage();
								writelock=1;
				specials++;
								break;
			case '?':
				printusage();
					default:
				break;
	}


	if (filemode && (optind!=argc)) {
		fprintf(stderr,"please dont add values in filemode\n");
		printusage();
	}

	if (!filemode && !reading) {
		if (len != (argc-optind)) {
			fprintf(stderr,"count dont match\n");
					printusage();
		}
		len=argc-optind;
	}

	if (reading && (optind!=argc)) {
				fprintf(stderr,"please dont add values when reading\n");
				printusage();
	}

	if ((specials>1) && (reading!=-1)) {
		fprintf(stderr,"please dont combine special commands with data transfer\n");
				printusage();
	}

	if (specials>1) {
		fprintf(stderr,"only one special command allowed per invocation\n");
	}

	if (len<0) {
		fprintf(stderr,"please specify count.\n");
				printusage();
	}

	if (addr<0) {
		fprintf(stderr,"please specify address.\n");
				printusage();
	}


#else
	len=1;
	addr=0;
	filemode=0;
	specials=0;
#endif

	parcont=parbase+1;

#ifdef  __GNUC__
	ioperm(parbase,2,1);
#endif

	off();


	if (specials==1) {

		if (programming) { enableprogramming(); off(); exit(0); }
		if (erasing) { eraseall(); off(); exit(0); }
		if (writelock) { writelockbits(); off(); exit(0); }

		exit(0);
	}
	if (reading==1) {
		readdata();
		off();
		exit(0);
	}
	if (reading==0) {
		writedata(argv,optind);
		off();
		exit(0);
	}
	if (reading==-1) {
		fprintf(stderr,"nothing to do honey\n");
		exit(0);
	}
	return 0;
}
