%{
	#include<stdio.h>
	#include<string.h>
	#include "syntax.tab.h"
	#include "symbol_table.h"
	extern YYSTYPE yylval;
	void insert(char* idf, char* code);
	void printList();
	int indexOfChar(char alphabet);
	int num_ligne=1;
	Symbol* symbolsTable[26];
	Symbol* find(char *idf);
	char tempType = ' ';
	char tempType2 = ' ';
%}
idf [A-Z]([a-z0-9]*)
integer ([0-9]+)|("("-[0-9]+")")
numeric ([0-9]+"."([0-9])*)|("("-[0-9]+"."([0-9])*")")
cond_operator >|<|==|!=|>=|<=
arit_operator "+"|-|"*"|"/"|%
type_kw "INTEGER"|"NUMERIC"|"CHARACTER"|"LOGICAL"
comment "#"([^\n]*)
taille "["[1-9][0-9]*"]"
%%
{idf} {
  if(yyleng<=10){
    strcpy(yylval.str, yytext);
    insert(yytext, "");
    return idf;
  } else
      printf("erreur lexical : idf trop long\n");
};
{integer} {
  if(atoi(yytext) >= -32768 && atoi(yytext) <= 32767) {
    if(strlen(yytext)>1 && yytext[1] == '-') {
		char temp[strlen(yytext)-2];
		strncpy(temp, yytext+1, strlen(yytext)-2);
		yylval.entier = atoi(temp);
  }
  else
    yylval.entier = atoi(yytext);
  return integer;
  } else
      printf("erreur lexical : integer value is out of range\n");
};
{numeric} {
  if(strlen(yytext)>1 && yytext[1] == '-') {
    char temp[strlen(yytext)-2];
    temp[0] = '-';
    strncpy(temp, yytext+1, strlen(yytext)-2);
    yylval.decimal = atof(temp);
  }
  else
    yylval.decimal = atof(yytext);
  return numeric;
};
'.' {
  yylval.charactere = yytext[1];
  return character;
};
"TRUE" {
  yylval.entier = 1;
  return logical;
};
"FALSE" {
  yylval.entier = 0;
  return logical;
};
{cond_operator} {
  return cond_operator;
};
{arit_operator} {
  yylval.charactere = yytext[0];
  return arit_operator;
};
"<-" {
  strcpy(yylval.str, yytext);
  return equal;
};
"and"|"or" {
  strcpy(yylval.str, yytext);
  return and_or;
};
[a-z]+ {
  strcpy(yylval.str, yytext);
  return index_idf;
}
{type_kw} {
  strcpy(yylval.str, yytext);
  tempType2 = yytext[0] + 32;
  return type;
};
"WHILE" {
  strcpy(yylval.str, yytext);
  return while_kw;
}
"FOR" {
  strcpy(yylval.str, yytext);
  return for_kw;
}
"IN" {
  strcpy(yylval.str, yytext);
  return in_kw;
}
":" {
  return range;
}
"IF" {
	return if_token;
}
"ELSE" {
	return else_token;
}
{taille} {
	char temp[strlen(yytext)-2];
    strncpy(temp, yytext+1, strlen(yytext)-2);
	yylval.entier = atoi(temp);
	return taille;
};
[(] return par_ouvr;
[)] return par_ferm;
"{" return aco_ouvr;
"}" return aco_ferm;
"," return virgule;
"#"([^\n]*)
[ \t]
[\n] {
	tempType = tempType2;
	tempType2 = ' ';
	num_ligne++;
	return num_ligne_token;
};
. {
	printf("erreur lexical a la ligne %d\n", num_ligne);
	exit(0);
};
%%

//display the list
void printList() {
  int i;
  printf("\n/***************Table des symboles ******************/\n");
  printf("_____________________________________________________________\n");
  printf("\t| NomEntite |  CodeEntite \t |  TypeEntite \t |  TailleTab\n");
  printf("_____________________________________________________________\n");
  for(i=0; i<26; i++) {
    Symbol *var = symbolsTable[i];

    while (var != NULL) {
      printf("\t|%10s |%12s  |%14c | %12d\n", var->entityName, var->entityCode,
             var->entityType, var->arraySize);
      var = var ->next;
    }
  }
}

//insert link at the first location
void insert(char idf[], char code[]) {
  if (find(idf) != NULL)
    return;
  // create a link
  Symbol *newVar = (Symbol *)malloc(sizeof(Symbol));

  strcpy(newVar->entityName, idf);
  strcpy(newVar->entityCode, code);
  newVar->entityType = ' ';
  newVar->arraySize = 0;

  // point it to old first node
  newVar->next = symbolsTable[indexOfChar(idf[0])];

  // point first to new first node
  symbolsTable[indexOfChar(idf[0])] = newVar;
  // printList();
}

//find a link with given key
Symbol* find(char* idf) {
  // start from the first link
  Symbol *current = symbolsTable[indexOfChar(idf[0])];

  // if list is empty
  if (symbolsTable[indexOfChar(idf[0])] == NULL) {
    return NULL;
  }

  // navigate through list
  while (strcmp(current->entityName, idf) != 0) {

    // if it is last node
    if (current->next == NULL) {
      return NULL;
    } else {
      // go to next link
      current = current->next;
    }
  }

  // if data found, return the current Link
  return current;
}

char* getVal(char* idf) {
  Symbol* var = find(idf);
  if(var != NULL) {
    return var->entityCode;
  }
  return " ";
}

void setVal(char idf[], char* val) {
  Symbol* var = find(idf);
  if(var != NULL) {
  strcpy(var->entityCode, val);
  }
}

char getType(char* idf) {
  Symbol* var = find(idf);
  if(var != NULL) {
    return var->entityType;
  }
  return ' ';
}

void setType(char idf[], char type) {
  Symbol* var = find(idf);
  if(var != NULL) {
    var->entityType = type;
  }
}

int hasType(char* idf) {
  if(getType(idf) != ' ')
    return 1; // True
  return 0; // False
}

char typeOf(char* val) {
  int size = strlen(val);
  int i;
  if (strcmp(val, "TRUE") == 0 || strcmp(val, "FALSE") == 0)
    return 'l'; //logical
  if (val[0] >= 'A' && val[0] <= 'z')
    return 'c'; //character
  for (i = 1; i < size; i++) {
    if (val[i] == '.')
      return 'n'; //numeric
  }
  return 'i'; //integer
}

int isCompatible(char* idf1, char* idf2) {
  char type1 = typeOf(idf1);
  char type2 = typeOf(idf2);

  if(type1 == type2)
    return 1;
  else if (type1 == 'n' && type2 == 'i' || type1 == 'i' && type2 == 'n')
    return 2;
  return 0;
}

int getArraySize(char* idf) {
  Symbol* var = find(idf);
  if(var != NULL)
    return var->arraySize;
  return -1;
}

int setArraySize(char* idf, int size) {
  Symbol *var = find(idf);
  if (var != NULL) {
    var->arraySize = size;
    return 0;
  }
  return -1;
}

int indexOfChar(char alphabet) {
  return (int)(alphabet - 'A');
}






