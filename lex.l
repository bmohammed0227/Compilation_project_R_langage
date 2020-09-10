%{
	#include<stdio.h>
	#include "syntax.tab.h"
	extern YYSTYPE yylval;
	int num_ligne=1;
%}
idf [A-Z]([a-z0-9]*)
integer -?[0-9]([0-9]*)
numeric ([0-9]+"."([0-9])*)|(-"("[0-9]+"."([0-9])*")")
character '.'
logical TRUE|FALSE
cond_operator >|<|==|!=|>=|<=
arit_operator "+"|-|"*"|"/"|%
logic_operator and|or
type_kw "INTEGER"|"NUMERIC"|"CHARACTER"
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
  yylval.decimal = atof(yytext);
  return numeric;
};
{character} {
  yylval.charactere = yytext[1];
  return character;
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
{type_kw} {
  yylval.str = strdup(yytext);
  return type;
}
"#"([^\n]*)
[ \t]
[\n] {
	num_ligne++;
};
. {
	printf("erreur lexical a la ligne %d\n", num_ligne);
	exit(0);
};
