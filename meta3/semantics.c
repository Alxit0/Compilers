#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semantics.h"

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

int compare_parms_diferent(Params_node* pr1, Params_node* pr2){
    Params_node* param1 = pr1;  //to check
    Params_node* param2 = pr2;  //preciso

    while (param1 != NULL && param2 != NULL)
    {
        // printf("\t Ola\n");
        if (param1->param == NULL || param2->param == NULL)
            return 0;

        if (strcmp(param1->param, param2->param) == 0){
            param1 = param1->next;
            param2 = param2->next;
            continue;
        }

        if (strcmp(param1->param, "double") == 0){
            if (strcmp(param2->param, "int") != 0)
                return 0;
        }else
        {
            return 0;
        }
        
        

        // if (strcmp(param1->param, "int") == 0){
        //     if (strcmp(param2->param, "double") != 0)
        //         return 0;
        // }
        
        param1 = param1->next;
        param2 = param2->next;
    }
    if (param1 == NULL && param2 == NULL){
        return 1;
    }
    
    return 0;
}

Params_node* get_call_needed_params(Node* node, Table* table){
    Node * aux = node->son->brother;
    Params_node* head = NULL;
    Params_node* tail = NULL;
    Params_node * temp;


    while (aux)
    {
        if (strcmp(aux->type, "Id") == 0){
            temp = procura_tabela_char(aux->value, table);
        }else{
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

Table_Node* find_method(Table* table, TokenContainer* id, Params_node* needed_params, int found){
    if (table == NULL){
        if (found > 1){
            printf("Line %d, col %d: Reference to method %s", id->line, id->pos, id->string);
            if (needed_params == NULL){
                printf("()\n");
                return NULL;
            }
            needed_params->is_method_args = 1;
            print_params(needed_params);
            printf(" is ambiguous\n");
            return NULL;
        }else{
            printf("Line %d, col %d: Cannot find symbol %s", id->line, id->pos, id->string);
            if (needed_params == NULL){
                printf("()\n");
                return NULL;
            }
            needed_params->is_method_args = 1;
            print_params(needed_params);
            printf("\n");
            return NULL;
        }
    }
    Table_Node* aux = table->elems;
    while (aux != NULL)
    {
        if (strcmp(aux->id, id->string) != 0){
            aux = aux->next;
            continue;
        }

        if (needed_params == NULL && aux->param == NULL)
            return aux;

        if (aux->param == NULL || aux->param->is_method_args != 1){
            aux = aux->next;
            continue;
        }
        
        // printf("%s >> %s\n", id, aux->id);
        if (compare_parms(aux->param, needed_params) == 1)
            return aux;
        aux = aux->next;
    }

    aux = table->elems;
    int possible_methods = 0;
    Table_Node* resp;
    while (aux != NULL)
    {
        if (strcmp(aux->id, id->string) != 0){
            aux = aux->next;
            continue;
        }

        if (needed_params == NULL && aux->param == NULL)
            return aux;

        if (aux->param == NULL || aux->param->is_method_args != 1){
            aux = aux->next;
            continue;
        }
        
        if (compare_parms_diferent(aux->param, needed_params) == 1){
            resp = aux;
            possible_methods++;
        }
            // return aux;
        aux = aux->next;
    }

    if (possible_methods == 1){
        return resp;
    }

    return find_method(table->parent, id, needed_params, found+possible_methods);
}



void analiza_programa(Node* root){
    if (root == NULL)
        return;
    
    Table_List* table_list = init_table_list();
    
    Table* class_table = init_table(root);
    
    class_table->method = "Class";
    class_table->name = root->son->value->string;
    
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
    // printf("Ola")
    print_table_list(table_list);
    print_anoted_tree(root, 0);
    // print_class_table(class_table);
}

void analiza_field_decl(Node* root, Table* class_table){
    if (root == NULL)
        return;

    add_element(class_table, root->son->brother->value, root->son->type, "", 1);
}

Table* analiza_method_decl(Node* root, Table* class_table){
    Table* method_table = init_table(root);
    
    Node* methodHeader = root->son;
    Node* methodBody = root->son->brother;

    // method header stuf
    method_table->name = methodHeader->son->brother->value->string;
    method_table->method = "Method";
    method_table->parent = class_table;

    add_element(method_table, create_tk_cont("return", -1, -1), methodHeader->son->type, "", 0);

    Node* aux = methodHeader->son->brother->brother->son; //ParamDecl
    while (aux != NULL)
    {
        add_param(method_table, aux->son->type);
        add_element(method_table, aux->son->brother->value, aux->son->type, "param", 1);
        aux = aux->brother;
    }

    Table_Node * aux2 = add_element(class_table, create_tk_cont(method_table->name, -1, -1), methodHeader->son->type, "", 0);
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
    // printf("%s\n", root->type);
    if (strcmp(root->type, "VarDecl")==0){
        add_element(target, root->son->brother->value, root->son->type, "", 1);
        return;
    }
    if (strcmp(root->type, "Id") == 0) {
        root->anotation = procura_tabela_char(root->value, target);
        // return;
    }
    if (strcmp(root->type, "DecLit") * 
        strcmp(root->type, "ParseArgs") * 
        strcmp(root->type, "Length") == 0){
        root->anotation = init_param("int");
        // return;
    }
    if (strcmp(root->type, "RealLit") == 0){
        root->anotation = init_param("double");
        
        // //convert string to float
        // char * numero_aux = strdup(root->value->string);
        // for (int i=0; i<strlen(numero_aux); i++){
        //     if (numero_aux[i] == '_'){
        //         for (int j=i; j<strlen(numero_aux);j++){
        //             *(numero_aux+j) = *(numero_aux+j+1);
        //         }
        //         i--;
        //     }
        // }
        // // printf("%s\n", numero_aux);
        // char* pointer = NULL;
        // long numero = strtol(numero_aux, &pointer, 10);
        // if (numero > 2147483647 || numero < -2147483648)
        //     printf("Line %d, col %d: Number %s out of bounds\n",
        //     root->value->line, root->value->pos, root->value->string);
        // // printf("float value : %4.8f\n", atof(root->value->string));
    }
    if (strcmp(root->type, "StrLit") == 0){
        root->anotation = init_param("String");
        // return;
    }
    

    Node * aux = root->son;
    if (strcmp(root->type, "Call") == 0)
        aux = aux->brother;
    while (aux != NULL)
    {
        handle_method_body(target, aux);
        aux = aux->brother;
    }

    if (strcmp(root->type, "Not") == 0){
        if (strcmp(root->son->anotation->param, "boolean") != 0){
            printf("Line %d, col %d: Operator %s cannot be applied to type %s\n",
            root->value->line, root->value->pos, root->value->string, root->son->anotation->param);
        }
        root->anotation = init_param("boolean");
    }
    if (strcmp(root->type, "BoolLit") == 0){
        root->anotation = init_param("boolean");
    }
    if (strcmp(root->type, "Eq") == 0 ||
        strcmp(root->type, "Ne") == 0 ||
        strcmp(root->type, "Gt") == 0 ||
        strcmp(root->type, "Ge") == 0 ||
        strcmp(root->type, "Lt") == 0 ||
        strcmp(root->type, "Le") == 0 ||
        strcmp(root->type, "And") == 0 ||
        strcmp(root->type, "Or") == 0 ||
        strcmp(root->type, "Xor") == 0){
        root->anotation = init_param("boolean");

        char *type1 = root->son->anotation->param;
        char *type2 = root->son->brother->anotation->param;
        if (strcmp(type1, "none") == 0 || strcmp(type2, "none") == 0){
            printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", 
                root->value->line, root->value->pos, root->value->string, type1, type2);
            root->anotation = init_param("boolean");
        }else if (strcmp(type1, type2) == 0 && (strcmp(type1, "boolean") == 0 || strcmp(type1, "int") == 0 || strcmp(type1, "double") == 0)){}
        else if ((strcmp(type1, "int") == 0 && strcmp(type2, "double") == 0) ||
                (strcmp(type1, "double") == 0 && strcmp(type2, "int") == 0)){}
        else{
            printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", 
                root->value->line, root->value->pos, root->value->string, type1, type2);
            // root->anotation = init_param("undef");
        }

        
        if (strcmp(root->type, "Xor") == 0 && strcmp(type1, type2) == 0 && strcmp(type1, "int") == 0)
            root->anotation = init_param("int");
        // return;
    }
    if (strcmp(root->type, "Assign") == 0){
        char* type1 = root->son->anotation->param;
        char* type2 = root->son->brother->anotation->param;

        // printf("%s", root->value->string);
        if ((strcmp(type1, "double") == 0 && strcmp(type2, "int") == 0)){
            // pass
        }else if (strcmp(type1, type2) != 0){
            printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", 
                root->value->line, root->value->pos, root->value->string, type1, type2);
        }

        root->anotation = root->son->anotation;
    }
    if (strcmp(root->type, "Plus") == 0 ||
        strcmp(root->type, "Minus") == 0) {
        char* type = root->son->anotation->param;
        if (strcmp(type, "int") == 0 || strcmp(type, "double") == 0)
            root->anotation = root->son->anotation;
        else{
            printf("Line %d, col %d: Operator %s cannot be applied to type %s\n",
                root->value->line, root->value->pos, root->value->string, type);
            root->anotation = init_param("undef");
        }
    }
    if (strcmp(root->type, "Add") == 0 ||
        strcmp(root->type, "Sub") == 0 ||
        strcmp(root->type, "Mul") == 0 ||
        strcmp(root->type, "Div") == 0 ||
        strcmp(root->type, "Mod") == 0) {
        


        char* type1 = root->son->anotation->param;
        char* type2 = root->son->brother->anotation->param;
        
        // printf("%s, %s %s\n", root->type, type1, type2);
        if (strcmp(type1, "undef") == 0){
            root->anotation = root->son->anotation;
        }
        else
            root->anotation = root->son->brother->anotation;
        
        if (strcmp(type1, "int") == 0){
            if (strcmp(type2, "int") == 0 || strcmp(type2, "double") == 0)
                root->anotation = root->son->brother->anotation;
            else
                root->anotation = init_param("undef");
        }else if (strcmp(type1, "double") == 0)
            if (strcmp(type2, "int") == 0 || strcmp(type2, "double") == 0)
                root->anotation = root->son->anotation;
            else
                root->anotation = init_param("undef");
        else
            root->anotation = init_param("undef");
        
        if (strcmp(root->anotation->param, "undef") == 0)
            printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", 
                root->value->line, root->value->pos, root->value->string, type1, type2);

    }
    if (strcmp(root->type, "If") == 0) {
        if (strcmp(root->son->anotation->param, "boolean") != 0){
            printf("Line %d, col %d: Incompatible type %s in if statement\n",
            root->son->value->line, root->son->value->pos, root->son->anotation->param);
        }
    }
    if (strcmp(root->type, "Lshift") == 0 ||
        strcmp(root->type, "Rshift") == 0){
        

        root->anotation = init_param("none");
    }
    if (strcmp(root->type, "Return") == 0){
        
        
        Node* aux = root->son;
        char* given_param = "void";
        if (aux != NULL)
            given_param = aux->anotation->param;
        
        // printf("%s %s\n",given_param ,target->elems->type);
        
        if (strcmp(target->elems->type, "void") == 0 && aux != NULL){
            printf("Line %d, col %d: Incompatible type %s in %s statement\n",
                aux->value->line, aux->value->pos, given_param, root->value->string);
        }else if (strcmp(target->elems->type, "double") == 0 && strcmp(given_param, "int") == 0)
        {  
        }else if (strcmp(given_param, target->elems->type) != 0 && aux != NULL){
            printf("Line %d, col %d: Incompatible type %s in %s statement\n",
                aux->value->line, aux->value->pos, given_param, root->value->string);
        }else if (strcmp(target->elems->type, "void") != 0 && aux == NULL){
            printf("Line %d, col %d: Incompatible type void in %s statement\n",
                root->value->line, root->value->pos, root->value->string);
        }
            
    }
    if (strcmp(root->type, "Print") == 0){
        
        Node* aux = root->son;

        if (strcmp(aux->anotation->param, "undef") == 0 || strcmp(aux->anotation->param, "String[]") == 0)
            printf("Line %d, col %d: Incompatible type %s in %s statement\n",
                aux->value->line, aux->value->pos, aux->anotation->param, root->value->string);
    }
    if (strcmp(root->type, "Length") == 0){

        Node* aux = root->son;

        if (strcmp(aux->anotation->param, "undef") == 0 || strcmp(aux->anotation->param, "String[]") != 0)
            printf("Line %d, col %d: Operator %s cannot be applied to type %s\n",
                root->value->line, root->value->pos, root->value->string, aux->anotation->param);
    }
    if (strcmp(root->type, "ParseArgs") == 0){

        Node* aux = root->son;
        char *type1 = root->son->anotation->param;
        char *type2 = root->son->brother->anotation->param;
        
        if (strcmp(type1, "String[]") != 0 || strcmp(type2, "int") != 0)
            printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n",
                root->value->line, root->value->pos, root->value->string, type1, type2);
    }
    if (strcmp(root->type, "Call") == 0){

        Params_node* needed_params = get_call_needed_params(root, target);
        Table_Node* called_method = find_method(target, root->son->value, needed_params, 0);

        TokenContainer* temp = root->son->value;

        root->value = create_tk_cont(temp->string, temp->pos, temp->line);
        root->value->is_to_show = 0;
        
        if (called_method == NULL){
            // printf("No method found!\n");
            root->anotation = init_param("undef");
            root->son->anotation = init_param("undef");

            return;
        }else{
            root->anotation = init_param(called_method->type);
            root->son->anotation = called_method->param;
            root->son->is_method_anoted = 1;
        }
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
