#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Structs
typedef struct Node
{
	char* nodeType;
	char* nodeValue;
	struct Node *son;
	struct Node *brother;
} Node;

Node *new_node(char *type, char *value, Node *son);
void print_tree(Node * node, int aux);
Node * new_brother(Node *brother, Node *brother_to_add);
void cleanTree(Node * node);