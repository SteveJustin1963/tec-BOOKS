#include <process.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <minmax.h>


#define EOL ";\n"
#define WSP " \t"


long Addr, Line, Next;

unsigned char ROM[2048];

struct
{
    int Addr, Size;
    char *Label;
}
Ops[256];

int NumOps = 0;



void Abort()
{
    printf("\nABORTING: Error on line %d\n", Line);
    exit(-1);
}


int Mov(const char **SSS, const char **DDD, const char *p, const char *q, char *s)
{
    for (int dst=0; strcmpi(p, DDD[dst]); dst++) if (dst==7) return -1;
    for (int src=0; strcmpi(q, SSS[src]); src++) if (src==7) return -1;

    sprintf(s, "%s, %s", DDD[dst], SSS[src]);

    return (src<<3) + dst;
}



int Mov(char *s)
{
    const char *SrcLo[] = { "w.l", "ip.l", "tos.l", "rs.l", "[w]", "[ip]", "0", "f" };
    const char *DstLo[] = { "w.l", "ip.l", "tos.l", "rs.l", "[w]", "op",   "a", "b" };

    const char *SrcHi[] = { "w.h", "ip.h", "tos.h", "rs.h", "[w]", "[ip]", "0", "f" };
    const char *DstHi[] = { "w.h", "ip.h", "tos.h", "rs.h", "[w]", "op",   "a", "b" };

    const char *Src16[] = { "w", "ip", "tos", "rs", "", "", "0", "" };
    const char *Dst16[] = { "w", "ip", "tos", "rs", "", "", "",  "" };
    
    char *p = strtok(0, WSP ",");
    char *q = strtok(0, WSP EOL);
    if (!p || !q) Abort();

    int op = Mov(SrcLo, DstLo, p, q, s);
    if (op != -1) return op;

    op = Mov(SrcHi, DstHi, p, q, s);
    if (op != -1) return op + 0x40;

    op = Mov(Src16, Dst16, p, q, s);
    if (op == -1) Abort();

    return op + 0x40 + (op<<8);
}


int IncDec(char *s)
{
    static char *RRR[] = { "w", "ip", "psp", "rsp" };

    char *p = strtok(0, WSP EOL);
    if (!p) Abort();

    for (int reg=0; strcmpi(p, RRR[reg]); reg++) if (reg==3) Abort();

    strcpy(s, RRR[reg]);
    return reg;
}


int Nibble(char *s)
{
    char *p = strtok(0, WSP EOL);
    if (!p) Abort();

    strcpy(s, p);
    return atoi(p) & 15;
}


int Jump(char *s)
{
    char *p = strtok(0, WSP EOL);
    if (!p) Abort();

    strcpy(s, p);
    return strcmpi(p, "NEXT") ? atoi(p) & 15 : Next;
}


int Alu(char *s)
{
    char *p = strtok(0, WSP EOL);
    if (!p) Abort();

    struct
    {
        int op; char *txt;
    }
    Func[] =
    {
        {0, "ADD"}, {1, "ADC"}, {2, "SUB"}, {3, "SBB"},
        {4, "ASL"}, {5, "ROL"},
        {8, "A"}, {9, "B"},
        {10, "AND"}, {11, "OR"}, {12, "NOT"}, {13, "XOR"}, {14, "A=B"},
//      {8, "0<"}, {12, "0="},
        {-1, 0}
    };

    for(int i=0; ; i++)
        if (Func[i].op<0) Abort(); else
        if (strcmpi(p, Func[i].txt)==0) break;

    strcpy(s, p);
    return Func[i].op;
}


void main(int argc, char *argv[])
{
    if (argc != 2) Abort();

    FILE *fp = fopen(argv[1], "r");
    if (!fp) Abort();

    memset(ROM, 0xFF, sizeof ROM);
    
    char s[132+1];

    for (Line=1; fgets(s, sizeof s, fp); Line++)
    {
        char *szLabel = "", szOperands[80] = {0};
        int op;

        char *p = strtok(s, WSP "\n");
        if (!p || *p==';') continue;

        if (p[strlen(p)-1]==':')
        {
            szLabel = p;
            p = strtok(0, WSP EOL);
            fputc('\n', stderr);

            if (strcmpi(szLabel, "NEXT:"))
            {
                if (NumOps) Ops[NumOps-1].Size = Addr - Ops[NumOps-1].Addr;
                while(Addr & 15) Addr++;
                Ops[NumOps].Label = strdup(szLabel);
                Ops[NumOps].Label[strlen(Ops[NumOps].Label)-1]=0;
                Ops[NumOps].Addr = Addr;
                NumOps++;
            }
            else
                Next = Addr;
        }

        fprintf(stderr, "%04X ", Addr);

        if  (!strcmpi(p, "mov"))
        {
            op = Mov(szOperands);

            if (op >> 8)
            {
                fprintf(stderr, "%04X", op);

                ROM[Addr++] = op >> 8;
                op &= 0xFF;
            }
            else
                fprintf(stderr, "%02X  ", op);
        }
        else
        {
            if      (!strcmpi(p, "dec"))    op = 0x80 + IncDec(szOperands);
            else if (!strcmpi(p, "dis"))    op = 0x84;
            else if (!strcmpi(p, "eni"))    op = 0x8C;
            else if (!strcmpi(p, "inc"))    op = 0x88 + IncDec(szOperands);
            else if (!strcmpi(p, "jmp"))    op = 0x90 + Jump(szOperands);
            else if (!strcmpi(p, "nxt"))    op = 0x90 + Next;
            else if (!strcmpi(p, "alu"))    op = 0xA0 + Alu(szOperands);
            else if (!strcmpi(p, "xop"))    op = 0xB0;
            else if (!strcmpi(p, "b??"))    op = 0xC0 + Nibble(szOperands);
            else if (!strcmpi(p, "bcs"))    op = 0xD0 + Nibble(szOperands);
            else if (!strcmpi(p, "bne"))    op = 0xE0 + Nibble(szOperands);
            else if (!strcmpi(p, "bis"))    op = 0xF0 + Nibble(szOperands);
            else Abort();

            fprintf(stderr, "%02X  ", op);
        }

        fprintf(stderr, " %10s %s %s\n", szLabel, p, szOperands);
        ROM[Addr++] = op;
    }

    fputc('\n', stderr);

    Ops[NumOps-1].Size = Addr - Ops[NumOps-1].Addr;

    int i;

    for (i=0; i<NumOps; i++)
    {
        printf("OP_%-21sEQU %d\n", Ops[i].Label, Ops[i].Addr/16);
    }

    for (int k=0; k<NumOps; k++)
    {
        Addr = Ops[k].Addr + Ops[k].Size;

        for (i=Ops[k].Addr; i<Addr; i+=16)
        {
            int c = min(16, Addr-i);
            printf(":%02X%04X00", c, i);
            c += i >> 8;
            c += i & 0xFF;
            for (int j=0; j<16 && i+j<Addr; c+=ROM[i+j++]) printf("%02X", ROM[i+j]);
            printf("%02X\n", (-c) & 0xFF);
        }
        
    }

    printf(":00000001FF\n");
}
