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
%token par_ouvr
%token par_ferm
%token virgule
%token <str> idf
%token <entier> integer
%token <decimal> numeric
%token <charactere> character
%token <entier> logical
%token <str> equal;
%token <charactere> arit_operator
%token <charactere> cond_operator
%token <str> and_or
%token <entier> taille
%start S
%type <str> affectation
%%

S : S affectation  {;}
| S declaration {;}
| {;}
;

affectation : idf variableType equal operation_arithmetique_logique {}
| type idf variableType equal operation_arithmetique_logique {}
;

declaration : type list_idf  
;

list_idf : idf variableType 
| idf variableType virgule list_idf 
;

variableType: taille
|
;

operation_arithmetique_logique : operation_arithmetique 
| operation_logique 
;

operation_arithmetique: expression_A  
|	expression_A arit_operator operation_arithmetique 
;

expression_A : integer
| numeric
| character
| par_ouvr operation_arithmetique par_ferm
;

operation_comparaison : par_ouvr operation_arithmetique cond_operator operation_comparaison par_ferm
| par_ouvr logical par_ferm
| par_ouvr operation_arithmetique cond_operator  operation_arithmetique par_ferm
;

operation_logique:  operation_comparaison and_or  operation_logique
|	operation_comparaison and_or operation_comparaison
;


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
