/* bk.c BMP osszehasonlito */
#include <stdio.h>
main(argc,argv)
int argc; char *argv[];
{ 
 FILE     *be, *ki;
 unsigned c, s;
 float    f=0, fs=0;

 if (!(be=fopen(argv[1],"rb"))) {printf("Be1?"); exit(1);}
 if (!(ki=fopen(argv[2],"rb"))) {printf("Be2?"); exit(1);}

 while((c=fgetc(be))!=EOF)
 { 
    s=fgetc(ki); if(s != c) fs++;
 
    f++;
 }
 fclose(be); fclose(ki); 
 printf("\n=> Be/Ki:%7.0f elteres::%7.0f <=",f,fs);
 printf("%6.1f %c\n",fs/f*100,37);
}
