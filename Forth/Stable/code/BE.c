/* be.c file-t BMP-be titkosito */
#include <stdio.h>
main(argc,argv) int argc; char  *argv[];
{  FILE *be, *ki;
 int   e=0, a=1, c,i,s,k; float f=0,fs=0;

 if (!(be=fopen(argv[1],"rb"))) {printf("BE?"); exit(1);}
 if (!(ki=fopen(argv[2],"wb"))) {printf("KI?"); exit(1);}

 for(i=0; i<54; i++) { c=fgetc(be); fputc(c,ki); } s=getc(stdin); 
 while((c=fgetc(be))!=EOF) { f++;
   k=c & 0xfe; if((s & a) != 0) k = k | 0x01;
   fputc(k,ki); a+=a;
   if(a>128){ 
     a=1;  
     if(e==0) { s=getc(stdin); fs++; }
     else     { s='\r'; }
     if(s==-1) { e=1;  }  
   }
 }
 fclose(be); fclose(ki); 
 printf("Be/Ki:%7.0f Hely:%7.0f Kod:%7.0f\n",f+54,f/8,fs);
}
