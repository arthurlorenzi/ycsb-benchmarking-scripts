#!/bin/bash
#
# Script para execução de benchmark do HBase 0.98.24 (Hadoop 2.5.2) utilizando o YCSB
#
# O script deve ser executado no mesmo diretório onde está localizado o YCSB, o Tarball descompactado do HBase
# e a definição do workload.
#
# Pré-requisitos do HBase: http://archive.cloudera.com/cdh5/cdh/5/hbase-0.98.6-cdh5.3.6/book/configuration.html#basic.prerequisites
# Para configurar o Hadoop: 
# * https://learninghadoopblog.wordpress.com/2013/08/03/hadoop-0-23-9-single-node-setup-on-ubuntu-13-04/
# * https://allthingshadoop.com/2010/04/20/hadoop-cluster-setup-ssh-key-authentication/
# (A propriedade "dfs.datanode.data.dir" não precisa ser configurada)
# Instruções para configuração do HBase: http://archive.cloudera.com/cdh5/cdh/5/hbase-0.98.6-cdh5.3.6/book/quickstart.html
#
# $1 : Nome do arquivo do workload
# $2 : Sufixo para os arquivos de saída (Ex.: números em sequência para realizar o mesmo teste diversas vezes)
# $3 : Diretório do YCSB (Default: ycsb-0.11.0)
#
# Editar conf/hbase-env.sh e alterar a linha do JAVA_HOME para local correto do Java:
# export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
#
# Baixar o Tarball do HBase: http://hbase.apache.org/
# Ver também: http://archive.cloudera.com/cdh5/cdh/5/hbase-0.98.6-cdh5.3.6/book/quickstart.html
#
# Problema que pode ocorrer: https://qnalist.com/questions/320533/stop-hbase-sh-takes-forever-never-stops
#

workload_file=${1:-workloada}
ycsb_dir=${3:-"ycsb-0.11.0"}

mkdir -p -m 777 results
mkdir -p -m 777 results/load
mkdir -p -m 777 results/run

# Inicia os daemons do Hadoop
./hadoop-2.5.2/sbin/start-dfs.sh
./hadoop-2.5.2/sbin/start-yarn.sh
# Tira o hadoop do safemode, caso ele fique preso nele
# ./hadoop-2.5.2/bin/hdfs dfsadmin -safemode leave
# Inicia o HBase
./hbase-0.98.24-hadoop2/bin/start-hbase.sh
# Chega o sistema de arquivos
# hbase hbck
# Corrige inconsistências
# ./hbase-0.98.24-hadoop2/bin/hbase hbck -fix
# Como a configuração hbase.master.wait.on.regionservers.mintostart é de 1 minuto, o script espera
sleep 61
# Configura a base
./hbase-0.98.24-hadoop2/bin/hbase shell ./hbase.rb
# Carrega a base
./$ycsb_dir/bin/ycsb load hbase098 -P $workload_file -cp hbase-0.98.24-hadoop2/conf -p table=usertable -p columnfamily=family  > results/load/hbase_${workload_file}_${2:-0}.dat
# Faz o benchmark das inserções/atualizações
./$ycsb_dir/bin/ycsb run hbase098 -P $workload_file -cp hbase-0.98.24-hadoop2/conf -p table=usertable -p columnfamily=family  > results/run/hbase_${workload_file}_${2:-0}.dat
# Para o HBase
./hbase-0.98.24-hadoop2/bin/stop-hbase.sh
# Para os daemons do Hadoop
./hadoop-2.5.2/sbin/stop-dfs.sh
./hadoop-2.5.2/sbin/stop-yarn.sh
