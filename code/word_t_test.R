library("tidyverse")
library("car")

reviews <- read_csv("./data/filtered_reviews.csv")
words <- read_csv("./data/tf_idf_words.csv", na = c("", "NA", "NaN"))[-1]
label <- read_csv("./data/word_list.csv",)[, -1]

business_id <- unique(reviews$business_id)
suggestions <- data.frame(business_id = business_id, word1 = NA, word2 = NA, word1_label = NA, word2_label = NA, suggestion1 = NA, suggestion2 = NA)


for (id in business_id) {
    reviews_selected <- reviews[reviews$business_id == id,]
    top1 <- words[words$business_id == id, "1"]
    top2 <- words[words$business_id == id, "2"]

    if (!is.na(top1)) {
        top1 <- as.character(top1)
        label1 <- label$Kind[label$Var1 == top1]
        top1_stars <- reviews_selected$stars[grep(top1, reviews_selected$text)]
        top1_test <- t.test(x = top1_stars, y = reviews_selected$stars, alternative = "less")

        if (top1_test$p.value < 0.05) {
            sugg1 <- paste0("You should improve the quality of ", top1, "There is significant ")
        } else {
            sugg1 <-
                    paste0("You are doing well in ", top1, ".\nBecause comments related to ", top1, "is not statistically lower than your average rating. se( ", top1_test$stderr, ")")
        }
    } else {
        sugg1 <- NA
        label1 <- NA
    }

    if (!is.na(top2)) {
        top2 <- as.character(top2)
        label2 <- label$Kind[label$Var1 == top2]
        top2_stars <- reviews_selected$stars[grep(top2, reviews_selected$text)]
        top2_test <- t.test(x = top2_stars, y = reviews_selected$stars, alternative = "less")

        if (top2_test$p.value < 0.05) {
            sugg2 <- paste0("You should improve the quality of ", label2, "There is significant ")
        } else {
            sugg2 <-
                    paste0("You are doing well in ", label2, ", specifically in ", top2, "\nBecause comments related to ", top2, "is not statistically lower than your average rating. se( ", top2_test$stderr, ")")
        }
    } else {
        sugg2 <- NA
        label2 <- NA
    }

    suggestions[suggestions$business_id == id, 2:7] <- c(top1, top2, label1, label2, sugg1, sugg2)
}

