#!/bin/sh

# run lex and compile the resulting C analyser
flex jucompiler.l
yacc -ydtv jucompiler.y
xcrun clang -o jucompiler y.tab.c lex.yy.c arvore.c
# ./test.sh ./jucompiler
# 'lex' and 'gcc' are commonly available too