#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semantics.h"

void analiza_programa(Node* root){
    if (root == NULL)
        return;
    
    Table_List* table_list = init_table_list();
    
    Table* class_table = init_table(root);
    
    class_table->method = "Class";
    class_table->name = root->son->value;
    
    add_table(table_list, class_table, "class");

    Node* aux = root->son;
    while (aux != NULL)
    {
        if (strcmp(aux->type, "FieldDecl") == 0)
            analiza_field_decl(aux, class_table);
        
        if (strcmp(aux->type, "MethodDecl") == 0){
            Table* aux2 = analiza_method_decl(aux, class_table);
            add_table(table_list, aux2, "method");
        }
        aux = aux->brother;
    }

    print_table_list(table_list);
    // print_class_table(class_table);
}

void analiza_field_decl(Node* root, Table* class_table){
    if (root == NULL)
        return;

    add_element(class_table, root->son->brother->value, root->son->type, "");
}

Table* analiza_method_decl(Node* root, Table* class_table){
    Table* method_table = init_table(root);
    
    Node* methodHeader = root->son;
    Node* methodBody = root->son->brother;

    // method header stuf
    method_table->name = methodHeader->son->brother->value;
    method_table->method = "Method";
    method_table->parent = class_table;

    add_element(method_table, "return", methodHeader->son->type, "");

    Node* aux = methodHeader->son->brother->brother->son; //ParamDecl
    while (aux != NULL)
    {
        add_param(method_table, aux->son->type);
        add_element(method_table, aux->son->brother->value, aux->son->type, "param");
        aux = aux->brother;
    }

    Table_Node * aux2 = add_element(class_table, method_table->name, methodHeader->son->type, "");
    free(aux2->param);
    aux2->param = method_table->params_head;
    if (aux2->param != NULL)
        aux2->param->is_method_args = 1;

    // method body stuf
    handle_method_body(method_table, methodBody);
    
    // print_method_table(method_table);
    return method_table;
}

void handle_method_body(Table* target, Node* root){
    if (root == NULL){
        return;
    }

    if (strcmp(root->type, "VarDecl")==0){
        add_element(target, root->son->brother->value, root->son->type, "");
        return;
    }
    
    Node * aux = root->son;
    while (aux != NULL)
    {
        handle_method_body(target, aux);
        aux = aux->brother;
    }
    
}