void quicksort(float *vetor, int inicio, int fim) {
    if (inicio < fim) {
        float pivo = vetor[fim];
        int i = inicio - 1;
        for (int j = inicio; j < fim; j++) {
            if (vetor[j] <= pivo) {
                i++;
                float temp = vetor[i];
                vetor[i] = vetor[j];
                vetor[j] = temp;
            }
        }
        float temp = vetor[i + 1];
        vetor[i + 1] = vetor[fim];
        vetor[fim] = temp;

        quicksort(vetor, inicio, i);
        quicksort(vetor, i + 2, fim);
    }
}

float* ordena(int tam, int tipo, float *vetor) {
    if (tipo == 1) { // tipo 1: quicksort
        quicksort(vetor, 0, tam - 1);
    }
    return vetor;
}
