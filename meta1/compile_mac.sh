#!/bin/sh

# run lex and compile the resulting C analyser
flex jucompiler.l
xcrun clang -o jucompiler lex.yy.c

# 'lex' and 'gcc' are commonly available too