#include "arvore.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Node *create_node(char *type, char *value, Node *son){
        Node *new_node = (Node *) malloc(sizeof(Node));
        new_node->type = type;
        new_node->value = value;
        new_node->son = son;
        new_node->brother = NULL;
        new_node->anotation = NULL;
        return new_node;
    }

Node *add_brother(Node *brother, Node *brother_to_add){
    if(brother == NULL)
        // return brother_to_add;
        return NULL;

    Node *head = brother;
    // aux->brother = brother_to_add;
    while(brother->brother != NULL){
        brother = brother->brother;
    }
    brother->brother = brother_to_add;
    return head;
}

void print_tree(Node * node, int lvl){
    if (node == NULL)
        return;
    
    for (int i = 0; i < lvl; ++i){
        printf("..");
    }

    if (node->value == NULL)
        printf("%s\n", node->type);
    else{
        if(strcmp(node->type, "StrLit") == 0)
            printf("%s(\"%s\")\n", node -> type, node->value);
        else
            printf("%s(%s)\n", node -> type, node->value);
    }
    
    print_tree(node->son, lvl+1);
    print_tree(node->brother, lvl);
}

void print_anoted_tree(Node * node, int lvl){
    if (node == NULL)
        return;
    
    for (int i = 0; i < lvl; ++i){
        printf("..");
    }

    if (node->value == NULL)
        printf("%s", node->type);
    else{
        if(strcmp(node->type, "StrLit") == 0)
            printf("%s(\"%s\")", node -> type, node->value);
        else
            printf("%s(%s)", node -> type, node->value);
    }

    if (node->anotation != NULL)
        printf(" - %s", node->anotation->param);
    printf("\n");
    
    print_anoted_tree(node->son, lvl+1);
    print_anoted_tree(node->brother, lvl);
}

void cleanTree(Node * node){
    if(node == NULL)
        return;
    cleanTree(node->brother);
    cleanTree(node->son);
    free(node);
}