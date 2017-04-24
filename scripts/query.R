library("arules")

query <- function(rules, commits, k){
  if(length(rules) < 1){
    return(0)
  }
  sum_ap <- 0
  num_transactions <- nrow(commits)
  n <- 1
  while(n <= num_transactions){
    files <-  commits$V1[n];
    observed <- strsplit(files, ",")[[1]]
    observed_len <- length(observed)
    recall <- 0
    precision <- 0
    if (observed_len > 1){
      precedent <- observed[1]
      exists <- nrow(subset(rules@lhs@itemInfo, rules@lhs@itemInfo == precedent))
      if(exists > 0){
        precedent_rules <- subset(rules, subset = lhs %in% precedent);
        predicted <- labels(sort(precedent_rules, by = "support"));
        predicted <- predicted[1:k]
        num_predicted <- length(predicted)
        other_files <- setdiff(observed, precedent)
        last_recall <- 0
        ap <- 0
        j <- 1
        while (j <= num_predicted){
          new_predicted <-  predicted[1:j]
          predicted_rules <- gsub(".* ", "", new_predicted)
          predicted_rules <- gsub("[{}]", "", predicted_rules)
          intersect_rules <- intersect(predicted_rules, other_files)
          intersection <- length(intersect_rules)
          precision <- intersection / j
          recall <- intersection / (observed_len - 1)
          diff_recall <- recall - last_recall
          last_recall <- recall
          ap <- ap + (precision * diff_recall)
          j <- j + 1
        }
        sum_ap <- sum_ap + ap
      }
    }  
    n <- n + 1
  }
  
  map <- sum_ap / num_transactions
  
  return(map)
}