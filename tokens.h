#ifndef TOKENS_H
#define TOKENS_H

#include <string>
#include <vector>
#include <unordered_map>
#include <iostream>
#include <iomanip>

using std::string;
using std::vector;
using std::unordered_map;
using std::cout;
using std::endl;
using std::setw;
using std::left;
using std::right;

// Definição padronizada de Tokens
enum TokenType {
    TOKEN_EOF = 0,
    TOKEN_CLASS = 256,
    TOKEN_RELATION,
    TOKEN_INSTANCE,
    TOKEN_NEW_TYPE,
    TOKEN_RESERVED,
    TOKEN_KEYWORD,
    TOKEN_STEREOTYPE_CLASS,
    TOKEN_STEREOTYPE_RELATION,
    TOKEN_META_ATTRIBUTE,
    TOKEN_NATIVE_TYPE,
    TOKEN_SPECIAL_SYMBOL,
    TOKEN_INT_NUMBER
};

// Estrutura para armazenar as ocorrências dos tokens
struct TokenOccurrence {
    int linha;
    int coluna;
    int id_token;
    string lexema;
};

// Declaração das variáveis globais compartilhadas (extern)
extern vector<TokenOccurrence> visao_analitica;
extern unordered_map<string, string> tabela_de_simbolos;


#endif // TOKENS_H