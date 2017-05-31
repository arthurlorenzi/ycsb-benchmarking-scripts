#!/bin/bash
#
# Script para execução de benchmark do MongoDB 3.2 utilizando o YCSB
#
# O script deve ser executado no mesmo diretório onde está localizado o YCSB e a definição do workload.
# Para criação de scripts JavaScript para o MongoDB ver:
# https://docs.mongodb.com/manual/tutorial/write-scripts-for-the-mongo-shell/
#
# $1 : Nome do arquivo do workload
# $2 : Sufixo para os arquivos de saída (Ex.: números em sequência para realizar o mesmo teste diversas vezes)
# $3 : Diretório do YCSB (Default: ycsb-0.11.0)
#
# Para instalação do MongoDB ver: https://docs.mongodb.com/manual/administration/install-community/

workload_file=${1:-workloada}
ycsb_dir=${3:-"ycsb-0.11.0"}

mkdir -p -m 777 results
mkdir -p -m 777 results/load
mkdir -p -m 777 results/run

sudo service mongod start
sleep 10
mongo ycsb mongodb.js
echo $?s
# Carrega a base 'ycsb'
./$ycsb_dir/bin/ycsb load mongodb -P $workload_file > results/load/mongodb_${workload_file}_${2:-0}.dat
# Faz o benchmark das outras operações do workload
./$ycsb_dir/bin/ycsb run mongodb -P $workload_file > results/run/mongodb_${workload_file}_${2:-0}.dat
# Para o service do MongoDB
sudo service mongod stop
