# $ Rscript transactions.R cpython .10

library("arules")

randomTransactions <- function(transactions){
  splitTransactions <- strsplit(transactions$V5,",")
  (cond <- lapply(splitTransactions, function(x) length(x) > 1))
  twoMoreTrans <- splitTransactions[unlist(cond)]
  i <- 1
  while(i <= length(twoMoreTrans)){
    rdm <- sample(twoMoreTrans[[i]])
    transaction <- paste(rdm, collapse = ',')
    write.table(transaction, file = paste0("random_transactions"), sep="\n", append = TRUE, quote=FALSE, row.names=FALSE, col.names=FALSE);
    i <- i + 1
  }
}

splitProject <- function(project, p_test){
  num_commits <- nrow(project)
  num_commits_test <- trunc(num_commits * p_test)
  num_commits_train <- num_commits - num_commits_test
  pos_test_start <- num_commits_train + 1
  
  test <- project[pos_test_start:num_commits,]
  train <- project[1:num_commits_train,]
  
  write.table(train$V5, file = "transactions", sep="\n", append = FALSE, quote=FALSE, row.names=FALSE, col.names=FALSE);
  transactions <- read.transactions("transactions", format = "basket", sep=",", rm.duplicates=TRUE);
  randomTransactions(test)
}

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
  stop("Informe os parametros!", call.=FALSE)
}

project_name <- args[1]
percent_test <- as.numeric(args[2]) 
dirResults <- "../projects_transactions"
if(!dir.exists(dirResults)){
  dir.create(dirResults)
}
setwd(dirResults)
project<-read.csv(paste0(project_name, ".csv"), header=FALSE, sep=";", stringsAsFactors=FALSE)
if(!dir.exists(project_name)){
  dir.create(project_name)
}
setwd(project_name)
splitProject(project, percent_test)
