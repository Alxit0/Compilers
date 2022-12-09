#include "arvore.h"

typedef struct params_node
{
    char * param;
    struct params_node * next;
}Params_node;

typedef struct table_node
{
    char * id;
    char * type;
    char * param;
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
void add_param(Table* target, char* value);
void add_element(Table* target, char* id, char* type, char* param);
void print_class_table(Table* target);
void print_method_table(Table* target);