%{
	#include <stdio.h>
	#include <string.h>
	char sauvType[20];
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	extern int num_ligne;
	void yyerror(char* msg);
	void updateIdfInt(char *idf, int val);
	void updateIdfFloat(char *idf, float val);
	void updateIdfChar(char *idf, char val);
	void updateIdfLogical(char *idf, int val);
	int calculateInt(int a, int b, char operator);
	float calculateFloat(float a, float b, char operator);
	int calculateLogic(int a, int b, char* and_or);
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
%token <entier> logical
%token <str> equal;
%token <charactere> operator
%token <str> and_or
%token <entier> taille
%start S
%type <str> affectation
%type <entier> operationInt
%type <decimal> operationFloat
%type <entier> operationLogic
%%

S : S affectation  {;}
| S declaration {;}
| {;}
;

affectation : idf variableType equal operationInt {updateIdfInt($1, $4);}
| idf variableType equal operationFloat {updateIdfFloat($1, $4);}
| idf variableType equal character { updateIdfChar($1, $4); }
| idf variableType equal operationLogic { updateIdfLogical($1, $4); }
;

declaration : type idf variableType {;}
;

variableType: taille
|
;

operationInt : operationInt operator integer { $$ = calculateInt($1, $3, $2); }
| integer {;}
;
operationFloat : operationFloat operator numeric { $$ = calculateFloat($1, $3, $2); }
| numeric { ; }
;
operationLogic : operationLogic and_or logical { $$ = calculateLogic($1, $3, $2);
}
| logical { ; };
%%
void updateIdfInt(char *idf, int val) {
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
void updateIdfLogical(char *idf, int val) {
  // mise a jour de la table des symboles
  char *boolean = "TRUE";
  if (val == 0)
    boolean = "FALSE";
  printf("updating %s = %s\n", idf, boolean);
}
int calculateInt(int a, int b, char operator) {
  if(operator == '+')
    return a+b;
  else if(operator == '-')
    return a-b;
  else if (operator== '*')
    return a*b;
  else if (operator== '/')
    return a/b;
  else
    return a%b;
}
float calculateFloat(float a, float b, char operator) {
  if (operator== '+')
    return a + b;
  else if (operator== '-')
    return a - b;
  else if (operator== '*')
    return a * b;
  else if (operator== '/')
    return a / b;
}
int calculateLogic(int a, int b, char* and_or) {
  if (and_or[0] == 'a')
    return a && b;
  return a || b;
}
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

int yywrap(){
}

void yyerror(char* msg){
	printf("Erreur syntaxique a la ligne %d\n", num_ligne);
}
