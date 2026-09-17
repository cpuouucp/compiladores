%{
#include "tokens.h" 
#include <cstdio>

// Vetor global para a Visão Analítica
vector<TokenOccurrence> visao_analitica;

// Tabela de Dispersão Dinâmica (Tabela de Símbolos) para novos lexemas/tipos
unordered_map<string, string> tabela_de_simbolos;

// Variáveis globais para rastreamento de posição
int linha_atual = 1;
int coluna_atual = 1;

// Contadores globais para a Tabela de Síntese
int quantidade_classes = 0; 
int quantidade_relacoes = 0;
int quantidade_palavras_chave = 0; 
int quantidade_individuos = 0; // instancias
int quantidade_meta_atributos = 0;  
int quantidade_novos_tipos = 0;
int quantidade_simbolos_especiais = 0;
int quantidade_tipos_nativos = 0;
int quantidade_estereotipos_classe = 0;
int quantidade_estereotipos_relacao = 0;
int quantidade_palavras_reservada = 0; 
int quantidade_numeros = 0;

// Função auxiliar para processar e armazenar o token
void registrar_token(int id, const char* lexema) {
    visao_analitica.push_back({linha_atual, coluna_atual, id, string(lexema)});
    coluna_atual += strlen(lexema); // Move a coluna para o fim do lexema
}

// Função que conta caracteres UTF-8 multi-byte para corrigir o desalinhamento do setw
void imprimir_alinhado(string texto, int largura_alvo) {
    int caracteres_reais = 0;
    for (size_t i = 0; i < texto.length(); i++) {
        // Em UTF-8, caracteres multi-byte (acentos) começam com bits 11xxxxxx
        // Isso significa que o byte tem valor assinado menor que -64 (ou em char isolado)
        if ((texto[i] & 0xC0) != 0x80) {
            caracteres_reais++;
        }
    }
    // Compensação: adiciona a diferença de bytes ao setw
    int diferenca = texto.length() - caracteres_reais;
    cout << left << setw(largura_alvo + diferenca) << texto;
}

%}

    // Opção para ler apenas um arquivo por execução
%option noyywrap

%%
 
    /* IGNORAR COMENTÁRIOS DE LINHA ÚNICA */
"//"[^\n]* { 
    coluna_atual += strlen(yytext);
}


    /* IGNORAR COMENTÁRIOS DE BLOCO (MÚLTIPLAS LINHAS) */
"/*" {
    int c;
    coluna_atual += 2;
    while ((c = yyinput()) != 0) {
        if (c == '\n') {
            linha_atual++;
            coluna_atual = 1;
        } else if (c == '*') {
            int proximo = yyinput();
            if (proximo == '/') {
                coluna_atual += 2;
                break; 
            } else {
                unput(proximo);
                coluna_atual++;
            }
        } else {
            coluna_atual++;
        }
    }
}

[ \t] { 
    // Espaços e tabs apenas deslocam o cursor da coluna
    coluna_atual += strlen(yytext); 
}

\n { 
    // Quebra de linha reseta a coluna e incrementa a linha
    linha_atual++; 
    coluna_atual = 1; 
}

    /* PALAVRAS RESERVADAS */
"genset"|"disjoint"|"complete"|"general"|"specifics"|"where"|"package"|"import"|"functional-complexes" {
    registrar_token(TOKEN_RESERVED, yytext);
    quantidade_palavras_reservada++;
    return TOKEN_RESERVED;
}

    /* PALAVRAS-CHAVE */
"class"|"specializes"|"enum"|"relation"|"datatype" {
    registrar_token(TOKEN_KEYWORD, yytext);
    quantidade_palavras_chave++;
    return TOKEN_KEYWORD;
}

    /* META-ATRIBUTOS */
"ordered"|"const"|"derived"|"subsets"|"redefines" {
    registrar_token(TOKEN_META_ATTRIBUTE, yytext);
    quantidade_meta_atributos++;
    return TOKEN_META_ATTRIBUTE;
}

    /* TIPOS NATIVOS */
"number"|"string"|"boolean"|"date"|"time"|"datetime" {
    registrar_token(TOKEN_NATIVE_TYPE, yytext);
    quantidade_tipos_nativos++;
    return TOKEN_NATIVE_TYPE;
}

    /* ESTERÉOTIPOS DE CLASSE */
"event"|"situation"|"process"|"category"|"mixin"|"phaseMixin"|"roleMixin"|"historicalRoleMixin"|"kind"|"collective"|"quantity"|"quality"|"mode"|"intrisicMode"|"extrinsicMode"|"subkind"|"phase"|"role"|"historicalRole" {
    registrar_token(TOKEN_STEREOTYPE_CLASS, yytext);
    quantidade_estereotipos_classe++;
    return TOKEN_STEREOTYPE_CLASS;
}

    /* ESTERÉOTIPOS DE RELAÇÕES */
"material"|"derivation"|"comparative"|"mediation"|"characterization"|"externalDependence"|"componentOf"|"memberOf"|"subCollectionOf"|"subQualityOf"|"instantiation"|"termination"|"participational"|"participation"|"historicalDependence"|"creation"|"manifestation"|"bringsAbout"|"triggers"|"composition"|"aggregation"|"inherence"|"value"|"formal"|"constitution" {
    registrar_token(TOKEN_STEREOTYPE_RELATION, yytext);
    quantidade_estereotipos_relacao++;
    return TOKEN_STEREOTYPE_RELATION;
}

    /* SÍMBOLOS ESPECIAIS (Retornam seu próprio valor ASCII individual) */
"{"|"}"|"("|")"|"["|"]"|"*"|"@"|":"|";"|"\.\."|"<>--"|"--<>"|"," {
    registrar_token(TOKEN_SPECIAL_SYMBOL, yytext);
    quantidade_simbolos_especiais++;
    return TOKEN_SPECIAL_SYMBOL;
}

    /* CONVENÇÃO DE NOVOS TIPOS (Sem números, sem sublinhado, termina com DataType) */
[a-zA-Z]+DataType {
    // Cadastro dinâmico na Tabela de Dispersão de Símbolos
    tabela_de_simbolos[string(yytext)] = "Novo Tipo Customizado";
    registrar_token(TOKEN_NEW_TYPE, yytext);
    quantidade_novos_tipos++;
    return TOKEN_NEW_TYPE;
}
    /* 10. NÚMEROS INTEIROS (Para cardinalidades e valores literais) */
[0-9]+ {
    registrar_token(TOKEN_INT_NUMBER, yytext);
    quantidade_numeros++; // 
    return TOKEN_INT_NUMBER;
}


    /* CONVENÇÃO DE INSTÂNCIAS (Inicia com qualquer letra/sublinhado e termina com inteiro) */
[a-zA-Z_]+[0-9]+ { // [a-zA-Z]+[[_?][a-zA-Z]]*[0-9]
    tabela_de_simbolos[string(yytext)] = "Instância / Indivíduo";
    registrar_token(TOKEN_INSTANCE, yytext);
    quantidade_individuos++;
    return TOKEN_INSTANCE;
}

    /* CONVENÇÃO DE CLASSES (Inicia com Maiúscula, podendo ter cadeia própria de sublinhado, sem números) */
[A-Z][a-zA-Z_]* { // [A-Z]+[[_?][a-zA-Z]]*
    tabela_de_simbolos[string(yytext)] = "Classe Ontológica";
    registrar_token(TOKEN_CLASS, yytext);
    quantidade_classes++;
    return TOKEN_CLASS;
}

    /* CONVENÇÃO DE RELAÇÕES (Inicia com Minúscula, podendo ter cadeia própria de sublinhado, sem números) */
[a-z][a-zA-Z_]* { // [a-z]+[[_?][a-zA-Z]]*
    tabela_de_simbolos[string(yytext)] = "Relação Ontológica";
    registrar_token(TOKEN_RELATION, yytext);
    quantidade_relacoes++;
    return TOKEN_RELATION;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    /* Esta regra vai engolir QUALQUER palavra inteira (letras/números misturados) */
    /* que não tenha se encaixado perfeitamente nas regras válidas acima (como C4sa) */
    cout << "\n";
    cout << "❌ Erro Léxico na Linha " << linha_atual << ", Coluna " << coluna_atual 
         << ": Identificador malformado '" << yytext << "'" << endl;
    cout << "   💡 Sugestão: Nomes com números misturados no meio não são permitidos na convenção TONTO." << endl;
    
    coluna_atual += strlen(yytext); // Avança a coluna pelo tamanho TOTAL do erro (4 caracteres)
}

    /* Caracteres isolados inválidos (ex: #, $, etc.) */
. {
    cout << "❌ Erro Léxico na Linha " << linha_atual << ", Coluna " << coluna_atual 
         << ": Caractere inválido '" << yytext << "'" << endl;
    coluna_atual += strlen(yytext);
}

%%

int main(int argc, char** argv) {
    // Tabela de dispersão estática para mapear ID numérico para String amigável
    unordered_map<int, string> nome_dos_tokens;
    nome_dos_tokens[TOKEN_CLASS]               = "Nome de Classe";
    nome_dos_tokens[TOKEN_RELATION]            = "Nome de Relação/Atributo";
    nome_dos_tokens[TOKEN_INSTANCE]            = "Nome de Instância";
    nome_dos_tokens[TOKEN_NEW_TYPE]            = "Novo Tipo de Dado";
    nome_dos_tokens[TOKEN_RESERVED]            = "Palavra Reservada";
    nome_dos_tokens[TOKEN_STEREOTYPE_CLASS]    = "Esteriótipo de Classe";
    nome_dos_tokens[TOKEN_STEREOTYPE_RELATION] = "Esteriótipo de Relação";
    nome_dos_tokens[TOKEN_META_ATTRIBUTE]      = "Meta-Atributo";
    nome_dos_tokens[TOKEN_NATIVE_TYPE]         = "Tipo Nativo";
    nome_dos_tokens[TOKEN_SPECIAL_SYMBOL]      = "Símbolo Especial";
    nome_dos_tokens[TOKEN_KEYWORD]             = "Palavra-Chave";
    nome_dos_tokens[TOKEN_INT_NUMBER]          = "Número Inteiro";

    // Recebe arquivo via linha de comando
    if (argc > 1) {
        FILE* arquivo = fopen(argv[1], "r");
        if (!arquivo) {
            cout << "Erro ao abrir o arquivo especificado: " << argv[1] << endl;
            return 1;
        }
        yyin = arquivo;
    } else {
        cout << "Aviso: Nenhum arquivo fornecido. Digite o código TONTO ou use: ./lexer arquivo.tonto" << endl;
    }

    // Dispara a leitura do arquivo inteiro pelo Flex
    while(yylex() != TOKEN_EOF);

    // -----------------------------------------------------------------
    //              VISUALIZAÇÃO 1: VISÃO ANALÍTICA DOS TOKENS        //             
    // -----------------------------------------------------------------
    cout << "\n" << string(90, '=') << endl;
    cout << "                         1. VISÃO ANALÍTICA DOS TOKENS                          " << endl;
    cout << string(90, '=') << endl;
    
    // Cabeçalho com larguras fixas perfeitamente distribuídas (Total: 90 caracteres)
    cout << right << setw(6)  << "LINHA" << " | " 
         << right << setw(6)  << "COLUNA" << " | " 
         << left << setw(30) << "TIPO DO TOKEN" << " | " 
         << left << setw(35) << "LEXEMA" << endl;
    cout << string(90, '-') << endl;

    for (const auto& t : visao_analitica) {
        string tipo_texto;
        
        // Proteção para buscar o token mapeado com segurança
        if (nome_dos_tokens.find(t.id_token) != nome_dos_tokens.end()) {
            tipo_texto = nome_dos_tokens[t.id_token];
        } else {
            tipo_texto = "TOKEN_UNKNOWN";
        }

        // Impressão usando a nova função auxiliar para alinhar
        cout << right << setw(6) << t.linha << " | ";
        cout << right << setw(6) << t.coluna << " | ";
        imprimir_alinhado(tipo_texto, 30); cout << " | ";
        imprimir_alinhado(t.lexema, 35); cout << endl;
    }
    cout << string(90, '=') << endl;

    // -----------------------------------------------------------------
    //          VISUALIZAÇÃO 2: TABELA DE SÍNTESE ACUMULADA           //
    // -----------------------------------------------------------------
    cout << "\n" << string(80, '=') << endl;
    cout << "                 2. TABELA DE SÍNTESE ACUMULADA             " << endl;
    cout << string(80, '=') << endl;
    cout << left << setw(58) << "       CONCEITO / CATEGORIA" << " | " << "QUANTIDADE" << endl;
    cout << string(80, '-') << endl;
    
    // Impressão usando a nova função auxiliar para alinhar
    imprimir_alinhado("Quantidade de Classes", 58);                              cout << " | " << quantidade_classes << endl;
    imprimir_alinhado("Quantidade de Relações e Atributos", 58);                 cout << " | " << quantidade_relacoes<< endl;
    imprimir_alinhado("Quantidade de Palavras-chave", 58);                       cout << " | " << quantidade_palavras_chave<< endl;
    imprimir_alinhado("Quantidade de Palavras Reservadas", 58);                  cout << " | " << quantidade_palavras_reservada<< endl;
    imprimir_alinhado("Quantidade de Indivíduos/Instâncias", 58);                cout << " | " << quantidade_individuos << endl;
    imprimir_alinhado("Quantidade de Meta-atributos", 58);                       cout << " | " << quantidade_meta_atributos << endl;
    imprimir_alinhado("Quantidade de Novos Tipos", 58);                          cout << " | " << quantidade_novos_tipos << endl;
    imprimir_alinhado("Quantidade de Símbolos Especiais", 58);                   cout << " | " << quantidade_simbolos_especiais<< endl;
    imprimir_alinhado("Quantidade de Tipos Nativos", 58);                        cout << " | " << quantidade_tipos_nativos << endl;
    imprimir_alinhado("Quantidade de Estereótipos de Classe", 58);               cout << " | " << quantidade_estereotipos_classe << endl;
    imprimir_alinhado("Quantidade de Estereótipos de Relação", 58);              cout << " | " << quantidade_estereotipos_relacao << endl;
    imprimir_alinhado("Quantidade de Números (provável cardinalidade)", 58);     cout << " | " << quantidade_numeros<< endl;
    cout << string(80, '=') << endl;

    return 0;
}