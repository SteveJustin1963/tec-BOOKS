/* Forth interpreter only - in C
 * (c) 2017 Andreas Klimas, klimas@w3group.de
 *
 * This source is public domain
 *
 * We need a datastack and a dictionary, added string handling
 */

#include <stdio.h>
#include <stdlib.h> // exit
#include <string.h> // strcmp
#include <ctype.h> // isspace

typedef struct xt_t { // Execution Token
	struct xt_t *next;
	char *name;
	void (*prim)(void);
} xt_t;
typedef long long cell_t;
static xt_t *dictionary; 
static xt_t *current_xt; // current xt
#define DATA_STACK_SIZE 32
static cell_t sp_base[DATA_STACK_SIZE], *sp_end=sp_base+DATA_STACK_SIZE;
static cell_t *sp=sp_base-1;

static xt_t *find(char *w) { // find word
	xt_t *xt;
	for(xt=dictionary;xt;xt=xt->next) if(!strcmp(xt->name, w)) return xt;

	return 0; // not found
}

static void ok(void) { // print data stack, than ok>
	cell_t *i;
	for(i=sp_base;i<=sp;i++) printf("%lld ", *i);
	printf("ok> ");
}
static int next_char(void) {
	static int last_char;
	if(last_char=='\n') ok(); // ok> prompt
	last_char=fgetc(stdin);
	return last_char==EOF?0:last_char;
}
static int skip_space(void) {
	int ch;
	while((ch=next_char()) && isspace(ch));
	return ch;
}
static char *word(void) { // symbol might have maximal 256 bytes
	static char buffer[256], *end=buffer+sizeof(buffer)-1;
	char *p=buffer, ch;
	if(!(ch=skip_space())) return 0; // no more input
	*p++=ch;
	if(ch=='"') { // +course02: string handling
		while(p<end && (ch=next_char()) && ch!='"') *p++=ch;
	} else {
		while(p<end && (ch=next_char()) && !isspace(ch)) *p++=ch;
	}
	*p=0; // zero terminated string
	return buffer;
}
static void terminate(char *msg) {
	fprintf(stderr, "terminated: %s\n", msg);
	exit(1);
}
static void sp_push(cell_t value) {
	if(sp==sp_end) terminate("Data stack overflow");
	*++sp=value;
}
static cell_t sp_pop(void) {
	if(sp<sp_base) terminate("Data stack underrun");
	return *sp--;
}

static void f_mul(void) {
	int v1=sp_pop();
	*sp*=v1;
}
static void f_add(void) {
	int v1=sp_pop();
	*sp+=v1;
}
static void f_hello_world(void) {
	printf("Hello World\n");
}
static void add_word(char *name, void (*prim)(void)) {
	xt_t *xt=calloc(1, sizeof(xt_t));
	xt->next=dictionary;
	dictionary=xt;
	xt->name=strdup(name);
	xt->prim=prim;
}
static void f_drop(void) {sp_pop();} // drop top of stack
static void f_words(void) { // display all defined words
	xt_t *w;
	for(w=dictionary;w;w=w->next) printf("%s ", w->name);
	printf("\n");
}
static void f_type(void){ // course02
	fputs((void*)sp_pop(), stdout);
}
static void f_cr(void){ // course02, newline
	fputc('\n', stdout);
}
static void f_dot(void) {
	printf("%lld ", sp_pop());
}
static void register_primitives(void) {
	add_word("+", f_add);
	add_word("*", f_mul);
	add_word("hello", f_hello_world);
	add_word("drop", f_drop);
	add_word("words", f_words);
	add_word("type", f_type); // course02
	add_word(".", f_dot); // output number
	add_word("cr", f_cr); // course02
}
static char *to_pad(char *str) { // add for course02: copy str into scratch pad
	static char scratch[1024];
	int len=strlen(str);
	if(len>sizeof(scratch)-1) len=sizeof(scratch)-1;
	memcpy(scratch, str, len);
	scratch[len]=0; // zero byte at string end
	return scratch;
}
static void interpret(char *w) {
	if(*w=='"') { // +course02: string handling
		sp_push((cell_t)to_pad(w+1));
	} else if((current_xt=find(w))) {
		current_xt->prim();
	} else { // not found, may be a number
		char *end;
		int number=strtol(w, &end, 0);
		if(*end) terminate("word not found");
		else sp_push(number);
	}
}
int main() {
	register_primitives();

	char *w;
	while((w=word())) interpret(w);

	return 0;
}
