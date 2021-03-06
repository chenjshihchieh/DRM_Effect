library(shinyjs)

randomNumb <- function(){
  sample(3:9, 7, replace = FALSE)
}

multQs1 <- unlist(replicate(50, randomNumb(), simplify = FALSE))
multQs2 <- sample(3:9, length(multQs1), replace = TRUE)
multAns <- multQs1*multQs2

wordList <- read.csv(file.path('www', 'wordsList_DRM.csv'), stringsAsFactors = FALSE)

judgList_food <- c(wordList$neutralWords_Food, wordList$falseStimuli_Food, wordList$recognitionList_food)
judgList_food <- sample(judgList_food, length(judgList_food), replace = FALSE)
judgList_food <- judgList_food[judgList_food != ""]
judgList_school <- c(wordList$neutralWords_school, wordList$falseStimuli_school, wordList$recognitionList_school)
judgList_school <- sample(judgList_school, length(judgList_school), replace = FALSE)
judgList_school <- judgList_school[judgList_school != ""]

Food <- paste0('Food', c('Conv', 'List'), c('Old', 'Young', 'Young', 'Old'))
School <- paste0('School', c('Conv', 'List'), c('Old', 'Young', 'Young', 'Old'))
