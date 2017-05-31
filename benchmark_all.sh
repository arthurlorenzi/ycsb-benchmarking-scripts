#!/bin/bash
#
# Script para execução de benchmark de todos bancos de dados NoSQL disponiveis no diretório utilizando o YCSB
#
# $1 : Nome do arquivo do workload
# $2 : Quantidade de testes a serem feitos em cada banco de dados
# $3 : Diretório do YCSB
#

if [ -z "$2" ]; then
    echo "Erro: os argumentos [workload] e [quantidade de testes] devem ser informados."
    exit;
fi

current_script=${0##*/}

for i in *.sh; do
    if [ $i != $current_script ]; then
        sudo chmod +x $1
        j=0
        while [ $j -lt $2 ]; do
            errors=0
            ./$i $1 $j $3
            if [ $? -eq 0 ] || [errors -eq 3]; then
                let j=j+1
            else
                let errors=errors+1
            fi
        done
    fi
done
