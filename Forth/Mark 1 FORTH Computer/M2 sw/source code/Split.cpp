#include <stdio.h>

void main(int argc, char *argv[])
{
    if (argc != 3) return;

    int OddEven = argv[1][0] & 1;

    FILE *fp = fopen(argv[2], "rb");

    fseek(fp, 4096, SEEK_SET);

    unsigned char s[32];
    int n;

    for (int i=0; n = fread(s, 1, 32, fp); i+=16)
    {
        int c = n/2;
        printf(":%02X%04X00", c, i);
        c += i >> 8;
        c += i & 0xFF;
        for (int j=0; j<n/2; c+=s[j*2+OddEven], j++) printf("%02X", s[j*2+OddEven]);
        printf("%02X\n", (-c) & 0xFF);
    }

    printf(":00000001FF\n");
}
