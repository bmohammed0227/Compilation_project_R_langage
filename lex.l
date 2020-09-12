%{
	#include<stdio.h>
	#include<string.h>
	#include "syntax.tab.h"
	extern YYSTYPE yylval;
	int num_ligne=1;
%}
idf [A-Z]([a-z0-9]*)
integer ([0-9]+)|("("-[0-9]+")")
numeric ([0-9]+"."([0-9])*)|("("-[0-9]+"."([0-9])*")")
cond_operator >|<|==|!=|>=|<=
arit_operator "+"|-|"*"|"/"|%
type_kw "INTEGER"|"NUMERIC"|"CHARACTER"|"LOGICAL"
comment "#"([^\n]*)
taille "["[1-9][0-9]*"]"
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
    if(strlen(yytext)>1 && yytext[1] == '-') {
		char temp[strlen(yytext)-2];
		strncpy(temp, yytext+1, strlen(yytext)-2);
		yylval.entier = atoi(temp);
  }
  else
    yylval.entier = atoi(yytext);
  return integer;
  } else
      printf("erreur lexical : integer value is out of range\n");
};
{numeric} {
  if(strlen(yytext)>1 && yytext[1] == '-') {
    char temp[strlen(yytext)-2];
    temp[0] = '-';
    strncpy(temp, yytext+1, strlen(yytext)-2);
    yylval.decimal = atof(temp);
  }
  else
    yylval.decimal = atof(yytext);
  return numeric;
};
'.' {
  yylval.charactere = yytext[1];
  return character;
};
"TRUE" {
  yylval.entier = 1;
  return logical;
};
"FALSE" {
  yylval.entier = 0;
  return logical;
};
{cond_operator} {
  return cond_operator;
};
{arit_operator} {
  yylval.charactere = yytext[0];
  return arit_operator;
};
"<-" {
  yylval.str = strdup(yytext);
  return equal;
};
"and"|"or" {
  yylval.str = strdup(yytext);
  return and_or;
};
{type_kw} {
  yylval.str = strdup(yytext);
  return type;
};
{taille} {
	char temp[strlen(yytext)-2];
    strncpy(temp, yytext+1, strlen(yytext)-2);
	yylval.entier = atoi(temp);
	return taille;
};
[(] return par_ouvr;
[)] return par_ferm;
"," return virgule;
"#"([^\n]*)
[ \t]
[\n] {
	num_ligne++;
};
. {
	printf("erreur lexical a la ligne %d\n", num_ligne);
	exit(0);
};
