%{
    #include <stdio.h>
    int yylex(void);
    void yyerror(char *s);
    int i = 0;
%}

//Reserved words

%token SEMICOLON
%token COMMA
%token DIV
%token STAR
%token MINUS
%token PLUS
%token EQ
%token GE
%token LBRACE
%token LE
%token LPAR
%token LSQ
%token NE
%token NOT
%token AND
%token OR
%token RBRACE
%token RPAR
%token RSQ
%token CLASS
%token PUBLIC
%token STATIC
%token RETURN
%token ELSE
%token IF
%token INT
%token BOOL
%token DOUBLE
%token STRING
%token PRINT
%token PARSEINT
%token ASSIGN
%token GT
%token MOD
%token LT
%token VOID
%token WHILE
%token XOR
%token LSHIFT
%token RSHIFT
%token DOTLENGTH
%token BOOLLIT

%union{
	struct Node *tree;
	char *string;
}

%token <string> ID STRLIT REALLIT INTLIT RESERVED
/* %type <tree> program declarations varDeclaration varSpec commaID type funcDeclaration parameters comma_ID_Type funcBody varsAndStatements statement state_SEMI parseArgs funcInvocation comma_Expr expr */

//Variables
%right ASSIGN
%left OR
%left AND
%left EQ NE LT LE GT GE
%left PLUS MINUS
%left STAR DIV MOD
%right LSHIFT RSHIFT
%right NOT
%right XOR

%%
Program: CLASS ID LBRACE Aux1 RBRACE

Aux1: /* vazio */
    | Aux1 MethodDecl 
    | Aux1 FieldDecl 
    | Aux1 SEMICOLON
    ; 


MethodDecl: PUBLIC STATIC MethodHeader MethodBody

FieldDecl: PUBLIC STATIC Type ID Aux2 SEMICOLON
    | error SEMICOLON
    ;

Aux2: COMMA ID Aux2
    | /* vazio */
    ;

Type: BOOL 
    | INT 
    | DOUBLE
    ;

MethodHeader: Type ID LPAR FormalParams RPAR
    | VOID ID LPAR FormalParams RPAR
    | Type ID LPAR RPAR
    | VOID ID LPAR RPAR
    ;


FormalParams: Type ID Aux3
    | STRING LSQ RSQ ID

Aux3: /* vazio */
    | Aux3 COMMA Type ID
    ;

MethodBody: LBRACE Aux4 RBRACE

Aux4: /* vazio */
    | Aux4 Statement
    | Aux4 VarDecl
    ;

VarDecl: Type ID Aux2 SEMICOLON

Statement: /* vazio */
    | LBRACE Statement RBRACE
    | Statement IF LPAR Expr RPAR Statement ELSE Statement 
    | Statement IF LPAR Expr RPAR Statement
    | Statement WHILE LPAR Expr RPAR Statement
    | Statement RETURN Expr SEMICOLON
    | Statement RETURN SEMICOLON
    | Statement SEMICOLON
    | Statement MethodInvocation SEMICOLON
    | Statement Assignment SEMICOLON
    | Statement ParseArgs SEMICOLON
    | Statement PRINT LPAR STRLIT RPAR SEMICOLON
    | Statement PRINT LPAR Expr RPAR SEMICOLON
    | error SEMICOLON
    ;

MethodInvocation: ID LPAR Expr Aux5 RPAR
    | ID LPAR RPAR
    | ID LBRACE error RPAR
    ;

Aux5: /* vazio */
    | Aux5 COMMA Expr
    ;

Assignment: ID ASSIGN Expr

ParseArgs: PARSEINT LPAR ID LSQ Expr RSQ RPAR
    | PARSEINT LPAR error RPAR
    ;

Expr: Expr MOD Expr
    | Expr DIV Expr
    | Expr STAR Expr
    | Expr MINUS Expr
    | Expr PLUS Expr
    | Expr AND Expr
    | Expr OR Expr
    | Expr XOR Expr
    | Expr LSHIFT Expr
    | Expr RSHIFT Expr
    | Expr EQ Expr
    | Expr GE Expr
    | Expr GT Expr
    | Expr LE Expr
    | Expr LT Expr
    | Expr NE Expr
    | MINUS Expr
    | NOT Expr
    | PLUS Expr
    | LPAR Expr RPAR
    | MethodInvocation 
    | Assignment 
    | ParseArgs
    | ID DOTLENGTH
    | ID
    | INTLIT 
    | REALLIT 
    | BOOLLIT
    | LPAR error RPAR
    ;
%%

