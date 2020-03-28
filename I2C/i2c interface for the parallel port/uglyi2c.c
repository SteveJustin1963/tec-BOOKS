/*
	uglyi2c
	a simple and ugly i2c programming utility
	(c) 29.01.2002 Franz Ackermann faz@obiwan.hvrlab.org


	at the moment of writing this the following types are
	inplemented:

	24xx02
	24xx64
	x24645

	the 24c02 is an i2c eeprom with 2k bits.
	the 24c64 is an i2c eeprom with 64k bits.
	the x24645 is an i2c eeprom with write protection bits

	this utility implements read and write operations to the chips
	on 2 wires connected to data bit 0 (=pin2, sda on i2c) and
	init (=pin16, scl on i2c) of the parallel port.
	a third wire has to go from pin2 to pin12 (PE) of the parallel 
        port, to insure the chip can pull the signal to logical zero.
	one may see this just as connecting the data-out and data-in
	lines of a microwire bus together.

	for testing chips with an osciloscope, it is recommended to
	implement an external trigger at the interesting point via
	the strobe signal.

	as this tool is also intended for in circuit programming,
	additional lines on the chip have to be or are already implemented
        in hardware, like providing power or setting address bits.

	as sda has to be read and written, a bidirectionel port would
	have been required, but the acutal reading is done via PE, so it
        should also work on old hardware, many chips are too weak to pull
        a data line to zero on their own anyway.

	compile using gcc -O -o uglyi2c uglyi2c.c
	dont forget the -O switch, otherwise outb/inb wont be found.

*/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#ifdef __GNUC__

#include <sys/time.h>
#include <sys/io.h>
#define outp(a1, a2)   outb(a2, a1)
#define inp(id)   inb(id)

#endif

#define CHIP_none   	0
#define CHIP_x24645 	1
#define CHIP_24x02 	2
#define CHIP_24x64 	7

unsigned char x24645val=0x2;
unsigned char user_x24645val=0x2;
int parbase=0x378;
int parstatus,parcont;
int chipaddress=0;
int verbosemode=0;
int pos,len;
char filename[8192]="";
char chipname[100];
int chiptype=CHIP_none;
char binbuffer[0xFFFF];
int basetick=0;

/* definitons of parallel port signals */

#define  PAR_SDA_0	0x0
#define  PAR_SDA_1	0x1
#define  PAR_SDA_IN_1   0x20

#define  PAR_SCL_0	0x0
#define  PAR_SCL_1	0x4

/* end of par defs */


/* timing definitions */

unsigned int synctick=10;
unsigned int waitfactor=10;

#define SY synctick 
/* len of clock intervall in port accesses */
#define SYNC_LEN 	((SY*10))
/* when the 0 to 1 switch on scl takes place */
#define SYNC_UP   ((SY*3))
/* when the 1 to 0 switch on scl takes place */
#define SYNC_DOWN   ((SY*8))
/* time for eventual reading */
#define SYNC_MID     ((SY*5))

void speedcheck()
{
	int i,q;
#if defined __GNUC__ && !__WIN32__
	struct timeval  start,stop;
	unsigned char w,v;
        unsigned char indummy=0;
	long diff;
	float f;
	int testlen=100;
	gettimeofday(&start,0);
	//fprintf(stderr,"%d %d\n",start.tv_sec,start.tv_usec);
	for(q=1;q<testlen;q++)
        for (i=0;i<SYNC_LEN;i++) {
                w=0;v=0;
                if((basetick%SYNC_LEN>SYNC_UP) && (basetick%SYNC_LEN<SYNC_DOWN)) v=v|PAR_SCL_1;
                if((basetick%SYNC_LEN<SYNC_MID)) w=0;
                outp(parbase,w);outp(parcont,v);
                basetick++;indummy=inp(parstatus);
        }

	gettimeofday(&stop,0);
	//fprintf(stderr,"%d %d\n",stop.tv_sec,stop.tv_usec);
	diff=(stop.tv_sec-start.tv_sec)*1000000+stop.tv_usec-start.tv_usec;
	f=testlen*1000000/diff;
	fprintf(stderr,"testing speed .. %d usecs elapsed for %d cycles, that is %.0f hz.\n",diff,testlen,f);
#endif
}


void do_nothing()
{
        int i,q;
        unsigned char w,v;
        unsigned char indummy=0;
	for (q=0;q<waitfactor;q++)
	for (i=0;i<SYNC_LEN;i++) {
		w=0;v=0;
                if((basetick%SYNC_LEN>SYNC_UP) && (basetick%SYNC_LEN<SYNC_DOWN)) v=v|PAR_SCL_1;
                //fprintf(stderr,"%d",v);
		if((basetick%SYNC_LEN<SYNC_MID)) w=w | PAR_SDA_1;
                indummy=inp(parstatus);indummy=inp(parstatus);
		basetick++;indummy=inp(parstatus);
        }      
}


void sendstart()
{
        int i;
        unsigned char w,v;
        unsigned char indummy=0;
	for (i=0;i<SYNC_LEN;i++) {
		w=0;v=0;
                if((basetick%SYNC_LEN>SYNC_UP) && (basetick%SYNC_LEN<SYNC_DOWN)) v=v|PAR_SCL_1;
                //fprintf(stderr,"%d",v);
		if((basetick%SYNC_LEN<SYNC_MID)) w=w | PAR_SDA_1;
                outp(parbase,w);outp(parcont,v);
		basetick++;indummy=inp(parstatus);
        }      
}


void sendstop()
{
        int i;
        unsigned char w,v;
        unsigned char indummy=0;
        for (i=0;i<SYNC_LEN;i++) {
		w=0;v=0;
		if((basetick%SYNC_LEN>SYNC_UP) && (basetick%SYNC_LEN<SYNC_DOWN)) v=v|PAR_SCL_1;
                if((basetick%SYNC_LEN>SYNC_MID)) w=w | PAR_SDA_1;
                outp(parbase,w);outp(parcont,v);
		basetick++;indummy=inp(parstatus);
        }  
}

void waitack(int pos)
{
        int i;
        unsigned char w,v;
        unsigned char indummy=0;
	unsigned char pulldown;
        for (i=0;i<SYNC_LEN;i++) {
                w=0;v=0;
		if((basetick%SYNC_LEN>SYNC_UP) && (basetick%SYNC_LEN<SYNC_DOWN)) v=v|PAR_SCL_1;

		if(basetick%SYNC_LEN==0) { w=w | PAR_SDA_1; outp(parbase,w); }
                
		if((basetick%SYNC_LEN==SYNC_MID)) pulldown=((inp(parstatus) & PAR_SDA_IN_1) == PAR_SDA_IN_1);

                outp(parcont,v);indummy=inp(parstatus);indummy=inp(parstatus);
		basetick++;
        } 
	//fprintf(stderr,"%d",pulldown);
	if (pulldown!=0) {
		fprintf (stderr,"acknowledge failed at position %d\n",pos);
		exit(1);
	}
}

void sendoutbit(unsigned char value)
{
	int i;
	unsigned char w,v;
	unsigned char indummy=0;
	for (i=0;i<SYNC_LEN;i++) {
		w=0;v=0;
		if((basetick%SYNC_LEN>SYNC_UP) && (basetick%SYNC_LEN<SYNC_DOWN)) v=v|PAR_SCL_1;
		w=w|value;
		outp(parbase,w);outp(parcont,v);
		basetick++;indummy=inp(parstatus);
	}	
}

unsigned char receivebit()
{
        int i;
        unsigned char w,v;
        unsigned char indummy=0;
        for (i=0;i<SYNC_LEN;i++) {
                v=0;
		if((basetick%SYNC_LEN>SYNC_UP) && (basetick%SYNC_LEN<SYNC_DOWN)) v=v|PAR_SCL_1;

		if((basetick%SYNC_LEN==SYNC_MID)) w=(inp(parstatus) & PAR_SDA_IN_1) == PAR_SDA_IN_1;

		outp(parcont,v);basetick++;indummy=inp(parstatus);indummy=inp(parstatus);
        }
	
	return(w); 
}

void sendack()
{
	sendoutbit(0);
}

/* functions for each chips protocol */

/* 24c02 */

void writeblock_24c02()
{
	unsigned int i;
        int inext,ipos,istep=1;

        inext=len/10;

        for (i=pos;i<pos+len;i++)
        {
                ipos=(i-pos);
                if((ipos>inext) && (len>10)) {
                        fprintf(stderr,"..%2d%%",istep*10);
                        istep++;inext=len*istep/10;
                }

if (verbosemode) fprintf(stderr,"asending start + type id + chip address + write\n");

                sendstart();

                sendoutbit(1);
                sendoutbit(0);
                sendoutbit(1);
                sendoutbit(0);
                sendoutbit((chipaddress & 0x04)==0x04);
                sendoutbit((chipaddress & 0x02)==0x02);
                sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit(0);
	
		waitack(i);
	
if (verbosemode) fprintf(stderr,"sending byte address low\n");

		sendoutbit((i>>7) & 0x1);
		sendoutbit((i>>6) & 0x1);
		sendoutbit((i>>5) & 0x1);
		sendoutbit((i>>4) & 0x1);
		sendoutbit((i>>3) & 0x1);
		sendoutbit((i>>2) & 0x1);
		sendoutbit((i>>1) & 0x1);
		sendoutbit((i>>0) & 0x1);

		waitack(i);

if (verbosemode) fprintf(stderr,"sending data\n");

		sendoutbit((binbuffer[i]>>7) & 0x1);
		sendoutbit((binbuffer[i]>>6) & 0x1);
		sendoutbit((binbuffer[i]>>5) & 0x1);
		sendoutbit((binbuffer[i]>>4) & 0x1);
		sendoutbit((binbuffer[i]>>3) & 0x1);
		sendoutbit((binbuffer[i]>>2) & 0x1);
		sendoutbit((binbuffer[i]>>1) & 0x1);
		sendoutbit((binbuffer[i]>>0) & 0x1);

		waitack(i);

		sendstop();

		do_nothing();		

	}
	fprintf(stderr,"..done\n");	
}


void readblock_24c02()
{
        unsigned int i;
	int inext,ipos,istep=1;

	inext=len/10;

        for (i=pos;i<pos+len;i++)
        {
		ipos=(i-pos);
		if((ipos>inext) && (len>10)) {
			fprintf(stderr,"..%2d%%",istep*10);
			istep++;inext=len*istep/10;
		}


if (verbosemode) fprintf(stderr,"sending start + type id + chip address + dummy write\n");
                sendstart();

                sendoutbit(1);
                sendoutbit(0);
                sendoutbit(1);
                sendoutbit(0);
                sendoutbit((chipaddress & 0x04)==0x04);
                sendoutbit((chipaddress & 0x02)==0x02);
                sendoutbit((chipaddress & 0x01)==0x01);
                sendoutbit(0);

                waitack(i);
		
if (verbosemode) fprintf(stderr,"sending byte address low\n");

                sendoutbit((i>>7) & 0x1);
                sendoutbit((i>>6) & 0x1);
                sendoutbit((i>>5) & 0x1);
                sendoutbit((i>>4) & 0x1);
                sendoutbit((i>>3) & 0x1);
                sendoutbit((i>>2) & 0x1);
                sendoutbit((i>>1) & 0x1);
                sendoutbit((i>>0) & 0x1);

                waitack(i);
		
if (verbosemode) fprintf(stderr,"sending start again + chipaddress  + read\n");

		sendstart();

                sendoutbit(1);
                sendoutbit(0);
                sendoutbit(1);
                sendoutbit(0);
                sendoutbit((chipaddress & 0x04)==0x04);
                sendoutbit((chipaddress & 0x02)==0x02);
                sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit(1);

		waitack(i);	

if (verbosemode) fprintf(stderr,"now reading ..");
	
		binbuffer[i]=0;

		binbuffer[i]=binbuffer[i] | (receivebit() << 7);
		binbuffer[i]=binbuffer[i] | (receivebit() << 6);
		binbuffer[i]=binbuffer[i] | (receivebit() << 5);
		binbuffer[i]=binbuffer[i] | (receivebit() << 4);
		binbuffer[i]=binbuffer[i] | (receivebit() << 3);
		binbuffer[i]=binbuffer[i] | (receivebit() << 2);
		binbuffer[i]=binbuffer[i] | (receivebit() << 1);
		binbuffer[i]=binbuffer[i] | (receivebit() << 0);

if (verbosemode) fprintf(stderr,"%x\n",binbuffer[i]);
                
		sendstop();

        }
	fprintf(stderr,"..done\n");
}

/* 24c64 */

void writeblock_24c64()
{
	unsigned int i;
        int inext,ipos,istep=1;

        inext=len/10;

        for (i=pos;i<pos+len;i++)
        {
                ipos=(i-pos);
                if((ipos>inext) && (len>10)) {
                        fprintf(stderr,"..%2d%%",istep*10);
                        istep++;inext=len*istep/10;
                }

if (verbosemode) fprintf(stderr,"sending start + type id + chip address + write\n");

                sendstart();

                sendoutbit(1);
                sendoutbit(0);
                sendoutbit(1);
                sendoutbit(0);
                sendoutbit((chipaddress & 0x04)==0x04);
                sendoutbit((chipaddress & 0x02)==0x02);
                sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit(0);
	
		waitack(i);

if (verbosemode) fprintf(stderr,"sending upper address bits\n");

                sendoutbit((i>>15) & 0x1); // chip doesnt care
                sendoutbit((i>>14) & 0x1); // chip doesnt care
                sendoutbit((i>>13) & 0x1); // chip doesnt care
                sendoutbit((i>>12) & 0x1);
                sendoutbit((i>>11) & 0x1);
                sendoutbit((i>>10) & 0x1);
                sendoutbit((i>>9) & 0x1);
                sendoutbit((i>>8) & 0x1);

                waitack(i);
	
if (verbosemode) fprintf(stderr,"sending byte address low\n");

		sendoutbit((i>>7) & 0x1);
		sendoutbit((i>>6) & 0x1);
		sendoutbit((i>>5) & 0x1);
		sendoutbit((i>>4) & 0x1);
		sendoutbit((i>>3) & 0x1);
		sendoutbit((i>>2) & 0x1);
		sendoutbit((i>>1) & 0x1);
		sendoutbit((i>>0) & 0x1);

		waitack(i);

if (verbosemode) fprintf(stderr,"sending data\n");

		sendoutbit((binbuffer[i]>>7) & 0x1);
		sendoutbit((binbuffer[i]>>6) & 0x1);
		sendoutbit((binbuffer[i]>>5) & 0x1);
		sendoutbit((binbuffer[i]>>4) & 0x1);
		sendoutbit((binbuffer[i]>>3) & 0x1);
		sendoutbit((binbuffer[i]>>2) & 0x1);
		sendoutbit((binbuffer[i]>>1) & 0x1);
		sendoutbit((binbuffer[i]>>0) & 0x1);

		waitack(i);

		sendstop();

		do_nothing();

	}
fprintf(stderr,"..done\n");	
}



void readblock_24c64()
{
        unsigned int i;
	int inext,ipos,istep=1;

	inext=len/10;

        for (i=pos;i<pos+len;i++)
        {
		ipos=(i-pos);
		if((ipos>inext) && (len>10)) {
			fprintf(stderr,"..%2d%%",istep*10);
			istep++;inext=len*istep/10;
		}


if (verbosemode) fprintf(stderr,"sending start + type id + chip address + dummy write\n");
                sendstart();

		sendoutbit(1);
		sendoutbit(0);
		sendoutbit(1);
		sendoutbit(0);
                sendoutbit((chipaddress & 0x04)==0x04);
                sendoutbit((chipaddress & 0x02)==0x02);
                sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit(0);

		waitack(i);

if (verbosemode) fprintf(stderr,"sending upper address bits\n");

                sendoutbit((i>>15) & 0x1); // chip doesnt care
                sendoutbit((i>>14) & 0x1); // chip doesnt care
                sendoutbit((i>>13) & 0x1); // chip doesnt care
                sendoutbit((i>>12) & 0x1);
                sendoutbit((i>>11) & 0x1);
                sendoutbit((i>>10) & 0x1);
                sendoutbit((i>>9) & 0x1);
                sendoutbit((i>>8) & 0x1);

                waitack(i);
		
if (verbosemode) fprintf(stderr,"sending byte address low\n");

                sendoutbit((i>>7) & 0x1);
                sendoutbit((i>>6) & 0x1);
                sendoutbit((i>>5) & 0x1);
                sendoutbit((i>>4) & 0x1);
                sendoutbit((i>>3) & 0x1);
                sendoutbit((i>>2) & 0x1);
                sendoutbit((i>>1) & 0x1);
                sendoutbit((i>>0) & 0x1);

                waitack(i);
		
if (verbosemode) fprintf(stderr,"sending start again + chipaddress  + read\n");

		sendstart();

		sendoutbit(1);
		sendoutbit(0);
		sendoutbit(1);
		sendoutbit(0);
                sendoutbit((chipaddress & 0x04)==0x04);
                sendoutbit((chipaddress & 0x02)==0x02);
                sendoutbit((chipaddress & 0x01)==0x01);

		sendoutbit(1);

		waitack(i);	

if (verbosemode) fprintf(stderr,"now reading ..");
	
		binbuffer[i]=0;

		binbuffer[i]=binbuffer[i] | (receivebit() << 7);
		binbuffer[i]=binbuffer[i] | (receivebit() << 6);
		binbuffer[i]=binbuffer[i] | (receivebit() << 5);
		binbuffer[i]=binbuffer[i] | (receivebit() << 4);
		binbuffer[i]=binbuffer[i] | (receivebit() << 3);
		binbuffer[i]=binbuffer[i] | (receivebit() << 2);
		binbuffer[i]=binbuffer[i] | (receivebit() << 1);
		binbuffer[i]=binbuffer[i] | (receivebit() << 0);

if (verbosemode) fprintf(stderr,"%x\n",binbuffer[i]);
                
		sendstop();

        }
	fprintf(stderr,"..done\n");
}


/* x24645 */


void unlock_x24645()
{
	unsigned int i,q;

	i=0x1fff;	/* address of lock byte */
	synctick=synctick*waitfactor;

if (verbosemode) fprintf(stderr,"unlocking at %x\n",i);
if (verbosemode) fprintf(stderr,"sending start + type id + chip address high + write for 0x1fff\n");

                sendstart();
                sendoutbit((chipaddress & 0x02)==0x02);
		sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit((i>>12) & 0x1);
		sendoutbit((i>>11) & 0x1);
		sendoutbit((i>>10) & 0x1);
		sendoutbit((i>>9) & 0x1);
		sendoutbit((i>>8) & 0x1);
		sendoutbit(0);
	
		waitack(i);
if (verbosemode) fprintf(stderr,"sending byte address low\n");

		sendoutbit((i>>7) & 0x1);
		sendoutbit((i>>6) & 0x1);
		sendoutbit((i>>5) & 0x1);
		sendoutbit((i>>4) & 0x1);
		sendoutbit((i>>3) & 0x1);
		sendoutbit((i>>2) & 0x1);
		sendoutbit((i>>1) & 0x1);
		sendoutbit((i>>0) & 0x1);
		waitack(i);

if (verbosemode) fprintf(stderr,"sending data: 0000 0010\n");
		synctick=synctick*100;
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(1);
		sendoutbit(0);

		waitack(i);

if (verbosemode) fprintf(stderr,"sending start + type id + chip address high + write for 0x1fff, 2nd time\n");

                sendstart();

                sendoutbit((chipaddress & 0x02)==0x02);
		sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit((i>>12) & 0x1);
		sendoutbit((i>>11) & 0x1);
		sendoutbit((i>>10) & 0x1);
		sendoutbit((i>>9) & 0x1);
		sendoutbit((i>>8) & 0x1);
		sendoutbit(0);
	
		waitack(i);
if (verbosemode) fprintf(stderr,"sending byte address low\n");

		sendoutbit((i>>7) & 0x1);
		sendoutbit((i>>6) & 0x1);
		sendoutbit((i>>5) & 0x1);
		sendoutbit((i>>4) & 0x1);
		sendoutbit((i>>3) & 0x1);
		sendoutbit((i>>2) & 0x1);
		sendoutbit((i>>1) & 0x1);
		sendoutbit((i>>0) & 0x1);
		waitack(i);

if (verbosemode) fprintf(stderr,"sending data: 0000 0110\n");
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(0);
		sendoutbit(1);
		sendoutbit(1);
		sendoutbit(0);

		waitack(i);

if (verbosemode) fprintf(stderr,"sending start + type id + chip address high + write for 0x1fff\n");
	
                sendstart();

                sendoutbit((chipaddress & 0x02)==0x02);
		sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit((i>>12) & 0x1);
		sendoutbit((i>>11) & 0x1);
		sendoutbit((i>>10) & 0x1);
		sendoutbit((i>>9) & 0x1);
		sendoutbit((i>>8) & 0x1);
		sendoutbit(0);
	
		waitack(i);
if (verbosemode) fprintf(stderr,"sending byte address low\n");

		sendoutbit((i>>7) & 0x1);
		sendoutbit((i>>6) & 0x1);
		sendoutbit((i>>5) & 0x1);
		sendoutbit((i>>4) & 0x1);
		sendoutbit((i>>3) & 0x1);
		sendoutbit((i>>2) & 0x1);
		sendoutbit((i>>1) & 0x1);
		sendoutbit((i>>0) & 0x1);
		waitack(i);

if (verbosemode) fprintf(stderr,"sending data: %x =",x24645val);
		
		for(q=7;q>=0;q--) {
if (verbosemode) fprintf(stderr,"%d",((x24645val>>q) & 0x1)==0x1);
		}
if (verbosemode) fprintf(stderr,"\n");

		sendoutbit((x24645val>>7) & 0x1);
		sendoutbit((x24645val>>6) & 0x1);
		sendoutbit((x24645val>>5) & 0x1);
		sendoutbit((x24645val>>4) & 0x1);
		sendoutbit((x24645val>>3) & 0x1);
		sendoutbit((x24645val>>2) & 0x1);
		sendoutbit((x24645val>>1) & 0x1);
		sendoutbit((x24645val>>0) & 0x1);


		waitack(i);	
	
if (verbosemode) fprintf(stderr,"sending stop %d\n",synctick);
		sendstop();

		do_nothing();

		synctick=synctick/waitfactor;

}

void writeblock_x24645()
{
	unsigned int i;
        int inext,ipos,istep=1;

        inext=len/10;

	unlock_x24645();

        for (i=pos;i<pos+len;i++)
        {
                ipos=(i-pos);
                if((ipos>inext) && (len>100)) {
                        fprintf(stderr,"..%2d%%",istep*10);
                        istep++;inext=len*istep/10;
                }

if (verbosemode) fprintf(stderr,"sending start + type id + chip address high + write\n");

                sendstart();

                sendoutbit((chipaddress & 0x02)==0x02);
                sendoutbit((chipaddress & 0x01)==0x01);
		sendoutbit((i>>12) & 0x1);
		sendoutbit((i>>11) & 0x1);
		sendoutbit((i>>10) & 0x1);
		sendoutbit((i>>9) & 0x1);
		sendoutbit((i>>8) & 0x1);

		sendoutbit(0);
	
		waitack(i);
	
if (verbosemode) fprintf(stderr,"sending byte address low\n");

		sendoutbit((i>>7) & 0x1);
		sendoutbit((i>>6) & 0x1);
		sendoutbit((i>>5) & 0x1);
		sendoutbit((i>>4) & 0x1);
		sendoutbit((i>>3) & 0x1);
		sendoutbit((i>>2) & 0x1);
		sendoutbit((i>>1) & 0x1);
		sendoutbit((i>>0) & 0x1);

		waitack(i);

if (verbosemode) fprintf(stderr,"sending data: %d\n",binbuffer[i]);

		sendoutbit((binbuffer[i]>>7) & 0x1);
		sendoutbit((binbuffer[i]>>6) & 0x1);
		sendoutbit((binbuffer[i]>>5) & 0x1);
		sendoutbit((binbuffer[i]>>4) & 0x1);
		sendoutbit((binbuffer[i]>>3) & 0x1);
		sendoutbit((binbuffer[i]>>2) & 0x1);
		sendoutbit((binbuffer[i]>>1) & 0x1);
		sendoutbit((binbuffer[i]>>0) & 0x1);

		waitack(i);

		sendstop();

		do_nothing();

	}
	fprintf(stderr,"..done\n");			

}

void readblock_x24645()
{
        unsigned int i;
	int inext,ipos,istep=1;

	inext=len/10;

	i=pos;
if (verbosemode) fprintf(stderr,"sending start + type id + chip address + dummy write\n");
        sendstart();

        sendoutbit((chipaddress & 0x02)==0x02);
        sendoutbit((chipaddress & 0x01)==0x01);
        sendoutbit((i>>12) & 0x1);
        sendoutbit((i>>11) & 0x1);
        sendoutbit((i>>10) & 0x1);
        sendoutbit((i>>9) & 0x1);
        sendoutbit((i>>8) & 0x1);

	sendoutbit(0);

        waitack(i);
		
if (verbosemode) fprintf(stderr,"sending byte address low\n");

        sendoutbit((i>>7) & 0x1);
        sendoutbit((i>>6) & 0x1);
        sendoutbit((i>>5) & 0x1);
        sendoutbit((i>>4) & 0x1);
        sendoutbit((i>>3) & 0x1);
        sendoutbit((i>>2) & 0x1);
        sendoutbit((i>>1) & 0x1);
        sendoutbit((i>>0) & 0x1);

        waitack(i);
		
if (verbosemode) fprintf(stderr,"sending start again + chipaddress  + read\n");

	sendstart();

        sendoutbit((chipaddress & 0x02)==0x02);
        sendoutbit((chipaddress & 0x01)==0x01);
        sendoutbit((i>>12) & 0x1);
        sendoutbit((i>>11) & 0x1);
        sendoutbit((i>>10) & 0x1);
        sendoutbit((i>>9) & 0x1);
        sendoutbit((i>>8) & 0x1);

	sendoutbit(1);

        waitack(i);	


        for (i=pos;i<pos+len;i++)
        {
		ipos=(i-pos);
		if((ipos>inext) && (len>10)) {
			fprintf(stderr,"..%2d%%",istep*10);
			istep++;inext=len*istep/10;
		}

if (verbosemode) fprintf(stderr,"reading ");	

		binbuffer[i]=0;

		binbuffer[i]=binbuffer[i] | (receivebit() << 7);
		binbuffer[i]=binbuffer[i] | (receivebit() << 6);
		binbuffer[i]=binbuffer[i] | (receivebit() << 5);
		binbuffer[i]=binbuffer[i] | (receivebit() << 4);
		binbuffer[i]=binbuffer[i] | (receivebit() << 3);
		binbuffer[i]=binbuffer[i] | (receivebit() << 2);
		binbuffer[i]=binbuffer[i] | (receivebit() << 1);
		binbuffer[i]=binbuffer[i] | (receivebit() << 0);

if (verbosemode) fprintf(stderr,".. %x\n",binbuffer[i]);
	
		sendack();

        }

	sendstop();	

	fprintf(stderr,"..done\n");
}


void printusage()
{
	fprintf(stderr,"uglyi2c		(c) 2003 Franz Ackermann faz@obiwan.hvrlab.org\n");
	fprintf(stderr,"Usage:\n");
	fprintf(stderr,"uglyi2c -r pos,len,file    read len bytes from pos to file\n");
	fprintf(stderr,"        -w pos,len,file    write len from file to pos\n");
	fprintf(stderr,"        -i ioport          parallel base ioport in hex, default %x\n",parbase);
	fprintf(stderr,"        -a chipaddress     i2c chip adress, default 0\n");
	fprintf(stderr,"        -s speed,factor    speed in io-ticks, default %d, 1=fastest\n",synctick);
	fprintf(stderr,"                           factor is clockticks after write, default: %d\n",waitfactor);
	fprintf(stderr,"        -v     	           be verbose\n");
	fprintf(stderr,"        -?                 this message\n");
	fprintf(stderr,"        -x value           on x24645, write this HEX value to wp register\n");
	fprintf(stderr,"        -t type            i2c chip type: 24x02,24x64,x24645\n");
	fprintf(stderr,"\n");
	exit(1);
}


int main (int argc, char **argv)
{
	FILE *f;
	int reading=-1;

	int c;
	extern int optind;
	extern char *optarg;

	while ((c = getopt(argc, argv, "vi:r:w:?a:t:s:x:")) != EOF)
		switch (c) {
			case 'v': verbosemode=1; break;
			case 'a':
				if (!sscanf(optarg,"%d",&chipaddress)) printusage();
				break;
			case 'x':
				if (!sscanf(optarg,"%x",&user_x24645val)) printusage();
				break;

			case 'i':
				if (!sscanf(optarg,"%x",&parbase)) printusage();
				fprintf(stderr,"using parallel address: %x\n",parbase);
				break;
			case 'w':
				if (reading!=-1) {
					fprintf(stderr,"load and save dont mix too well.\n");
					printusage();
				}
				reading=0;
				if (!sscanf(optarg,"%d,%d,%s",&pos,&len,&filename)) printusage();
				fprintf(stderr,"writing %d bytes to %x, from file %s to eeprom\n",len,pos,filename);
				break;
			case 'r':
				if (reading!=-1) {
					fprintf(stderr,"load and save dont mix too well.\n");
					printusage();
				}
				reading=1;
				if (!sscanf(optarg,"%d,%d,%s",&pos,&len,&filename)) printusage();
				fprintf(stderr,"reading %d bytes from %x in eeprom to file %s\n",len,pos,filename);
				break;
			case '?':
				printusage();
				break;
			case 's':
                                if (!sscanf(optarg,"%d,%d",&synctick,&waitfactor)) printusage();
                                fprintf(stderr,"using %d speed throtling factor, wait factor %d\n",synctick,waitfactor);
                                break;
			case 't':
                                if (!sscanf(optarg,"%s",&chipname)) printusage();
				if (0==strcmp(chipname,"24x02")) chiptype=CHIP_24x02;
				if (0==strcmp(chipname,"24x64")) chiptype=CHIP_24x64;
				if (0==strcmp(chipname,"x24645")) chiptype=CHIP_x24645;
                                break;
			default:
				break;
	}


	parcont=parbase+2;
	parstatus=parbase+1;

#ifdef  __GNUC__
	ioperm(parbase,3,1);
#endif

	if (reading==-1) {
		fprintf(stderr,"nothing to do.\n");
		printusage();
	}

	if(chiptype==CHIP_none) {
		fprintf(stderr,"please specify supported chipype!\n");
		printusage();
	}

	speedcheck();

	if (reading==1) {
		if(chiptype==CHIP_24x02) readblock_24c02();
		if(chiptype==CHIP_24x64) readblock_24c64();
		if(chiptype==CHIP_x24645) readblock_x24645();
		f=fopen(filename,"wb");
                fwrite(&binbuffer[pos],1,len,f);
                fclose(f);
	}


	if (reading==0) {
		f=fopen(filename,"rb");
		fread(&binbuffer[pos],1,len,f);
		fclose(f);
		if(chiptype==CHIP_24x02) writeblock_24c02();
		if(chiptype==CHIP_24x64) writeblock_24c64();
		if(chiptype==CHIP_x24645) writeblock_x24645();
	}

	if (user_x24645val!=x24645val) {
		x24645val=user_x24645val;
		unlock_x24645();
	}	

	return (0);
}
