typedef struct Symbol{
  char entityName[20];
  char entityType;
  int arraySize;
  struct Symbol *next;
} Symbol;