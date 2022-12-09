#include "arvore.h"
#include "table.h"

void analiza_programa(Node* root);
void analiza_field_decl(Node *root, Table* class_table);
void analiza_method_decl(Node *root, Table* class_table);
void handle_method_body(Table* target, Node* root);