library("tidyverse")
library("car")

reviews <- read_csv("./data/filtered_reviews.csv")
words <- read_csv("./data/tf_idf_words.csv", na = c("", "NA", "NaN"))[-1]
label <- read_csv("./data/word_list.csv",)[, -1]

business_id <- unique(reviews$business_id)
suggestions <- data.frame(business_id = business_id, word1 = NA, word2 = NA, word1_label = NA, word2_label = NA, suggestion1 = NA, suggestion2 = NA, average_rating = NA)

i <- 0
for (id in business_id) {
    reviews_selected <- reviews[reviews$business_id == id,]
    top1 <- words[words$business_id == id, "1"]
    top2 <- words[words$business_id == id, "2"]

    if (!any(is.na(top1), sd(top1_stars <- reviews_selected$stars[grep(top1, reviews_selected$text)]) == 0, is.na(sd(top1_stars)), na.rm = TRUE)) {
        top1 <- as.character(top1)
        label1 <- label$Kind[label$Var1 == top1]
        top1_test <- t.test(x = top1_stars, y = reviews_selected$stars, alternative = "less")

        if (top1_test$p.value < 0.1) {
            sugg1 <- paste0("You should improve the quality of ", label1, ", specifically in ",
                            top1, ".\nBecause comments related to ", top1,
                            "is statistically lower than your average ratings")
        } else {
            sugg1 <- paste0("You are doing well in ", label1, ", specifically in ",
                            top1, ".\nBecause comments related to ", top1,
                            "is not statistically lower than your average ratings")
        }
    } else {
        sugg1 <- NA
        label1 <- NA
    }

    if (!any(is.na(top1), sd(top2_stars <- reviews_selected$stars[grep(top2, reviews_selected$text)]) == 0, is.na(sd(top2_stars)), na.rm = TRUE)) {
        top2 <- as.character(top2)
        label2 <- label$Kind[label$Var1 == top2]
        top2_test <- t.test(x = top2_stars, y = reviews_selected$stars, alternative = "less")

        if (top2_test$p.value < 0.1) {
            sugg2 <- paste0("You should improve the quality of ", label2, ", specifically in ",
                            top2, ".\nBecause comments related to ", top2,
                            "is statistically lower than your average ratings")
        } else {
            sugg2 <- paste0("You are doing well in ", label2, ", specifically in ",
                            top2, ".\nBecause comments related to ", top2,
                            "is not statistically lower than your average ratings")
        }
    } else {
        sugg2 <- NA
        label2 <- NA
    }
    average_rating <- mean(reviews_selected$stars)
    suggestions[suggestions$business_id == id, 2:8] <- c(top1, top2, label1, label2, sugg1, sugg2, average_rating)
    i <- i + 1
    cat(sep = "", i,"/", length(business_id), "\n")

}

write.csv(suggestions, "./data/suggestions.csv")
