#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semantics.h"

void analiza_programa(Node* root){
    if (root == NULL)
        return;
    
    Table* class_table = init_table(root);
    
    class_table->method = "Class";
    class_table->name = root->son->value;
    
    Node* aux = root->son;
    while (aux != NULL)
    {
        if (strcmp(aux->type, "FieldDecl") == 0)
            analiza_field_decl(aux, class_table);
        
        if (strcmp(aux->type, "MethodDecl") == 0)
            analiza_method_decl(aux, class_table);
        aux = aux->brother;
    }

    print_class_table(class_table);
}

void analiza_field_decl(Node* root, Table* class_table){
    if (root == NULL)
        return;

    
}

void analiza_method_decl(Node* root, Table* class_table){
    Table* method_table = init_table(root);
    
    Node* methodHeader = root->son;
    Node* methodBody = root->son->brother;

    method_table->name = methodHeader->son->brother->value;
    method_table->method = "Method";
    method_table->parent = class_table;

    int i = 0;
    Node* aux = methodHeader->son->brother->brother->son; //ParamDecl
    while (aux != NULL)
    {
        add_param(method_table, aux->son->type);
        if (i++ == 10)
            break;
        aux = aux->brother;
    }
    
    
    print_method_table(method_table);
}