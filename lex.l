%{
	#include<stdio.h>
	#include "Syntax.tab.h"
	extern YYSTYPE yylval;
	int num_ligne=1;
%}
idf [A-Z]([a-z0-9]*)
%%
{idf} {    
	if(yyleng<=10){
		yylval.str=strdup(yytext);
		//inserer(yytext,"idf");  
		return idf;
	}else 
		printf("erreur lexical : idf trop long\n");
};
[ \t]
[\n] {
	num_ligne++;
};
. {
	printf("erreur lexical a la ligne %d\n", num_ligne);
	exit(0);
};
