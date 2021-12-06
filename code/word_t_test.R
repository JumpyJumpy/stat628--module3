library("tidyverse")
library("car")

reviews <- read_csv("./data/filtered_reviews.csv")
words <- read_csv("./data/tf_idf_words.csv", na = c("", "NA", "NaN"))

business_id <- unique(reviews$business_id)
suggestions <- data.frame(business_id = business_id, word1 = NA, word2 = NA, word1_label = NA, word2_label = NA, suggestion = NA)


for (id in business_id) {
    reviews_selected <- reviews[reviews$business_id == id,]
    top1 <- words[words$business_id == id, "1"]
    top2 <- words[words$business_id == id, "2"]
    
    if(!is.na(top1)) {
        top1 <- as.character(top1)
        lable1 <- 
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
        suggestions[suggestions$business_id == id, 2:6] <- c()
    }
    
    
    if (!is.na(top2))
        top2_stars <- reviews_selected$stars[grep(top2, reviews_selected$text)]
    top2_test <- t.test(x = top2_stars, y = reviews_selected$stars, alternative = "less")
    
    if (top1_test$p.value < 0.05) {
        sugg1 <- paste0("You should improve the quality of ", top1)
        reason1 <- paste0("There is significant ")
    } else {
        sugg1 <- paste0("You are doing well in ", top1)
        reason1 <- paste0("Because comments related to ", top1, "is not statistically lower than your average rating. se( ", top1_test$stderr, ")")
    }
    
>>>>>>> 32bd3bad1839dfecc16ae80143c626c3c816464d
}

