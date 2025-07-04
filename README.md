# EP1 - Organização e Arquitetura de Computadores

## Descrição do Projeto

Este projeto tem como objetivo principal a leitura, armazenamento, processamento e escrita de números reais (floats) a partir de um arquivo de entrada. A tarefa está baseada na manipulação de dados numéricos utilizando Assembly MIPS, como parte do EP1 da disciplina de Organização e Arquitetura de Computadores.

O programa em Assembly realiza as seguintes etapas:

1. **Leitura de um arquivo de texto (`entrada.txt`)** contendo números reais separados por espaço ou nova linha.
2. **Parsing manual** desses valores para armazená-los como floats em um vetor.
3. **Impressão** no terminal dos valores lidos.
4. **Escrita** desses valores formatados (com 4 casas decimais) no final do mesmo arquivo.

Também é disponibilizada uma **versão equivalente em C**, estruturada para facilitar a tradução para Assembly, com as mesmas funções e estrutura geral.

## Requisitos de Execução

- O simulador **[MARS](http://courses.missouristate.edu/kenvollmar/mars/)** (versão `.jar`) deve estar na **mesma pasta** dos arquivos `.asm` e `.txt`.
- O arquivo `entrada.txt` **deve ser reinicializado (limpo)** antes de cada nova execução. Isso evita que dados anteriores causem **comportamentos inesperados**, pois o programa escreve os resultados ao final do mesmo arquivo.

## Estrutura do Projeto

```
.
├── entrada.txt              # Arquivo de entrada e saída de dados numéricos (Teste)
├── dadosEP2_completo.txt    # Arquivo de entrada e saída de dados numéricos (Mais Completo)
├── Mars4_5.jar              # Simulador MARS (requer Java instalado)
├── ultimaversao.asm         # Código principal em Assembly MIPS
├── versao_equivalente.c     # Implementação equivalente em C
└── README.md                # Este arquivo
```

## Funções Implementadas

- `main`: Função principal que coordena o fluxo geral.
- `preparar_entrada`: Lê e interpreta os números reais do arquivo.
- `imprimir`: Exibe os valores no terminal.
- `escrever`: Escreve os resultados formatados no final do arquivo.
- *(em Assembly)* Funções auxiliares para conversão de inteiros em strings com padding.

## Observações

- O vetor de entrada suporta até 100 valores.
- O código está estruturado para facilitar a futura adição de métodos de ordenação conforme os critérios do exercício.
- A função `ordena(int tam, int tipo, float *vetor)` já está declarada tanto em Assembly quanto em C, conforme requerido, mas sua lógica ainda será implementada.
