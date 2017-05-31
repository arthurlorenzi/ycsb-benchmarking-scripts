#!/bin/bash
#
# Script para execução de benchmark do Tarantool 1.7.1 utilizando o YCSB
#
# O script deve ser executado no mesmo diretório onde está localizado o YCSB, o arquivo tarantool.lua e
# a definição do workload. Durante a execução uma nova janela do terminal será aberta para que o servidor
# do Tarantool seja inicializado.
#
# $1 : Nome do arquivo do workload
# $2 : Sufixo para os arquivos de saída (Ex.: números em sequência para realizar o mesmo teste diversas vezes)
# $3 : Diretório do YCSB (Default: ycsb-0.11.0)
#
# Para instalação do Tarantool ver: https://tarantool.org/download.html

tar_space_id="512"
workload_file=${1:-workloada}
ycsb_dir=${3:-"ycsb-0.11.0"}

# Mata os processos de benchmark anteriores
pkill -f tarantool.lua

mkdir -p -m 777 results
mkdir -p -m 777 results/load
mkdir -p -m 777 results/run

# Inicializa o Tarantool com script em outro terminal
# x-terminal-emulator -e "tarantool tarantool.lua $tar_space_id"
xterm -e "tarantool tarantool.lua $tar_space_id" &
# Espera até que o processo tarantol comece a servir na porta
sleep 10
# Carrega a base 'ycsb'
./$ycsb_dir/bin/ycsb load tarantool -P $workload_file -p tarantool.space=$tar_space_id > results/load/tarantool_${workload_file}_${2:-0}.dat
# Faz o benchmark das outras operações do workload
./$ycsb_dir/bin/ycsb run tarantool -P $workload_file -p tarantool.space=$tar_space_id > results/run/tarantool_${workload_file}_${2:-0}.dat

# Remove os (muitos) arquivos de WAL do Tarantool. Em caso de erro, comentar essa linha
rm *.xlog
