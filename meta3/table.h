/* Alexandre Silva Regalado 2020212059 */
/* Martim António Aldeia Neves 2020232499 */
#ifndef TABLE_H_INCLUDED
#define TABLE_H_INCLUDED

#include "arvore.h"

typedef struct params_node
{
    char * param;
    int is_method_args;
    struct params_node * next;
}Params_node;

typedef struct table_node
{
    char * id;
    char * type;
    Params_node* param;
    struct table_node * next;
}Table_Node;

typedef struct table
{
    char * method;
    char * name;
    Params_node * params_head;
    struct table* parent;
    Table_Node* elems;
}Table;


Table* init_table(Node* root);
Params_node* init_param(char * param);
void add_param(Table* target, char* value);
Table_Node * add_element(Table* target, TokenContainer* id, char* type, char* param, int check, int is_method);
void print_class_table(Table* target);
void print_method_table(Table* target);
void print_params(Params_node* head);
Params_node* procura_tabela_char(TokenContainer* id, Table* table, int check_find);
#endif