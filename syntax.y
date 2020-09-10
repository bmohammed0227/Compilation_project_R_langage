%{
	#include <stdio.h>
	char sauvType[20];
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	extern int num_ligne;
	int nbr_ligne = 1;
  void yyerror(char* msg);
  void updateIdfInt(char* idf, int val);
  void updateIdfFloat(char *idf, float val);
  void updateIdfChar(char *idf, char val);
  %}
%union{
	int entier;
  float decimal;
  char charactere;
	char* str;
}
%token type
%token <str> idf
%token <entier> integer
%token <decimal> numeric
%token <charactere> character
%start S
%type <str> affectation
%%

S : affectation  {printf("S\n");}
| S affectation  {;}
;

affectation : idf '=' integer {updateIdfInt($1, $3);}
| idf '=' numeric {updateIdfFloat($1, $3);}
| idf '=' character { updateIdfChar($1, $3); };

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

void updateIdfInt(char* idf, int val) {
  // mise a jour de la table des symboles
  printf("updating %s = %d\n", idf, val);
}
void updateIdfFloat(char *idf, float val) {
  // mise a jour de la table des symboles
  printf("updating %s = %f\n", idf, val);
}
void updateIdfChar(char *idf, char val) {
  // mise a jour de la table des symboles
  printf("updating %s = %c\n", idf, val);
}
int yywrap(){
}

void yyerror(char* msg){
	printf("Erreur syntaxique\n");
}
