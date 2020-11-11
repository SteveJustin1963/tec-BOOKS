/* (c) 2017, Andreas Klimas, klimas@w3group.de
 *
 * Public Domain for educational purpose
 */

#include <stdio.h>
#include <setjmp.h>
#include <stdlib.h>

typedef struct xt_t {
	struct xt_t *next;
	void (*prim)(void);
	char *name;
	int data;
	int ip;
} xt_t;
typedef union cell_t { // data stack type
	long long ival;
	void *ptr;
	double fval;
} cell_t;
#define MAX_CODE_SIZE 65536
#define MAX_STACK_DEPTH 256
xt_t   *dictionary;
xt_t   *code_base[MAX_CODE_SIZE];
int     here=0, ip=0;
int     rp_base[MAX_STACK_DEPTH];
int     rp=-1;
cell_t  sp_base[MAX_STACK_DEPTH];
int     sp=-1;

// Precompiled words
static xt_t *xt_halt, *xt_exit, *xt_docol, *xt_lit, *xt_type;
static xt_t *xt_sub, *xt_while, *xt_drop;

xt_t *W; // current executed word
jmp_buf vm_halt;

static void f_halt(void) {longjmp(vm_halt, 1);}

// error handling (stack over- or underflow) removed */
static void rp_push(int i) {rp_base[++rp]=i;}
static int  rp_pop(void) { return rp_base[rp--]; }
static void sp_push(cell_t i) {sp_base[++sp]=i;}
static cell_t  sp_pop(void) { return sp_base[sp--]; }
static void f_exit(void) {ip=rp_pop();} // return from subroutine
static void f_docol(void) { // enter a subroutine (high level word)
	rp_push(ip); // save current instruction pointer
	ip=W->data;
}
static void vm(void) {
	if(setjmp(vm_halt)) return; // VM halt primitive called

	for(;;) {
		W=code_base[ip++];
		// printf("vm:%s\n", W->name);
		(W->prim)();
	}
}

static xt_t *add_word(char *name, void (*prim)(void)) {
	xt_t *w=calloc(1, sizeof(xt_t));
	w->next=dictionary;
	dictionary=w;
	w->prim=prim;
	w->name=name;
	w->data=here;
	return w;
}
static void f_lit(void) {
	cell_t i;
	i.ptr=code_base[ip++];
	sp_push(i);
}
static void f_type(void) {fputs(sp_pop().ptr, stdout); }
static void f_sub(void) {
	int v=sp_pop().ival;
	sp_base[sp].ival-=v;
}
static void f_while(void) { 
	xt_t *xt=code_base[ip++];
	if(sp_base[sp].ival) ip=(long long)xt;
}
static void f_drop(void) {sp_pop();}
static void build_dictionary(void) {
	xt_halt=add_word("halt", f_halt); // halt virtual engine
	xt_exit=add_word("exit", f_exit); // return from word
	xt_docol=add_word("docol", f_docol); // enter high level word
	xt_lit=add_word("lit", f_lit); // literal
	xt_type=add_word("type", f_type); // print string on stdout
	xt_sub=add_word("-", f_sub); // subtract operation (top of stack
	                             // from next of stack, leave result on
										  // top of stack
										  // ( a b -- a-b)  ( stackInput -- stackOutput)
	xt_while=add_word("(while)", f_while); // loop until top of stack is 0
	xt_drop=add_word("drop", f_drop); // drop top of stack
}
int main() {
	build_dictionary();

	// Define high level word  hello
	xt_t *hello=add_word("bar", f_docol);
	code_base[here++]=xt_lit; // push Hello World on stack
	code_base[here++]=(void*)"Hello World\n";
	code_base[here++]=xt_type; // print Hello World
	code_base[here++]=xt_exit; // return from subroutine

	// Define high level word  foo
	xt_t *foo=add_word("foo", f_docol);
	code_base[here++]=xt_lit; // push down counter on stack
	code_base[here++]=(void*)10; // 10 times
	long long begin=here;           // this is our begin loop address
	code_base[here++]=hello;    // print hello world
	code_base[here++]=xt_lit; // push decrement item
	code_base[here++]=(void*)1;
	code_base[here++]=xt_sub  ;// decrement by one
	code_base[here++]=xt_while;// repeat until top of stack becomes 0
	code_base[here++]=(void*)begin;
	code_base[here++]=xt_drop; // remove down counter
	code_base[here++]=xt_halt; // FINISHED

	ip=foo->data; // start of foo
	vm();
	return 0;
}
