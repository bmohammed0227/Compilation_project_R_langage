%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>
	#include "symbol_table.h"
	#include "quadruplet.h"
  #include "pile.h"
  #include "stack.h"
  #include "infixToPostfix.h"
	char sauvType[20];
	extern int yylex();
	extern int yyparse();
	extern void printList();
	extern FILE *yyin;
	int numero_ligne = 1;
	extern Symbol* symbolsTable[26];
	extern Symbol *find(char *idf);
	extern void insert(char *idf, char *code);
	extern char typeOf(char *val);
	extern char tempType;
	extern char* getVal(char* idf);
	extern char getType(char* idf);
  extern int infixToPostfix(char* res, char* exp);
  int postfixToQuadruple(char *exp);
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
	void generation_code_machine();
  char operation[200];
  char postfixExp[200];
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
%token num_ligne_token
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

S : S affectation  nouvelle_ligne
| S declaration nouvelle_ligne
| S incrementation_decrementation nouvelle_ligne
| S loop nouvelle_ligne
| S if_instruction nouvelle_ligne
| nouvelle_ligne
;

nouvelle_ligne : num_ligne_token {numero_ligne++;}
|
;

affectation : idf variableType equal {operation[0]='\0';} operation_arithmetique_logique {
	char idf_array[strlen($1)];
	strcpy(idf_array, $1);
	if($2 != 0){
		char size[10];
		sprintf(size, "@%d", $2);
		strcat(idf_array, size);
	}
	updateEntityVal(idf_array, $5);
	quadr(":=", getVal(idf_array), "", idf_array);
}
| type idf variableType equal {operation[0]='\0';} operation_arithmetique_logique {
  char idf_array[strlen($2)];
  strcpy(idf_array, $2);
  if ($3 != 0) {
    char size[10];
    sprintf(size, "@%d", $3);
    strcat(idf_array, size);
	}
	
	updateEntityVal(idf_array, $6);
	quadr(":=", getVal(idf_array), "", idf_array);
}
| idf variableType equal if_token else_token par_ouvr operation_logique virgule operation_arithmetique_logique virgule operation_arithmetique_logique par_ferm {
  char idf_array[strlen($1)];
  strcpy(idf_array, $1);
  if ($2 != 0) {
    char size[10];
    sprintf(size, "@%d", $2);
    strcat(idf_array, size);
	}
	
	if($7==1){
		updateEntityVal(idf_array, $9);
		quadr(":=", $9, "", idf_array);
	}else{
		updateEntityVal(idf_array, $11);
		quadr(":=", $11, "", idf_array);
	}
	
}
| type idf variableType equal if_token else_token par_ouvr {operation[0]='\0';} operation_logique virgule {operation[0]='\0';} operation_arithmetique_logique virgule {operation[0]='\0';} operation_arithmetique_logique par_ferm{

  printf("%d Operation : %s\n", numero_ligne, operation);
  char idf_array[strlen($2)];
  strcpy(idf_array, $2);
  if ($3 != 0) {
    char size[10];
    sprintf(size, "@%d", $3);
    strcat(idf_array, size);
	}
	
	if($9==1){
		updateEntityVal(idf_array, $12);
		quadr(":=", $12, "", idf_array);
	}else{
		updateEntityVal(idf_array, $15);
		quadr(":=", $15, "", idf_array);
	}
}
;

declaration : type list_idf
;

list_idf : idf variableType {
	if($2 ==0){
		//declaration normal
		updateEntityType($1, tempType);
		updateEntitySize($1, $2);
		quadr("Dec", $1, "", "");
	}else{
		//declaration multiple
		char idf_array[strlen($1)];
		strcpy(idf_array, $1);
		updateEntityType(idf_array, tempType);
		updateEntitySize(idf_array, $2);
		int size = $2;
		for(int i=1; i<=size; i++){
			char i_str[10];
			sprintf(i_str, "@%d", i);
			strcpy(idf_array, $1);
			strcat(idf_array, i_str);
			insert(idf_array, "");
			updateEntityType(idf_array, tempType);
			updateEntitySize(idf_array, 0);
			quadr("Dec", idf_array, "", "");
		}
	}
  
}
| idf variableType {
 	if($2 ==0){
		//declaration normal
		updateEntityType($1, tempType);
		updateEntitySize($1, $2);
		quadr("Dec", $1, "", "");
	}else{
		//declaration multiple
		char idf_array[strlen($1)];
		strcpy(idf_array, $1);
		updateEntityType(idf_array, tempType);
		updateEntitySize(idf_array, $2);
		int size = $2;
		for(int i=1; i<=size; i++){
			char i_str[10];
			sprintf(i_str, "@%d", i);
			strcpy(idf_array, $1);
			strcat(idf_array, i_str);
			insert(idf_array, "");
			updateEntityType(idf_array, tempType);
			updateEntitySize(idf_array, 0);
			quadr("Dec", idf_array, "", "");
		}
	}
} virgule list_idf 
;

variableType: taille {$$ = $1;}
| {$$ = 0;}
;

operation_arithmetique_logique : operation_arithmetique {
  postfixExp[0] = '\0';
  infixToPostfix(postfixExp, operation);
  postfixToQuadruple(postfixExp);
  strcpy($$, quad[qc-1].res);}
| operation_logique {
  postfixExp[0] = '\0';
  infixToPostfix(postfixExp, operation);
  postfixToQuadruple(postfixExp);
  /* strcpy($$, quad[qc].op1); */
  if ($1 == 1)
    strcpy($$, "TRUE");
  else
    strcpy($$, "FALSE");
 }
;

operation_arithmetique: expression_A {strcat(operation, " ");strcpy($$, $1);}
| expression_A {
  strcat(operation, " ");
}
arit_operator {
  char temp[2];
  temp[0] = $3;
  temp[1] = ' ';
  strcat(operation, temp);
} operation_arithmetique {
  calculate($$, $1, $5, $3);
}
| par_ouvr {strcat(operation, "( ");} operation_arithmetique par_ferm {strcat(operation, ") ");strcpy($$, $3);}
;

expression_A : integer {
  snprintf($$, 20, "%d", $1);
  strcat(operation, $$);
}
| numeric {
  snprintf($$, 20, "%f", $1);
  strcat(operation, $$);
}
| character {
  $$[0] = $1;
  $$[1] = '\0';
  strcat(operation, $$);
}
| idf variableType{

	char idf_array[strlen($1)];
	strcpy(idf_array, $1);
	if($2 != 0){
		char size[10];
		sprintf(size, "@%d", $2);
		strcat(idf_array, size);
	}
	strcat(operation, idf_array);
	strcpy($$, getVal(idf_array));
	}
// | par_ouvr expression_A par_ferm {strcpy($$, $2);}
;

operation_comparaison : par_ouvr operation_arithmetique cond_operator {
  strcat(operation, $3);
  strcat(operation, " ");
}
operation_arithmetique par_ferm {
  $$ = calculateCond($2, $5, $3);
}
| operation_arithmetique cond_operator {
  strcat(operation, $2);
  strcat(operation, " ");
}
operation_arithmetique {
  $$ = calculateCond($1, $4, $2);
};

operation_logique:  operation_comparaison and_or {
  strcat(operation, $2);
  strcat(operation, " ");
} operation_logique {$$ = calculateLogic($1, $4, $2);}
|	operation_comparaison {$$ = $1;}
| logical {
  if ($1 == 1)
    strcat(operation, "TRUE");
  else
    strcat(operation, "FALSE");
  strcat(operation, " ");
}
and_or {
  strcat(operation, $3);
  strcat(operation, " ");
}
operation_logique { $$ = calculateLogic($1, $5, $3); }
| logical {
  if ($1 == 1)
    strcat(operation, "TRUE");
  else
    strcat(operation, "FALSE");
  strcat(operation, " ");
  $$ = $1;
}
;

incrementation_decrementation : idf variableType arit_operator equal integer {

	char idf_array[strlen($1)];
	strcpy(idf_array, $1);
	if($2 != 0){
		char size[10];
		sprintf(size, "@%d", $2);
		strcat(idf_array, size);
	}


 incrementation_decrementation(idf_array, $3, $5);
 char integer_str[20];
 sprintf(integer_str, "%d", $5);
 if($3 == '+') quadr("+", idf_array, integer_str, idf_array);
 else quadr("-", idf_array, integer_str, idf_array);
};

loop : while_kw par_ouvr {operation[0]='\0';} operation_logique par_ferm 
{
	sprintf(sauv_BR_while[sauv_BR_while_indice], "%d", qc);
	sauv_BR_while_indice++;
	sauv_bz_while[sauv_bz_while_indice] = qc;
	sauv_bz_while_indice++;
	if($4 == 0)
		quadr("BZ", "FALSE", "", "");
	else quadr("BZ", "TRUE", "", "");
}
aco_ouvr S aco_ferm
{
	quadr("BR", "", "", sauv_BR_while[sauv_BR_while_indice-1]);
	sauv_BR_while_indice--;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_bz_while[sauv_bz_while_indice-1], 3, qc_char);
	sauv_bz_while_indice--;
}
| for_kw par_ouvr index_idf in_kw integer range integer par_ferm 
{
	sprintf(sauv_BR_for[sauv_BR_for_indice], "%d", qc);
	sauv_BR_for_indice++;
	sauv_bz_for[sauv_bz_for_indice] = qc;
	sauv_bz_for_indice++;
	if($5 == $7)
		quadr("BZ", "FALSE", "", "");
	else quadr("BZ", "TRUE", "", ""); 
}
aco_ouvr S aco_ferm 
{
	quadr("BR", "", "", sauv_BR_for[sauv_BR_for_indice-1]);
	sauv_BR_for_indice--;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_bz_for[sauv_bz_for_indice-1], 3, qc_char);
	sauv_bz_for_indice--;
}
;

if_instruction : if_token par_ouvr {operation[0]='\0';} operation_logique par_ferm 
{
	if($4 == 0)
		quadr("BZ", "FALSE", "", "");
	else quadr("BZ", "TRUE", "", ""); 
	sauv_BZ_if = qc;
}
aco_ouvr S aco_ferm ELSE 

ELSE : else_token
 {
	quadr("BR", "", "", "");
	sauv_BR_if[sauv_BR_if_indice] = qc;
	sauv_BR_if_indice++;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_BZ_if-1, 3, qc_char);
}
 if_instruction {
	sprintf(qc_char, "%d", qc);
	for(int i=0; i<=sauv_BR_if_indice; i++){
		ajout_quad(sauv_BR_if[i]-1, 3, qc_char);
	}
	sauv_BR_if_indice = 0;
}
| else_token {
	quadr("BR", "", "", "");
	sauv_BR_if[sauv_BR_if_indice] = qc;
	sauv_BR_if_indice++;
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_BZ_if-1, 3, qc_char);
}
 aco_ouvr S aco_ferm {
	sprintf(qc_char, "%d", qc);
	for(int i=0; i<=sauv_BR_if_indice; i++){
		ajout_quad(sauv_BR_if[i]-1, 3, qc_char);
	}
	sauv_BR_if_indice = 0;
}
| {
	sprintf(qc_char, "%d", qc);
	ajout_quad(sauv_BZ_if-1, 3, qc_char);
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
    /* printList(); */
	afficher_qdr();
	generation_code_machine();
	return 0;
}

int yywrap(){
}

void yyerror(char* msg){
	printf("\nErreur syntaxique a la ligne %d\n", numero_ligne);
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

int label(int num){
    char str_num[10];
    sprintf(str_num, "%d", num);
    for(int i=1; i<=qc; i++){
        if (strcmp(quad[i].oper, "BR")==0 && strcmp(quad[i].res, str_num)==0){
            return 1;
        }
    }
    return 0;
}

int isIdf(char* str){
    if(str[0] == 'A' || str[0] == 'B' || str[0] == 'C' || str[0] == 'D' ||
       str[0] == 'E' || str[0] == 'F' || str[0] == 'G' || str[0] == 'H' ||
       str[0] == 'I' || str[0] == 'J' || str[0] == 'K' || str[0] == 'L' ||
       str[0] == 'M' || str[0] == 'N' || str[0] == 'O' || str[0] == 'P' ||
       str[0] == 'Q' || str[0] == 'R' || str[0] == 'S' || str[0] == 'T' ||
       str[0] == 'U' || str[0] == 'V' || str[0] == 'W' || str[0] == 'X' ||
       str[0] == 'Y' || str[0] == 'Z')
        return 1;
    return 0;
}

int opr(char* token){
    if(strcmp(token, "+")==0 || strcmp(token, "-")==0 || strcmp(token, "*")==0 || strcmp(token, "/")==0 )
        return 0;
    return 1;
}

int postfixToQuadruple(char *exp) {
    Pile* pile = initialiser();
    char* token = strtok(exp, " ");
    int j = 1;
    while(token != NULL){
        if(opr(token)==1)
            empiler(pile, token);
        else{
            char* opr = token;
            char* op1 = depiler(pile);
            char* op2 = depiler(pile);
            char str_j[10];
            sprintf(str_j,"%d", j);
            char temp[] = "t";
            strcat(temp, str_j);
            quadr("Dec", temp, "", "");
            quadr(opr, op1, op2, temp);
            empiler(pile, strdup(temp));
            j++;
        }
        token = strtok(NULL, " ");
    }
    return 0;
}

void generation_code_machine(){
    int type_branchement;
    FILE* f = fopen("code_machine.asm", "w");
    fprintf(f, "TITLE code_machine.asm: R language compiler \n");
    fprintf(f, "CODE segment\n");
    fprintf(f, "MAIN:\n");
    fprintf(f, "ASSUME CS:CODE, DS:DATA, SS:Pile\n");
    for(int i=1; i<=qc; i++){
    if(label(i)==1){
        fprintf(f,"Label_%d: ",i);
    }
    if((strcmp(quad[i].oper, "Dec"))==0){
        fprintf(f, "%s DW ?\n",quad[i].op1);
    }else   if((strcmp(quad[i].oper, ":="))==0){
        if(isIdf(quad[i].op1)==1){
            fprintf(f, "MOV AX, %s\n",quad[i].op1);
            fprintf(f, "MOV %s, AX\n",quad[i].res);
        }
        else{
            fprintf(f, "MOV %s, %s\n",quad[i].res, quad[i].op1);
        }
    }else   if((strcmp(quad[i].oper, ">"))==0){
                type_branchement = 4;
                fprintf(f,"MOV AX, %s\n",quad[i].op1);
                fprintf(f,"CMP AX, %s\n",quad[i].op2);
    }else   if((strcmp(quad[i].oper, "<"))==0){
                type_branchement = 3;
                fprintf(f,"MOV AX, %s\n",quad[i].op1);
                fprintf(f,"CMP AX, %s\n",quad[i].op2);
    }else   if((strcmp(quad[i].oper, "=="))==0){
                type_branchement = 5;
                fprintf(f,"MOV AX, %s\n",quad[i].op1);
                fprintf(f,"CMP AX, %s\n",quad[i].op2);
    }else   if((strcmp(quad[i].oper, ">="))==0){
                type_branchement = 1;
                fprintf(f,"MOV AX, %s\n",quad[i].op1);
                fprintf(f,"CMP AX, %s\n",quad[i].op2);
    }else   if((strcmp(quad[i].oper, "<="))==0){
                type_branchement = 0;
                fprintf(f,"MOV AX, %s\n",quad[i].op1);
                fprintf(f,"CMP AX, %s\n",quad[i].op2);
    }else   if((strcmp(quad[i].oper, "!="))==0){
                type_branchement = 2;
                fprintf(f,"MOV AX, %s\n",quad[i].op1);
                fprintf(f,"CMP AX, %s\n",quad[i].op2);
    }else   if((strcmp(quad[i].oper, "+"))==0){
                fprintf(f, "MOV AX, %s\n",quad[i].op1);
                fprintf(f, "ADD AX, %s\n",quad[i].op2);
                fprintf(f, "MOV %s, AX\n",quad[i].res);
    }else   if((strcmp(quad[i].oper, "-"))==0){
                fprintf(f, "MOV AX, %s\n",quad[i].op1);
                fprintf(f, "SUB AX, %s\n",quad[i].op2);
                fprintf(f, "MOV %s, AX\n",quad[i].res);
    }else   if((strcmp(quad[i].oper, "*"))==0){
                fprintf(f, "MOV AX, %s\n",quad[i].op1);
                fprintf(f, "MOV BX, %s\n",quad[i].op2);
                fprintf(f, "MUL AX\n");
                fprintf(f, "MOV %s, AX\n",quad[i].res);
    }else   if((strcmp(quad[i].oper, "/"))==0){
                fprintf(f, "MOV AX, %s\n",quad[i].op1);
                fprintf(f, "MOV BX, %s\n",quad[i].op2);
                fprintf(f, "DIV AX\n");
                fprintf(f, "MOV %s, AX\n",quad[i].res);
    }else   if((strcmp(quad[i].oper, "%"))==0){// ********
                fprintf(f, "MOV AX, %s\n",quad[i].op1);
                fprintf(f, "MOV BX, %s\n",quad[i].op2);
                fprintf(f, "DIV AX\n");
                fprintf(f, "MOV %s, DX\n",quad[i].res);
    }else   if((strcmp(quad[i].oper, "BZ"))==0){
                fprintf(f, "CMP %s, 0\n",quad[i].op1);
                fprintf(f, "JE label_%s\n", quad[i].res);
    }else   if((strcmp(quad[i].oper, "BR"))==0){
                switch(type_branchement){
                    case 0: {
                        fprintf(f, "JA Label_%s\n",quad[i].res);
                    }
                    break;
                    case 1: {
                       fprintf(f, "JL Label_%s\n",quad[i].res);
                    }
                    break;
                    case 2: {
                        fprintf(f, "JE Label_%s\n",quad[i].res);
                    }
                    break;
                    case 3: {
                        fprintf(f, "JAE Label_%s\n",quad[i].res);
                    }
                    break;
                    case 4: {
                        fprintf(f, "JLE Label_%s\n",quad[i].res);
                    }
                    break;
                    case 5: {
                        fprintf(f, "JNE Label_%s\n",quad[i].res);
                    }
                    break;
                    case 6: {
                        fprintf(f, "JMP Label_%s\n",quad[i].res);
                    }
                    break;
                }
                    type_branchement = 6;
            }
    }
    fflush(f);
}

