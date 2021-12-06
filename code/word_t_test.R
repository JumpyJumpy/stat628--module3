library("tidyverse")
library("car")

reviews <- read_csv("./data/filtered_reviews.csv")
words <- read_csv("./data/tf_idf_words.csv")

business_id <- unique(reviews$business_id)

for (id in business_id) {
    reviews_selected <- reviews[reviews$business_id == id,]
    top1 <- as.character(words[words$business_id == id, "1"])
    top2 <- as.character(words[words$business_id == id, "2"])

    business_mean <- mean(reviews_selected$stars)
    top1_mean <- mean(reviews_selected$stars[grep(top1, reviews_selected$text)])
    top2_mean <- mean(reviews$stars[grep(pattern = top2, reviews$text[reviews$business_id == id])])
    break
}

