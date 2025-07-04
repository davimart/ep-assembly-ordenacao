# ============================================================
# EP1 - Leitura, contagem, armazenamento e escrita de floats
# ============================================================
# Funcoes (labels principais):
# - main:              Coordena a execucao
# - preparar_entrada:  Le o arquivo, extrai os floats, preenche vetor_entrada
# - imprimir:          Imprime todos os floats do vetor_entrada
# - escrever:          Escreve os floats do vetor_saida no final do arquivo
#
# Variaveis principais:
# - buffer:            Guarda conteudo lido do arquivo como string
# - vetor_entrada:     Vetor que armazena os floats lidos
# - vetor_saida:       Vetor de saida (por enquanto, ponteiro = vetor_entrada)
#
# Registradores:
# - $s0: descritor de arquivo
# - $s1: ponteiro para vetor_entrada
# - $s2: ponteiro para vetor_saida
# - $s3: numero de elementos lidos (n)
# ============================================================

.data
filename:        .asciiz "entrada.txt"
buffer:          .space 2048
newline:         .asciiz "\n"
float_sep:       .asciiz " "
buffer_saida:    .space 2048      # string final a ser escrita no arquivo
buffer_temp:     .space 64        # string temporaria para cada numero

vetor_entrada:   .space 400       # ate 100 floats
vetor_saida:     .space 400

.text
.globl main

# -------------------------------------------------------------
# main:
# Funcao principal: inicializa ponteiros, chama leitura, impressao e escrita
# -------------------------------------------------------------
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    la $s1, vetor_entrada
    la $s2, vetor_saida

    jal preparar_entrada     # leitura e parse
    jal imprimir             # imprime os valores lidos
    move $s2, $s1            # ALTERAR!!!!!!!!!!
    jal escrever             # escreve no final do arquivo

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 10
    syscall
# -------------------------------------------------------------
# preparar_entrada:
# Le o arquivo texto, converte floats com sinal e preenche vetor_entrada
# -------------------------------------------------------------
preparar_entrada:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # abre arquivo
    li $v0, 13
    la $a0, filename
    li $a1, 0       # leitura
    syscall
    move $s0, $v0

    # le conteudo para buffer
    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 2048
    syscall

    # fecha o arquivo
    li $v0, 16
    move $a0, $s0
    syscall

    # inicializa ponteiros e contador
    la $t0, buffer     # leitura
    move $t1, $s1      # escrita
    li $t2, 0          # contador de elementos

# Loop principal que percorre o buffer lido do arquivo
# Cada iteracao tenta encontrar e processar um novo numero
proximo_numero:
# Ignora caracteres nao numericos como espaco, tab, nova linha, etc.
# Avanca ate encontrar o inicio de um numero valido
ignorar:
    lb $t3, 0($t0)
    beqz $t3, fim_parse
    li $t4, ' '
    beq $t3, $t4, avancar
    li $t4, '\n'
    beq $t3, $t4, avancar
    li $t4, '\r'
    beq $t3, $t4, avancar
    li $t4, '\t'
    beq $t3, $t4, avancar
    j comeca_parse
# Avanca o ponteiro de leitura ($t0) em uma posicao
# Usado dentro do bloco de ignorar
avancar:
    addi $t0, $t0, 1
    j ignorar

# Inicia o parse do numero
# Verifica se ha um sinal negativo e ajusta a flag de sinal
comeca_parse:
    li $t9, 0
    lb $t3, 0($t0)
    li $t4, '-'
    bne $t3, $t4, parse_inteira
    li $t9, 1
    addi $t0, $t0, 1

# Inicializa o acumulador da parte inteira do numero
# Prepara para comecar a conversao dos digitos antes do ponto
parse_inteira:
    li $t5, 0

# Loop que percorre os caracteres numericos da parte inteira
# Converte cada digito de ASCII para valor decimal e acumula
loop_inteira:
    lb $t3, 0($t0)
    li $t4, '.'
    beq $t3, $t4, inicio_frac
    li $t4, ' '
    beq $t3, $t4, montar_float
    li $t4, '\n'
    beq $t3, $t4, montar_float
    li $t4, '\r'
    beq $t3, $t4, montar_float
    li $t4, 0
    beq $t3, $t4, montar_float

    li $t4, '0'
    sub $t6, $t3, $t4
    mul $t5, $t5, 10
    add $t5, $t5, $t6
    addi $t0, $t0, 1
    j loop_inteira

# Avanca apos o ponto decimal
# Inicializa acumuladores para parte fracionaria
inicio_frac:
    addi $t0, $t0, 1
    li $t7, 0
    li $t8, 0

# Loop que percorre os caracteres da parte fracionaria
# Converte cada digito decimal e conta o numero de casas decimais
loop_frac:
    lb $t3, 0($t0)
    li $t4, ' '
    beq $t3, $t4, montar_float
    li $t4, '\n'
    beq $t3, $t4, montar_float
    li $t4, '\r'
    beq $t3, $t4, montar_float
    li $t4, 0
    beq $t3, $t4, montar_float

    li $t4, '0'
    sub $t6, $t3, $t4
    mul $t7, $t7, 10
    add $t7, $t7, $t6
    addi $t8, $t8, 1
    addi $t0, $t0, 1
    j loop_frac
# Combina parte inteira e parte fracionaria para formar o float final
# Aplica divisao pela potencia de 10 correspondente ao numero de casas
montar_float:
    mtc1 $t5, $f4              # move parte inteira para $f4
    cvt.s.w $f4, $f4           # converte inteiro para float

    li $t6, 1
    li $t4, 0
# Calcula a potencia de 10 com base no numero de casas decimais encontradas
# Usado para converter parte fracionaria em float
# Exemplo: se houverem 3 digitos -> calcula 10^3 = 1000
pot10:
    beq $t4, $t8, pot10_done   # calcula 10^casas_decimais
    mul $t6, $t6, 10
    addi $t4, $t4, 1
    j pot10
# Fim do calculo da potencia de 10
# O valor resultante fica armazenado em $t6
pot10_done:
    mtc1 $t7, $f6              # parte fracionaria em $f6
    cvt.s.w $f6, $f6
    mtc1 $t6, $f8              # divisor (potencia de 10)
    cvt.s.w $f8, $f8
    div.s $f6, $f6, $f8        # f6 = parte_fracionaria / 10^casas

    add.s $f2, $f4, $f6        # f2 = parte_inteira + parte_fracionaria

    # aplica sinal, se necessario
    beqz $t9, salvar_float
    neg.s $f2, $f2

# Aplica o sinal (se for negativo) e salva o float no vetor de entrada
# Atualiza ponteiros e contador de elementos lidos
salvar_float:
    swc1 $f2, 0($t1)
    addi $t1, $t1, 4           # avanca para proxima posicao
    addi $t2, $t2, 1           # incrementa contador
    addi $t0, $t0, 1           # avanca no buffer
    j proximo_numero

# Fim do processamento do buffer
# Salva o total de elementos lidos em $s3
fim_parse:
    move $s3, $t2              # $s3 = numero de elementos lidos
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# -------------------------------------------------------------
# imprimir:
# Percorre o vetor_entrada e imprime os floats um por um.
# Cada numero e seguido por um espaco.
# -------------------------------------------------------------
imprimir:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0                # indice de iteracao
    move $t1, $s1            # ponteiro para vetor_entrada

print_loop:
    beq $t0, $s3, print_end  # se todos os elementos foram impressos, sai

    lwc1 $f12, 0($t1)        # carrega float atual
    li $v0, 2
    syscall                  # imprime o float

    li $v0, 4
    la $a0, float_sep
    syscall                  # imprime separador (espaco)

    addi $t1, $t1, 4         # avanca para proximo float
    addi $t0, $t0, 1
    j print_loop

print_end:
    li $v0, 4
    la $a0, newline
    syscall                  # imprime nova linha

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# -------------------------------------------------------------
# escrever:
# Converte cada float do vetor_saida para string com 4 casas decimais.
# Salva os resultados em buffer_saida e escreve tudo no final do arquivo.
# -------------------------------------------------------------
escrever:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0                  # indice
    move $t1, $s2              # ponteiro para vetor_saida
    la $t2, buffer_saida       # ponteiro para escrita do texto final

    # adiciona quebra dupla de linha no inicio do buffer_saida
    li $t6, '\n'
    sb $t6, 0($t2)
    sb $t6, 1($t2)
    addi $t2, $t2, 2

escrever_loop:
    slt $t8, $t0, $s3          # se t0 < n
    beqz $t8, escrever_final   # sai do loop se t0 >= s3

    lwc1 $f12, 0($t1)          # carrega float atual do vetor_saida

    # verifica se e negativo
    li $t7, 0
    mtc1 $t7, $f0
    li $t9, 0
    c.lt.s $f12, $f0
    bc1t numero_negativo
    j continua_positivo

numero_negativo:
    li $t9, 1                  # marca como negativo
    neg.s $f12, $f12           # usa valor absoluto

continua_positivo:
    # separa parte inteira
    cvt.w.s $f4, $f12
    mfc1 $t3, $f4
    cvt.s.w $f6, $f4
    sub.s $f8, $f12, $f6       # decimal = float - parte inteira

    # multiplica parte decimal por 10000
    li $t4, 10000
    mtc1 $t4, $f10
    cvt.s.w $f10, $f10
    mul.s $f8, $f8, $f10
    cvt.w.s $f8, $f8
    mfc1 $t4, $f8              # parte decimal como inteiro

    # escreve string formatada em buffer_temp
    la $a1, buffer_temp
    beqz $t9, skip_sinal
    li $t7, '-'
    sb $t7, 0($a1)
    addi $a1, $a1, 1

skip_sinal:
    move $a0, $t3
    jal int_to_str             # escreve parte inteira
    move $t5, $v0              # ponteiro apos a parte inteira

    li $t6, '.'
    sb $t6, 0($t5)
    addi $t5, $t5, 1

    move $a0, $t4              # parte decimal
    move $a1, $t5
    li   $a2, 4
    jal int_to_str_pad         # escreve parte decimal com 4 digitos
    move $t5, $v0              # ponteiro apos decimal

    li $t6, '\n'
    sb $t6, 0($t5)
    addi $t5, $t5, 1

    li $t6, 0                  # terminador nulo
    sb $t6, 0($t5)
    # copia buffer_temp para buffer_saida
    la $t7, buffer_temp
copy_temp:
    lb $t6, 0($t7)
    beqz $t6, next_numero      # termina quando encontrar '\0'
    sb $t6, 0($t2)
    addi $t7, $t7, 1
    addi $t2, $t2, 1
    j copy_temp

# passa para o proximo float
next_numero:
    addi $t1, $t1, 4           # proximo float no vetor
    addi $t0, $t0, 1           # incrementa indice
    j escrever_loop

# -------------------------------------------------------------
# escrever_final:
# Abre o arquivo em modo append e escreve o buffer_saida completo
# -------------------------------------------------------------
escrever_final:
    la $t6, buffer_saida
    subu $a2, $t2, $t6         # calcula o tamanho da string a ser escrita

    li $v0, 13
    la $a0, filename
    li $a1, 9                  # modo: escrita + append
    syscall
    move $s0, $v0              # salva descritor

    li $v0, 15
    move $a0, $s0
    la $a1, buffer_saida
    syscall                    # escreve buffer_saida

    li $v0, 16
    move $a0, $s0
    syscall                    # fecha arquivo

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# -------------------------------------------------------------
# int_to_str:
# Converte um inteiro positivo em $a0 para string decimal ASCII.
# Escreve a partir de $a1. Retorna em $v0 o ponteiro final.
# Exemplo: $a0 = 123 -> escreve "123" em $a1
# -------------------------------------------------------------
int_to_str:
    li $t8, 0
    move $t9, $a0
    la $t7, buffer_temp+30     # comeca do final (vai preencher ao contrario)

itoa_loop:
    li $t6, 10
    divu $t9, $t6
    mfhi $t5                   # resto = digito atual
    mflo $t9                   # quociente
    addi $t5, $t5, 48          # converte digito para ASCII
    subi $t7, $t7, 1
    sb $t5, 0($t7)
    addi $t8, $t8, 1
    bnez $t9, itoa_loop

# copia os digitos para $a1
copy_itoa:
    lb $t5, 0($t7)
    sb $t5, 0($a1)
    addi $a1, $a1, 1
    addi $t7, $t7, 1
    subi $t8, $t8, 1
    bgtz $t8, copy_itoa

    move $v0, $a1
    jr $ra

# -------------------------------------------------------------
# int_to_str_pad:
# Converte um inteiro em $a0 para string com padding de zeros a esquerda.
# Escreve em $a1, garantindo pelo menos $a2 digitos.
# Exemplo: $a0 = 5, $a2 = 4 -> escreve "0005"
# -------------------------------------------------------------
int_to_str_pad:
    li $t8, 0
    move $t9, $a0
    la $t7, buffer_temp+30

itoa_pad_loop:
    li $t6, 10
    divu $t9, $t6
    mfhi $t5
    mflo $t9
    addi $t5, $t5, 48
    subi $t7, $t7, 1
    sb $t5, 0($t7)
    addi $t8, $t8, 1
    bgtz $t9, itoa_pad_loop

# adiciona zeros a esquerda se necessario
pad_zero:
    blt $t8, $a2, pad_more
    j pad_done
pad_more:
    subi $t7, $t7, 1
    li $t5, '0'
    sb $t5, 0($t7)
    addi $t8, $t8, 1
    j pad_zero

pad_done:
copy_pad:
    lb $t5, 0($t7)
    sb $t5, 0($a1)
    addi $a1, $a1, 1
    addi $t7, $t7, 1
    subi $t8, $t8, 1
    bgtz $t8, copy_pad

    move $v0, $a1
    jr $ra
