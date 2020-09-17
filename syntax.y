%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include<stdbool.h>
	#include "symbol_table.h"
	#include "quadruplet.h"
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
	qdr quad[1000];
	int qc=0;
	int sauv_BZ_if;
	int sauv_BR_if[20];
	int sauv_BR_if_indice = 0;
	char sauv_BR_while[20][20];
	int sauv_BR_while_indice = 0;
	int sauv_bz_while[20];
	int sauv_bz_while_indice = 0;
	char sauv_BR_for[20][20];
	int sauv_BR_for_indice = 0;
	int sauv_bz_for[20];
	int sauv_bz_for_indice = 0;
	char qc_char[20];
	void quadr(char opr[],char op1[],char op2[],char res[]);
	void ajout_quad(int num_quad, int colon_quad, char val []);
	void afficher_qdr();
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
%token <str> aco_ouvr
%token <str> aco_ferm
%token <str> range
%token virgule
%token <str> idf
%token <entier> integer
%token <decimal> numeric
%token <charactere> character
%token <entier> logical
%token <str> index_idf
%token <str> equal;
%token <charactere> arit_operator
%token <str> cond_operator
%token <str> and_or
%token <entier> taille
%token <str> while_kw
%token <str> for_kw
%token <str> in_kw
%token <str> if_token
%token <str> else_token
%start S
%type <str> affectation
%type <str> operation_arithmetique_logique
%type <str> operation_arithmetique
%type <entier> operation_logique
%type <entier> operation_comparaison
%type <entier> variableType
%type <str> expression_A
%type <str> loop
%type <str> if_instruction 
%%

S : S affectation  {quadr("Instruction_affectation", "", "", "");}
| S declaration {quadr("Instruction_declaration", "", "", "");}
| S incrementation_decrementation {quadr("Instruction_incrementation_decrementation", "", "", "");}
| S loop {}
| S if_instruction 
| {;}
;


affectation : idf variableType equal operation_arithmetique_logique {
  updateEntityVal($1, $4);
}
| type idf variableType equal operation_arithmetique_logique {updateEntityVal($2, $5);}
| idf variableType equal if_token else_token par_ouvr operation_logique virgule operation_arithmetique_logique virgule operation_arithmetique_logique par_ferm
| type idf variableType equal if_token else_token par_ouvr operation_logique virgule operation_arithmetique_logique virgule operation_arithmetique_logique par_ferm
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
| idf {strcpy($$, getVal($1));}
// | par_ouvr expression_A par_ferm {strcpy($$, $2);}
;

operation_comparaison : par_ouvr operation_arithmetique cond_operator operation_arithmetique par_ferm {
  $$ = calculateCond($2, $4, $3);
}
| operation_arithmetique cond_operator operation_arithmetique {$$ = calculateCond($1, $3, $2);}
;

operation_logique:  operation_comparaison and_or  operation_logique {$$ = calculateLogic($1, $3, $2);}
|	operation_comparaison {$$ = $1;}
| logical and_or operation_logique { $$ = calculateLogic($1, $3, $2); }
| logical { $$ = $1; }
;

incrementation_decrementation : idf arit_operator equal integer {
 incrementation_decrementation($1, $2, $4);
};

loop : while_kw par_ouvr operation_logique par_ferm 
{
	sprintf(sauv_BR_while[sauv_BR_while_indice], "%d", qc);
	sauv_BR_while_indice++;
	sauv_bz_while[sauv_bz_while_indice] = qc;
	sauv_bz_while_indice++;
	quadr("BZ", "", "Cond", "");  
}
aco_ouvr S aco_ferm
{
	quadr("BR", sauv_BR_while[sauv_BR_while_indice-1], "", "");
	sauv_BR_while_indice--;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_bz_while[sauv_bz_while_indice-1], 1, qc_char);
	sauv_bz_while_indice--;
}
| for_kw par_ouvr index_idf in_kw integer range integer par_ferm 
{
	sprintf(sauv_BR_for[sauv_BR_for_indice], "%d", qc);
	sauv_BR_for_indice++;
	sauv_bz_for[sauv_bz_for_indice] = qc;
	sauv_bz_for_indice++;
	quadr("BZ", "", "Cond", "");  
}
aco_ouvr S aco_ferm 
{
	quadr("BR", sauv_BR_for[sauv_BR_for_indice-1], "", "");
	sauv_BR_for_indice--;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_bz_for[sauv_bz_for_indice-1], 1, qc_char);
	sauv_bz_for_indice--;
}
;

if_instruction : if_token par_ouvr operation_logique par_ferm 
{
	quadr("BZ", "", "Cond", "");
	sauv_BZ_if = qc;
}
aco_ouvr S aco_ferm ELSE 

ELSE : else_token
 {
	quadr("BR", "", "", "");
	sauv_BR_if[sauv_BR_if_indice] = qc;
	sauv_BR_if_indice++;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_BZ_if-1, 1, qc_char);
}
 if_instruction {
	sprintf(qc_char, "%d", qc);
	for(int i=0; i<=sauv_BR_if_indice; i++){
		ajout_quad(sauv_BR_if[i]-1, 1, qc_char);
	}
	sauv_BR_if_indice = 0;
}
| else_token {
	quadr("BR", "", "", "");
	sauv_BR_if[sauv_BR_if_indice] = qc;
	sauv_BR_if_indice++;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_BZ_if-1, 1, qc_char);
}
 aco_ouvr S aco_ferm {
	sprintf(qc_char, "%d", qc);
	for(int i=0; i<=sauv_BR_if_indice; i++){
		ajout_quad(sauv_BR_if[i]-1, 1, qc_char);
	}
	sauv_BR_if_indice = 0;
}
| {
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_BZ_if-1, 1, qc_char);
	sauv_BR_if_indice = 0;
}

%%
void updateEntityVal(char* idf, char* val) {
  char typeVal = typeOf(val);
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
	afficher_qdr();
	return 0;
}

int yywrap(){
}

void yyerror(char* msg){
	printf("Erreur syntaxique a la ligne %d\n", num_ligne);
	printf("%s\n", msg);
}


////////////////////////
// Partie quadruplet///
//////////////////////

// ajout d'une ligne
void quadr(char opr[],char op1[],char op2[],char res[])
{
	strcpy(quad[qc].oper, opr);
	strcpy(quad[qc].op1, op1);
	strcpy(quad[qc].op2, op2);
	strcpy(quad[qc].res, res);
	qc++;
}

// ajout d'une colonne
void ajout_quad(int num_quad, int colon_quad, char val [])
{
if (colon_quad==0)    strcpy(quad[num_quad].oper, val);
else if (colon_quad==1)   strcpy(quad[num_quad].op1, val);
         else if (colon_quad==2)    strcpy(quad[num_quad].op2, val);
                   else if (colon_quad==3)    strcpy(quad[num_quad].res, val);
}

// affichage
void afficher_qdr()
{
printf("*********************LesQuadruplets***********************\n");

int i;

for(i=0;i<qc;i++)
		{

printf("\n %d - ( %s  ,  %s  ,  %s  ,  %s )",i,quad[i].oper,quad[i].op1,quad[i].op2,quad[i].res); 
printf("\n---------------------------------------------------\n");

}
}

