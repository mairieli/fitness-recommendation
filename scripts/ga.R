#$ nohup Rscript ga.R hadoop .00003 .0005 5 > ../logs/saida.out &

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 4) {
  stop("Informe os parametros!", call.=FALSE)
}

library("futile.logger")
flog.info("Started!")
library("GA")
library("scatterplot3d")
library("arules")
source("query.R")

project_name <- args[1] 
percent_test <- args[4]
dirTran <- paste0("../projects_transactions/", percent_test , "%/", project_name, "/")
transactions_train <- read.csv(paste0(dirTran,"transactions"), header=FALSE, sep=";", stringsAsFactors=FALSE)
transactions_test <- read.csv(paste0(dirTran,"random_transactions"), header=FALSE, sep=";", stringsAsFactors=FALSE)

dirResults <- "../logs"
if(!dir.exists(dirResults)){
  dir.create(dirResults)
}
setwd(dirResults)

confidence_min <- .1
confidence_max <- 1
support_min <- as.numeric(args[2]) 
support_max <- as.numeric(args[3]) 
transaction_train_min <- .1
transaction_train_max <- 1 - (percent_test/100)

mins <- c(confidence_min,support_min, transaction_train_min)
maxs <- c(confidence_max,support_max, transaction_train_max)

fitnessFunc <- function(x, train, test) {
  confidence <- x[1]
  support <- x[2]
  transaction_train <- x[3]
  
  num_commits <- nrow(train)
  num_commits_train <- trunc(num_commits * transaction_train)
  pos_train_start <- (num_commits - num_commits_train) + 1
  
  commits <- train[pos_train_start:num_commits,]
  
  splitTransactions <- strsplit(commits,",")
  transactions <- as(splitTransactions, "transactions")
  
  rules <- apriori(transactions, parameter = list(supp = support, conf = confidence, minlen = 2, maxlen = 2));  
  
  map <- query(rules, test, 10);
  
  num_commits_test <- nrow(test)
  log <- c(support, confidence, transaction_train, num_commits_train, 
           num_commits_test, length(rules), map)
  finalResults <- data.frame(t(log))
  write.table(finalResults, paste0("log_map.csv"), append=TRUE, eol = "\n", sep=";", col.names = F, row.names = F)
  
  return (map)
}

monitor <- function(obj) {
  if(obj@iter == 1){
    jpeg(filename = "populacao_inicial.jpg")
    print(obj@population)
    x <- obj@population[,1]
    y <- obj@population[,2]
    z <- obj@population[,3]
    scatterplot3d(x, y, z, highlight.3d=TRUE, pch=19,
                  type="h",        
                  lty.hplot=2,
                  main="População Inicial",
                  xlab="Confiança",
                  ylab="Suporte",
                  zlab="Treino")
    dev.off()
  }
}

flog.info("Project: %s - Support min: %s Support max: %s", project_name, support_min, support_max)

model <- ga(type="real-valued", fitness = fitnessFunc, transactions_train, transactions_test, min = mins, max= maxs, popSize = 200, pcrossover = 0.8, pmutation = 0.1, parallel = 5, maxiter = 1000, monitor = monitor)

summary(model)
jpeg(filename = paste0(project_name, ".jpg"))
plot(model)
dev.off()
flog.info("Finished!")
