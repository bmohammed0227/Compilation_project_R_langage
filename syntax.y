%{
	#include <stdio.h>
  #include <stdlib.h>
	#include <string.h>
  #include "symbol_table.h"
  char sauvType[20];
  extern int yylex();
  extern int yyparse();
  extern void printList();
	extern FILE *yyin;
	extern int num_ligne;
  extern Symbol* symbolsTable[26];
  extern Symbol *find(char *idf);
  extern void insert(char *idf, char *code);
  extern char typeOf(char *val);
  extern char tempType;
  void yyerror(char *msg);
  void updateEntityVal(char* idf, char* val);
  void updateEntityType(char* idf, char type);
  void updateEntitySize(char *idf, int size);
  // void updateIdfInt(char *idf, int val);
  // void updateIdfFloat(char *idf, float val);
  // void updateIdfChar(char *idf, char val);
  // void updateIdfLogical(char *idf, int val);
  char* calculate(char* result, char* idf1, char* idf2, char* operand);
  int calculateInt(int a, int b, char operator);
  float calculateFloat(float a, float b, char operator);
  int calculateLogic(char* a, char* b, char *and_or);
  %}
%union{
	int entier;
	float decimal;
	char charactere;
	char str[20];
}
%token <str> type
%token <str> par_ouvr
%token <str> par_ferm
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
%type <str> operation_arithmetique_logique
%type <str> operation_arithmetique
%type <str> operation_logique
%type <str> operation_comparaison
%type <entier> variableType
%type <str> expression_A
%%

S : S affectation  {;}
| S declaration {;}
| {;}
;

affectation : idf variableType equal operation_arithmetique_logique {
  updateEntityVal($1, $4);
}
| type idf variableType equal operation_arithmetique_logique {updateEntityVal($2, $5);}
;

declaration : type list_idf
;

list_idf : idf variableType {
  updateEntityType($1, tempType);
  updateEntitySize($1, $2);}
| idf variableType virgule list_idf {
  updateEntityType($1, tempType);
  updateEntitySize($1, $2);
};

variableType: taille {$$ = $1;}
| {$$ = 0;}
;

operation_arithmetique_logique : operation_arithmetique 
| operation_logique 
;

operation_arithmetique: expression_A  
|	expression_A arit_operator operation_arithmetique 
;

expression_A : integer {snprintf($$, 20, "%d", $1);}
| numeric { snprintf($$, 20, "%f", $1); }
| character { $$[0] = $1; $$[1] = '\0'; }
| par_ouvr operation_arithmetique par_ferm
;

operation_comparaison : par_ouvr operation_arithmetique cond_operator operation_comparaison par_ferm
| par_ouvr logical par_ferm {
  if($2 == 1)
    strcpy($$, "TRUE");
 else
   strcpy($$, "FALSE");
}
| par_ouvr operation_arithmetique cond_operator operation_arithmetique par_ferm;

operation_logique:  operation_comparaison and_or  operation_logique {calculate($$, $1, $3, $2);}
|	operation_comparaison and_or operation_comparaison {calculate($$, $1, $3, $2);}
;


%%
void updateEntityVal(char* idf, char* val) {
  char typeVal = typeOf(val);
  printf("updating %s with value %s of type %c\n", idf, val, typeVal);
  Symbol *var = find(idf);
  if (var == NULL) {
    insert(idf, val);
    var->entityType = typeVal;
  }
  else {
    if (typeVal == var->entityType)
      strcpy(var->entityCode, val);
    else if (var->entityType == ' ') {
      var->entityType = typeVal;
      strcpy(var->entityCode, val);
    }
    else
      yyerror("Type de variable incompatible avec la valeur\n");
  }
}
void updateEntityType(char *idf, char type) {
  Symbol *var = find(idf);
  if (var == NULL) {
    printf("Idf %s not found\n",idf);
  } else {
    if (var->entityType == ' ')
      var->entityType = type;
    else
      yyerror("La variable a deja un type attribuee.\n");
  }
}
void updateEntitySize(char *idf, int size) {
  if (size == 0)
    return;
  Symbol *var = find(idf);
  if (var == NULL) {
    printf("Idf %s not found\n", idf);
  } else {
    if (var->arraySize == 0)
      var->arraySize = size;
    else
      yyerror("Le tableau a deja une taille attribuee.\n");
  }
}
char* calculate(char* resultChar, char* idf1, char* idf2, char* op) {
  Symbol *var1 = find(idf1);
  Symbol *var2 = find(idf2);
  if (var1 == NULL || var2 == NULL)
    return NULL;
  if(var1->entityType == var2->entityType) {
    if (var1->entityType == 'i') {
      int result, val1, val2;
      val1 = atoi(var1->entityCode);
      val2 = atoi(var2->entityCode);
      result = calculateInt(val1, val2, op[0]);
      snprintf(resultChar, 20, "%d", result);
    }
    else if (var1->entityType == 'n') {
      float result, val1, val2;
      val1 = atof(var1->entityCode);
      val2 = atof(var2->entityCode);
      result = calculateFloat(val1, val2, op[0]);
      snprintf(resultChar, 20, "%f", result);
    }
    else if (var1->entityType == 'l') {
      int result;
      result = calculateLogic(var1->entityCode, var2->entityCode, op);
      if (result == 1)
        strcpy(resultChar, "TRUE");
      else
        strcpy(resultChar, "FALSE");
    }
    return resultChar;
  }

  //   NEED TO IMPLEMENT FLOAT INT OPERATIONS
  printf("Types differents\n");
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
int calculateLogic(char* a, char* b, char* and_or) {
  int val1, val2;
  if(strcpy(a, "TRUE") == 0)
    val1 = 1;
  else
    val1 = 0;
  if (strcpy(b, "TRUE") == 0)
    val1 = 1;
  else
    val1 = 0;
  if (and_or[0] == 'a')
    return val1 && val2;
  return val1 || val2;
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
  yyparse();
  printList();
	return 0;
}

int yywrap(){
}

void yyerror(char* msg){
	printf("Erreur syntaxique a la ligne %d\n", num_ligne);
  printf("%s\n", msg);
}
