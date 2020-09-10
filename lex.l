%{
	#include<stdio.h>
	#include "syntax.tab.h"
	extern YYSTYPE yylval;
	int num_ligne=1;
%}
idf [A-Z]([a-z0-9]*)
integer -?[0-9]([0-9]*)
numeric [0-9]+"."([0-9])*|-"("[0-9]+"."([0-9])*")"
character '.'
logical TRUE|FALSE
cond_operator >|<|==|!=|>=|<=
arit_operator "+"|-|"*"|"/"|%
logic_operator and|or
comment "#"([^\n]*)
%%
{idf} {
  if(yyleng<=10){
    yylval.str=strdup(yytext);
    //inserer(yytext,"idf");
    return idf;
  } else
      printf("erreur lexical : idf trop long\n");
};
{integer} {
  if(atoi(yytext) >= -32768 && atoi(yytext) <= 32767) {
    yylval.entier = atoi(yytext);
    return integer;
  } else
      printf("erreur lexical : integer value is out of range\n");
};
{numeric} {
  printf("numeric : %s (%g)\n",yytext, atof(yytext));
};
{character} {
  printf("character : %s (%c)\n",yytext, yytext[1]);
};
{logical} {
  printf("logical : %s\n",yytext);
};
{cond_operator} {
  printf("condition operator : %s\n",yytext);
};
{arit_operator} {
  printf("arithmetic operator : %s\n",yytext);
};
"<-" {
  return '=';
};
{logic_operator} {
  printf("logical operator : %s\n",yytext);
};
"#"([^\n]*)
[ \t]
[\n] {
	num_ligne++;
};
. {
	printf("erreur lexical a la ligne %d\n", num_ligne);
	exit(0);
};
