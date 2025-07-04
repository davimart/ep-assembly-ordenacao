
#include <stdio.h>
#include <stdlib.h>

#define MAX 100

float vetor_entrada[MAX];
float vetor_saida[MAX];
int n = 0;
const char* arquivo = "entrada.txt";

void preparar_entrada();
void escrever();
void imprimir();
float* ordena(int tam, int tipo, float* vetor);

void preparar_entrada() {
    FILE *fp = fopen(arquivo, "r");
    if (!fp) exit(1);

    while (fscanf(fp, "%f", &vetor_entrada[n]) == 1 && n < MAX) {
        n++;
    }

    fclose(fp);
}

void escrever() {
    FILE *fp = fopen(arquivo, "a");
    if (!fp) exit(1);

    fputs("\n\n", fp);
    for (int i = 0; i < n; i++) {
        fprintf(fp, "%.4f\n", vetor_saida[i]);
    }

    fclose(fp);
}

void imprimir() {
    for (int i = 0; i < n; i++) {
        printf("%.4f ", vetor_entrada[i]);
    }
    printf("\n");
}

int main() {
    preparar_entrada();
    imprimir();
    // chamada da funcao de ordenacao (ainda nao implementada)
    ordena(n, 0, vetor_saida);

    escrever();
    return 0;
}
