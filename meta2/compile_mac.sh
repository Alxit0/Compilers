#!/bin/sh

# run lex and compile the resulting C analyser
flex jucompiler.l
yacc -ydtv jucompiler.y
xcrun clang -o jucompiler y.tab.c lex.yy.c

# 'lex' and 'gcc' are commonly available too