/* Alexandre Silva Regalado 2020212059 */
/* Martim António Aldeia Neves 2020232499 */
#ifndef ARVORE_H_INCLUDED
#define ARVORE_H_INCLUDED

struct params_node;

typedef struct token_container
{
    char * string;
    int pos;
    int line;
    int is_to_show;
}TokenContainer;


typedef struct Node{
        char* type;
        TokenContainer* value;
        struct Node *son;
        struct Node *brother;
        struct params_node* anotation;
        int is_method_anoted;
} Node;

#include "table.h"
Node *create_node(char *type, TokenContainer* value, Node *son);
Node *add_brother(Node *brother, Node *brother_to_add);
void print_tree(Node * node, int lvl);
void print_anoted_tree(Node * node, int lvl);
void cleanTree(Node * node);
TokenContainer* create_tk_cont(char* string, int pos, int line);

#endif