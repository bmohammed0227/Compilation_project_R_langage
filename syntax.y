%{
	#include <stdio.h>
	char sauvType[20];
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	extern int num_ligne;
	int nbr_ligne = 1;
  void yyerror(char* msg);
  void updateIdfVal(char* idf, int val);
%}
%union{
	int entier;
	char* str;
}
%token <str> idf
%token <entier> integer
%start S
%type <str> affectation
%%

S : affectation  {printf("S\n");}
;

affectation : idf '=' integer {updateIdfVal($1, $3);}
;
%%
int main(int argc, char** argv){
	char nomFichier[20];
	printf("Veuillez entrer le nom du fichier a compiler\n");
	scanf("%s", nomFichier);
	FILE *file = fopen(nomFichier, "r");
	if (!file) {
		printf("Fichier introuvable, verifiez le nom du fichier et reessayez\n");
		return -1;
	}
	yyin = file;
	return yyparse();
}

void updateIdfVal(char* idf, int val) {
  // mise a jour de la table des symboles
  printf("updating %s = %d\n", idf, val);
}
int yywrap(){
}

void yyerror(char* msg){
	printf("Erreur syntaxique\n");
}
