#ifndef ARVORE_H_INCLUDED
#define ARVORE_H_INCLUDED

typedef struct Node{
        char* type;
        char* value;
        struct Node *son;
        struct Node *brother;
} Node;

Node *create_node(char *type, char *value, Node *son);
Node *add_brother(Node *brother, Node *brother_to_add);
void print_tree(Node * node, int lvl);
void cleanTree(Node * node);

#endif