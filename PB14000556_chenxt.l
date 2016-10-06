%{
#include <stdlib.h>
#include <stdio.h>

#define Endinput  0
#define CREATOR 257
#define STRING 	258
#define NUMBER 	259
#define ID	260
#define GRAPH 	261
#define NODE 	262
#define LABEL 	263
#define EDGE 	264
#define SOURCE 	265
#define TARGET 	266
#define VALUE	267

#define LARGE_NUM 500 
#define STR_LEN  30
typedef struct
{
	int id;
	char label[STR_LEN];
}Node;

typedef struct
{
	int source;
	int target;
	int value;
}Edge;

int syntax_error = 0;
int lookhead;
Node N_array[LARGE_NUM];
Edge E_array[LARGE_NUM];
int N_num = 0;
int E_num = 0;
int yy_num;
char yy_str[STR_LEN];

%}

number	[0-9]+

string  \"(\\.|[^"\\])*\"	

%%

[ \t\n]+	{/*do nothing, just skip*/}
{number}	{yy_num = atoi(yytext); return NUMBER;}
{string}	{strcpy(yy_str, yytext); return STRING;}
.		{return yytext[0];}
Creator		{return CREATOR;}
label		{return LABEL;}
node		{return NODE;}
edge		{return EDGE;}
source		{return SOURCE;}
target		{return TARGET;}
value		{return VALUE;}
graph		{return GRAPH;}
id		{return ID;}
%%

/* Production(s) Set

S -> H G

G -> graph [ N E ]

N -> N_0 N | 

E -> E_0 E |

N_0 -> node [ id NUM label STR ]

E_0 -> edge [ source NUM target NUM value NUM ]

NUM -> {number}

STR -> {string}
*/

void S();void H(); void G();
void N(); void E();
void N_0(); void E_0();

int next_token()
{
	return yylex();
}

void match(int t)
{
	if (syntax_error == 1)
		return;
	if (lookhead == t)
		lookhead = next_token();
	else
		printf("\ninvalid input!! got:%c%d expected:%c%d\n", lookhead, lookhead, t, t);
}

void S()
{
	H(); G();
	if (lookhead == Endinput)
		printf("input finished!!\n");
}

void H()
{
	if (syntax_error == 1)
		return;
	match(CREATOR);	match(STRING);
}

void G()
{
	if (syntax_error == 1)
		return;		
	match(GRAPH);
	match('['); N(); E(); match(']');
}

void N()
{
	if (syntax_error == 1)
		return;
	match(NODE); N_0();
	if (lookhead == NODE)
		 N();
}

void N_0()
{
	if (syntax_error == 1)
		return;
	match('['); 
	match(ID); match(NUMBER); N_array[N_num].id = yy_num;
	match(LABEL); match(STRING); strcpy(N_array[N_num].label, yy_str);
	match(']');
	N_num++;
}

void E()
{
	if (syntax_error == 1)
		return;
	match(EDGE); E_0();
	if (lookhead == EDGE)
		E();
}

void E_0()
{
	if (syntax_error == 1)
		return;	
	match('[');
	match(SOURCE); match(NUMBER); E_array[E_num].source = yy_num;
	match(TARGET); match(NUMBER); E_array[E_num].target = yy_num;
	match(VALUE); match(NUMBER); E_array[E_num].value = yy_num;
	match(']');
	E_num++;
}

int compare(const void* a,const void* b)
{
	Node* p1 = (Node*)a; Node* p2 = (Node*)b;
	return (((p1->id) > (p2->id)) ? 1 : -1);
}

int main()
{
	lookhead = next_token();
	S();
	int i;
	printf("\nOutput:\n");
	for (i = 0; i < E_num; i++)
	{
		printf("source: %s\t target: %s\t value: %d\n", N_array[E_array[i].source].label, N_array[E_array[i].target].label, E_array[i].value);
	}
	return 0;
}

int yywrap()
{
	return 1;
}
