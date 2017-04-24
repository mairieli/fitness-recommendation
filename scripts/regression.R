#$ RScript regression.R PROJECT SUP CONF TEST TRAIN_REG

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
  stop("Informe os parametros!", call.=FALSE)
}

library("GA")
library("scatterplot3d")
library("arules")
source("query.R")

project_name <- args[1] 
train_reg <- as.integer(args[2])
int_support <- c(2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20)
confidence <- c(.1, .5, .9)
test <- c(5, 10, 20, 30)

for(t in test){
  dirTran <- paste0("../projects_transactions/", t, "%/", project_name, "/")
  transactions_train <- read.csv(paste0(dirTran,"transactions"), header=FALSE, sep=";", stringsAsFactors=FALSE)
  transactions_test <- read.csv(paste0(dirTran,"random_transactions"), header=FALSE, sep=";", stringsAsFactors=FALSE)
  
  num_commits <- nrow(transactions_train)
  pos_train_start <- (num_commits - train_reg) + 1
  commits <- transactions_train[1:num_commits,]
  if(pos_train_start >= 0){
    commits <- transactions_train[pos_train_start:num_commits,]
  }
  
  splitTransactions <- strsplit(commits,",")
  transactions <- as(object = splitTransactions, Class = "transactions")

  for(s in int_support){
    support <- s / length(commits)
    
    for(c in confidence){
      rules <- apriori(transactions, parameter = list(supp = support, conf = c, minlen = 2, maxlen = 2)) 
      
      map <- query(rules, transactions_test, 10)
      
      resultsTest<-c(project_name, t, train_reg, s, support, c, length(commits), nrow(transactions_test), map)
      finalResults <- data.frame(t(resultsTest))
      #colnames(finalResults)[1] <- "Project"
      write.table(finalResults, "teste.csv", append=TRUE, eol = "\n", sep=";", col.names = F, row.names = F)
    }
  }
}
