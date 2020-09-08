%{
	#include <stdio.h>
	char sauvType[20];
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	extern int num_ligne;
	int nbr_ligne = 1;
%}
%union{
	int entier;
	char* str;
}
%token idf
%%
S : idf SUITE {
		printf("programme syntaxiquement correcte\n");
		YYACCEPT;
};

SUITE : idf | ;
%%
main(int argc, char** argv){
	char nomFichier[20];
	printf("Veuillez entrer le nom du fichier a compiler\n");
	scanf("%s", nomFichier);
	FILE *file = fopen(nomFichier, "r");
	if (!file) {
		printf("Fichier introuvable, verifiez le nom du fichier et reessayez\n");
		return -1;
	}
	yyin = file;
	yyparse();
}

yywrap(){
}

yyerror(char* msg){
	printf("Erreur syntaxique\n");
}
