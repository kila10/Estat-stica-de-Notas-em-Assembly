#=====================================================================
# PROJETO FINAL - Curso Introdutorio de Programacao de Baixo Nivel
# Liga ProtoFPGA - UFSC Ararangua
#
# Dupla: <nome 1> e <nome 2>
# Tema : 9 - Estatisticas de notas
#
# O que o programa faz:
#   Le dez notas inteiras (0 a 10) e as guarda em um vetor.
#   Depois imprime a soma, a media inteira, a maior nota, a menor
#   nota e quantos alunos foram aprovados (nota >= 6).
#   Extra: imprime tambem as notas acima da media.
#
# Teste obrigatorio:
#   7 4 9 6 3 10 5 8 6 2
#   -> Soma = 60, Media = 6, Maior = 10, Menor = 2, Aprovados = 6
#
# Funcoes (argumentos em $a0-$a3, resultado em $v0, volta com jr $ra):
#   le_notas(vetor, n)         le n notas validas para o vetor
#   le_nota_valida(numero)     le UMA nota e repete ate ficar entre 0 e 10
#   soma(vetor, n)             devolve a soma das notas
#   media(soma, n)             devolve soma / n (divisao inteira)
#   maior(vetor, n)            devolve a maior nota
#   menor(vetor, n)            devolve a menor nota
#   aprovados(vetor, n)        devolve quantas notas sao >= 6
#   acima_media(vetor, n, m)   imprime as notas maiores que a media m
#   imprime(texto, valor)      imprime "texto" + valor + quebra de linha
#=====================================================================

        .data
        .align 2
vetor:          .space 40                       # 10 notas x 4 bytes

msg_titulo:     .asciiz "Estatisticas de notas\n"
msg_pede:       .asciiz "Digite a nota "
msg_faixa:      .asciiz " (0 a 10): "
msg_invalida:   .asciiz "Nota invalida! Use um valor de 0 a 10.\n"
txt_soma:       .asciiz "Soma = "
txt_media:      .asciiz "Media = "
txt_maior:      .asciiz "Maior = "
txt_menor:      .asciiz "Menor = "
txt_aprov:      .asciiz "Aprovados = "
txt_acima:      .asciiz "Notas acima da media:"
txt_nenhuma:    .asciiz " nenhuma"

        .text
        .globl main

#---------------------------------------------------------------------
# main
# Registradores $s (sobrevivem as chamadas com jal):
#   $s0 = endereco do vetor     $s1 = quantidade de notas (n)
#   $s2 = soma                  $s3 = media
#   $s4 = maior                 $s5 = menor
#   $s6 = aprovados
#---------------------------------------------------------------------
main:
        la   $a0, msg_titulo            # titulo do programa
        li   $v0, 4
        syscall

        la   $s0, vetor
        li   $s1, 10                    # n = 10 notas

        # --- leitura das notas ---
        move $a0, $s0
        move $a1, $s1
        jal  le_notas

        # --- calculo das estatisticas ---
        move $a0, $s0
        move $a1, $s1
        jal  soma
        move $s2, $v0                   # $s2 = soma

        move $a0, $s2
        move $a1, $s1
        jal  media
        move $s3, $v0                   # $s3 = media

        move $a0, $s0
        move $a1, $s1
        jal  maior
        move $s4, $v0                   # $s4 = maior

        move $a0, $s0
        move $a1, $s1
        jal  menor
        move $s5, $v0                   # $s5 = menor

        move $a0, $s0
        move $a1, $s1
        jal  aprovados
        move $s6, $v0                   # $s6 = aprovados

        # --- impressao dos resultados ---
        la   $a0, txt_soma
        move $a1, $s2
        jal  imprime

        la   $a0, txt_media
        move $a1, $s3
        jal  imprime

        la   $a0, txt_maior
        move $a1, $s4
        jal  imprime

        la   $a0, txt_menor
        move $a1, $s5
        jal  imprime

        la   $a0, txt_aprov
        move $a1, $s6
        jal  imprime

        # --- extra: notas acima da media ---
        move $a0, $s0
        move $a1, $s1
        move $a2, $s3
        jal  acima_media

        li   $v0, 10                    # encerra o programa
        syscall

#---------------------------------------------------------------------
# imprime(texto, valor)
#   $a0 = endereco do texto, $a1 = valor inteiro
#   Imprime o texto, o valor e uma quebra de linha.
#---------------------------------------------------------------------
imprime:
        move $t0, $a1                   # guarda o valor (syscall usa $a0)
        li   $v0, 4                     # imprime o texto (ja esta em $a0)
        syscall
        move $a0, $t0
        li   $v0, 1                     # imprime o inteiro
        syscall
        li   $a0, 10                    # '\n'
        li   $v0, 11
        syscall
        jr   $ra

#---------------------------------------------------------------------
# le_nota_valida(numero)
#   $a0 = numero da nota (so para mostrar na tela)
#   Devolve em $v0 uma nota entre 0 e 10; repete a leitura se invalida.
#---------------------------------------------------------------------
le_nota_valida:
        move $t0, $a0                   # guarda o numero da nota
lnv_pede:
        la   $a0, msg_pede
        li   $v0, 4
        syscall
        move $a0, $t0
        li   $v0, 1
        syscall
        la   $a0, msg_faixa
        li   $v0, 4
        syscall

        li   $v0, 5                     # le inteiro -> $v0
        syscall
        bltz $v0, lnv_erro              # nota < 0
        bgt  $v0, 10, lnv_erro          # nota > 10
        jr   $ra                        # nota valida em $v0

lnv_erro:
        la   $a0, msg_invalida
        li   $v0, 4
        syscall
        j    lnv_pede

#---------------------------------------------------------------------
# le_notas(vetor, n)
#   $a0 = endereco do vetor, $a1 = quantidade
#   Chama le_nota_valida, por isso guarda $ra na pilha. Tambem usa
#   $s0-$s2, entao salva os valores antigos e restaura no final.
#---------------------------------------------------------------------
le_notas:
        addi $sp, $sp, -16
        sw   $ra, 12($sp)
        sw   $s0, 8($sp)
        sw   $s1, 4($sp)
        sw   $s2, 0($sp)

        move $s0, $a0                   # $s0 = vetor
        move $s1, $a1                   # $s1 = n
        li   $s2, 0                     # $s2 = i = 0

ln_laco:
        beq  $s2, $s1, ln_fim           # i == n ? termina
        addi $a0, $s2, 1                # numero da nota (i + 1)
        jal  le_nota_valida
        sll  $t0, $s2, 2                # i * 4
        add  $t0, $s0, $t0              # &vetor[i]
        sw   $v0, 0($t0)                # vetor[i] = nota lida
        addi $s2, $s2, 1                # i++
        j    ln_laco

ln_fim:
        lw   $s2, 0($sp)
        lw   $s1, 4($sp)
        lw   $s0, 8($sp)
        lw   $ra, 12($sp)
        addi $sp, $sp, 16
        jr   $ra

#---------------------------------------------------------------------
# soma(vetor, n)  -> $v0 = soma das notas
#---------------------------------------------------------------------
soma:
        li   $v0, 0                     # acumulador
        li   $t0, 0                     # i = 0
so_laco:
        beq  $t0, $a1, so_fim
        sll  $t1, $t0, 2
        add  $t1, $a0, $t1
        lw   $t2, 0($t1)                # vetor[i]
        add  $v0, $v0, $t2
        addi $t0, $t0, 1
        j    so_laco
so_fim:
        jr   $ra

#---------------------------------------------------------------------
# media(soma, n)  -> $v0 = soma / n (divisao inteira)
#---------------------------------------------------------------------
media:
        div  $a0, $a1
        mflo $v0                        # quociente
        jr   $ra

#---------------------------------------------------------------------
# maior(vetor, n)  -> $v0 = maior nota
#---------------------------------------------------------------------
maior:
        lw   $v0, 0($a0)                # comeca com vetor[0]
        li   $t0, 1                     # i = 1
ma_laco:
        beq  $t0, $a1, ma_fim
        sll  $t1, $t0, 2
        add  $t1, $a0, $t1
        lw   $t2, 0($t1)
        ble  $t2, $v0, ma_prox          # nao e maior: pula
        move $v0, $t2
ma_prox:
        addi $t0, $t0, 1
        j    ma_laco
ma_fim:
        jr   $ra

#---------------------------------------------------------------------
# menor(vetor, n)  -> $v0 = menor nota
#---------------------------------------------------------------------
menor:
        lw   $v0, 0($a0)                # comeca com vetor[0]
        li   $t0, 1
me_laco:
        beq  $t0, $a1, me_fim
        sll  $t1, $t0, 2
        add  $t1, $a0, $t1
        lw   $t2, 0($t1)
        bge  $t2, $v0, me_prox          # nao e menor: pula
        move $v0, $t2
me_prox:
        addi $t0, $t0, 1
        j    me_laco
me_fim:
        jr   $ra

#---------------------------------------------------------------------
# aprovados(vetor, n)  -> $v0 = quantidade de notas >= 6
#---------------------------------------------------------------------
aprovados:
        li   $v0, 0                     # contador
        li   $t0, 0
ap_laco:
        beq  $t0, $a1, ap_fim
        sll  $t1, $t0, 2
        add  $t1, $a0, $t1
        lw   $t2, 0($t1)
        blt  $t2, 6, ap_prox            # nota < 6: reprovado
        addi $v0, $v0, 1
ap_prox:
        addi $t0, $t0, 1
        j    ap_laco
ap_fim:
        jr   $ra

#---------------------------------------------------------------------
# acima_media(vetor, n, media)
#   Imprime as notas estritamente maiores que a media.
#---------------------------------------------------------------------
acima_media:
        move $t3, $a0                   # $t3 = vetor
        move $t4, $a2                   # $t4 = media
        la   $a0, txt_acima
        li   $v0, 4
        syscall

        li   $t0, 0                     # i = 0
        li   $t5, 0                     # quantas foram impressas
ac_laco:
        beq  $t0, $a1, ac_fim
        sll  $t1, $t0, 2
        add  $t1, $t3, $t1
        lw   $t2, 0($t1)
        ble  $t2, $t4, ac_prox          # nota <= media: pula
        li   $a0, 32                    # espaco
        li   $v0, 11
        syscall
        move $a0, $t2
        li   $v0, 1
        syscall
        addi $t5, $t5, 1
ac_prox:
        addi $t0, $t0, 1
        j    ac_laco
ac_fim:
        bnez $t5, ac_nl                 # imprimiu alguma? vai pro \n
        la   $a0, txt_nenhuma
        li   $v0, 4
        syscall
ac_nl:
        li   $a0, 10
        li   $v0, 11
        syscall
        jr   $ra
        