/* Forth interpreter and simple compiler with conditionals - in C
 * (c) 2017 Andreas Klimas, klimas@w3group.de
 *
 * This source is public domain
 *
 * We have a datastack, a dictionary, and string handling
 * We have a return stack and a macro dictionary, code segment
 * and an instruction pointer
 * We have conditions like if and while and unconditional loops
 *
 * Now we build an disassembler (see <word> and dis) to show
 * simplicity of ITC code. Also we introduce function pointer,
 * i.e. pointer to words which can executed with execute
 */

#include <stdio.h>
#include <stdlib.h> // exit
#include <string.h> // strcmp
#include <ctype.h> // isspace

typedef struct xt_t { // Execution Token
	struct xt_t *next;
	char *name;
	void (*prim)(void);
	struct xt_t **data; // for variables and high level code
	int has_lit; // does consume the next ip as literal (0branch, 1branch, lit)
} xt_t;
typedef long long cell_t;
static xt_t *dictionary; 
static xt_t *macros;  // course03
static xt_t **definitions=&dictionary; // where to store new words
static xt_t **ip; // course03, instruction pointer
static xt_t *latest; // last defined word
#define RETURN_STACK_SIZE 32
static xt_t **rp_base[RETURN_STACK_SIZE], ***rp_end=rp_base+RETURN_STACK_SIZE;
static xt_t ***rp=rp_base-1;

static xt_t *current_xt; // current xt
static xt_t *xt_dup, *xt_drop, *xt_interpreting, *xt_word, *xt_bye, *xt_lit, *xt_leave, *xt_branch, *xt_1branch, *xt_0branch; // some execution tokens need for compiling

#define DATA_STACK_SIZE 32
static cell_t sp_base[DATA_STACK_SIZE], *sp_end=sp_base+DATA_STACK_SIZE;
static cell_t *sp=sp_base-1;
static int is_compile_mode; // course03: we are either interpreting or compiling
#define CODE_SIZE 65536
static xt_t *code_base[CODE_SIZE], **code=code_base, **code_end=code_base+CODE_SIZE;


static xt_t *compile(xt_t *xt) ;
static void interpreting(char *w) ;

static xt_t *find(xt_t *dict, char *w) { // find word either in dictionary or macros
	for(;dict;dict=dict->next) if(!strcmp(dict->name, w)) return dict;

	return 0; // not found
}

static void ok(void) { // print data stack, than ok>
	cell_t *i;
	for(i=sp_base;i<=sp;i++) printf("%lld ", *i);
	printf(is_compile_mode?"compile> ":"ok> ");
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
static void rp_push(xt_t **ip) {
	if(rp==rp_end) terminate("return stack overflow");
	*++rp=ip;
}
static xt_t **rp_pop(void) {
	if(rp<rp_base) terminate("return stack underrun");
	return *rp--;
}
static void sp_push(cell_t value) {
	if(sp==sp_end) terminate("Data stack overflow");
	*++sp=value;
}
static cell_t sp_pop(void) {
	if(sp<sp_base) terminate("Data stack underrun");
	return *sp--;
}

static void f_mul(void) { int v1=sp_pop(); *sp*=v1; }
static void f_add(void) { int v1=sp_pop(); *sp+=v1; }
static void f_sub(void) { int v1=sp_pop(); *sp-=v1; }
static void f_div(void) { int v1=sp_pop(); *sp/=v1; }
static void f_hello_world(void) { printf("Hello World\n"); }
static xt_t *add_word(char *name, void (*prim)(void)) {
	xt_t *xt=calloc(1, sizeof(xt_t));
	xt->next=*definitions;
	*definitions=xt;
	xt->name=strdup(name);
	xt->prim=prim;
	xt->data=code;
	return latest=xt;
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
static void f_docol(void) { // course03, VM: enter function (word)new 
	rp_push(ip);
	ip=current_xt->data;
}
static void f_colon(void) { // course03, define a new word
	char *w=word(); // read next word which becomes the word name
	add_word(strdup(w), f_docol);
	is_compile_mode=1; // switch to compile mode
}
static void f_semis(void) { // course03, macro, end of definition
	compile(xt_leave);
	is_compile_mode=0;
}
static void f_leave(void) { // course03, return from subroutine
	ip=rp_pop();
}
static void f_lit(void) {
	sp_push((cell_t)*ip++);
}
static void f_dot(void) {
	printf("%lld ", sp_pop());
}
static void f_bye(void) {exit(0);}
static void f_branch(void) { ip=(void*)*ip; } // unconditional jump
static void f_0branch(void) { // jump if top of stack is zero
	if(sp_pop()) ip++;
	else         ip=(void*)*ip;
}
static void f_1branch(void) { // jump if top of stack is zero
	if(sp_pop()) ip=(void*)*ip;
	else         ip++;
}
static void f_word(void) { sp_push((cell_t)word()); }
static void f_interpreting(void) {
	interpreting((void*)sp_pop());
}
static void f_dup(void){cell_t t=*sp; sp_push(t);}
static void f_if(void) {
	compile(xt_0branch);
	sp_push((cell_t)code++); // push forward reference on stack
}
static void f_swap(void) {
	cell_t t=*sp;
	*sp=sp[-1];
	sp[-1]=t;
}
static void f_else(void) {
	xt_t ***dest=(void*)sp_pop();
	compile(xt_branch);
	sp_push((cell_t)code++);
	*dest=code;
}
static void f_then(void) {
	xt_t ***dest=(void*)sp_pop();
	*dest=code;
}
static void f_begin(void) { sp_push((cell_t)code); }
static void f_while(void) {
	compile(xt_1branch);
	*code++=(void*)sp_pop();
}
static void f_again(void) {
	compile(xt_branch);
	*code++=(void*)sp_pop();
}
static void f_exit(void) { ip=rp_pop(); }
static void f_dis(void) {
	xt_t **ip=(void*)sp_pop();
	for(; (*ip)->prim!=f_leave;ip++) {
		xt_t *xt=*ip;
		if(xt->has_lit) {
			printf("%p %s %p\n", ip, xt->name, ip[1]);
			ip++;
		} else {
			printf("%p %s\n", ip, xt->name);
		}
	}
}
static void f_tick(void) {
	char *w=word();
	xt_t *xt=find(dictionary, w);
	if(xt) sp_push((cell_t)xt);
	else   terminate("word not found");
}
static void f_see(void) {
	f_tick();
	xt_t *xt=(xt_t*)(*sp);
	*sp=(cell_t)xt->data;
	f_dis();
}
static void f_execute(void) {
	xt_t *cur=current_xt;
	current_xt=(void*)sp_pop();
	current_xt->prim();
	current_xt=cur;
}
static void f_xt_to_name(void) {
	*sp=(cell_t)((xt_t*)*sp)->name;
}
static void f_xt_to_data(void) {
	*sp=(cell_t)((xt_t*)*sp)->data;
}
static void register_primitives(void) {
	add_word("+", f_add);
	add_word(".", f_sub);
	add_word("*", f_mul);//top of stack (TOS) * next of stack => TOS
	add_word("/", f_div);//top of stack (TOS) * next of stack => TOS
	add_word("hello", f_hello_world); // say hello world
	xt_drop=add_word("drop", f_drop); // discard top of stack
	xt_dup=add_word("dup", f_dup);
	add_word("swap", f_swap);
	add_word("words", f_words); // list all defined words
	add_word("type", f_type); // course02, output string
	add_word(".", f_dot); // course02, output number
	add_word("cr", f_cr); // course02, output CR
	add_word(":", f_colon); // course03, define new word, enter compile mode
	xt_bye=add_word("bye", f_bye);
	xt_leave=add_word("leave", f_leave);
	xt_lit=add_word("lit", f_lit);
	latest->has_lit=1;

	xt_0branch=add_word("0branch", f_0branch); // jump on zero
	latest->has_lit=1;

	xt_1branch=add_word("1branch", f_1branch); // jump on not zero
	latest->has_lit=1;

	xt_branch=add_word("branch", f_branch);
	latest->has_lit=1;

	xt_word=add_word("word", f_word);
	xt_interpreting=add_word("interpreting", f_interpreting);
	add_word("exit", f_exit); // same as leave but leave is used to recognize the end of assembling
	add_word("'", f_tick); // ' <word> => execution token on stack
	add_word("execute", f_execute); // ' <word> => execution token on stack
	add_word("see", f_see); // see <word>
	add_word("dis", f_dis); // dis ( ip--) until leave
	add_word("xt>data", f_xt_to_data);
	add_word("xt>name", f_xt_to_name);


	definitions=&macros;
	add_word(";", f_semis); // course03, end of new word, leave compile mode
	add_word("if", f_if); // compiles an if condition
	add_word("then", f_then); // this is the endif
	add_word("else", f_else);
	add_word("begin", f_begin); // begin of while loop
	add_word("while", f_while); // while loop (condition at end of loop)
	add_word("again", f_again); // unconditional loop to begin

	definitions=&dictionary;
}
static char *to_pad(char *str) { // add for course02: copy str into scratch pad
	static char scratch[1024];
	int len=strlen(str);
	if(len>sizeof(scratch)-1) len=sizeof(scratch)-1;
	memcpy(scratch, str, len);
	scratch[len]=0; // zero byte at string end
	return scratch;
}

static xt_t *compile(xt_t *xt) {
	if(code>=code_end) terminate("code space full");
	return *code++=xt;
}
static void literal(cell_t value) {
	compile(xt_lit);
	*code++=(xt_t*)value;
}
static void compiling(char *w) { // course03
	if(*w=='"') { // +course02: string handling
		literal((cell_t)strdup(w+1)); // compile a literal
	} else if((current_xt=find(macros, w))) { // if word is a macro execute it immediatly
		current_xt->prim();
	} else if((current_xt=find(dictionary, w))) { // if word is in regular dictionary, compile it
		*code++=current_xt;
	} else { // not found, may be a number
		char *end;
		int number=strtol(w, &end, 0);
		if(*end) terminate("word not found");
		else literal(number); // compile a number literal
	}
}
static void interpreting(char *w) {
	if(is_compile_mode) return compiling(w);

	if(*w=='"') { // +course02: string handling
		sp_push((cell_t)to_pad(w+1));
	} else if((current_xt=find(dictionary, w))) {
		current_xt->prim();
	} else { // not found, may be a number
		char *end;
		int number=strtol(w, &end, 0);
		if(*end) terminate("word not found");
		else sp_push(number);
	}
}
static void vm(void) {
	for(;;) {
		current_xt=*ip++;
		current_xt->prim();
	}
}
int main() {
	register_primitives();

	/* we compile interpreting by hand */
	add_word("shell", f_docol);
	xt_t **begin=code;
	compile(xt_word);
	compile(xt_dup);
	compile(xt_0branch); // if top of stack is null
	xt_t **here=code++; // forward jump reference
	compile(xt_interpreting);
	compile(xt_branch);
	*code++=(void*)begin; // Loop back
	*here=(void*)code; // resolve reference
	*code++=xt_drop;
	*code++=xt_bye; // leave VM

	ip=begin; // set instruction pointer
	vm(); // and run the vm

	return 0;
}
