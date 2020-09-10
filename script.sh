#!/bin/bash
flex lex.l
bison -d syntax.y
gcc lex.yy.c syntax.tab.c -lfl -ly -o compil