#include <stdio.h>
main(argc,argv)
int  argc; char *argv[];
{ 
 FILE     *f1;  int a=1, b,c,i, k=0;

 if (!(f1=fopen(argv[1],"rb"))) {printf("f1?"); exit(1);}

 for(i=0; i<54; i++) { c=fgetc(f1); }

 while((c=fgetc(f1))!=EOF)
 { 
   b=c&1;  if(b) { k = k | a; } 

   a+=a;   if(a>128) { if(k)putc(k,stdout); a=1; k=0; }   
 }
 fclose(f1); 
}
