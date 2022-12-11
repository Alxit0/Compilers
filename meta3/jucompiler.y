/* Alexandre Silva Regalado 2020212059 */
/* Martim António Aldeia Neves 2020232499 */

%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include <stdbool.h>

    #include "arvore.h"


    extern int flag;
    extern bool syntax_error_found;

    Node *root;
    int yylex(void);
    void yyerror(const char *s);
%}

%token SEMICOLON
%token COMMA
/* %token DIV
%token STAR
%token MINUS
%token PLUS */
/* %token EQ */
/* %token GE */
%token LBRACE
/* %token LE */
%token LPAR
%token LSQ
/* %token NE */
/* %token NOT */
/* %token AND */
/* %token OR */
%token RBRACE
%token RPAR
%token RSQ
%token CLASS
%token PUBLIC
%token STATIC
/* %token RETURN */
%token ELSE
%token IF
%token INT
%token BOOL
%token DOUBLE
%token STRING
/* %token PRINT */
/* %token PARSEINT */
/* %token ASSIGN */
/* %token GT */
/* %token MOD */
/* %token LT */
%token VOID
%token WHILE
/* %token XOR */
/* %token LSHIFT */
/* %token RSHIFT */
/* %token DOTLENGTH */


%union {
    struct Node *tree;
    char * string;
    struct token_container* tk;
}

%token <tk> ID STRLIT REALLIT INTLIT BOOLLIT RESERVED PLUS MINUS STAR DIV MOD ASSIGN RETURN PRINT EQ GT GE LT LE AND OR NOT NE LSHIFT RSHIFT XOR DOTLENGTH PARSEINT

%type <tree> Program Aux1 Aux2 MethodDecl FieldDecl Type MethodHeader Aux3 FormalParams Aux4 MethodBody Aux5 VarDecl Aux6 Statement Aux7 StatementPrint MethodInvocation MethodInvocation2 MethodInvocationExpr Assignment ParseArgs Expr Expr2

%right ASSIGN
%left OR
%left AND
%left XOR
%left EQ NE
%left GE GT LE LT
%left LSHIFT RSHIFT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%left LPAR RPAR LSQ RSQ

%right ELSE

%%

Program:    
        CLASS ID LBRACE Aux1 RBRACE         {root = create_node("Program", NULL, add_brother(create_node("Id", $2, NULL), $4));}
        ;

Aux1:     
        /* empty */                         {$$ = NULL;}
        |    MethodDecl Aux1                {$$ = add_brother($1, $2);}
        |    FieldDecl Aux1                 {$$ = add_brother($1, $2);}
        |    SEMICOLON Aux1                 {$$ = $2;}            
        ;

MethodDecl:    
        PUBLIC STATIC MethodHeader MethodBody   {$$ = create_node("MethodDecl", NULL, add_brother($3, $4));}
        ;

FieldDecl:    
        PUBLIC STATIC Type ID Aux2 SEMICOLON    {
                                                    Node *aux = add_brother(create_node("Id", $4, NULL), $5);
                                                    Node *resp = create_node("Temp", NULL, NULL);
                                                    Node *temp, *next;
                                                    while(aux != NULL){
                                                        temp = add_brother(
                                                            create_node($3->type, NULL, NULL),
                                                            aux
                                                        );
                                                        add_brother(resp, create_node("FieldDecl", NULL, temp));
                                                        
                                                        next = aux->brother;
                                                        aux->brother = NULL;
                                                        aux = next;
                                                    }
                                                    $$ = resp->brother;
                                                }
    |    error SEMICOLON                         {$$ = NULL;syntax_error_found = true;}
    ;

Aux2:    
        /* empty */                 {$$ = NULL;}
    |    COMMA ID Aux2              {$$ = add_brother(create_node("Id", $2, NULL), $3);}
    ;

Type: 
        BOOL              {$$ = create_node("Bool", NULL, NULL);}
    |   INT               {$$ = create_node("Int", NULL, NULL);}
    |   DOUBLE            {$$ = create_node("Double", NULL, NULL);}
    ;

MethodHeader:    
        Type ID LPAR Aux3 RPAR      {
                                        Node *aux = add_brother($1, create_node("Id", $2, NULL));
                                        aux = add_brother(aux, create_node("MethodParams", NULL, $4));
                                        $$ = create_node("MethodHeader", NULL, aux);
                                    }
    |    VOID ID LPAR Aux3 RPAR      {
                                        Node *aux = add_brother(create_node("Void", NULL, NULL), create_node("Id", $2, NULL));
                                        aux = add_brother(aux, create_node("MethodParams", NULL, $4));
                                        $$ = create_node("MethodHeader", NULL, aux);
                                    }
    ;

Aux3:    
        /* empty */                 {$$ = NULL;}
    |   FormalParams                {$$ = $1;}
    ;

FormalParams:    
            Type ID Aux4            {
                                        $$ = add_brother(
                                            create_node("ParamDecl", NULL, add_brother($1, create_node("Id", $2, NULL))),
                                            $3
                                        );
                                    }
        |   STRING LSQ RSQ ID       {
                                        $$ = create_node("ParamDecl", NULL,
                                            add_brother(
                                                create_node("StringArray", NULL, NULL),
                                                create_node("Id", $4, NULL)
                                            )
                                        );
                                    }
        ;

Aux4:    
        /* empty */             {$$ = NULL;}
    |    COMMA Type ID Aux4     {
                                    Node *temp = add_brother(
                                        $2,
                                        create_node("Id", $3, NULL)
                                    );
                                    $$ = add_brother(create_node("ParamDecl", NULL, temp), $4);
                                }
    ;

MethodBody:    
        LBRACE Aux5 RBRACE          {$$ = create_node("MethodBody", NULL, $2);}
        ;

Aux5:     
        /* empty */         {$$ = NULL;}
    |    Statement Aux5      {if ($1 == NULL)$$=$2;else $$ = add_brother($1, $2);}
    |    VarDecl Aux5        {$$ = add_brother($1, $2);}
    ;

VarDecl:    
        Type ID Aux6 SEMICOLON      {
                                        Node *aux = add_brother(create_node("Id", $2, NULL), $3);
                                        Node *tail = create_node("Temp", NULL, NULL);
                                        Node *head = tail;
                                        while(aux != NULL){
                                            
                                            Node *temp = add_brother(
                                                create_node($1->type, NULL, NULL),
                                                aux
                                            );
                                            tail = add_brother(tail, create_node("VarDecl", NULL, temp));
                                            
                                            Node *next = aux->brother;
                                            aux->brother = NULL;
                                            aux = next;
                                        }
                                        $$ = head->brother;
                                    }
        ;

Aux6:    
        /* empty */         {$$ = NULL;}
    |    COMMA ID Aux6       {$$ = add_brother(create_node("Id", $2, NULL), $3);}
    ;

Statement:    
        LBRACE Aux7 RBRACE                              {
                                                            if ($2 != NULL && $2->brother != NULL)$$ = create_node("Block", NULL, $2);
                                                            else $$ = $2;
                                                        }
    |    IF LPAR Expr RPAR Statement %prec ELSE          {
                                                            Node *stm = $5;
                                                            if ($5 == NULL || $5->brother != NULL)
                                                                stm = create_node("Block", NULL, stm);
                                                            $$ = create_node("If", NULL, add_brother($3, add_brother(stm, create_node("Block", NULL, NULL))));
                                                        }
    |    IF LPAR Expr RPAR Statement ELSE Statement      {
                                                            Node *stm1 = $5;
                                                            Node *stm2 = $7;
                                                            if ($5 == NULL || $5->brother != NULL)
                                                                stm1 = create_node("Block", NULL, stm1);
                                                            if ($7 == NULL || $7->brother != NULL)
                                                                stm2 = create_node("Block", NULL, stm2);
                                                            $$ = create_node("If", NULL, add_brother($3, add_brother(stm1, stm2)));
                                                        }
    |    WHILE LPAR Expr RPAR Statement                  {
                                                            Node *stm = $5;
                                                            if ($5 == NULL || $5->brother != NULL)
                                                                stm = create_node("Block", NULL, $5);
                                                            $$ = create_node("While", NULL, add_brother($3, stm));
                                                        }
    |    RETURN Expr SEMICOLON                          {$$ = create_node("Return", $1, $2);}
    |    RETURN SEMICOLON                               {$$ = create_node("Return", $1, NULL);}
    |   SEMICOLON                                       {$$ = NULL;}
    |    MethodInvocation SEMICOLON                     {$$ = $1;}
    |    Assignment SEMICOLON                           {$$ = $1;}
    |    ParseArgs SEMICOLON                            {$$ = $1;}
    |    PRINT LPAR StatementPrint RPAR SEMICOLON       {$$ = create_node("Print", $1, $3);}
    |    error SEMICOLON                                {$$ = NULL;syntax_error_found = true;}
    ;

Aux7:    
        /* empty */             {$$ = NULL;}
    |   Statement Aux7          {if ($1 == NULL)$$=$2;else $$ = add_brother($1, $2);}
    ;

StatementPrint:    
        Expr            {$$ = $1;}
    |   STRLIT         {$$ = create_node("StrLit", $1, NULL);}
    ;

MethodInvocation:    
            ID LPAR MethodInvocation2 RPAR          {$$ = create_node("Call", NULL, add_brother(create_node("Id", $1, NULL), $3));}
        |   ID LPAR error RPAR                      {$$ = NULL;syntax_error_found = true;}
        ;

MethodInvocation2:    
            /* empty */                     {$$ = NULL;}
        |   Expr MethodInvocationExpr       {$$ = add_brother($1, $2);}
        ;

MethodInvocationExpr:    
            /* empty */                         {$$ = NULL;}
        |   COMMA Expr MethodInvocationExpr     {$$ = add_brother($2, $3);}
        ;

Assignment:    
        ID ASSIGN Expr      {$$ = create_node("Assign", $2, add_brother(create_node("Id", $1, NULL), $3));}
        ;

ParseArgs:    
        PARSEINT LPAR ID LSQ Expr RSQ RPAR          {$$ = create_node("ParseArgs", $1, add_brother(create_node("Id", $3, NULL), $5));}
    |   PARSEINT LPAR error RPAR                    {$$ = NULL;syntax_error_found = 1;}
    ;

Expr:    
        Assignment      {$$ = $1;}
    |   Expr2           {$$ = $1;}
    ;

Expr2:  
        Expr2 PLUS Expr2        {$$ = create_node("Add", $2, add_brother($1, $3));}
    |   Expr2 MINUS Expr2       {$$ = create_node("Sub", $2, add_brother($1, $3));}
    |   Expr2 STAR Expr2        {$$ = create_node("Mul", $2, add_brother($1, $3));}
    |   Expr2 DIV Expr2         {$$ = create_node("Div", $2, add_brother($1, $3));}
    |   Expr2 MOD Expr2         {$$ = create_node("Mod", $2, add_brother($1, $3));}
    |   Expr2 AND Expr2         {$$ = create_node("And", $2, add_brother($1, $3));}
    |   Expr2 OR Expr2          {$$ = create_node("Or", $2, add_brother($1, $3));}
    |   Expr2 XOR Expr2         {$$ = create_node("Xor", $2, add_brother($1, $3));}
    |   Expr2 LSHIFT Expr2      {$$ = create_node("Lshift", $2, add_brother($1, $3));}
    |   Expr2 RSHIFT Expr2      {$$ = create_node("Rshift", $2, add_brother($1, $3));}
    |   Expr2 EQ Expr2          {$$ = create_node("Eq", $2, add_brother($1, $3));}
    |   Expr2 GE Expr2          {$$ = create_node("Ge", $2, add_brother($1, $3));}
    |   Expr2 GT Expr2          {$$ = create_node("Gt", $2, add_brother($1, $3));}
    |   Expr2 LE Expr2          {$$ = create_node("Le", $2, add_brother($1, $3));}
    |   Expr2 LT Expr2          {$$ = create_node("Lt", $2, add_brother($1, $3));}
    |   Expr2 NE Expr2          {$$ = create_node("Ne", $2, add_brother($1, $3));}
    |   PLUS Expr2 %prec NOT    {$$ = create_node("Plus", NULL, $2);}
    |   MINUS Expr2 %prec NOT   {$$ = create_node("Minus", NULL, $2);}
    |   NOT Expr2               {$$ = create_node("Not", $1, $2);}
    |   LPAR Expr RPAR          {$$ = $2;}
    |   LPAR error RPAR         {$$ = NULL;syntax_error_found = 1;}
    |   MethodInvocation        {$$ = $1;}
    |   ParseArgs               {$$ = $1;}
    |   ID                      {$$ = create_node("Id", $1, NULL);}
    |   ID DOTLENGTH            {$$ = create_node("Length", $2, create_node("Id", $1, NULL));}
    |   INTLIT                  {$$ = create_node("DecLit", $1, NULL);}
    |   REALLIT                 {$$ = create_node("RealLit", $1, NULL);}
    |   BOOLLIT                 {$$ = create_node("BoolLit", $1, NULL);}
    ;
%%
