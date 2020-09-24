
// A utility function to check if the given character is operand
int isOperand(char item[]) {
  return (item[0] >= 'A' && item[0] <= 'Z') || (item[0] >= '0' && item[0] <= '9');
}

// A utility function to return precedence of a given operator
// Higher returned value means higher precedence
int Prec(char item[]) {
  if (item[0] == 'a') // and
    return 1;
  if (item[0] == 'o') // or
    return 2;
  if (item[0] == '>' || item[0] == '<' || item[0] == '=' || item[0] == '!')
    return 3;
  if (item[0] == '+' || item[0] == '-')
    return 4;
  if (item[0] == '*' || item[0] == '/' || item[0] == '%')
    return 5;
  return -1;
}

// The main function that converts given infix expression
// to postfix expression.
int infixToPostfix(char *res, char *exp) {

  // Create a stack of capacity equal to expression size
  struct Stack *stack = createStack(strlen(exp));
  if (!stack) // See if stack was created successfully
    return -1;

  int i, k, j, itemRead;
  char item[10];
  int size = strlen(exp);

  for(i=0, k=0 ; i<size; i++) {
    if(exp[i] == ' ') {
      strncpy(item, exp+k, i-k);
      item[i-k] = '\0';
      k = i+1;
      itemRead = 1;
    }
    else if (i == size - 1) {
      strncpy(item, exp+k, i+1-k);
      item[i+1-k] = '\0';
      itemRead = 1;
    }
    else {
      itemRead = 0;
    }

    if (itemRead == 1) {
      // If the scanned character is an operand, add it to output.
      if (isOperand(item) == 1) {
        strcat(res, item);
        strcat(res, " ");
      }

      // If the scanned character is an â€˜(â€˜, push it to the st
      else if (item[0] == '(') {
        push(stack, item);
        // printf("%s %s\n",item, peek(stack));
      }

      // If the scanned character is an â€˜)â€™, pop and output from the s
      // until an â€˜(â€˜ is encounte
      else if (item[0] == ')') {
        while (!isEmpty(stack) && peek(stack)[0] != '(') {
            strcat(res, pop(stack));
            strcat(res, " ");
        }
        if (!isEmpty(stack) && peek(stack)[0] != '(')
          return -1; // invalid expression
        else
          pop(stack);
      } else // an operator is encountered
      {
        while (!isEmpty(stack) && Prec(item) <= Prec(peek(stack))) {
          strcat(res, pop(stack));
          strcat(res, " ");
        }
        push(stack, item);
      }
        // printf("%s\n",item);
    }
  }

  // pop all the operators from the stack
  while (!isEmpty(stack)) {
    strcat(res, pop(stack));
    strcat(res, " ");
  }

  // res[++k] = '\0';
}
