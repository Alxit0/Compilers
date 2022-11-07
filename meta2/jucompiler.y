%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "tree.h"
    Node *root;
    Node *auxNode;
    Node *auxNode2;

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

%union{
	struct Node *tree;
	char *string;
}

%token <string> ID STRLIT REALLIT INTLIT BOOLLIT RESERVED
%type <tree> Program Aux1 MethodDecl FieldDecl Aux2 Type MethodHeader FormalParams Aux3 MethodBody Aux4 VarDecl Statement MethodInvocation Aux5 Assignment ParseArgs Expr Expr2

//Variables
%right ASSIGN
%right NOT

%left COMMA
%left XOR
%left OR
%left AND
%left EQ NE 
%left LT LE GT GE
%left LSHIFT RSHIFT
%left PLUS MINUS
%left STAR DIV MOD
%left LSQ RSQ LPAR RPAR
%left AUX1 AUX2

%nonassoc ELSE IF WHILE

%%
Program: CLASS ID LBRACE Aux1 RBRACE    {root = new_node("Program", NULL, new_brother(new_node("Id", $2, NULL), $4));}

Aux1: /* vazio */       {$$ = NULL;}
    | Aux1 MethodDecl                   {if ($1 == NULL)$$ = $2;else $$ = new_brother($1, $2);}
    | Aux1 FieldDecl                    {if ($1 == NULL)$$ = $2;else $$ = new_brother($1, $2);}
    | Aux1 SEMICOLON                    {$$ = $1;}
    ; 


MethodDecl: PUBLIC STATIC MethodHeader MethodBody   {if($3 == NULL)$$ = $4;else $$ = new_node("MethodDecl", NULL, new_brother($3, $4));}

FieldDecl: PUBLIC STATIC Type ID Aux2 SEMICOLON     {
                                                        Node* node_aux = new_node("Id", $4, NULL);
                                                        if($3 != NULL)node_aux = new_brother($3, node_aux);
                                                        $$ = new_node("FieldDecl", NULL, new_brother(node_aux, $5));
                                                    }
    | error SEMICOLON                               {$$ = NULL;}
    ;

Aux2: COMMA ID Aux2             {$$ = new_brother(new_node("Id", $2, NULL), $3);}
    | /* vazio */               {$$ = NULL;}
    ;

Type: BOOL              {$$ = new_node("Bool", NULL, NULL);}
    | INT               {$$ = new_node("Int", NULL, NULL);}
    | DOUBLE            {$$ = new_node("Double", NULL, NULL);}
    ;

MethodHeader: Type ID LPAR FormalParams RPAR    {
                                                    Node *node_aux = new_node("Id", $2, NULL);
                                                    if($1 != NULL)node_aux = new_brother($1, node_aux);
                                                    $$ = new_node("MethodHeader", NULL, new_brother(node_aux, $4));
                                                }
    | VOID ID LPAR FormalParams RPAR            {$$ = new_node("MethodHeader", NULL, new_brother(new_node("Id", $2, NULL), $4));}
    | Type ID LPAR RPAR                         {
                                                    Node *node_aux = new_node("Id", $2, NULL);
                                                    if($1 != NULL)node_aux = new_brother($1, node_aux);
                                                    $$ = new_node("MethodHeader", NULL, node_aux);
                                                }
    | VOID ID LPAR RPAR                         {$$ = new_node("MethodHeader", NULL, new_node("Id", $2, NULL));}
    ;


FormalParams: Type ID Aux3          {
                                        Node *node_aux = new_node("Id", $2, NULL);
                                        if($1 != NULL)node_aux = new_brother($1, node_aux);
                                        $$ = new_node("MethodParams", NULL, new_brother(node_aux, $3));
                                    }
    | STRING LSQ RSQ ID             {
                                        $$ = new_node("MethodParams", NULL, new_node("Id", $4, NULL));
                                    }

Aux3: /* vazio */                   {$$ = NULL;}
    | Aux3 COMMA Type ID            {
                                        Node *node_aux = new_node("Id", $4, NULL);
                                        if($3 != NULL)node_aux = new_brother($3, node_aux);
                                        if($1 != NULL)node_aux = new_brother($1, node_aux);
                                        $$ = node_aux;
                                    }
    ;

MethodBody: LBRACE Aux4 RBRACE      {$$ = new_node("MethodBody", NULL, $2);}

Aux4: /* vazio */           {$$ = NULL;}
    | Aux4 Statement        {if($1 == NULL)$$ = $2;else $$ = new_brother($1, $2);}
    | Aux4 VarDecl          {if($1 == NULL)$$ = $2;else $$ = new_brother($1, $2);}
    ;

VarDecl: Type ID Aux2 SEMICOLON     {
                                        Node *node_aux = new_node("Id", $2, NULL);
                                        if($1 != NULL)node_aux = new_brother($1, node_aux);
                                        if($3 != NULL)node_aux = new_brother(node_aux, $3);
                                        $$ = new_node("VarDecl", NULL, node_aux);
                                    }

Statement: LBRACE Statement RBRACE                  {$$ = new_node("Statement", NULL, $2);}
    | LBRACE RBRACE                                 {$$ = new_node("Statement", NULL, NULL);}
    | IF LPAR Expr RPAR Statement ELSE Statement    {
                                                        Node *node_aux = $3;
                                                        if($3 == NULL)node_aux = $5;
                                                        else node_aux = new_brother($3, $5);
                                                        if($5 == NULL)node_aux = $7;
                                                        else node_aux = new_brother($3, $7);
                                                        $$ = new_node("Statement", NULL, node_aux);
                                                    }
    | IF LPAR Expr RPAR Statement                   {
                                                        Node *node_aux = $3;
                                                        if($3 == NULL)node_aux = $5;
                                                        else node_aux = new_brother($3, $5);
                                                        $$ = new_node("Statement", NULL, node_aux);
                                                    }
    | WHILE LPAR Expr RPAR Statement                {
                                                        Node *node_aux = $3;
                                                        if($3 == NULL)node_aux = $5;
                                                        else node_aux = new_brother($3, $5);
                                                        $$ = new_node("Statement", NULL, node_aux);
                                                    }
    | RETURN Expr SEMICOLON                         {$$ = new_node("Statement", NULL, $2);}
    | RETURN SEMICOLON                              {$$ = new_node("Statement", NULL, NULL);}
    | SEMICOLON                                     {$$ = new_node("Statement", NULL, NULL);}
    | MethodInvocation SEMICOLON                    {$$ = new_node("Statement", NULL, $1);}
    | Assignment SEMICOLON                          {$$ = new_node("Statement", NULL, $1);}
    | ParseArgs SEMICOLON                           {$$ = new_node("Statement", NULL, $1);}
    | PRINT LPAR STRLIT RPAR SEMICOLON              {$$ = new_node("Statement", NULL, NULL);}
    | PRINT LPAR Expr RPAR SEMICOLON                {$$ = new_node("Statement", NULL, $3);}
    | error SEMICOLON                               {$$ = NULL;}
    ;

MethodInvocation: ID LPAR Expr Aux5 RPAR        {
                                                    Node *node_aux = new_node("Id", $1, NULL);
                                                    if($3 != NULL)node_aux = new_brother(node_aux, $3);
                                                    if($4 != NULL)node_aux = new_brother(node_aux, $4);
                                                    $$ = new_node("MethodInvocation", NULL, node_aux);
                                                }
    | ID LPAR RPAR                              {$$ = new_node("MethodInvocation", NULL, NULL);}
    | ID LBRACE error RPAR                      {$$ = NULL;}
    ;

Aux5: /* vazio */       {$$ = NULL;}
    | Aux5 COMMA Expr   {if($1 == NULL)$$ = $3;else $$ = new_brother($1, $3);}
    ;

Assignment: ID ASSIGN Expr  {$$ = new_brother(new_node("Id", $1, NULL), $3);}

ParseArgs: PARSEINT LPAR ID LSQ Expr RSQ RPAR       {$$ = new_brother(new_node("Id", $3, NULL), $5);}
    | PARSEINT LPAR error RPAR                      {$$ = NULL;}
    ;

Expr: Assignment        {$$ = new_node("Expr", NULL, $1);}
    | Expr2             {$$ = new_node("Expr", NULL, $1);}

Expr2: Expr2 MOD Expr2          {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 DIV Expr2           {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 STAR Expr2          {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 MINUS Expr2         {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 PLUS Expr2          {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 AND Expr2           {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 OR Expr2            {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 XOR Expr2           {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 LSHIFT Expr2        {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 RSHIFT Expr2        {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 EQ Expr2            {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 GE Expr2            {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 GT Expr2            {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 LE Expr2            {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 LT Expr2            {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | Expr2 NE Expr2            {if($1 == NULL)$$ = $3;else new_brother($1, $3);}
    | MINUS Expr2 %prec AUX1    {$$ = $2;}
    | NOT Expr2                 {$$ = $2;}
    | PLUS Expr2 %prec AUX2     {$$ = $2;}
    | LPAR Expr RPAR            {$$ = $2;}
    | MethodInvocation          {$$ = $1;}
    | ParseArgs                 {$$ = $1;}
    | ID DOTLENGTH              {$$ = NULL;}
    | ID                        {$$ = new_node("Id", $1, NULL);}
    | INTLIT                    {$$ = new_node("DecLit", $1, NULL);}
    | REALLIT                   {$$ = new_node("RealLit", $1, NULL);}
    | BOOLLIT                   {$$ = new_node("BoolLit", $1, NULL);}
    | LPAR error RPAR           {$$ = NULL;}
    ;
%%

