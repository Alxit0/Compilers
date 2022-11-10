%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include <stdbool.h>

    typedef struct Node{
        char* nodeType;
        char* nodeValue;
        struct Node *son;
        struct Node *brother;
    } Node;

    Node *new_node(char *type, char *value, Node *son){
        Node *new = (Node *) malloc(sizeof(Node));
        new->nodeType = type;
        new->nodeValue = value;
        new->son = son;
        new->brother = NULL;
        return new;
    }

    void print_tree(Node * node, int depth){
        if (node == NULL)
            return;
        for (int i = 0; i < depth; ++i)
            printf("..");
        if (node->nodeValue != NULL)
            if(strcmp(node->nodeType, "StrLit")==0)
                printf("%s(\"%s\")\n", node -> nodeType, node->nodeValue);
            else printf("%s(%s)\n", node -> nodeType, node->nodeValue);
        else
            printf("%s\n", node->nodeType);
        print_tree(node->son, depth+1);
        print_tree(node->brother, depth);
    }

    Node * new_brother(Node *brother, Node *brother_to_add){
        if(brother == NULL) return NULL;
        Node *aux = brother;
        while(brother->brother != NULL){
            brother = brother->brother;
        }
        brother->brother = brother_to_add;
        return aux;
    }
    
    void cleanTree(Node * node){
        if(node == NULL)
            return;
        cleanTree(node->brother);
        cleanTree(node->son);
        free(node);
    }


    extern int flag;
    extern bool syntax_error_found;

    Node *root;
    int yylex(void);
    void yyerror(const char *s);
%}

%union {
    char * string;
    struct Node *tree;
}

%token AND ASSIGN STAR COMMA DIV EQ GE GT LBRACE LE LPAR LSQ LT MINUS MOD NE NOT OR PLUS RBRACE RPAR RSQ SEMICOLON ARROW LSHIFT RSHIFT XOR CLASS DOTLENGTH ELSE IF PRINT PARSEINT PUBLIC RETURN STATIC STRING VOID WHILE INT DOUBLE BOOL


%token <string> ID STRLIT REALLIT INTLIT BOOLLIT RESERVED


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
        CLASS ID LBRACE Aux1 RBRACE         {root = new_node("Program", NULL, new_brother(new_node("Id", $2, NULL), $4));}
        ;

Aux1:     
        /* empty */                         {$$ = NULL;}
        |    MethodDecl Aux1                {$$ = new_brother($1, $2);}
        |    FieldDecl Aux1                 {$$ = new_brother($1, $2);}
        |    SEMICOLON Aux1                 {$$ = $2;}            
        ;

MethodDecl:    
        PUBLIC STATIC MethodHeader MethodBody   {$$ = new_node("MethodDecl", NULL, new_brother($3, $4));}
        ;

FieldDecl:    
        PUBLIC STATIC Type ID Aux2 SEMICOLON    {
                                                    Node *aux = new_brother(new_node("Id", $4, NULL), $5);
                                                    Node *resp = new_node("Temp", NULL, NULL);
                                                    while(aux != NULL){
                                                        
                                                        Node *temp = new_brother(
                                                            new_node($3->nodeType, NULL, NULL),
                                                            aux
                                                        );
                                                        new_brother(resp, new_node("FieldDecl", NULL, temp));
                                                        
                                                        Node *next = aux->brother;
                                                        aux->brother = NULL;
                                                        aux = next;
                                                    }
                                                    $$ = resp->brother;
                                                }
    |    error SEMICOLON                         {$$ = NULL;syntax_error_found = true;}
    ;

Aux2:    
        /* empty */                 {$$ = NULL;}
    |    COMMA ID Aux2               {$$ = new_brother(new_node("Id", $2, NULL), $3);}
    ;

Type: 
        BOOL              {$$ = new_node("Bool", NULL, NULL);}
    |   INT               {$$ = new_node("Int", NULL, NULL);}
    |   DOUBLE            {$$ = new_node("Double", NULL, NULL);}
    ;

MethodHeader:    
        Type ID LPAR Aux3 RPAR      {
                                        Node *aux = new_brother($1, new_node("Id", $2, NULL));
                                        aux = new_brother(aux, new_node("MethodParams", NULL, $4));
                                        $$ = new_node("MethodHeader", NULL, aux);
                                    }
    |    VOID ID LPAR Aux3 RPAR      {
                                        Node *aux = new_brother(new_node("Void", NULL, NULL), new_node("Id", $2, NULL));
                                        aux = new_brother(aux, new_node("MethodParams", NULL, $4));
                                        $$ = new_node("MethodHeader", NULL, aux);
                                    }
    ;

Aux3:    
        /* empty */                 {$$ = NULL;}
    |   FormalParams                {$$ = $1;}
    ;

FormalParams:    
            Type ID Aux4            {
                                        $$ = new_brother(
                                            new_node("ParamDecl", NULL, new_brother($1, new_node("Id", $2, NULL))),
                                            $3
                                        );
                                    }
        |   STRING LSQ RSQ ID       {
                                        $$ = new_node("ParamDecl", NULL,
                                            new_brother(
                                                new_node("StringArray", NULL, NULL),
                                                new_node("Id", $4, NULL)
                                            )
                                        );
                                    }
        ;

Aux4:    
        /* empty */             {$$ = NULL;}
    |    COMMA Type ID Aux4      {
                                    Node *temp = new_brother(
                                        $2,
                                        new_node("Id", $3, NULL)
                                    );
                                    $$ = new_brother(new_node("ParamDecl", NULL, temp), $4);
                                }
    ;

MethodBody:    
        LBRACE Aux5 RBRACE          {$$ = new_node("MethodBody", NULL, $2);}
        ;

Aux5:     
        /* empty */         {$$ = NULL;}
    |    Statement Aux5      {if ($1 == NULL)$$=$2;else $$ = new_brother($1, $2);}
    |    VarDecl Aux5        {$$ = new_brother($1, $2);}
    ;

VarDecl:    
        Type ID Aux6 SEMICOLON      {
                                        Node *aux = new_brother(new_node("Id", $2, NULL), $3);
                                        Node *tail = new_node("Temp", NULL, NULL);
                                        Node *head = tail;
                                        while(aux != NULL){
                                            
                                            Node *temp = new_brother(
                                                new_node($1->nodeType, NULL, NULL),
                                                aux
                                            );
                                            tail = new_brother(tail, new_node("VarDecl", NULL, temp));
                                            
                                            Node *next = aux->brother;
                                            aux->brother = NULL;
                                            aux = next;
                                        }
                                        $$ = head->brother;
                                    }
        ;

Aux6:    
        /* empty */         {$$ = NULL;}
    |    COMMA ID Aux6       {$$ = new_brother(new_node("Id", $2, NULL), $3);}
    ;

Statement:    
        LBRACE Aux7 RBRACE                              {
                                                            if ($2 != NULL && $2->brother != NULL)$$ = new_node("Block", NULL, $2);
                                                            else $$ = $2;
                                                        }
    |    IF LPAR Expr RPAR Statement %prec ELSE          {
                                                            Node *stm = $5;
                                                            if ($5 == NULL || $5->brother != NULL)
                                                                stm = new_node("Block", NULL, stm);
                                                            $$ = new_node("If", NULL, new_brother($3, new_brother(stm, new_node("Block", NULL, NULL))));
                                                        }
    |    IF LPAR Expr RPAR Statement ELSE Statement      {
                                                            Node *stm1 = $5;
                                                            Node *stm2 = $7;
                                                            if ($5 == NULL || $5->brother != NULL)
                                                                stm1 = new_node("Block", NULL, stm1);
                                                            if ($7 == NULL || $7->brother != NULL)
                                                                stm2 = new_node("Block", NULL, stm2);
                                                            $$ = new_node("If", NULL, new_brother($3, new_brother(stm1, stm2)));
                                                        }
    |    WHILE LPAR Expr RPAR Statement                  {
                                                            Node *stm = $5;
                                                            if ($5 == NULL || $5->brother != NULL)
                                                                stm = new_node("Block", NULL, $5);
                                                            $$ = new_node("While", NULL, new_brother($3, stm));
                                                        }
    |    RETURN Expr SEMICOLON                          {$$ = new_node("Return", NULL, $2);}
    |    RETURN SEMICOLON                               {$$ = new_node("Return", NULL, NULL);}
    |   SEMICOLON                                       {$$ = NULL;}
    |    MethodInvocation SEMICOLON                     {$$ = $1;}
    |    Assignment SEMICOLON                           {$$ = $1;}
    |    ParseArgs SEMICOLON                            {$$ = $1;}
    |    PRINT LPAR StatementPrint RPAR SEMICOLON       {$$ = new_node("Print", NULL, $3);}
    |    error SEMICOLON                                {$$ = NULL;syntax_error_found = true;}
    ;

Aux7:    
        /* empty */             {$$ = NULL;}
    |   Statement Aux7          {if ($1 == NULL)$$=$2;else $$ = new_brother($1, $2);}
    ;

StatementPrint:    
        Expr            {$$ = $1;}
    |   STRLIT         {$$ = new_node("StrLit", $1, NULL);}
    ;

MethodInvocation:    
            ID LPAR MethodInvocation2 RPAR          {$$ = new_node("Call", NULL, new_brother(new_node("Id", $1, NULL), $3));}
        |   ID LPAR error RPAR                      {$$ = NULL;syntax_error_found = true;}
        ;

MethodInvocation2:    
            /* empty */                     {$$ = NULL;}
        |   Expr MethodInvocationExpr       {$$ = new_brother($1, $2);}
        ;

MethodInvocationExpr:    
            /* empty */                         {$$ = NULL;}
        |   COMMA Expr MethodInvocationExpr     {$$ = new_brother($2, $3);}
        ;

Assignment:    
        ID ASSIGN Expr      {$$ = new_node("Assign", NULL, new_brother(new_node("Id", $1, NULL), $3));}
        ;

ParseArgs:    
        PARSEINT LPAR ID LSQ Expr RSQ RPAR          {$$ = new_node("ParseArgs", NULL, new_brother(new_node("Id", $3, NULL), $5));}
    |   PARSEINT LPAR error RPAR                    {$$ = NULL;syntax_error_found = 1;}
    ;

Expr:    
        Assignment      {$$ = $1;}
    |   Expr2           {$$ = $1;}
    ;

Expr2:  
        Expr2 PLUS Expr2        {$$ = new_node("Add", NULL, new_brother($1, $3));}
    |   Expr2 MINUS Expr2       {$$ = new_node("Sub", NULL, new_brother($1, $3));}
    |   Expr2 STAR Expr2        {$$ = new_node("Mul", NULL, new_brother($1, $3));}
    |   Expr2 DIV Expr2         {$$ = new_node("Div", NULL, new_brother($1, $3));}
    |   Expr2 MOD Expr2         {$$ = new_node("Mod", NULL, new_brother($1, $3));}
    |   Expr2 AND Expr2         {$$ = new_node("And", NULL, new_brother($1, $3));}
    |   Expr2 OR Expr2          {$$ = new_node("Or", NULL, new_brother($1, $3));}
    |   Expr2 XOR Expr2         {$$ = new_node("Xor", NULL, new_brother($1, $3));}
    |   Expr2 LSHIFT Expr2      {$$ = new_node("Lshift", NULL, new_brother($1, $3));}
    |   Expr2 RSHIFT Expr2      {$$ = new_node("Rshift", NULL, new_brother($1, $3));}
    |   Expr2 EQ Expr2          {$$ = new_node("Eq", NULL, new_brother($1, $3));}
    |   Expr2 GE Expr2          {$$ = new_node("Ge", NULL, new_brother($1, $3));}
    |   Expr2 GT Expr2          {$$ = new_node("Gt", NULL, new_brother($1, $3));}
    |   Expr2 LE Expr2          {$$ = new_node("Le", NULL, new_brother($1, $3));}
    |   Expr2 LT Expr2          {$$ = new_node("Lt", NULL, new_brother($1, $3));}
    |   Expr2 NE Expr2          {$$ = new_node("Ne", NULL, new_brother($1, $3));}
    |   PLUS Expr2 %prec NOT    {$$ = new_node("Plus", NULL, $2);}
    |   MINUS Expr2 %prec NOT   {$$ = new_node("Minus", NULL, $2);}
    |   NOT Expr2               {$$ = new_node("Not", NULL, $2);}
    |   LPAR Expr RPAR          {$$ = $2;}
    |   LPAR error RPAR         {$$ = NULL;syntax_error_found = 1;}
    |   MethodInvocation        {$$ = $1;}
    |   ParseArgs               {$$ = $1;}
    |   ID                      {$$ = new_node("Id", $1, NULL);}
    |   ID DOTLENGTH            {$$ = new_node("Length", NULL, new_node("Id", $1, NULL));}
    |   INTLIT                  {$$ = new_node("DecLit", $1, NULL);}
    |   REALLIT                 {$$ = new_node("RealLit", $1, NULL);}
    |   BOOLLIT                 {$$ = new_node("BoolLit", $1, NULL);}
    ;
%%
