#include <stdio.h>
#include <minmax.h>
#include <stdlib.h>

void main(int argc, char *argv[])
{
    if (argc != 3) return;

    int i = atoi(argv[1]);

    FILE *fp = fopen(argv[2], "rb");

    fseek(fp, i, SEEK_SET);

    unsigned char s[16];

    for (int n; n = fread(s, 1, 16, fp); i+=16)
    {
        int c = min(16, n);
        printf(":%02X%04X00", c, i);
        c += i >> 8;
        c += i & 0xFF;
        for (int j=0; j<n; c+=s[j++]) printf("%02X", s[j]);
        printf("%02X\n", (-c) & 0xFF);
    }

    printf(":00000001FF\n");
}
