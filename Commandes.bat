flex lex.l
Bison -d syntax.y
gcc lex.yy.c Syntax.tab.c  -lfl -ly -o compil.exe