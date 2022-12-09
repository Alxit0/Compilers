#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "table.h"

void print_params(Params_node* head);
char * translate_param(char * param);

// public funcs
Table* init_table(Node* root){
    if (root == NULL)
        return NULL;
    
    Table* temp = (Table*) malloc(sizeof(Table));

    temp->method = NULL;
    temp->name = NULL;
    temp->parent = NULL;
    temp->params_head = NULL;

    return temp;
}

void add_param(Table* target, char* value){
    if (target == NULL)
        return;
    
    Params_node* param = (Params_node*) malloc(sizeof(Params_node));
    // translate_param(value);
    param->param = translate_param(value);

    if (target->params_head == NULL){
        target->params_head = param;
        return;
    }
    Params_node* aux = target->params_head;
    while (aux->next != NULL)
    {
        aux = aux->next;
    }
    aux->next = param;
    // printf("%s\n", aux->next->param);

}

void add_element(Table* target, char* id, char* type, char* param){
    if (target == NULL)
        return;
    
    Table_Node* temp = (Table_Node*) malloc(sizeof(Table_Node));
    
    temp->id = id;
    temp->type = translate_param(type);
    temp->param = param;

    if (target->elems == NULL){
        target->elems = temp;
        return;
    }
    
    Table_Node* aux = target->elems;
    while (aux->next != NULL)
    {
        aux = aux->next;
    }
    aux->next = temp;
    
}



void print_class_table(Table* target){
    if (target == NULL)
        return;
    
    printf("==== %s %s Symbol Table =====\n", target->method, target->name);
}

void print_method_table(Table* target){
    if (target == NULL)
        return;

    printf("==== %s %s(", target->method, target->name);
    print_params(target->params_head);
    printf(") Symbol Table =====\n");

    Table_Node* aux = target->elems;
    while (aux != NULL)
    {
        printf("%s\t\t%s", aux->id, aux->type);

        if (strcmp(aux->param, "") != 0)
        {
            printf("\t param");
        }
        printf("\n");
        aux = aux->next;
    }
    printf("\n");
}


// private funcs
char * translate_param(char * param){
    if (strcmp(param, "Bool")==0)
        return "boolean";
    if (strcmp(param, "Double")==0)
        return "double";
    if (strcmp(param, "Int")==0)
        return "int";
    if (strcmp(param, "StringArray")==0)
        return "String[]";
    if (strcmp(param, "Void")==0)
        return "void";
    
    return param;
}

void print_params(Params_node* head){
    if (head == NULL)
        return;
    
    Params_node* aux = head;
    while (aux->next != NULL)
    {
        printf("%s,", aux->param);
        aux = aux->next;
    }
    
    printf("%s", aux->param);
}
