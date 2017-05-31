#
# Script para criação de planilha xlsx com os resultados dos testes.
#
# O script deve ser executado do mesmo diretório onde está localizado diretório "results", criado pelo
# script de benchmark. O arquivo de saída terá diferentes sheets para cada workload encontrado. Para
# executar este script utilizar o comando:
# Rscript get_xlsx.r
#

req.packages <- c("gsubfn", "xlsx")
new.packages <- req.packages[!(req.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(gsubfn)
library(xlsx)

databases <- c("tarantool", "mongodb", "orientdb", "hbase")
workloads <- list.files(pattern = "wld")

# Habilitar essa linha para considerar arquivos de workload que não contenham
# a palavra "wld".
#
# workloads <- c(workloads, "[workload]")

throughput_data <- list()

for (wld in workloads)
  throughput_data[[wld]] <- list()

for(db in databases)
  for(wld in workloads)
  {
    pattern <- paste(db, "_", wld, ".*\\.dat", sep = "")
    
    for(dir in c("load", "run"))
    {
      test_data <- c()
      series_name = paste(db, "-", dir, sep = "")

      files <- list.files(path = paste(getwd(), "/results/", dir, sep = ""),
                          pattern = pattern,
                          full.names = T)
      
      for (filename in files)
      {
        file_string <- readChar(filename, file.info(filename)$size)
        # Pega o throughput geral do arquivo
        throughput <- strapply(file_string, "\\[OVERALL\\], Throughput\\(ops/sec\\), [[:digit:]]+\\.[[:digit:]]+");
        throughput <- strapply(throughput[[1]], "[[:digit:]]+\\.[[:digit:]]+")
        test_data <- append(test_data, as.numeric(throughput[[1]]))
      }
      
      if (length(file) > 0)
        throughput_data[[wld]][[series_name]] = test_data
    }
  }

if (file.exists("throughput_data.xlsx"))
  file.remove("throughput_data.xlsx")

order_throughput <- function(df)
{
  cols <- names(df)
  
  return(cols[order(!grepl("\\.load", cols))])
}

for (wld in workloads)
{
  df <- data.frame(throughput_data[[wld]])
  
  if (length(df) != 0)
    write.xlsx(df[, order_throughput(df)],
               "throughput_data.xlsx",
               sheetName = wld,
               append = T) 
}
