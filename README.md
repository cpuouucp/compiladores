# Analisador Léxico para a Linguagem TONTO (Textual Ontology Language)

Este projeto consiste no desenvolvimento de um **Analisador Léxico**  para a linguagem **TONTO**, como requisito avaliativo para a disciplina de **Compiladores** da **Universidade Federal Rural do Semi-Árido (UFERSA)**, sob a orientação do **Professor Patrício de Alencar Silva**.

O analisador foi desenvolvido utilizando a ferramenta **Flex** integrada com **C++**, fazendo o uso de tabelas de dispersão (`std::unordered_map`) para o gerenciamento padronizado de tokens.

---

## 🛠️ Decisões de Projeto e Alinhamento com a Literatura

Durante a análise do artigo científico da linguagem (*Coutinho et al., 2024*) e dos requisitos do projeto, as seguintes decisões arquiteturais foram tomadas para garantir a robustez do compilador:

1. **Padronização Estrita de Tokens:** Todos os IDs de tokens personalizados foram configurados no `enum` iniciando a partir de **256** para evitar qualquer colisão com a tabela ASCII padrão. Suas nomenclaturas de exibição foram completamente padronizadas com o prefixo `TOKEN_`.
2. **Tratamento de Atributos e Relações:** Na semântica da linguagem TONTO e do OntoUML, os atributos das classes (ex: `crm`, `cep`) são conceitualmente tratados de forma idêntica a relações de dependência. Como o analisador é estritamente léxico, ambos compartilham a mesma expressão regular baseada na convenção de letras minúsculas (`[a-z][a-zA-Z_]*`) e são agrupados de forma correta.
3. **Validação da Vírgula (`,`):** Diferente de outras estruturas da linguagem, a documentação formal da TONTO prevê o uso obrigatório de vírgulas como delimitadores exclusivos dentro de blocos de `enum`. Portanto, a vírgula foi integrada com sucesso ao token genérico de símbolos especiais.
4. **Resolução de Ambiguidade (*Longest Match*):** Foi inserida uma regra *catch-all* de varredura no Flex para capturar identificadores malformados inteiros (ex: `C4sa`) de forma unificada, impedindo que o Flex fatiasse o erro em dois tokens válidos.
5. **Compensação Dinâmica de Acentos:** Criou-se uma função auxiliar para calcular o tamanho real de strings UTF-8 no Linux Mint. Isso garante que as tabelas do terminal mantenham um alinhamento das barras verticais (`|`), mesmo exibindo acentuações na tabela de síntese.

---

## 📊 Estrutura de Saída do Terminal

O programa gera duas visualizações obrigatórias diretamente no console:
* **Visão Analítica:** Uma tabela indexada exibindo a Linha, Coluna, Nome Padronizado do Token e o seu respectivo Lexema.
* **Tabela de Síntese Acumulada:** Uma contagem totalizada de todos os conceitos estruturais identificados no arquivo fonte.

---

## 🚀 Como Compilar e Executar no Linux Mint

### Pré-requisitos
Certifique-se de ter as ferramentas de compilação essenciais e o Flex instalados no seu sistema. Caso não tenha, instale abrindo o terminal (`Ctrl + Alt + T`) e digitando:

```bash
sudo apt update && sudo apt install build-essential flex -y
```

### Compilação Manual
Gere o código intermediário do Flex e compile-o com o `g++`:

```bash
flex lexer.l
g++ lex.yy.c -o analisador_tonto
```

### Executando com os Arquivos de Teste
O repositório acompanha arquivos de teste estruturados para validar o comportamento do analisador (contendo cenários de sucesso e erros intencionais). Execute passando o arquivo desejado por parâmetro:

```bash
# Para rodar o primeiro cenário de testes
./analisador_tonto exemplo.tonto

# Para rodar o cenário com enums, datatypes e heranças estruturais
./analisador_tonto teste.tonto
```

### Automação com Makefile
Se preferir, utilize o arquivo de automação do Linux para compilar e rodar tudo com um único comando:

```bash
make run
```

---

## 📁 Organização dos Arquivos
* `lexer.l`: Código-fonte principal com as regras do Flex e rotinas de impressão em C++.
* `tokens.h`: Arquivo de cabeçalho que contém `#include` e um `enum`com os tokens a serem utilizados para a construção da tabela.
* `exemplo.tonto`: Primeiro cenário de testes fornecido para validação léxica inicial.
* `teste.tonto`: Cenário de testes complexo englobando heranças (`specializes`), `enum` e estruturas avançadas.
* `Makefile`: Script de automação nativa para o terminal do Linux Mint.
* `.vscode/tasks.json`: Configuração de tarefas para compilar o projeto direto pelas teclas de atalho do VS Code (`Ctrl + Shift + B`).


### observação: o programa não trata erros sintáticos nem semânticos.

- Palavras reservadas que não foram previamente registradas na tabela se "casar" com um lexema válido na construção de nome de Classes, nome de Relações, ou nome de Instâncias, assim será ele classificado como tal, na regra em que o lexema "acertou".

## 🎥 Vídeo de Apresentação do Projeto

O vídeo explicativo com a demonstração prática do analisador léxico pode ser assistido através do link abaixo:

👉 **[Clique aqui para assistir ao Vídeo do Projeto](INSIRA_O_LINK_DO_SEU_VIDEO_AQUI)**

---

