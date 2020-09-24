// Stack type
struct Stack {
  int top;
  char array[100][20];
};

// Stack Operations
struct Stack *createStack(unsigned capacity) {
  struct Stack *stack = (struct Stack *)malloc(sizeof(struct Stack));

  if (!stack)
    return NULL;

  stack->top = -1;

  return stack;
}
int isEmpty(struct Stack *stack) { return stack->top == -1; }
char* peek(struct Stack *stack) { return stack->array[stack->top]; }
char* pop(struct Stack *stack) {
  if (!isEmpty(stack))
    return stack->array[stack->top--];
  return "$";
}
void push(struct Stack *stack, char op[]) { strcpy(stack->array[++stack->top], op); }