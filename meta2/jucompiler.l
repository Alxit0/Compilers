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

%X COMMENT_LINE COMMENT_BLOCK STRING_STATE

ID                  [a-zA-Z_$][0-9a-zA-Z_$]*
INTLIT              0|([1-9]("_"*[0-9])*)
INTLIT_AUX          [0-9]("_"*[0-9])* 
EXPOENT             ["eE"]("+"|"-")?({INTLIT_AUX})
REALLIT             ({INTLIT_AUX}"."{INTLIT_AUX}?{EXPOENT}?)|("."{INTLIT_AUX}{EXPOENT}?)|({INTLIT_AUX}{EXPOENT})
PARAGRAPH_ESCAPE    "\n"|"\r"|"\r\n"
BOOLLIT             ("true"|"false")
AND                 "&&"
ASSIGN              "="
STAR                "*"
COMMA               "," 
DIV                 "/"
EQ                  "=="
GE                  ">="
GT                  ">"
LBRACE              "{"
LE                  "<="
LPAR                "("
LSQ                 "["
LT                  "<"
MINUS               "-"
MOD                 "%"
NE                  "!="
NOT                 "!"
OR                  "||"
PLUS                "+"
RBRACE              "}"
RPAR                ")"
RSQ                 "]"
SEMICOLON           ";"
ARROW               "->"
RSHIFT              ">>"
LSHIFT              "<<"
XOR                 "^"
BOOL                "boolean"
CLASS               "class"
DOTLENGTH           ".length"
DOUBLE              "double"
ELSE                "else"
IF                  "if"
INT                 "int"
PRINT               "System.out.print"
PARSEINT            "Integer.parseInt"
PUBLIC              "public"
RETURN              "return"
STATIC              "static"
STRING              "String"
VOID                "void"
WHILE               "while"
RESERVED            "++"|"--"|"null"|"Integer"|"System"|"abstract"|"abstract"|"assert"|"break"|"byte"|"case"|"catch"|"char"|"const"|"default"|"do"|"enum"|"extends"|"final"|"finally"|"float"|"for"|"goto"|"implements"|"import"|"instanceof"|"interface"|"long"|"native"|"new"|"package"|"private"|"protected"|"short"|"strictfp"|"super"|"switch"|"synchronized"|"this"|"throw"|"throws"|"transient"|"try"|"volatile"|"continue"

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

{AND}                       {if(show_tokens)printf("AND\n");pos+=yyleng;return AND;}
{ASSIGN}                    {if(show_tokens)printf("ASSIGN\n");pos+=yyleng;return ASSIGN;}
{STAR}                      {if(show_tokens)printf("STAR\n");pos+=yyleng;return STAR;}
{COMMA}                     {if(show_tokens)printf("COMMA\n");pos+=yyleng;return COMMA;}
{DIV}                       {if(show_tokens)printf("DIV\n");pos+=yyleng;return DIV;}
{EQ}                        {if(show_tokens)printf("EQ\n");pos+=yyleng;return EQ;}
{GE}                        {if(show_tokens)printf("GE\n");pos+=yyleng;return GE;}
{GT}                        {if(show_tokens)printf("GT\n");pos+=yyleng;return GT;}
{LBRACE}                    {if(show_tokens)printf("LBRACE\n");pos+=yyleng;return LBRACE;}
{LE}                        {if(show_tokens)printf("LE\n");pos+=yyleng;return LE;}
{LPAR}                      {if(show_tokens)printf("LPAR\n");pos+=yyleng;return LPAR;}
{LSQ}                       {if(show_tokens)printf("LSQ\n");pos+=yyleng;return LSQ;}
{LT}                        {if(show_tokens)printf("LT\n");pos+=yyleng;return LT;}
{MINUS}                     {if(show_tokens)printf("MINUS\n");pos+=yyleng;return MINUS;}
{MOD}                       {if(show_tokens)printf("MOD\n");pos+=yyleng;return MOD;}
{NE}                        {if(show_tokens)printf("NE\n");pos+=yyleng;return NE;}
{NOT}                       {if(show_tokens)printf("NOT\n");pos+=yyleng;return NOT;}
{OR}                        {if(show_tokens)printf("OR\n");pos+=yyleng;return OR;}
{PLUS}                      {if(show_tokens)printf("PLUS\n");pos+=yyleng;return PLUS;}
{RBRACE}                    {if(show_tokens)printf("RBRACE\n");pos+=yyleng;return RBRACE;}
{RPAR}                      {if(show_tokens)printf("RPAR\n");pos+=yyleng;return RPAR;}
{RSQ}                       {if(show_tokens)printf("RSQ\n");pos+=yyleng;return RSQ;}
{SEMICOLON}                 {if(show_tokens)printf("SEMICOLON\n");pos+=yyleng;return SEMICOLON;}
{ARROW}                     {if(show_tokens)printf("ARROW\n");pos+=yyleng;}
{LSHIFT}                    {if(show_tokens)printf("LSHIFT\n");pos+=yyleng;return LSHIFT;}
{RSHIFT}                    {if(show_tokens)printf("RSHIFT\n");pos+=yyleng;return RSHIFT;}
{XOR}                       {if(show_tokens)printf("XOR\n");pos+=yyleng;return XOR;}
{BOOL}                      {if(show_tokens)printf("BOOL\n");pos+=yyleng;return BOOL;}
{CLASS}                     {if(show_tokens)printf("CLASS\n");pos+=yyleng;return CLASS;}
{DOTLENGTH}                 {if(show_tokens)printf("DOTLENGTH\n");pos+=yyleng;return DOTLENGTH;}
{DOUBLE}                    {if(show_tokens)printf("DOUBLE\n");pos+=yyleng;return DOUBLE;}
{ELSE}                      {if(show_tokens)printf("ELSE\n");pos+=yyleng;return ELSE;}
{IF}                        {if(show_tokens)printf("IF\n");pos+=yyleng;return IF;}
{INT}                       {if(show_tokens)printf("INT\n");pos+=yyleng;return INT;}
{PRINT}                     {if(show_tokens)printf("PRINT\n");pos+=yyleng;return PRINT;}
{PARSEINT}                  {if(show_tokens)printf("PARSEINT\n");pos+=yyleng;return PARSEINT;}
{PUBLIC}                    {if(show_tokens)printf("PUBLIC\n");pos+=yyleng;return PUBLIC;}
{RETURN}                    {if(show_tokens)printf("RETURN\n");pos+=yyleng;return RETURN;}
{STATIC}                    {if(show_tokens)printf("STATIC\n");pos+=yyleng;return STATIC;}
{STRING}                    {if(show_tokens)printf("STRING\n");pos+=yyleng;return STRING;}
{VOID}                      {if(show_tokens)printf("VOID\n");pos+=yyleng;return VOID;}
{WHILE}                     {if(show_tokens)printf("WHILE\n");pos+=yyleng;return WHILE;}

{INTLIT}                    {if(show_tokens)printf("INTLIT(%s)\n",yytext);pos+=yyleng;return INTLIT;}
{REALLIT}                   {if(show_tokens)printf("REALLIT(%s)\n",yytext);pos+=yyleng;return REALLIT;}
{BOOLLIT}                   {if(show_tokens)printf("BOOLLIT(%s)\n", yytext);pos+=yyleng;return BOOLLIT;}
{RESERVED}                  {if(show_tokens)printf("RESERVED(%s)\n", yytext);pos+=yyleng;}
{ID}                        {if(show_tokens)printf("ID(%s)\n",yytext);pos+=yyleng;return ID;}

["\t\f "]                   {pos+=1;} 
{PARAGRAPH_ESCAPE}          {line++;pos=1;}
.                           {printf("Line %d, col %d: illegal character (%s)\n", line, pos, yytext);pos++;}

%%
int main(int argc, char *argv[]){
    
    if (argc == 2){
        if (strcmp(argv[1],"-l") == 0){
            show_errors = true;
            show_tokens = true;
            yylex();
            // printf("tokens e mensagens de erro");
            }
        if (strcmp(argv[1], "-e1")==0){
            show_errors = true;
            yylex();
            // printf("mensagens de erro");
        }
        if (strcmp(argv[1], "-t")==0){
            yyparse();
            // printf("mensagens de erro");
        }
        if (strcmp(argv[1], "-e2")==0){
            yyparse();
            // printf("mensagens de erro");
        }
    }else if (argc ==1){
        show_errors = true;
        show_tokens = false;
        yylex();
        yyparse();
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

void yyerror(char *s){
    printf("Line %d col %d: %s: %s\n", line, (int)( pos - strlen(yytext)), s, yytext);
}