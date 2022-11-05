%X COMMENT_LINE COMMENT_BLOCK STRING_STATE

ID                  [a-zA-Z_$][0-9a-zA-Z_$]*
INTLIT              0|([1-9]("_"*[0-9])*)
INTLIT_AUX          [0-9]("_"*[0-9])* 
EXPOENT             ["eE"]("+"|"-")?({INTLIT_AUX})
REALLIT             ({INTLIT_AUX}"."{INTLIT_AUX}?{EXPOENT}?)|("."{INTLIT_AUX}{EXPOENT}?)|({INTLIT_AUX}{EXPOENT})
PARAGRAPH_ESCAPE    "\n"|"\r"|"\r\n"
RESERVED            "++"|"--"|"null"|"Integer"|"System"|"abstract"|"abstract"|"assert"|"break"|"byte"|"case"|"catch"|"char"|"const"|"default"|"do"|"enum"|"extends"|"final"|"finally"|"float"|"for"|"goto"|"implements"|"import"|"instanceof"|"interface"|"long"|"native"|"new"|"package"|"private"|"protected"|"short"|"strictfp"|"super"|"switch"|"synchronized"|"this"|"throw"|"throws"|"transient"|"try"|"volatile"|"continue"

%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "y.tab.h"
int pos = 1;
int line = 1;
bool show_errors = false;
bool show_tokens = false;
int in_state = 0;
int pos_extra = 0;
int string_pos = 0;
int temp_line = 0;
char string_buff[100000];
bool error_found = false;
void yyparse();
%}

%%
"//"                                    {BEGIN COMMENT_LINE; pos+=2;}
<COMMENT_LINE>{PARAGRAPH_ESCAPE}        {BEGIN 0;pos=1;line++;}
<COMMENT_LINE>.                         {pos++;}

"/*"                                    {BEGIN COMMENT_BLOCK; in_state=1;pos_extra=pos; temp_line=line; pos+=2;}
<COMMENT_BLOCK>"*/"                     {BEGIN 0;pos+=2;in_state=0;}
<COMMENT_BLOCK>{PARAGRAPH_ESCAPE}       {pos=1;line++;}
<COMMENT_BLOCK>.                        {pos++;}

"\""                                            {BEGIN STRING_STATE; pos_extra = pos; pos++;error_found=false;in_state=2;string_pos=0;}
<STRING_STATE>\"                                      {BEGIN 0; in_state=0; pos = pos + yyleng;string_buff[string_pos ++]='\0';if(show_tokens && !error_found)printf("STRLIT(\"%s\")\n", string_buff);}
<STRING_STATE>"\\"({PARAGRAPH_ESCAPE})                {BEGIN 0; in_state=0; printf("Line %d, col %d: invalid escape sequence (\\)\n", line, pos); printf("Line %d, col %d: unterminated string literal\n", line, pos_extra); line++; pos = 1;}
<STRING_STATE>"\\"[^"fnrt\\\""]                       {error_found=true; printf("Line %d, col %d: invalid escape sequence (%s)\n", line, pos, yytext);pos+=2;}
<STRING_STATE>"\\"["fnrt\\\""]                        {pos+=2;string_buff[string_pos++]=yytext[0];string_buff[string_pos++]=yytext[1];}
<STRING_STATE>{PARAGRAPH_ESCAPE}                      {BEGIN 0; in_state=0; printf("Line %d, col %d: unterminated string literal\n", line, pos_extra);line++;pos=1;}
<STRING_STATE>.                                       {pos++;string_buff[string_pos++]=yytext[0];}

{RESERVED}                   {pos+=yyleng;if(show_tokens)printf("RESERVED(%s)\n", yytext);return RESERVED;}

";"                          {pos+=yyleng;if(show_tokens)printf("SEMICOLON\n");return SEMICOLON;}
","                          {pos+=yyleng;if(show_tokens)printf("COMMA\n");return COMMA;}
"/"                          {pos+=yyleng;if(show_tokens)printf("DIV\n");return DIV;}
"*"                          {pos+=yyleng;if(show_tokens)printf("STAR\n");return STAR;}
"-"                          {pos+=yyleng;if(show_tokens)printf("MINUS\n");return MINUS;}
"+"                          {pos+=yyleng;if(show_tokens)printf("PLUS\n");return PLUS;}
"=="                         {pos+=yyleng;if(show_tokens)printf("EQ\n");return EQ;}
">="                         {pos+=yyleng;if(show_tokens)printf("GE\n");return GE;}
"{"                          {pos+=yyleng;if(show_tokens)printf("LBRACE\n");return LBRACE;}
"<="                         {pos+=yyleng;if(show_tokens)printf("LE\n");return LE;}
"("                          {pos+=yyleng;if(show_tokens)printf("LPAR\n");return LPAR;}
"["                          {pos+=yyleng;if(show_tokens)printf("LSQ\n");return LSQ;}
"%"|"mod"                    {pos+=yyleng;if(show_tokens)printf("MOD\n");return MOD;}
"!="                         {pos+=yyleng;if(show_tokens)printf("NE\n");return NE;}
"!"                          {pos+=yyleng;if(show_tokens)printf("NOT\n");return NOT;}
"&&"                         {pos+=yyleng;if(show_tokens)printf("AND\n");return AND;}
"||"                         {pos+=yyleng;if(show_tokens)printf("OR\n");return OR;}
"}"                          {pos+=yyleng;if(show_tokens)printf("RBRACE\n");return RBRACE;}
")"                          {pos+=yyleng;if(show_tokens)printf("RPAR\n");return RPAR;}
"]"                          {pos+=yyleng;if(show_tokens)printf("RSQ\n");return RSQ;}
"class"                      {pos+=yyleng;if(show_tokens)printf("CLASS\n");return CLASS;}
"public"                     {pos+=yyleng;if(show_tokens)printf("PUBLIC\n");return PUBLIC;}
"static"                     {pos+=yyleng;if(show_tokens)printf("STATIC\n");return STATIC;}
"Id"                         {pos+=yyleng;if(show_tokens)printf("ID\n");return ID;}
"return"                     {pos+=yyleng;if(show_tokens)printf("RETURN\n");return RETURN;}
"else"                       {pos+=yyleng;if(show_tokens)printf("ELSE\n");return ELSE;}
"if"                         {pos+=yyleng;if(show_tokens)printf("IF\n");return IF;}
"int"                        {pos+=yyleng;if(show_tokens)printf("INT\n");return INT;}
"bool"                       {pos+=yyleng;if(show_tokens)printf("BOOL\n");return BOOL;}
"double"                     {pos+=yyleng;if(show_tokens)printf("DOUBLE\n");return DOUBLE;}
"string"                     {pos+=yyleng;if(show_tokens)printf("STRING\n");return STRING;}
"println"                    {pos+=yyleng;if(show_tokens)printf("PRINT\n");return PRINT;}
"parseInt"                   {pos+=yyleng;if(show_tokens)printf("PARSEINT\n");return PARSEINT;}
"="                          {pos+=yyleng;if(show_tokens)printf("ASSIGN\n");return ASSIGN;}
">"                          {pos+=yyleng;if(show_tokens)printf("GT\n");return GT;}
"<"                          {pos+=yyleng;if(show_tokens)printf("LT\n");return LT;}

%%
int main(int argc, char *argv[]){
    
    if (argc == 2){
        if (strcmp(argv[1],"-l") == 0){
            show_errors = true;
            show_tokens = true;
            yylex();
            // printf("tokens e mensagens de erro");
            }
        if (strcmp(argv[1], "-t")==0){
            show_errors = true;
            yyparse();
            // printf("mensagens de erro");
        }
    }else if (argc ==1){
        yyparse();
        show_errors = true;
        // printf("mensagens de erro");
    }
    else{
        printf("erro");
        return 0;
    }

    if (in_state == 1)
        printf("Line %d, col %d: unterminated comment\n", temp_line, pos_extra);
    else if (in_state == 2)
        printf("Line %d, col %d: unterminated string literal\n", line, pos_extra);

    return 0;
}

int yywrap()
{
return 1;
}
