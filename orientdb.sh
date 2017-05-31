#!/bin/bash
#
# Script para execução de benchmark do OrientDB 2.2.10 utilizando o YCSB
#
# O script deve ser executado no mesmo diretório onde está localizado o YCSB, o Tarball descompactado do OrientDB
# e a definição do workload.
# No arquivo server.sh do OrientDB as variáveis ORIENTDB_OPTS_MEMORY e ORIENTDB_SETTINGS devem ser alteradas para a
# configuração de memória disponível. Ex.:
# -> ORIENTDB_OPTS_MEMORY="-Xms512m -Xmx2560M"
# -> ORIENTDB_SETTINGS="Dstorage.diskCache.bufferSize=8192"
# Nesse exemplo foram disponibilizados 2,5GB para a JVM, que já sera iniciada com 512MB alocados, e para cache em disco
# foram disponibilizados 8GB
#
# $1 : Nome do arquivo do workload
# $2 : Sufixo para os arquivos de saída (Ex.: números em sequência para realizar o mesmo teste diversas vezes)
# $3 : Diretório do YCSB (Default: ycsb-0.11.0)
#
# Baixar o Tarball do OrientDB: http://orientdb.com/orientdb/
# Ver também: http://orientdb.com/docs/last/Tutorial-Installation.html
#
# Para que o script seja executado corretamente o OrientDB deve estar configurado como um serviço.
# Ver: http://orientdb.com/docs/2.2.x/Unix-Service.html
#
# Obs.: em caso de erro durante a execução tentar forçar um local diferente para salvar o BD

orientdb_folder="orientdb-community-2.2.10"
workload_file=${1:-workloada}
ycsb_dir=${3:-"ycsb-0.11.0"}
# Caminho completo até o diretório em que o script foi executado
parent_path=${0%/*}
db_path="$parent_path/orientdb-database"

mkdir -p -m 777 results
mkdir -p -m 777 results/load
mkdir -p -m 777 results/run

sudo service orientdb start
sleep 10
# Carrega a base 'ycsb'
./$ycsb_dir/bin/ycsb load orientdb -P $workload_file -p orientdb.url=plocal:$db_path -p orientdb.newdb=true -p orientdb=massiveinsert > results/load/orientdb_${workload_file}_${2:-0}.dat
# Faz o benchmark das inserções/atualizações
./$ycsb_dir/bin/ycsb run orientdb -P $workload_file -p orientdb.url=plocal:$db_path > results/run/orientdb_${workload_file}_${2:-0}.dat
# Para o service do MongoDB
sudo service orientdb stop
