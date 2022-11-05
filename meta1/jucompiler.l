/* Alexandre Silva Regalado 2020212059 */
/* Martim António Aldeia Neves 2020232499 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
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

%}

%X COMMENT_LINE COMMENT_BLOCK STRLIT
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

"\""                                            {BEGIN STRLIT; pos_extra = pos; pos++;error_found=false;in_state=2;string_pos=0;}
<STRLIT>\"                                      {BEGIN 0; in_state=0; pos=pos + yyleng;string_buff[string_pos++]='\0';if(show_tokens && !error_found)printf("STRLIT(\"%s\")\n", string_buff);}
<STRLIT>"\\"({PARAGRAPH_ESCAPE})                {BEGIN 0; in_state=0; printf("Line %d, col %d: invalid escape sequence (\\)\n", line, pos); printf("Line %d, col %d: unterminated string literal\n", line, pos_extra); line++; pos = 1;}
<STRLIT>"\\"[^"fnrt\\\""]                       {error_found=true; printf("Line %d, col %d: invalid escape sequence (%s)\n", line, pos, yytext);pos+=2;}
<STRLIT>"\\"["fnrt\\\""]                        {pos+=2;string_buff[string_pos++]=yytext[0];string_buff[string_pos++]=yytext[1];}
<STRLIT>{PARAGRAPH_ESCAPE}                      {BEGIN 0; in_state=0; printf("Line %d, col %d: unterminated string literal\n", line, pos_extra);line++;pos=1;}
<STRLIT>.                                       {pos++;string_buff[string_pos++]=yytext[0];}

{AND}                       {if(show_tokens)printf("AND\n");pos+=yyleng;}
{ASSIGN}                    {if(show_tokens)printf("ASSIGN\n");pos+=yyleng;}
{STAR}                      {if(show_tokens)printf("STAR\n");pos+=yyleng;}
{COMMA}                     {if(show_tokens)printf("COMMA\n");pos+=yyleng;}
{DIV}                       {if(show_tokens)printf("DIV\n");pos+=yyleng;}
{EQ}                        {if(show_tokens)printf("EQ\n");pos+=yyleng;}
{GE}                        {if(show_tokens)printf("GE\n");pos+=yyleng;}
{GT}                        {if(show_tokens)printf("GT\n");pos+=yyleng;}
{LBRACE}                    {if(show_tokens)printf("LBRACE\n");pos+=yyleng;}
{LE}                        {if(show_tokens)printf("LE\n");pos+=yyleng;}
{LPAR}                      {if(show_tokens)printf("LPAR\n");pos+=yyleng;}
{LSQ}                       {if(show_tokens)printf("LSQ\n");pos+=yyleng;}
{LT}                        {if(show_tokens)printf("LT\n");pos+=yyleng;}
{MINUS}                     {if(show_tokens)printf("MINUS\n");pos+=yyleng;}
{MOD}                       {if(show_tokens)printf("MOD\n");pos+=yyleng;}
{NE}                        {if(show_tokens)printf("NE\n");pos+=yyleng;}
{NOT}                       {if(show_tokens)printf("NOT\n");pos+=yyleng;}
{OR}                        {if(show_tokens)printf("OR\n");pos+=yyleng;}
{PLUS}                      {if(show_tokens)printf("PLUS\n");pos+=yyleng;}
{RBRACE}                    {if(show_tokens)printf("RBRACE\n");pos+=yyleng;}
{RPAR}                      {if(show_tokens)printf("RPAR\n");pos+=yyleng;}
{RSQ}                       {if(show_tokens)printf("RSQ\n");pos+=yyleng;}
{SEMICOLON}                 {if(show_tokens)printf("SEMICOLON\n");pos+=yyleng;}
{ARROW}                     {if(show_tokens)printf("ARROW\n");pos+=yyleng;}
{LSHIFT}                    {if(show_tokens)printf("LSHIFT\n");pos+=yyleng;}
{RSHIFT}                    {if(show_tokens)printf("RSHIFT\n");pos+=yyleng;}
{XOR}                       {if(show_tokens)printf("XOR\n");pos+=yyleng;}
{BOOL}                      {if(show_tokens)printf("BOOL\n");pos+=yyleng;}
{CLASS}                     {if(show_tokens)printf("CLASS\n");pos+=yyleng;}
{DOTLENGTH}                 {if(show_tokens)printf("DOTLENGTH\n");pos+=yyleng;}
{DOUBLE}                    {if(show_tokens)printf("DOUBLE\n");pos+=yyleng;}
{ELSE}                      {if(show_tokens)printf("ELSE\n");pos+=yyleng;}
{IF}                        {if(show_tokens)printf("IF\n");pos+=yyleng;}
{INT}                       {if(show_tokens)printf("INT\n");pos+=yyleng;}
{PRINT}                     {if(show_tokens)printf("PRINT\n");pos+=yyleng;}
{PARSEINT}                  {if(show_tokens)printf("PARSEINT\n");pos+=yyleng;}
{PUBLIC}                    {if(show_tokens)printf("PUBLIC\n");pos+=yyleng;}
{RETURN}                    {if(show_tokens)printf("RETURN\n");pos+=yyleng;}
{STATIC}                    {if(show_tokens)printf("STATIC\n");pos+=yyleng;}
{STRING}                    {if(show_tokens)printf("STRING\n");pos+=yyleng;}
{VOID}                      {if(show_tokens)printf("VOID\n");pos+=yyleng;}
{WHILE}                     {if(show_tokens)printf("WHILE\n");pos+=yyleng;}
{INTLIT}                    {if(show_tokens)printf("INTLIT(%s)\n",yytext);pos+=yyleng;}
{REALLIT}                   {if(show_tokens)printf("REALLIT(%s)\n",yytext);pos+=yyleng;}
{BOOLLIT}                   {if(show_tokens)printf("BOOLLIT(%s)\n", yytext);pos+=yyleng;}
{RESERVED}                  {if(show_tokens)printf("RESERVED(%s)\n", yytext);pos+=yyleng;}
{ID}                        {if(show_tokens)printf("ID(%s)\n",yytext);pos+=yyleng;}
["\t\f "]                   {pos+=1;} 
{PARAGRAPH_ESCAPE}          {line++;pos=1;}
.                           {printf("Line %d, col %d: illegal character (%s)\n", line, pos, yytext);pos++;}
%%

int main(int argc, char *argv[])
{
if (argc == 2){
    if (strcmp(argv[1],"-l")==0){
        show_errors = true;
        show_tokens = true;
        // printf("tokens e mensagens de erro");
        }
    if (strcmp(argv[1], "-e1")==0){
        show_errors = true;
        // printf("mensagens de erro");
    }
}else if (argc ==1){
    show_errors = true;
    // printf("mensagens de erro");
}
else{
    printf("erro");
    return 0;
}
yylex();

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
