/*
	93c66
	a simple 93c66 read/write prommer for the parallel port

	(c) 25.01.1999 Franz Ackermann faz@obiwan.hvrlab.org
	(c) 15.09.2000 Franz Ackermann
	distributed under GPL

	This is a modified source version for reading a 93C46 organised as
	a 64 16bit word serial eeprom. Furthermore linux support is
	included.

	compile using gcc -O -o 93c46lin 93c46lin.c
	dont forget the -O switch, otherwise outb/inb wont be found.

	-snip-

	the 93c66 is a 256x16bit serial eeprom

	cs   1=u=8   vcc
	sk   2   7   nc
	di   3   6   nc
	do   4===5   gnd

	cs chip select
	sk serial clock
	di data in
	do data out
	vcc +5v

	to operate the chip cs has to go to high (1). this is is done
	by setting bit 0 of the parallel port to 1.

	sk clock impulse is initiated by the transition from 0 to 1.
	this is done by switching bit 1 of parallel port.

	di is the imput signal, its provided by bit 2 of parallel port

	do is read via the paper emty line of the parallel port. therefore
	even old unidirectional interfaces should work.


	parallel port connections:

	cs connects to pin 2
	sk connects to pin 3
	di connects to pin 4
	do connects to pin 12
	vcc is +5v (joystik pin 1 or whatsoever)
	gnd is pin 18-15 or sheilding



	as the parallel port provides no timing or triggering
	functionality, the timing is done by a basic n/2 times down,
	n/2 times up sync on bit 1.


	programm usage:


    single word commandos:

	93c66 r pos
	prints high and lowbyte on position pos

	93c66 w pos high low
	sets word on position pos to high*256+low
	writing includes erasing for compatibility

	complete block commandos:

	please note that files are little endian. sure
	I feel I'll toast in hell for this :-)

	93c66 l filename
	loads data from file filename into chip, takes a few seconds

	93c66 s filename
	saves chips contents to file named filename


	26.01.1999
	
	added defines to work with 93c46, which is only a quarter of
	the 93c66 sized. modification is via the <eeprom definiton>
	defines below. 93c56 should have 7 addressbits, however
	I dont have anyone around.

*/


#include <stdio.h>
#include <stdlib.h>

#ifdef __GNUC__
#include <sys/io.h>
#define outp(a1, a2)   outb(a2, a1)
#define inp(id)   inb(id)
#else
#include <conio.h>
#endif

/* parallel port 0x378=lpt1 under dos, lpt1 could also be 0x3bc,
   lpt2=0x278 */

int parbase=0x378;
int parcont=0x379;

/* definition of parallel port signals */

#define C_DO_1 0x20
#define C_DO_0 0x0

#define C_CS_1 0x1
#define C_CS_0 0x0

#define C_SK_1 0x2
#define C_SK_0 0x0

#define C_DI_1 0x4
#define C_DI_0 0x0


/* timing definitions */

/* timeout while waitint for completion */
#define twp 30000
/* len of clock intervall in port accesses */
#define SYNC_LEN 	6
/* when the 0 to 1 switch takes place */
#define SYNC_HALF   2
/* time for eventual reading */
#define SYNC_75     5

#define SYNC_LONGER (SYNC_LEN*5)

/* eeprom defintions */

#define NR_DATA_WORDS 64
#define NR_DATA_BITS 16
#define NR_ADDR_BITS 6

/*

reading works by sending 110 and the address to be read
to the chip. the address is msb first. the chip outputs
d15 downto (hey reminds of modula?) d0.

*/

void getword(int pos, char* hb, char* lb)
{
	int i,q;
	int basetick=0;
	char w=0;
	char indummy=0;
	char bits[16];

	/* just the clock is running */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* the clock is running, turn on cs too */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* now output read head */
	/* basetick is at %6=0 */

	/* leading 1 */
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* the next 1 */

	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* the 0 of read */

	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_0;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}



	/* now output the adress bits, starting with the msb */

	for(q=NR_ADDR_BITS-1;q>=0;q--) {

		for(i=0;i<SYNC_LEN;i++) {
			w=0;
			if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
			w=w|C_CS_1;
			if( (pos & (1<<q)) ) {
				w=w|C_DI_1;
			}
			outp(parbase,w);basetick++;indummy=inp(parcont);
		}

	}


	/* now read the 16 data bits, starting with msb */

	for(q=NR_DATA_BITS-1;q>=0;q--) {

		for(i=0;i<SYNC_LEN;i++) {
			w=0;
			if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
			w=w|C_CS_1;
			outp(parbase,w);basetick++;indummy=inp(parcont);

			if(basetick%SYNC_LEN==SYNC_75) {
				if(indummy&C_DO_1) bits[q]=1; else bits[q]=0;

			}
		}

	}

	/* build hb and lowb */
	*lb=0;
	for(q=0;q<8;q++)
		if(bits[q]) *lb=*lb|(1<<q);

	*hb=0;
	for(q=8;q<16;q++)
		if(bits[q]) *hb=*hb|(1<<(q-8));


	/* the clock is still running, but turn cs down */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

}



/*

writing works by sending 101 and the adress to be read
to the chip. the adress is msb first. d15 downto d0 follow.

before doing so, the chips gets a write enable signal
(10011xxxxxx), afterwards programming is disabled (10000xxxxxx)


*/

void setword(int pos, char hb, char lb)
{
	int i,q,timeout;
	int basetick=0;
	char w=0;
	char indummy=0;
	char bits[16];

	/* build bits field for conveniece */
	for(q=0;q<8;q++) {
		if(lb&(1<<q)) bits[q]=1; else bits[q]=0;
	}
	for(q=8;q<16;q++) {
		if(hb&(1<<(q-8))) bits[q]=1; else bits[q]=0;
	}


	/* just the clock is running */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* the clock is running, turn on cs too */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* now output write enable */

	/* leading 1 */
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* the next 00 */
	for(q=0;q<2;q++)
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* the next 11xxxxxx where x is one, just for fun */

	for(q=0;q<2+(NR_ADDR_BITS-2);q++)
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* send a few syncs only.
	not sure if low cs is required, guess no */
	for(q=0;q<1000;q++) /* argl. stupid slow piece of .. */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}


	/* erase the destination word */

	/* send a few syncs and cs only */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* now the actual erase commando */

	/* leading 111 */
	for(q=0;q<3;q++)
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* now output the adress bits, starting with the msb */

	for(q=(NR_ADDR_BITS-1);q>=0;q--) {

		for(i=0;i<SYNC_LEN;i++) {
			w=0;
			if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
			w=w|C_CS_1;
			if( (pos & (1<<q)) ) {
				w=w|C_DI_1;
			}
			outp(parbase,w);basetick++;indummy=inp(parcont);
		}

	}

	/* some syncs with cs to try.. */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* send a few syncs without cs
	the first sync without cs initiates internal erase
	this should take at least 250ns no problem*/
	for(q=0;q<1;q++)
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* now pull cs up again and wait till d0 is logical 1
	again.
	shit, the chips written and graphical docu seem to differ
	I'll try the logical 1 (graphic case).
	ok: this works: wait for going to logical 1

	*/
	timeout=0;
	while( (timeout++<twp) )
	for (i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);

		if(indummy&C_DO_1) {
/*		  fprintf(stderr,"erase ready at: %d\n",timeout);*/
		  timeout=twp+2;
		}

	}
	if(timeout==(twp+1)) fprintf(stderr,"erase ready timed out\n");



	/* now the actual write commando */

	/* leading 1 */
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* next 0 */
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* next 1 */
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}


	/* now output the adress bits, starting with the msb */

	for(q=(NR_ADDR_BITS-1);q>=0;q--) {

		for(i=0;i<SYNC_LEN;i++) {
			w=0;
			if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
			w=w|C_CS_1;
			if( (pos & (1<<q)) ) {
				w=w|C_DI_1;
			}
			outp(parbase,w);basetick++;indummy=inp(parcont);
		}

	}


	/* now write the 16 data bits, starting with msb */

	for(q=(NR_DATA_BITS-1);q>=0;q--) {

		for(i=0;i<SYNC_LEN;i++) {
			w=0;
			if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
			w=w|C_CS_1;
			if(bits[q]) {
				w=w|C_DI_1;
			}
			outp(parbase,w);basetick++;indummy=inp(parcont);
		}

	}

	/* send a few syncs and without cs only
	the first sync without cs initiates internal write */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}


	/* now pull cs up again and wait till d0 is logical 1
	again.
	*/
	timeout=0;
	while( (timeout++<twp) )
	for (i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);

		if(indummy&C_DO_1) {
/*		  fprintf(stderr,"write ready at: %d\n",timeout);*/
		  timeout=twp; }

	}



	/* send a few syncs and cs only */
	for (q=0;q<10;q++);
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}


	/* now disable further writing */

	/* leading 1 */
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		w=w|C_DI_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* the next 0000xxxxxx where x is 0, to make it fair */
	for(q=0;q<(NR_ADDR_BITS+2);q++)
	for(i=0;i<SYNC_LEN;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

	/* send a few syncs and cs only */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		w=w|C_CS_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}


	/* the clock is still running, but turn cs down */
	for (i=0;i<SYNC_LONGER;i++) {
		w=0;
		if(basetick%SYNC_LEN>SYNC_HALF) w=w|C_SK_1;
		outp(parbase,w);basetick++;indummy=inp(parcont);
	}

}


/* saves the complete data to a given filename */

void saveto(char *filename)
{
	int i;
	char hb,lb;

	FILE *outfile=fopen(filename,"wb");

	for(i=0;i<NR_DATA_WORDS;i++) {
		getword(i,&hb,&lb);
		fputc(lb,outfile);
		fputc(hb,outfile);
	}

	fclose(outfile);
}


/* loades the complete data from filename */

void loadfrom(char *filename)
{
	int i;
	char hb,lb;

	FILE *infile=fopen(filename,"rb");

	for(i=0;i<NR_DATA_WORDS;i++) {
		lb=fgetc(infile);
		hb=fgetc(infile);
		setword(i,hb,lb);
	}

	fclose(infile);
}


int main (int argc, char **argv)
{
	char a,b;

	if(argc==1) {
		fprintf(stderr,"\nUsage:\n");
		fprintf(stderr,"93c66 r pos     	 read from pos\n");
		fprintf(stderr,"93c66 w pos hb lb    write to pos\n");
		fprintf(stderr,"93c66 l filename     load all from filename\n");
		fprintf(stderr,"93c66 s filename     save all to filename\n");
		exit(1);
	}


#ifdef  __GNUC__
        ioperm(parbase,2,1);
#endif

	if(argv[1][0]=='r') {

		getword(atoi(argv[2]),&a,&b);

		fprintf(stderr,"read:  %4d: %2x %2x\n",atoi(argv[2]),a,b);

	}

	if(argv[1][0]=='w') {

		a=atoi(argv[3]);
		b=atoi(argv[4]);
		setword(atoi(argv[2]),a,b);

		fprintf(stderr,"write: %4d: %2x %2x\n",atoi(argv[2]),a,b);

	}

	if(argv[1][0]=='s') {
		fprintf(stderr,"saving to %s\n",argv[2]);
		saveto(argv[2]);
	}

	if(argv[1][0]=='l') {
		fprintf(stderr,"loading from %s\n",argv[2]);
		loadfrom(argv[2]);
	}
	return 0;
}
