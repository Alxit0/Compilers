#include "arvore.h"

typedef struct params_node
{
    char * param;
    struct params_node * next;
}Params_node;


typedef struct table
{
    char * method;
    char * name;
    Params_node * params_head;
    struct table* parent;

}Table;


Table* init_table(Node* root);
void add_param(Table* target, char* value);
void print_class_table(Table* target);
void print_method_table(Table* target);