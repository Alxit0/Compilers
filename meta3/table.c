#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "table.h"

void print_params(Params_node* head);
char * translate_param(char * param);
Table_Node* check_symbol_extistance(Table* table, char* id);

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

Params_node* init_param(char * param){
    Params_node* temp = (Params_node*) malloc(sizeof(Params_node));
    temp->param = translate_param(param);
    temp->is_method_args = 0;
    return temp;
}

void add_param(Table* target, char* value){
    if (target == NULL)
        return;
    
    Params_node* param = init_param(value);
    // translate_param(value);

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

Table_Node * add_element(Table* target, TokenContainer* id, char* type, char* param, int check){
    if (target == NULL)
        return NULL;
    
    Table_Node* temp = (Table_Node*) malloc(sizeof(Table_Node));
    
    temp->id = id->string;
    temp->type = translate_param(type);
    temp->param = init_param(param);

    if (target->elems == NULL){
        target->elems = temp;
        return temp;
    }
    
    Table_Node* aux = target->elems;
    Table_Node* checker = check_symbol_extistance(target, id->string);
    
    if (check == 1 && checker != NULL){
        printf("Line %d, col %d: Symbol %s already defined\n", id->line, id->pos, id->string);
        return checker;
    }
    if (strcmp(id->string, "_") == 0){
        printf("Line %d, col %d: Symbol _ is reserved\n", id->line, id->pos);
        return NULL;
    }

    while (aux->next != NULL)
    {
        aux = aux->next;
    }
    aux->next = temp;

    return temp;    
}



void print_class_table(Table* target){
    if (target == NULL)
        return;
    
    printf("===== %s %s Symbol Table =====\n", target->method, target->name);

    Table_Node * aux = target->elems;

    while (aux)
    {
        // printf("%s\t%s\t%s\n", aux->id, aux->type);

        printf("%s\t", aux->id);
        print_params(aux->param);
        
        if (aux->param == NULL || aux->param->is_method_args == 1){
            printf("\t%s", aux->type);
        }
        else
            printf("%s", aux->type);
        aux = aux->next;
        printf("\n");
    }
    
}

void print_method_table(Table* target){
    if (target == NULL)
        return;

    printf("===== %s %s", target->method, target->name);
    print_params(target->params_head);
    printf(" Symbol Table =====\n");

    Table_Node* aux = target->elems;
    while (aux != NULL)
    {
        printf("%s\t\t%s", aux->id, aux->type);

        if (strcmp(aux->param->param, "") != 0)
        {
            printf("\tparam");
        }
        printf("\n");
        aux = aux->next;
    }
}

Params_node* procura_tabela_char(TokenContainer* id, Table* table) {
    if (table == NULL){
        printf("Line %d, col %d: Cannot find symbol %s\n", id->line, id->pos, id->string);
        return init_param("undef");
    }
    
    Table_Node* aux = table->elems;
    
    while (aux)
    {
        // printf("Ola %s\n", aux->id);
        if (aux->param == NULL){
            aux = aux->next;
            continue;
        }

        if (strcmp(aux->id, id->string) == 0){
            // printf("\t%s\n", aux->type);
            return init_param(aux->type);
        }
        aux = aux->next;
    }
    return procura_tabela_char(id, table->parent);
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
    if (head == NULL){
        printf("()");
        return;
    }
    if (head->is_method_args == 1)
        printf("(");

    Params_node* aux = head;
    while (aux->next != NULL)
    {
        printf("%s,", aux->param);
        aux = aux->next;
    }
    
    printf("%s", aux->param);
    if (head->is_method_args == 1)
        printf(")");
}

Table_Node* check_symbol_extistance(Table* table, char* id){
    if (table == NULL)
        return NULL;
    
    Table_Node* aux = table->elems;
    while (aux)
    {
        if (strcmp(aux->id, id) == 0)
            return aux;
        aux = aux->next;
    }
    return NULL;
    
}