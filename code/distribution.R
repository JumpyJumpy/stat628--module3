rm(list = ls())
getwd()
setwd("/Users/ranee/desktop")
library(tidytext)
library(tidyr)
library(dplyr)
library(stringr)
reviews <- read.csv("./data/filtered_reviews.csv", stringsAsFactors = F)
stars <- reviews$stars
reviews$stars <- as.integer(reviews$stars)


reviews$text <- tolower(reviews$text)
reviews$text <- gsub("[0-9]", " ", reviews$text)
reviews$text <- gsub("\n", " not ", reviews$text)
reviews$text <- gsub("[.)(~!@#$%&*_+-]", " ", reviews$text)
reviews$text <- gsub("waiting", "wait", reviews$text)
reviews$text <- gsub("waited", "wait", reviews$text)
reviews$text <- gsub("worse", "bad", reviews$text)
reviews$text <- gsub("worst", "bad", reviews$text)


review_filtered <- reviews %>%
        unnest_tokens(word, text) %>%
        anti_join(stop_words)


attitudes <- c("awesome", "awful", "bad", "excellent", "fantastic", "terrible")
Type_of_food <- c("americano", "breakfast", "brew", "espresso", "latte", "tea")
ambience <- c("clean", "loud", "quiet", "rude", "spacious", "wait")


##ambience##


review_ambience_filtered <- review_filtered %>%
        filter(word %in% ambience)


ambience_freq <- data.frame()
ambience_all <- c(1:5)
for (i in 1:5) {
    ambience_all[i] <- nrow(review_filtered[review_filtered$stars == i,])
    ambience1 <- review_ambience_filtered[review_ambience_filtered$stars == i,]
    ambience_freq1 <- round(((as.data.frame(table(ambience1$word))$Freq) / ambience_all[i]) * 100, 4)
    ambience_freq <- rbind(ambience_freq, ambience_freq1)
}
colnames(ambience_freq) <- ambience

barplot(ambience_freq$spacious, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of spacious(%)", main = "spacious")
barplot(ambience_freq$wait, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of wait(%)", main = "wait")
barplot(ambience_freq$loud, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of loud(%)", main = "loud")
barplot(ambience_freq$rude, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of rude(%)", main = "rude")
barplot(ambience_freq$clean, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of Clean(%)", main = "clean")
barplot(ambience_freq$quiet, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of Quiet(%)", main = "quiet")


# Type of food #

review_food_filtered <- review_filtered %>%
        filter(word %in% Type_of_food)

food_freq <- data.frame()
food_all <- c(1:5)
for (i in 1:5) {
    food_all[i] <- nrow(review_filtered[review_filtered$stars == i,])
    food1 <- review_food_filtered[review_food_filtered$stars == i,]
    food_freq1 <- round(((as.data.frame(table(food1$word))$Freq) / food_all[i]) * 100, 4)
    food_freq <- rbind(food_freq, food_freq1)
}
colnames(food_freq) <- Type_of_food

barplot(food_freq$americano, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of americano(%)", main = "americano")
barplot(food_freq$brew, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of brew(%)", main = "brew")
barplot(food_freq$latte, names.arg = c(1:5), xlab = "latte", ylab = "Frequency of latte(%)", main = "latte")
barplot(food_freq$espresso, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of espresso(%)", main = "espresso")
barplot(food_freq$tea, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of tea(%)", main = "tea")
barplot(food_freq$breakfast, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of breakfast(%)", main = "breakfast")


## attitudes ##
review_attitudes_filtered <- review_filtered %>%
        filter(word %in% attitudes)

attitudes_freq <- data.frame()
attitudes_all <- c(1:5)
for (i in 1:5) {
    attitudes_all[i] <- nrow(review_filtered[review_filtered$stars == i,])
    attitudes1 <- review_attitudes_filtered[review_attitudes_filtered$stars == i,]
    attitudes_freq1 <- round(((as.data.frame(table(attitudes1$word))$Freq) / attitudes_all[i]) * 100, 4)
    attitudes_freq <- rbind(attitudes_freq, attitudes_freq1)
}
colnames(attitudes_freq) <- attitudes

barplot(attitudes_freq$awful, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of awful(%)", main = "awful")
barplot(attitudes_freq$terrible, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of terrible(%)", main = "terrible")
barplot(attitudes_freq$bad, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of bad(%)", main = "bad")
barplot(attitudes_freq$fantastic, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of fantastic(%)", main = "fantastic")
barplot(attitudes_freq$excellent, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of excellent(%)", main = "excellent")
barplot(attitudes_freq$awesome, names.arg = c(1:5), xlab = "Star", ylab = "Frequency of awesome(%)", main = "awesome")
