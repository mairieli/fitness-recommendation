#$ RScript regression.R PROJECT

getNumFiles <- function(history){
  commits <- history$V5
  transaction_files <- strsplit(commits, ",")
  files <- unlist(transaction_files)
  unique_files <- unique(files)
  return(length(unique_files))
}

getAVGCommitSize <- function(history){
  commits <- history$V5
  transaction_files <- strsplit(commits, ",")
  transaction_length <- sapply(transaction_files, length)
  return(mean(transaction_length))
}

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 1) {
  stop("Informe os parametros!", call.=FALSE)
}
project_name <- args[1]
project <- read.csv(paste0(project_name, ".csv"), sep = ";", header = FALSE, stringsAsFactors = FALSE)
num_files <- getNumFiles(project)
avg_transactions <- getAVGCommitSize(project)
print(num_files)
print(avg_transactions)
