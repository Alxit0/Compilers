#ifndef TABLE_LIST_H_INCLUDED
#define TABLE_LIST_H_INCLUDED

#include "table.h"

typedef struct table_list_node
{
    Table* table;
    char* table_type;
    struct table_list_node* next;
}TLNode;

typedef struct table_list
{
    TLNode* head;    
    TLNode* tail;    
}Table_List;

Table_List* init_table_list();
void add_table(Table_List* table_list, Table* table, char* table_type);
void print_table_list(Table_List* table_list);

#endif