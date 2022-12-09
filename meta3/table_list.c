#include "table_list.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Table_List* init_table_list(){
    Table_List* temp = (Table_List*) malloc(sizeof(Table_List));
    temp->head = NULL;
    temp->tail = NULL;
    return temp;
}

void add_table(Table_List* table_list, Table* table, char* table_type){
    if (table_list == NULL)
        return;
    
    TLNode* temp = (TLNode*) malloc(sizeof(TLNode));
    temp->table = table;
    temp->table_type = table_type;
    
    if (table_list->head == NULL){
        table_list->head = temp;
        table_list->tail = temp;
        return;

    }

    table_list->tail->next = temp;
    table_list->tail = temp;

}

void print_table_list(Table_List* table_list){
    if (table_list == NULL)
        return;
    
    TLNode* aux = table_list->head;
    while (aux)
    {
        if (strcmp(aux->table_type, "class") == 0)
            print_class_table(aux->table);
        else
            print_method_table(aux->table);
        
        aux = aux->next;
    }
    
}