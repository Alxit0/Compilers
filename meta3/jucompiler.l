/* Alexandre Silva Regalado 2020212059 */
/* Martim António Aldeia Neves 2020232499 */

%{

    #include "y.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include <stdbool.h>

    #include "semantics.h"

    extern struct Node *root;
    char guarda[256];
    
    int pos = 1;
    int line = 1;
    bool show_tokens = false;
    bool return_stf = false;
    bool syntax_error_found = false;
    int in_state = 0;
    int pos_extra = 0;
    int string_pos = 0;
    int temp_line = 0;
    char string_buff[100000];
    bool error_found = false;

    int yyparse(void);
    void cleanTree();
    void print_tree();
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

"/*"                                    {BEGIN COMMENT_BLOCK; pos_extra=pos; temp_line=line; pos+=2;}
<COMMENT_BLOCK>"*/"                     {BEGIN 0;pos+=2;}
<COMMENT_BLOCK>{PARAGRAPH_ESCAPE}       {pos=1;line++;}
<COMMENT_BLOCK><<EOF>>                  {BEGIN 0; printf("Line %d, col %d: unterminated comment\n", temp_line, pos_extra);}
<COMMENT_BLOCK>.                        {pos++;}

"\""                                            {BEGIN STRING_STATE;in_state=1;pos_extra = pos; pos++;error_found=false;in_state=2;string_pos=0;}
<STRING_STATE>\"                                      {BEGIN 0; in_state=0;pos = pos + yyleng;string_buff[string_pos ++]='\0';if(show_tokens && !error_found)printf("STRLIT(\"%s\")\n", string_buff);if(return_stf && !error_found){yylval.tk = create_tk_cont(strdup(string_buff), pos-yyleng, line);return STRLIT;}}
<STRING_STATE>"\\"({PARAGRAPH_ESCAPE})                {BEGIN 0; printf("Line %d, col %d: invalid escape sequence (\\)\n", line, pos); printf("Line %d, col %d: unterminated string literal\n", line, pos_extra); line++; pos = 1;}
<STRING_STATE>"\\"[^"fnrt\\\""]                       {error_found=true; printf("Line %d, col %d: invalid escape sequence (%s)\n", line, pos, yytext);pos+=2;}
<STRING_STATE>"\\"["fnrt\\\""]                        {pos+=2;string_buff[string_pos++]=yytext[0];string_buff[string_pos++]=yytext[1];}
<STRING_STATE>{PARAGRAPH_ESCAPE}                      {BEGIN 0; printf("Line %d, col %d: unterminated string literal\n", line, pos_extra);line++;pos=1;}
<STRING_STATE><<EOF>>                                 {BEGIN 0; printf("Line %d, col %d: unterminated string literal\n", line, pos);}
<STRING_STATE>.                                       {pos++;string_buff[string_pos++]=yytext[0];}

{AND}                       {if(show_tokens)printf("AND\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return AND;};}
{ASSIGN}                    {if(show_tokens)printf("ASSIGN\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return ASSIGN;}}
{STAR}                      {if(show_tokens)printf("STAR\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return STAR;}}
{COMMA}                     {if(show_tokens)printf("COMMA\n");pos+=yyleng;if(return_stf)return COMMA;}
{DIV}                       {if(show_tokens)printf("DIV\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return DIV;}}
{EQ}                        {if(show_tokens)printf("EQ\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return EQ;}}
{GE}                        {if(show_tokens)printf("GE\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return GE;}}
{GT}                        {if(show_tokens)printf("GT\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return GT;}}
{LBRACE}                    {if(show_tokens)printf("LBRACE\n");pos+=yyleng;if(return_stf)return LBRACE;}
{LE}                        {if(show_tokens)printf("LE\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return LE;}}
{LPAR}                      {if(show_tokens)printf("LPAR\n");pos+=yyleng;if(return_stf)return LPAR;}
{LSQ}                       {if(show_tokens)printf("LSQ\n");pos+=yyleng;if(return_stf)return LSQ;}
{LT}                        {if(show_tokens)printf("LT\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return LT;}}
{MINUS}                     {if(show_tokens)printf("MINUS\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return MINUS;}}
{MOD}                       {if(show_tokens)printf("MOD\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return MOD;}}
{NE}                        {if(show_tokens)printf("NE\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return NE;}}
{NOT}                       {if(show_tokens)printf("NOT\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return NOT;}}
{OR}                        {if(show_tokens)printf("OR\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return OR;}}
{PLUS}                      {if(show_tokens)printf("PLUS\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return PLUS;}}
{RBRACE}                    {if(show_tokens)printf("RBRACE\n");pos+=yyleng;if(return_stf)return RBRACE;}
{RPAR}                      {if(show_tokens)printf("RPAR\n");pos+=yyleng;if(return_stf)return RPAR;}
{RSQ}                       {if(show_tokens)printf("RSQ\n");pos+=yyleng;if(return_stf)return RSQ;}
{SEMICOLON}                 {if(show_tokens)printf("SEMICOLON\n");pos+=yyleng;if(return_stf)return SEMICOLON;}
{ARROW}                     {if(show_tokens)printf("ARROW\n");pos+=yyleng;}
{LSHIFT}                    {if(show_tokens)printf("LSHIFT\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return LSHIFT;}}
{RSHIFT}                    {if(show_tokens)printf("RSHIFT\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return RSHIFT;}}
{XOR}                       {if(show_tokens)printf("XOR\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return XOR;}}
{BOOL}                      {if(show_tokens)printf("BOOL\n");pos+=yyleng;if(return_stf)return BOOL;}
{CLASS}                     {if(show_tokens)printf("CLASS\n");pos+=yyleng;if(return_stf)return CLASS;}
{DOTLENGTH}                 {if(show_tokens)printf("DOTLENGTH\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return DOTLENGTH;}}
{DOUBLE}                    {if(show_tokens)printf("DOUBLE\n");pos+=yyleng;if(return_stf)return DOUBLE;}
{ELSE}                      {if(show_tokens)printf("ELSE\n");pos+=yyleng;if(return_stf)return ELSE;}
{IF}                        {if(show_tokens)printf("IF\n");pos+=yyleng;if(return_stf)return IF;}
{INT}                       {if(show_tokens)printf("INT\n");pos+=yyleng;if(return_stf)return INT;}
{PRINT}                     {if(show_tokens)printf("PRINT\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return PRINT;}}
{PARSEINT}                  {if(show_tokens)printf("PARSEINT\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return PARSEINT;}}
{PUBLIC}                    {if(show_tokens)printf("PUBLIC\n");pos+=yyleng;if(return_stf)return PUBLIC;}
{RETURN}                    {if(show_tokens)printf("RETURN\n");pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);yylval.tk->is_to_show=0;return RETURN;}}
{STATIC}                    {if(show_tokens)printf("STATIC\n");pos+=yyleng;if(return_stf)return STATIC;}
{STRING}                    {if(show_tokens)printf("STRING\n");pos+=yyleng;if(return_stf)return STRING;}
{VOID}                      {if(show_tokens)printf("VOID\n");pos+=yyleng;if(return_stf)return VOID;}
{WHILE}                     {if(show_tokens)printf("WHILE\n");pos+=yyleng;if(return_stf)return WHILE;}

{INTLIT}                    {if(show_tokens)printf("INTLIT(%s)\n",yytext);pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);return INTLIT;}}
{REALLIT}                   {if(show_tokens)printf("REALLIT(%s)\n",yytext);pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);return REALLIT;}}
{BOOLLIT}                   {if(show_tokens)printf("BOOLLIT(%s)\n", yytext);pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);return BOOLLIT;}}
{RESERVED}                  {if(show_tokens)printf("RESERVED(%s)\n", yytext);pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);return RESERVED;}}
{ID}                        {if(show_tokens)printf("ID(%s)\n",yytext);pos+=yyleng;if(return_stf){yylval.tk = create_tk_cont(strdup(yytext), pos-yyleng, line);return ID;}}

["\t\f "]                   {pos+=1;} 
{PARAGRAPH_ESCAPE}          {line++;pos=1;}
.                           {printf("Line %d, col %d: illegal character (%s)\n", line, pos, yytext);pos++;}

%%

int yywrap() {
    return 1;
}

void yyerror(const char *s){
    syntax_error_found = true;
    if (yytext[0] == '"')
        printf("Line %d, col %d: %s: \"%s\"\n", line, (int)( pos -2 - strlen(string_buff)), s, string_buff);
    else
        printf("Line %d, col %d: %s: %s\n", line, (int)( pos - strlen(yytext)), s, yytext);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        if (strcmp(argv[1],"-l") == 0) {
            show_tokens = true;
            yylex();
        }else if (strcmp(argv[1], "-e1") == 0) {
            yylex();
        }else if (strcmp(argv[1],"-t") == 0) {
            return_stf = true;
            yyparse();
            if (!syntax_error_found) {
                print_tree(root, 0);
            }            
        }else if (strcmp(argv[1], "-e2") == 0) {
            return_stf = true;
            yyparse();
            yylex();
        }else if (strcmp(argv[1], "-s") == 0) {
            return_stf = true;
            yyparse();
            if (!syntax_error_found)
                analiza_programa(root, 1);
        }
    }
    else {
        return_stf = true;
        yyparse();
        yylex();
        if (!syntax_error_found)
            analiza_programa(root, 0);
    }

    cleanTree(root);
}
