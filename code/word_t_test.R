library("tidyverse")
library("car")

reviews <- read_csv("./data/filtered_reviews.csv")
words <- read_csv("./data/tf_idf_words.csv", na = c("", "NA", "NaN"))[, -1]
label <- read_csv("./data/word_list.csv")
label[!duplicated(label$Var1),]


business_id <- unique(reviews$business_id)
suggestions <- data.frame(business_id = business_id, word1 = NA, word2 = NA, word3 = NA,
                          word1_label = NA, word2_label = NA, word3_lable = NA,
                          suggestion1 = NA, suggestion2 = NA, suggestions3 = NA,
                          average_rating = NA)

i <- 0
for (id in business_id) {
    reviews_selected <- reviews[reviews$business_id == id,]
    top1 <- words[words$business_id == id, "1"]
    top2 <- words[words$business_id == id, "2"]
    top3 <- words[words$business_id == id, "3"]

    if (!any(is.na(top1), sd(top1_stars <- reviews_selected$stars[grep(top1, reviews_selected$text)]) == 0, is.na(sd(top1_stars)), na.rm = TRUE)) {
        top1 <- as.character(top1)
        label1 <- label$Kind[label$Var1 == top1][1]
        top1_test <- t.test(x = top1_stars, y = reviews_selected$stars, alternative = "less")

        if (top1_test$p.value < 0.1) {
            sugg1 <- paste0("You should improve the quality of ", label1, ", specifically ",
                            top1, ", because comments related to ", top1,
                            " is statistically lower than your average ratings")
        } else {
            sugg1 <- paste0("You are doing well in ", label1, ", specifically ",
                            top1, ", because comments related to ", top1,
                            " is not statistically lower than your average ratings")
        }
    } else {
        top1 <- NA
        sugg1 <- NA
        label1 <- NA
    }

    if (!any(is.na(top1), sd(top2_stars <- reviews_selected$stars[grep(top2, reviews_selected$text)]) == 0, is.na(sd(top2_stars)), na.rm = TRUE)) {
        top2 <- as.character(top2)
        label2 <- label$Kind[label$Var1 == top2][1]
        top2_test <- t.test(x = top2_stars, y = reviews_selected$stars, alternative = "less")

        if (top2_test$p.value < 0.1) {
            sugg2 <- paste0("You should improve the quality of ", label2, ", specifically ",
                            top2, ", because comments related to ", top2,
                            " is statistically lower than your average ratings")
        } else {
            sugg2 <- paste0("You are doing well in ", label2, ", specifically ",
                            top2, ", because comments related to ", top2,
                            " is not statistically lower than your average ratings")
        }
    } else {
        top2 <- NA
        sugg2 <- NA
        label2 <- NA
    }

    if (!(as.character(top3) %in% c(top1, top2)) & !is.na(top3)) {
        top3 <- as.character(top3)
        label3 <- label$Kind[label$Var1 == top3][1]

        sugg3 <- paste0("You should improve the quality of ", label3, ", specifically ",
                        top3, ", because negative comments are mostly related to ", top3, ".")
    } else if (is.na(top3)) {
        top3 <- NA
        sugg3 <- NA
        label3 <- NA
    } else if (as.character(top3) %in% c(top1, top2)) {
        top1 <- as.character(top1)
        top2 <- as.character(top2)
        top3 <- as.character(top3)
        label3 <- label$Kind[label$Var1 == top3][1]
        sugg3 <- paste0("You should offer more stable ", label3, " quality, specifically ",
                        top3, ", because there are many positive and negative comments related to ", top3, ".")

        eval(parse(text = paste0("sugg", which(c(top1, top2) == top3), " <- NA")))
        eval(parse(text = paste0("label", which(c(top1, top2) == top3), " <- NA")))
        eval(parse(text = paste0("top", which(c(top1, top2) == top3), " <- NA")))

    }


    average_rating <- mean(reviews_selected$stars)
    suggestions[suggestions$business_id == id, 2:11] <-
            c(top1, top2, top3, label1, label2, label3, sugg1, sugg2, sugg3, average_rating)
    i <- i + 1
    cat(sep = "", i, "/", length(business_id), "\n")
}

write.csv(suggestions, "./data/suggestions.csv")
