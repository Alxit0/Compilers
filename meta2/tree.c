#include "tree.h"

Node *new_node(char *type, char *value, Node *son)
{
    Node *new = (Node *) malloc(sizeof(Node));
    new->nodeType = type;
      new->nodeValue = value;
    new->son = son;
    new->brother = NULL;
    return new;
}


Node * new_brother(Node *brother, Node *brother_to_add)
{
    if(brother == NULL) return NULL;
    Node *aux = brother;
    while(brother->brother != NULL){
        brother = brother->brother;
    }
    brother->brother = brother_to_add;
    return aux;
}


void print_tree(Node * node, int depth)
{
    if (node == NULL)
        return;
    for (int i = 0; i < depth; ++i)
        printf("..");
    if (node->nodeValue != NULL)
        if(strcmp(node->nodeType, "StrLit")==0)
            printf("%s(\"%s\")\n", node -> nodeType, node->nodeValue);
        else printf("%s(%s)\n", node -> nodeType, node->nodeValue);
    else
        printf("%s\n", node->nodeType);
    print_tree(node->son, depth+1);
    print_tree(node->brother, depth);
}

void cleanTree(Node * node){
    if(node == NULL)
        return;
    cleanTree(node->brother);
    cleanTree(node->son);
    free(node);
}
