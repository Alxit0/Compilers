#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semantics.h"

void handle_call(Node * node, Table* table);


Params_node* procura_tabela_char(char * nome, Table* table) {
    if (table == NULL)
        return init_param("undef");
    
    Table_Node* aux = table->elems;
    
    while (aux)
    {
        // printf("Ola %s\n", aux->id);
        if (aux->param == NULL){
            aux = aux->next;
            continue;
        }

        if (strcmp(aux->id, nome) == 0){
            printf("\t%s\n", aux->type);
            return init_param(aux->type);
        }
        aux = aux->next;
    }
    return procura_tabela_char(nome, table->parent);
}

int compare_parms(Params_node* pr1, Params_node* pr2){
    
    Params_node* param1 = pr1;
    Params_node* param2 = pr2;
    while (param1 != NULL && param2 != NULL)
    {
        // printf("\t Ola\n");
        if (param1->param == NULL || param2->param == NULL)
            return 0;
        
        if (strcmp(param1->param, param2->param) != 0)
            return 0;
        
        param1 = param1->next;
        param2 = param2->next;
    }
    if (param1 == NULL && param2 == NULL){
        return 1;
    }
    
    return 0;
}

int compare_parms_diferent(Params_node* param1, Params_node* param2){
    return 0;
}

Params_node* get_call_needed_params(Node* node, Table* table){
    Node * aux = node->son->brother;
    Params_node* head = NULL;
    Params_node* tail = NULL;
    Params_node * temp;
    
    printf("%s\n", node->son->value);
    while (aux)
    {
        printf("\t%s\n", aux->type);
        if (strcmp(aux->type, "Id") == 0){
            temp = procura_tabela_char(aux->value, table);
            aux->anotation = temp;
        }
        if (strcmp(aux->type, "Call") == 0){
            handle_call(aux, table);
            temp = aux->anotation;
        }
        if (head == NULL){
            head = temp;
            tail = head;
        }else{
            tail->next = temp;
            tail = tail->next;
        }
        aux = aux->brother;
    }
    
    return head;
}

Table_Node* find_method(Table* table, char* id, Params_node* needed_params){
    if (table == NULL)
        return NULL;
    
    Table_Node* aux = table->elems;
    while (aux != NULL)
    {
        if (aux->param != NULL && aux->param->is_method_args != 1){
            aux = aux->next;
            continue;
        }
        if (strcmp(aux->id, id) != 0){
            aux = aux->next;
            continue;
        }

        // printf("%s >> %s\n", id, aux->id);
        if (compare_parms(aux->param, needed_params) == 1)
            return aux;
        aux = aux->next;
    }

    aux = table->elems;
    while (aux != NULL)
    {
        if (aux->param == NULL || aux->param->is_method_args != 1){
            aux = aux->next;
            continue;
        }

        if (strcmp(aux->id, id) != 0 || aux->param->is_method_args != 1){
            aux = aux->next;
            continue;
        }

        if (compare_parms_diferent(aux->param, needed_params) == 1)
            return aux;
        aux = aux->next;
    }

    return find_method(table->parent, id, needed_params);
}

void handle_call(Node * node, Table* table){
    // printf(" %s\n", node->son->value);
    Params_node* needed_params = get_call_needed_params(node, table);
    Table_Node* called_method = find_method(table, node->son->value, needed_params);
    
    if (called_method == NULL){
        node->anotation = init_param("undef");
    }else{
        node->anotation = called_method->param;
    }
}



void analiza_programa(Node* root){
    if (root == NULL)
        return;
    
    Table_List* table_list = init_table_list();
    
    Table* class_table = init_table(root);
    
    class_table->method = "Class";
    class_table->name = root->son->value;
    
    add_table(table_list, class_table, "class");

    Node* aux = root->son;
    while (aux != NULL)
    {
        if (strcmp(aux->type, "FieldDecl") == 0)
            analiza_field_decl(aux, class_table);
        
        if (strcmp(aux->type, "MethodDecl") == 0){
            Table* aux2 = analiza_method_decl(aux, class_table);
            add_table(table_list, aux2, "method");
        }
        aux = aux->brother;
    }

    // update_tree(root, table_list);
    generate_tree(root, table_list);
    print_table_list(table_list);
    print_anoted_tree(root, 0);
    // print_class_table(class_table);
}

void analiza_field_decl(Node* root, Table* class_table){
    if (root == NULL)
        return;

    add_element(class_table, root->son->brother->value, root->son->type, "");
}

Table* analiza_method_decl(Node* root, Table* class_table){
    Table* method_table = init_table(root);
    
    Node* methodHeader = root->son;
    Node* methodBody = root->son->brother;

    // method header stuf
    method_table->name = methodHeader->son->brother->value;
    method_table->method = "Method";
    method_table->parent = class_table;

    add_element(method_table, "return", methodHeader->son->type, "");

    Node* aux = methodHeader->son->brother->brother->son; //ParamDecl
    while (aux != NULL)
    {
        add_param(method_table, aux->son->type);
        add_element(method_table, aux->son->brother->value, aux->son->type, "param");
        aux = aux->brother;
    }

    Table_Node * aux2 = add_element(class_table, method_table->name, methodHeader->son->type, "");
    free(aux2->param);
    aux2->param = method_table->params_head;
    if (aux2->param != NULL)
        aux2->param->is_method_args = 1;

    // method body stuf
    // handle_method_body(method_table, methodBody);
    
    // print_method_table(method_table);
    return method_table;
}

void handle_method_body(Table* target, Node* root){
    if (root == NULL){
        return;
    }
    if (strcmp(root->type, "VarDecl")==0){
        add_element(target, root->son->brother->value, root->son->type, "");
        return;
    }
    if (strcmp(root->type, "Id") == 0) {
        root->anotation = procura_tabela_char(root->value, target);
        printf("%s %s\n", root->value, root->anotation->param);
        // return;
    }

    if (strcmp(root->type, "DecLit") * strcmp(root->type, "ParseArgs") * strcmp(root->type, "Length") == 0){
        root->anotation = init_param("int");
        // return;
    }
    if (strcmp(root->type, "RealLit") == 0){
        root->anotation = init_param("double");
        // return;
    }
    if (strcmp(root->type, "StrLit") == 0){
        root->anotation = init_param("String");
        // return;
    }
    if (strcmp(root->type, "Eq") == 0 ||
            strcmp(root->type, "Gt") == 0 ||
            strcmp(root->type, "Ge") == 0 ||
            strcmp(root->type, "Lt") == 0 ||
            strcmp(root->type, "Le") == 0 ||
            strcmp(root->type, "And") == 0 ||
            strcmp(root->type, "Or") == 0 ||
            strcmp(root->type, "Not") == 0 ||
            strcmp(root->type, "BoolLit") == 0){
        root->anotation = init_param("boolean");
        // return;
    }

    Node * aux = root->son;
    while (aux != NULL)
    {
        handle_method_body(target, aux);
        aux = aux->brother;
    }

    if (strcmp(root->type, "Assign") == 0 ||
        strcmp(root->type, "Plus") == 0 ||
        strcmp(root->type, "Minus") == 0) {
        
        root->anotation = root->son->anotation;
    }
    if (strcmp(root->type, "Add") == 0 ||
        strcmp(root->type, "Sub") == 0 ||
        strcmp(root->type, "Mul") == 0 ||
        strcmp(root->type, "Div") == 0 ||
        strcmp(root->type, "Mod") == 0) {
        
        Params_node* anota;
        if (strcmp(root->son->anotation->param, root->son->brother->anotation->param) == 0) {
            anota = root->son->anotation;
        }
        else {
            anota = init_param("double");
        }
        root->anotation = anota;
    }
    if (strcmp(root->type, "Call") == 0){
        // handle_call(root, target);
    }

    
}

void generate_tree(Node* root, Table_List* table_list){
    if (root == NULL)
        return;
    
    TLNode* table_node_aux = table_list->head->next;  // 1a is the class one
    Node* cur_node = root->son;
    while (cur_node != NULL && table_node_aux != NULL)
    {
        if (strcmp(cur_node->type, "MethodDecl") != 0){
            cur_node = cur_node->brother;
            continue;
        }
        handle_method_body(table_node_aux->table, cur_node->son->brother);
        cur_node = cur_node->brother;
        table_node_aux = table_node_aux->next;
    }
}
