%{
	#include <stdio.h>
  #include <stdlib.h>
	#include <string.h>
	#include<stdbool.h>
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
  extern char* getVal(char* idf);
  extern char getType(char* idf);
  void setVal(char idf[], char* val);
  void yyerror(char *msg);
  void updateEntityVal(char* idf, char* val);
  void updateEntityType(char* idf, char type);
  void updateEntitySize(char *idf, int size);
  void calculate(char* resultChar, char* idf1, char* idf2, char op);
  int calculateInt(int a, int b, char operator);
  float calculateFloat(float a, float b, char operator);
  int calculateLogic(int a, int b, char *and_or);
  int calculateCond(char *a, char *b, char *op);
   void incrementation_decrementation(char* idf, char arit_op, int entier);
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
%token <str> cond_operator
%token <str> and_or
%token <entier> taille
%start S
%type <str> affectation
%type <str> operation_arithmetique_logique
%type <str> operation_arithmetique
%type <entier> operation_logique
%type <entier> operation_comparaison
%type <entier> variableType
%type <str> expression_A
%%

S : S affectation  {;}
| S declaration {;}
| S incrementation_decrementation {}
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

operation_arithmetique_logique : operation_arithmetique {strcpy($$, $1);}
| operation_logique {
  if ($1 == 1)
    strcpy($$, "TRUE");
  else
    strcpy($$, "FALSE");
 }
;

operation_arithmetique: expression_A {strcpy($$, $1);}
|	expression_A arit_operator operation_arithmetique {calculate($$, $1, $3, $2);}
| par_ouvr operation_arithmetique par_ferm {strcpy($$, $2);}
;

expression_A : integer {snprintf($$, 20, "%d", $1);}
| numeric { snprintf($$, 20, "%f", $1); }
| character { $$[0] = $1; $$[1] = '\0'; }
// | par_ouvr expression_A par_ferm {strcpy($$, $2);}
;

operation_comparaison : par_ouvr operation_arithmetique cond_operator operation_arithmetique par_ferm {
  $$ = calculateCond($2, $4, $3);
 };

operation_logique:  operation_comparaison and_or  operation_logique {$$ = calculateLogic($1, $3, $2);}
|	operation_comparaison {$$ = $1;}
| logical and_or operation_logique { $$ = calculateLogic($1, $3, $2); }
| logical { $$ = $1; }
;

incrementation_decrementation : idf arit_operator equal integer {
 incrementation_decrementation($1, $2, $4);
};


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
void calculate(char* resultChar, char* a, char* b, char op) {
  float val1, val2;
  char type1, type2;
  if(a[0] >= 'A' && a[0] <= 'Z') {
    Symbol *var1 = find(a);
    val1 = (float) atof(a);
    type1 = var1->entityType;
  }
  else {
    if (typeOf(a) == 'n') {
      val1 = atof(a);
      type1 = 'n';
    }
    else if(typeOf(a) == 'i') {
      val1 = (float) atoi(a);
      type1 = 'i';
    }
  }
  if (b[0] >= 'A' && b[0] <= 'Z') {
    Symbol *var1 = find(b);
    val2 = (float)atof(b);
    type2 = var1->entityType;
  } else {
    if (typeOf(b) == 'n') {
      val2 = atof(b);
      type2 = 'n';
    } else if (typeOf(b) == 'i') {
      val2 = (float)atoi(b);
      type2 = 'i';
    }
  }

  if (type1 == type2) {
      if (type1 == 'i') {
        int result;
        result = calculateInt((int)val1, (int)val2, op);
        snprintf(resultChar, 20, "%d", result);
      } else if (type2 == 'n') {
        float result;
        result = calculateFloat(val1, val2, op);
        snprintf(resultChar, 20, "%f", result);
      }
  }
  else
    printf("Types differents\n");
  //   NEED TO IMPLEMENT FLOAT INT OPERATIONS
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
int calculateCond(char *a, char *b, char *op) {
  if (typeOf(a) == 'i') {
    int val1 = atoi(a);
    int val2 = atoi(b);
    if (strcmp(op, "==") == 0)
      return val1 == val2;
    else if (strcmp(op, "!=") == 0)
      return val1 != val2;
    else if (strcmp(op, ">=") == 0)
      return val1 >= val2;
    else if (strcmp(op, "<=") == 0)
      return val1 <= val2;
    else if (strcmp(op, ">") == 0)
      return val1 > val2;
    else if (strcmp(op, "<") == 0)
      return val1 < val2;
  } else if (typeOf(a) == 'n') {
    float val1 = atof(a);
    float val2 = atof(b);
    if (strcmp(op, "==") == 0)
      return val1 == val2;
    else if (strcmp(op, "!=") == 0)
      return val1 != val2;
    else if (strcmp(op, ">=") == 0)
      return val1 >= val2;
    else if (strcmp(op, "<=") == 0)
      return val1 <= val2;
    else if (strcmp(op, ">") == 0)
      return val1 > val2;
    else if (strcmp(op, "<") == 0)
      return val1 < val2;
  }
}

void incrementation_decrementation(char* idf, char arit_op, int entier){
 	if(arit_op != '+' && arit_op != '-')
		yyerror("Operateur arithmetique errone.");
	if(entier <= 0)
		yyerror("La valeur doit etre de type integer positif.");
		
	char typeIdf = getType(idf);
	if(typeIdf == 'n' || typeIdf == 'i'){
		if(arit_op == '-') entier = -entier;
		char* idfValue = getVal(idf);
		char result[12];
		if(typeIdf == 'n'){
			float i1 = atof(idfValue);
			i1 += entier;
			sprintf(result, "%f", i1);
			setVal(idf, result);
		}else{
			int i2 = atoi(idfValue);
			i2 += entier;
			sprintf(result, "%d", i2);
			printf("%s", result);
			setVal(idf, result);
		}
		printf("resultat : %s", result);
	}else 
		if(typeIdf == ' ') yyerror("Variable non initialise.");
			else yyerror("Type incompatible.");
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
